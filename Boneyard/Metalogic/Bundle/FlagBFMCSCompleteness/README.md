# FlagBFMCS Completeness Pipeline (Archived)

**Archived**: 2026-03-20
**Reason**: Structural incompatibility with official truth_at semantics

## Summary

This directory contains the FlagBFMCS completeness infrastructure, which was an attempt to prove completeness via the `satisfies_at` relation. The approach was abandoned because `satisfies_at` is structurally incompatible with the official `truth_at` semantics.

## Files

| File | Lines | Description |
|------|-------|-------------|
| FlagBFMCS.lean | 270 | Core FlagBFMCS structure |
| FlagBFMCSTruthLemma.lean | 560 | Truth lemma for satisfies_at |
| FlagBFMCSCompleteness.lean | 110 | Completeness theorem attempt |
| FlagBFMCSValidityBridge.lean | 220 | Bridge to validity (incomplete) |
| FlagBFMCSIntBundle.lean | 170 | Integer-indexed bundle |
| FlagBFMCSRatBundle.lean | 510 | Rational-indexed bundle with sorries |

**Total**: ~1840 lines, 21 sorries

## Why Archived

The `satisfies_at` relation lacks essential components required by `truth_at`:

1. **No TaskFrame D**: truth_at requires a D set for task relation semantics
2. **No WorldHistory**: truth_at requires convex time domains with world states
3. **No Convexity**: The shifted embedding into Rat is not convex (FlagBFMCSRatBundle.lean:364)
4. **No Task Relation**: satisfies_at has no concept of task-based time shifts

The convexity sorry in FlagBFMCSRatBundle.lean is provably false - countable embeddings into Rat create gaps.

## Reusable Components (Not Extracted)

The following lemmas were candidates for extraction but have no external consumers:

- `g_content_propagation`: G-content propagates through CanonicalMCS ordering
- `h_content_propagation`: H-content propagates (backwards) through CanonicalMCS ordering
- `PartialOrder CanonicalMCS`: Antisymmetry of CanonicalMCS preorder
- `LinearOrder ChainFMCSDomain`: Total order on flag chains

These can be re-derived if needed for future work.

## Related Tasks

- **Task 1006**: Canonical TaskFrame completeness (uses StagedConstruction instead)
- **Task 997**: Dense completeness via Cantor (the approach that succeeded)
- **Task 988**: Original completeness investigation

## Alternative Approach

The StagedConstruction completeness approach (Theories/Bimodal/Metalogic/StagedConstruction/) successfully proves dense completeness without the satisfies_at relation. It uses:

1. Cantor isomorphism: TimelineQuot (canonical MCS quotient) is order-isomorphic to Q
2. CanonicalFMCS: Sorry-free temporal coherent family over all MCSs
3. Truth lemma: MCS membership iff semantic truth (bmcs_truth_lemma)

This approach is sorry-free and axiom-free for all published results.
