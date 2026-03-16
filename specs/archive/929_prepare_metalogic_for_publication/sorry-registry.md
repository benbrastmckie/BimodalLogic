# Sorry Registry: Metalogic Module

This document tracks all sorries in the Metalogic module hierarchy for transparency.

## Summary

| Category | Count | Publication Impact |
|----------|-------|-------------------|
| Publication Path | 0 | N/A |
| Non-Publication Path | 9 | None |
| Archived (Boneyard) | ~40 | None |

## Publication Path: 0 Sorries

The following modules are on the publication path and have **zero sorries**:

- `StagedConstruction/` (all 10 files): Cantor-interval completeness
- `Bundle/TruthLemma.lean`: BFMCS truth lemma
- `Bundle/CanonicalConstruction.lean`: TaskFrame-level truth lemma
- `Bundle/CanonicalFMCS.lean`: All-MCS temporal coherence
- `Soundness.lean`: Soundness theorem
- `SoundnessLemmas.lean`: Axiom validity lemmas

## Non-Publication Path: 9 Sorries

### TemporalCoherentConstruction.lean (2 sorries)

| Line | Symbol | Category | Notes |
|------|--------|----------|-------|
| 422 | `temporal_coherent_family_exists_Int` | Deprecated | Int-specific; DovetailingChain archived |
| 516 | `fully_saturated_bfmcs_exists_int` | Deprecated | Combines temporal + modal saturation |

**Status**: These are in deprecated Int-specialized code. The publication path uses
CanonicalMCS (syntax-only) and CanonicalFMCS.lean instead.

### ConstructiveFragment.lean (2 sorries)

| Line | Symbol | Category | Notes |
|------|--------|----------|-------|
| 579 | `standard_weak_completeness_constructive` | Research | Constructive fragment completeness |
| 584 | `standard_strong_completeness_constructive` | Research | Constructive fragment completeness |

**Status**: Research path exploring constructive/intuitionistic fragment. Not on
publication path which uses classical completeness.

### DiscreteTimeline.lean (5 sorries)

| Line | Symbol | Category | Notes |
|------|--------|----------|-------|
| 179 | (in `buildDiscreteTimeline`) | Discrete-only | Successor construction |
| 187 | (in `buildDiscreteTimeline`) | Discrete-only | Predecessor construction |
| 200 | (in proof) | Discrete-only | Coverness obligation |
| 218 | (in proof) | Discrete-only | Successor witness |
| 231 | (in proof) | Discrete-only | Predecessor witness |

**Status**: Discrete timeline is an alternative to the dense timeline on the publication
path. The dense path (StagedConstruction) uses Cantor intervals and is sorry-free.

## Archived (Boneyard)

The following archived files contain sorries that are not counted above:

- `Boneyard/Metalogic_v8/Bundle/DovetailingChain.lean`: 5 sorries (F/P witness gap)
- `Theories/Bimodal/Boneyard/Metalogic_v8/Bundle/DovetailingChain.lean`: 5 sorries (same file)
- Other archived files in various Boneyard directories

These are intentionally archived research paths and do not affect the build or publication.

## Verification Commands

```bash
# Count sorries on publication path (expect 0)
grep -rn "^\s*sorry$" Theories/Bimodal/Metalogic/StagedConstruction/ --include="*.lean"
grep -rn "^\s*sorry$" Theories/Bimodal/Metalogic/Bundle/TruthLemma.lean
grep -rn "^\s*sorry$" Theories/Bimodal/Metalogic/Bundle/CanonicalConstruction.lean
grep -rn "^\s*sorry$" Theories/Bimodal/Metalogic/Bundle/CanonicalFMCS.lean

# Count all sorries in Metalogic (excluding Boneyard)
grep -rn "^\s*sorry$" Theories/Bimodal/Metalogic/ --include="*.lean" | grep -v Boneyard | wc -l
```

---

*Generated: 2026-03-15*
*Task: 929 (prepare_metalogic_for_publication)*
