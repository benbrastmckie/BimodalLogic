# Metalogic_v4 Archive

**Archived**: 2026-01-30 (Task 772)
**Original Location**: `Theories/Bimodal/Metalogic/Representation/`
**Status**: Contains 17 sorries total - architecturally unprovable

## Overview

This archive contains the representation theorem infrastructure that was moved from
`Metalogic/Representation/` because it contains sorries that are architecturally
unprovable. The sorry-free completeness result is provided by `semantic_weak_completeness`
in `FMP/SemanticCanonicalModel.lean`.

## Archived Files

| File | Sorry Count | Reason |
|------|-------------|--------|
| TaskRelation.lean | 5 | Cross-sign duration composition |
| CoherentConstruction.lean | 8 | Cross-origin coherence |
| TruthLemma.lean | 4 | Box (S5 semantics) + omega-rule |
| CanonicalHistory.lean | 0 | Depends on TaskRelation (sorried compositionality) |
| UniversalCanonicalModel.lean | 0 | Depends on TruthLemma + CoherentConstruction |
| InfinitaryStrongCompleteness.lean | 0 | Depends on UniversalCanonicalModel |
| Compactness.lean | 0 | Depends on InfinitaryStrongCompleteness |

## Why the Representation Theorem Approach Failed

The representation theorem approach tried to prove:

```
SetConsistent {phi} -> exists model, satisfiable phi
```

by constructing a **universal canonical model** from an indexed MCS family. This required:

1. **Task Relation Compositionality**: For tasks to compose across duration signs (d1 > 0, d2 < 0)
2. **Cross-Origin Coherence**: MCS coherence between positive and negative time indices
3. **Truth Lemma for Box**: Proving box psi true requires ALL histories, not just one

### The Fundamental Issues

#### 1. Cross-Sign Duration Composition (TaskRelation.lean)

When composing task relations with d1 + d2 = 0, we need to prove MCS equality:
- From world w, go forward d1 to u
- From u, go backward d2 = -d1 to v
- Need to show w = v

This requires proving that formula propagation composes correctly across sign
boundaries, which would need an omega-rule or cross-origin axioms not present in TM logic.

#### 2. Cross-Origin Coherence (CoherentConstruction.lean)

The MCS family construction builds:
- Forward chain: mcs(0), mcs(1), mcs(2), ... using forward seeds
- Backward chain: mcs(0), mcs(-1), mcs(-2), ... using backward seeds

There's no mechanism to ensure coherence between mcs(-1) and mcs(1) because:
- Forward seeds only carry G-formulas
- Backward seeds only carry H-formulas
- No axiom connects G-formulas in backward chain to H-formulas in forward chain

#### 3. Box Semantics (TruthLemma.lean)

Box uses S5-style universal quantification:
```
truth_at M tau t (box psi) <-> forall sigma, truth_at M sigma t psi
```

For arbitrary history sigma:
- The world state at time t may have a DIFFERENT MCS
- The valuation depends on MCS membership
- Therefore, we cannot prove psi true at arbitrary histories from box psi in one MCS

#### 4. Temporal Backward Direction (TruthLemma.lean)

To prove `G psi in mcs(t)` from `forall s > t, psi in mcs(s)`, we need G-completeness:
```
(forall s > t, psi in mcs(s)) -> G psi in mcs(t)
```

This requires deriving G psi from infinitely many instances of psi - an omega-rule
that TM logic cannot express.

## The Working Alternative

`semantic_weak_completeness` in `FMP/SemanticCanonicalModel.lean` works via **contrapositive**:

1. If phi is not provable, then {phi.neg} is consistent
2. Extend {phi.neg} to full MCS M via Lindenbaum
3. Project M to closure MCS S
4. Build FiniteWorldState from S where phi is FALSE
5. Build SemanticWorldState at origin
6. phi is false in the semantic model (by construction!)
7. This contradicts the validity hypothesis

**Key insight**: The contrapositive approach only needs to show phi is FALSE at ONE
specific world state built from the MCS. It never needs to reason about arbitrary
histories or compose tasks across sign boundaries.

## References

- Task 750: Truth bridge analysis confirming these are architectural limitations
- Task 769: Deprecation of sorried code with DEPRECATED markers
- Task 772: This archival

## Usage

These files are archived for historical reference. Do NOT import them for new code.

For completeness proofs, use:
```lean
import Bimodal.Metalogic.FMP.SemanticCanonicalModel

-- semantic_weak_completeness : forall w, semantic_truth phi w -> |- phi
```
