# Research Report: Teammate B Findings - Shortcomings, Cleanup, and Publication Readiness

## Task 928: Refactor metalogic terminology (BMCS->BFMCS, FMCS, MCS) and archive to Boneyard

## Key Findings

1. **5 actual sorries** exist in active Metalogic code (excluding Boneyard and comments), spread across 3 files.
2. **2 custom axioms** exist in active Metalogic code (`fully_saturated_bmcs_exists`, `saturated_extension_exists`), both in the LEGACY completeness chain that is superseded by the sorry-free ChainBundleBMCS chain.
3. **Phase 2 of task 925 was entirely skipped** - constant family constructions and CoherentConstruction.lean were NOT moved to Boneyard.
4. **BFMCS remains the dominant name** - 264 occurrences across 20 files vs 34 occurrences of FMCS across 5 files. The FMCS alias is barely used.
5. **Metalogic.lean sorry count table is stale** - claims 7 sorries but the actual count is 5; claims "4 cross-sign propagation and F/P witnesses" in DovetailingChain but only 2 remain.
6. **CoherentConstruction.lean is still in active code** despite being a Boneyard candidate - it imports into TemporalCoherentConstruction.lean and TruthLemma.lean.

## Sorry/Axiom Analysis

### Active Sorries (5 total, excluding Boneyard)

| File | Line | Sorry | Category | Impact |
|------|------|-------|----------|--------|
| `Bundle/Construction.lean` | 197 | `singleFamilyBMCS.modal_backward` | Construction assumption | Inherited by `construct_temporal_bmcs` in legacy chain |
| `Bundle/TemporalCoherentConstruction.lean` | 613 | `temporal_coherent_family_exists` (generic D) | Development placeholder | Only Int instantiated downstream; generic D never used |
| `Bundle/TemporalCoherentConstruction.lean` | 819 | `fully_saturated_bmcs_exists_int` | Construction assumption | Inherited by Representation.lean standard completeness |
| `Bundle/DovetailingChain.lean` | 1869 | `buildDovetailingChainFamily_forward_F` | Fundamental obstacle | F-formulas do not persist through GContent seeds |
| `Bundle/DovetailingChain.lean` | 1881 | `buildDovetailingChainFamily_backward_P` | Fundamental obstacle | Symmetric to forward_F; linear chain fundamental limitation |

### Active Axioms (2 custom axioms)

| File | Line | Axiom | Category | Impact |
|------|------|-------|----------|--------|
| `Bundle/TemporalCoherentConstruction.lean` | 755 | `fully_saturated_bmcs_exists` | Construction assumption | In legacy chain; superseded by ChainBundleBMCS |
| `Bundle/CoherentConstruction.lean` | 871 | `saturated_extension_exists` | Existence assumption | In legacy chain; requires Zorn proof for elimination |

**Note**: `Decidability/ProofExtraction.lean` line 23 contains the string "axiom" in a comment, not an actual axiom declaration.

### Publication Assessment

The **sorry-free completeness chain** (ChainBundleBMCS.lean) is publication-ready:
- `bmcs_weak_completeness_mcs` and `bmcs_strong_completeness_mcs` depend ONLY on standard Lean axioms
- Verified: propext, Classical.choice, Quot.sound (standard)

The **standard completeness chain** (Representation.lean) inherits sorry from `fully_saturated_bmcs_exists_int`:
- `standard_weak_completeness` and `standard_strong_completeness` are sorry-dependent
- These bridge BMCS truth to standard `truth_at` semantics

**Conclusion**: The core completeness result is publication-ready via ChainBundleBMCS. The standard-semantics bridge (Representation.lean) has technical debt that blocks transitive sorry-freedom for the standard formulation.

## Boneyard Candidates

### Priority 1: CoherentConstruction.lean (HIGH - Skipped Phase 2 of Task 925)

**Status**: Still in active `Metalogic/Bundle/` directory.

**Why move**: The file is entirely based on the constant-family approach, which was proven mathematically impossible for forward_F (task 916 analysis). It contains 1 custom axiom (`saturated_extension_exists`) and heavy constant-family infrastructure (`IsConstantFamily`, `constantBFMCS_is_constant`, etc.). No theorem in the sorry-free completeness chain depends on it.

**Blockers**:
- `TemporalCoherentConstruction.lean` imports CoherentConstruction (line 5)
- `TruthLemma.lean` imports CoherentConstruction (line 5)
- These imports must be analyzed to determine if they use anything from CoherentConstruction directly, or if they can be removed.

### Priority 2: Constant Family Definitions in Construction.lean and ModalSaturation.lean

**What to move**:
- `constantBFMCS` definition and lemmas in `Construction.lean` (lines 91-114)
- `constantWitnessFamily` and `constructWitnessFamily` in `ModalSaturation.lean` (lines 248-288)
- `singleFamilyBMCS` in `Construction.lean` (lines 178-199) - includes the sorry

**Complication**: `constantBFMCS` is used by CoherentConstruction.lean (which itself should be in Boneyard) AND by `construct_temporal_bmcs` in TemporalCoherentConstruction.lean. The legacy chain depends on these.

### Priority 3: Legacy Completeness Chain Files (after constant family elimination)

Once CoherentConstruction.lean and constant families are moved, the following become candidates for Boneyard or at least clear "legacy" marking:
- The sorry-backed portion of `TemporalCoherentConstruction.lean` (the `fully_saturated_bmcs_exists` axiom and `construct_temporal_bmcs`)
- The sorry-backed portion of `DovetailingChain.lean` (forward_F, backward_P sorries)
- The legacy chain in `Bundle/Completeness.lean` (which uses `construct_temporal_bmcs`)

**Note**: DovetailingChain has proven infrastructure (forward_G, backward_H, seed consistency) used by the sorry-free chain. Only the sorry'd forward_F/backward_P and their callers would be candidates for archival.

### Not Boneyard Candidates

- `WitnessGraph.lean` - Contains proven infrastructure (sorry-free forward_G/backward_H)
- `CanonicalBFMCS.lean` - Sorry-free temporal coherence; used by ChainBundleBMCS
- `ChainFMCS.lean` - Core of sorry-free construction
- `ChainBundleBMCS.lean` - The sorry-free completeness chain

## Code Quality Issues

### 1. Terminology Inconsistency (CRITICAL for Task 928)

**BFMCS vs FMCS**: The rename was only partially done:
- `BFMCS.lean` retains the canonical structure definition as `structure BFMCS`
- `FMCS.lean` provides only a type alias: `abbrev FMCS := BFMCS`
- **264 occurrences of `BFMCS`** across 20 files vs **34 occurrences of `FMCS`** across 5 files
- The alias approach means all new code still needs to write `BFMCS` for structure fields (e.g., `BFMCS.mcs`, `BFMCS.forward_G`)
- The file `CanonicalBFMCS.lean` was never renamed to `CanonicalFMCS.lean` (planned in Phase 1 but not done)

**BMCS naming**: The BMCS name is used correctly for the bundle, but docstrings in some files still describe BFMCS as "Bundled Family" (the Lean4 sense) which conflicts with the task 928 intent to reserve "B" for "Bundle of families."

### 2. Stale Documentation in Metalogic.lean

The sorry table in `Metalogic.lean` (lines 32-39) states:
```
Active sorries in Metalogic/: 7 total
Bundle/DovetailingChain.lean | 4 | cross-sign propagation and F/P witnesses
```

**Reality**: DovetailingChain has 2 sorries (forward_F, backward_P). The cross-sign cases were resolved in task 916. Total is 5, not 7.

### 3. Module Structure Listing Incomplete

`Metalogic.lean` (lines 58-82) lists the Bundle/ module structure but is missing:
- `FMCS.lean`
- `ChainFMCS.lean`
- `ChainBundleBMCS.lean`
- `CanonicalEmbedding.lean`
- `CanonicalQuotient.lean`
- `CanonicalReachable.lean`
- `WitnessGraph.lean`
- `CanonicalFrame.lean`
- `CanonicalBFMCS.lean`
- `TemporalContent.lean`

This is a significant documentation gap - the sorry-free completeness chain (ChainBundleBMCS) is not even mentioned in the module directory.

### 4. Redundant/Duplicate Definitions

- `CanonicalWorldState` is defined in both `Completeness.lean` (line 647) and `Representation.lean` (line 95)
- `constantBFMCS` in `Construction.lean` and `constantWitnessFamily` in `ModalSaturation.lean` are essentially the same construction
- `dne_theorem'` in `TemporalCoherentConstruction.lean` (line 70) is a trivial re-export

### 5. Import Chain Pollution

CoherentConstruction.lean is imported by:
- `TemporalCoherentConstruction.lean` (uses `constantBFMCS_is_constant`)
- `TruthLemma.lean` (import may be unnecessary - needs audit)

This means even the sorry-free chain transitively imports CoherentConstruction (via ChainBundleBMCS -> TemporalCoherentConstruction -> CoherentConstruction), picking up the `saturated_extension_exists` axiom. While this axiom is not USED by the sorry-free chain, it is in the same import tree.

### 6. Naming Convention Issues Beyond BMCS/FMCS/MCS

- `CanonicalBFMCS.lean` uses BFMCS not FMCS (should be `CanonicalFMCS.lean` per plan)
- `ChainFMCS.lean` uses the new FMCS name (inconsistent with CanonicalBFMCS)
- `ChainBundleBMCS.lean` uses BMCS (correct for the bundle)
- `BMCSTruth.lean` uses BMCS (correct)
- `constantBFMCS` should be `constantFMCS` under new terminology
- `singleFamilyBMCS` is fine (it IS a BMCS)

## Prior Task Gaps

### Task 925 Phase 2: Constant Family Elimination [NOT STARTED]

This phase was explicitly marked `[NOT STARTED]` in the plan. The implementation summary confirms:
> Phase 2 (Boneyard cleanup): File reorganization, not blocking completeness

All of the following items from Phase 2 remain undone:
- [ ] Create `Theories/Bimodal/Boneyard/Bundle/` directory structure
- [ ] Move `constantBFMCS` definition from Construction.lean to Boneyard
- [ ] Move `constantWitnessFamily`, `constructWitnessFamily` from ModalSaturation.lean to Boneyard
- [ ] Move `CoherentConstruction.lean` entirely to Boneyard
- [ ] Remove constant family comments from ModalSaturation.lean, WitnessGraph.lean, BFMCS.lean, Representation.lean
- [ ] Verify no `constantBFMCS`, `constantWitnessFamily`, `IsConstantFamily` in active code

### Task 925 Phase 1: Incomplete Rename

Phase 1 planned but did not fully execute:
- [ ] CanonicalBFMCS.lean was NOT renamed to CanonicalFMCS.lean
- [ ] BFMCS.lean structure was NOT renamed to FMCS; only an alias was created
- [ ] Remaining 264 BFMCS references were NOT updated

## Recommended Actions

### Immediate (Task 928 Scope)

1. **Rename `structure BFMCS` to `structure FMCS`** in BFMCS.lean, or make BFMCS.lean a re-export of FMCS.lean (invert current relationship). Update all 264 occurrences.

2. **Rename `CanonicalBFMCS.lean` to `CanonicalFMCS.lean`** and update imports.

3. **Move CoherentConstruction.lean to Boneyard** - audit imports in TemporalCoherentConstruction.lean and TruthLemma.lean first; extract any needed definitions.

4. **Move constant family constructions to Boneyard** - `constantBFMCS`, `constantWitnessFamily`, `constructWitnessFamily`, `IsConstantFamily`.

5. **Update Metalogic.lean** - Fix sorry count table, update module structure listing, add ChainBundleBMCS and other missing files.

### Follow-up (Separate Tasks)

6. **Investigate removing CoherentConstruction import from TruthLemma.lean** - May be unnecessary.

7. **Archive legacy chain sorries** - Consider moving DovetailingChain forward_F/backward_P and their callers to Boneyard, keeping only the proven infrastructure.

8. **Eliminate `CanonicalWorldState` duplication** between Completeness.lean and Representation.lean.

9. **Update Boneyard README** to document new additions and the constant-family approach's failure reason.

## Confidence Level

**HIGH** - All findings are based on direct codebase analysis with exact line numbers and file paths. Sorry/axiom counts verified by grep. Phase 2 skip confirmed by plan status markers and implementation summary.
