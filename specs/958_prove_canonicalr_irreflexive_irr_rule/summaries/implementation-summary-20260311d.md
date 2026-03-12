# Implementation Summary: Task #958 - Product Frame Bulldozing (Blocked)

**Task**: 958 - prove_canonicalr_irreflexive_irr_rule
**Plan**: implementation-006.md (product frame bulldozing)
**Session**: sess_1773273158_954466
**Date**: 2026-03-11
**Status**: BLOCKED (requires_user_review)

## What Was Attempted

Phase 0 investigation of the product frame bulldozing plan (implementation-006.md).

## Phase 0 Investigation Results

### StagedTimeline Bypass Check

1. **StagedTimeline does NOT bypass the need**: While `StagedPoint.lt` is irreflexive by definition (`CanonicalR a.mcs b.mcs AND NOT CanonicalR b.mcs a.mcs`), the completeness infrastructure requires `canonicalR_irreflexive` for establishing strict ordering properties of the canonical relation.

2. **Theorem is NOT imported anywhere**: `canonicalR_irreflexive` exists only in `CanonicalIrreflexivity.lean` and is not imported by any other Lean file. The 2 sorries (lines 1245 and 1328) exist only within the proof body.

3. **Product frame approach misconception**: The plan's product frame approach from `IRRSoundness.lean` provides SOUNDNESS infrastructure (proving IRR rule is sound on irreflexive frames), not COMPLETENESS infrastructure. It cannot directly prove `canonicalR_irreflexive`.

### Mathematical Analysis

The fundamental blocker identified across 8 research reports and now confirmed through independent analysis:

**The naming argument requires**: From a finite derivation L ++ {atom(p), H(neg(atom(p)))} |- bot, extract chi = L.foldr imp bot where p is NOT in chi.atoms, then apply IRR to get |- chi.

**The blocker**: When the base set includes GContent(M) formulas that mention p, chi WILL mention p, and IRR's freshness condition is unsatisfiable. This is structural and cannot be worked around with any choice of p (GContent(M) collectively mentions all strings).

### Viable Path Forward (Not Yet Implemented)

An F+ conservative extension approach exists but requires infrastructure not yet built:

1. In F+, the set `embed'' GContent(M) U {atom_ext(q), H_ext(neg_ext(atom_ext(q)))}` IS provably F+-consistent (all embedded GContent formulas are q-free, where q = Sum.inr())
2. This F+ set would need to be extended to an F+-MCS via **F+ Lindenbaum** (not yet implemented)
3. The F+-MCS would need to be projected back to an F-MCS via `M'_F = {phi | embed(phi) in M'_ext}`
4. GContent(M) subset M'_F follows trivially from the seed
5. Standard duality argument yields contradiction

**Missing infrastructure**: `ExtSetConsistent`, `ExtSetMaximalConsistent`, `ext_set_lindenbaum` (~100-150 lines, mirroring F-level Lindenbaum)

## What Was Not Modified

No Lean source files were modified. The 2 sorries in `CanonicalIrreflexivity.lean` remain unchanged.

## Recommendations

1. **Build F+ Lindenbaum infrastructure**: Create `ExtSetMaximalConsistent` and `ext_set_lindenbaum` in a new file (e.g., `ConservativeExtension/ExtLindenbaum.lean`), then prove `canonicalR_irreflexive` via the enlarged naming set in F+

2. **Alternative: Remove the theorem**: Since `canonicalR_irreflexive` is not imported anywhere, the sorries are contained. The completeness proof may not actually need this theorem if the StagedTimeline construction handles irreflexivity by construction.

3. **Alternative: Bulldozing at the completeness level**: Modify the completeness proof to work with a potentially reflexive canonical model, then apply bulldozing transformation. This is architecturally invasive but mathematically sound.
