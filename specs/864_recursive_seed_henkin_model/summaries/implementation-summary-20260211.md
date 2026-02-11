# Implementation Summary: Task #864

**Status**: Partial (ongoing)
**Sessions**: 2 (session 27-28)

## Session 28 Changes

### Documentation Updates

Updated docstrings in `TemporalCoherentConstruction.lean` to document the RecursiveSeed approach:

1. **`temporal_coherent_family_exists_Int` docstring**:
   - Documents RecursiveSeed strategy (pre-placing F/P witnesses during seed construction)
   - Explains that DovetailingChain is used pending full RecursiveSeed integration
   - Notes that RecursiveSeed eliminates 2 cross-sign sorries by pre-placing witnesses
   - Clarifies that forward_F/backward_P sorries require witness enumeration

2. **`temporal_coherent_family_exists` (generic D) docstring**:
   - Documents why RecursiveSeed cannot be used for generic D (Int-specific timeIdx)
   - Explains the RecursiveSeed witness pre-placement approach
   - Notes that Lindenbaum-added F/P formulas need witness enumeration
   - Lists technical debt requirements for full proof

### Analysis Findings

1. **RecursiveSeed Architecture**:
   - `buildSeed` processes formula structure and pre-places witnesses
   - `neg(G psi)` creates a witness at `freshFutureTime` with `neg psi`
   - `neg(H psi)` creates a witness at `freshPastTime` with `neg psi`
   - `seedConsistent` theorem proves all seed entries are consistent

2. **Blocking Sorries for Full Implementation**:
   - `SeedCompletion.lean:189` - `buildFamilyFromSeed` (constructs IndexedMCSFamily from seed)
   - `SeedCompletion.lean:158` - `modal_witness_includes_boxcontent`
   - `SeedBMCS.lean:89,94` - `modal_forward`, `modal_backward`
   - `DovetailingChain.lean:633,640` - `forward_F`, `backward_P` (witness enumeration)

3. **Key Insight**:
   - RecursiveSeed places F/P witnesses for formulas IN THE STARTING FORMULA
   - Lindenbaum-added F/P formulas still need witness enumeration
   - `temporal_witness_seed_consistent` proves witness sets are consistent

## Previous Session Changes (Session 27)

1. **Added import**: `Bimodal.Metalogic.Bundle.DovetailingChain` to TemporalCoherentConstruction.lean

2. **Added theorem**: `temporal_coherent_family_exists_Int`
   - Proven via direct application of `temporal_coherent_family_exists_theorem`
   - No sorries in this theorem
   - Provides temporal coherent family for `D = Int`

## Files Modified

- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean`
  - Updated `temporal_coherent_family_exists_Int` docstring (lines 577-602)
  - Updated `temporal_coherent_family_exists` docstring (lines 610-630)

## Verification

- `lake build Bimodal` succeeds with 999 jobs
- All changes compile without new errors
- Existing sorry count unchanged

## Technical Notes

### RecursiveSeed vs DovetailingChain

| Aspect | RecursiveSeed | DovetailingChain |
|--------|---------------|------------------|
| Witness placement | During seed construction (BEFORE Lindenbaum) | During chain building (AFTER MCS construction) |
| Cross-sign temporal | Avoided (witnesses pre-placed) | 2 sorries (forward_G t<0, backward_H t>=0) |
| F/P for starting formula | Pre-placed in seed | Built during enumeration |
| F/P for Lindenbaum-added | Needs enumeration | 2 sorries (forward_F, backward_P) |

### Path Forward

To fully implement RecursiveSeed approach:
1. Implement `buildFamilyFromSeed` (SeedCompletion.lean:189)
2. Prove `modal_witness_includes_boxcontent` (SeedCompletion.lean:158)
3. Complete `SeedBMCS` modal coherence proofs
4. Add witness enumeration for Lindenbaum-added F/P formulas

### Why Generic D Keeps Sorry

The proof infrastructure (RecursiveSeed, DovetailingChain) uses Int specifically:
- `timeIdx : Int` in SeedEntry
- `dovetailIndex : Nat → Int`

Generalizing to arbitrary `D : AddCommGroup` would require:
- Replacing Int with generic D throughout seed construction
- Implementing fresh time functions for generic ordered groups
- Major refactoring of ~1500 lines of code
