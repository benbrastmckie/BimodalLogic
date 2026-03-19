# Theories/Bimodal/Boneyard

This directory contains deprecated Lean code that has been superseded by the publication path (StagedConstruction + Bundle). Files are preserved for historical reference and potential future exploration.

## Directory Structure

### Metalogic_v8/

**Archived 2026-03-15** (Task 929)

Contains files from the v8 metalogic iteration that were superseded by the StagedConstruction approach:

- **Bundle/DovetailingChain.lean**: F/P witness construction using dovetailing chains
  - *Why archived*: Irreducible F-persistence gap (F-formulas don't persist through GContent seeds)
  - *Sorries*: 5 (forward_F, backward_P, and related)
  - *Superseded by*: CanonicalFMCS.lean (all-MCS approach) + StagedConstruction

### Task956_IntRat/

**Archived 2026-03-11** (Task 956)

Contains Int/Rat-specialized constructions that violated the pure-syntax constraint:

- **BidirectionalReachable.lean**: CanonicalReachable fragment with linearity proofs
- **CanonicalChain.lean**: Linear chain construction over Int
- **FragmentCompleteness.lean**: Completeness for the reachable fragment
- And others...

*Why archived*: D must emerge from temporal axioms (pure-syntax), not be imported as Int.

### Task956_StrictDensity/

**Archived 2026-03-11** (Task 956)

Contains strict density attempts that didn't pan out:

- **DensityFrameCondition_StrictAttempt.lean**: Earlier strict density approach

*Why archived*: Superseded by Cantor-interval density construction.

### IntRepresentation/

**Archived 2026-03-14**

Contains Int-specialized representation theory:

- **Representation.lean**: Int-based representation theorems

*Why archived*: Publication path uses CanonicalMCS (syntax-only) as D, not Int.

### Task994_DovetailedQuot/

**Archived 2026-03-19** (Task 994)

Contains the dovetailed timeline quotient construction, an alternative approach to completeness:

- **DovetailedTimelineQuot.lean**: Dovetailed timeline quotient with witness chain proofs (65KB)
- **DovetailedFMCS.lean**: FMCS wrapper for dovetailed construction (13KB)

*Why archived*: Orphaned from completeness chain - main proof uses TimelineQuot path instead. All sorries stem from proving density witnesses exist in the dovetailed timeline union.

*Patterns preserved*: Strong induction on iterated modalities, density-via-encoding-overflow technique.

## Restoration

To restore any file for exploration:

```bash
# Copy back to active location
cp Theories/Bimodal/Boneyard/Metalogic_v8/Bundle/DovetailingChain.lean \
   Theories/Bimodal/Metalogic/Bundle/DovetailingChain.lean

# Update imports as needed
```

Note: Archived files may not build cleanly with current Mathlib/Lean versions.

## Publication Path

The publication-ready completeness proof uses:

1. **StagedConstruction/**: Cantor-interval staged timeline construction
2. **Bundle/CanonicalFMCS.lean**: All-MCS approach (sorry-free F/P witnesses)
3. **Bundle/TruthLemma.lean**: Truth lemma via temporally coherent families
4. **Bundle/CanonicalConstruction.lean**: TaskFrame-level truth lemma

All publication-path files are sorry-free with zero custom axioms.

---

*Last updated: 2026-03-19*
*Task: 994 (archive_dead_code_in_staged_construction)*
