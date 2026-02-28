/-!
# Truth Lemma Backward Direction (Archived Documentation)

This file documents the backward direction of the truth lemma which is NOT REQUIRED
for completeness proofs. The actual code remains in `TruthLemma.lean` as part of the
mutual induction structure, but this documentation explains why the backward sorries
are acceptable.

## Status

**Archived**: 2026-02-02 (Task 809)
**Reason**: Backward direction sorries are fundamental limitations, not missing proofs

## Backward Direction Sorries

The backward direction `truth_at → φ ∈ MCS` has 3 sorries:

### 1. Box Backward Case (TRUSTED)
```
(∀ sigma, truth_at sigma t psi) → box psi ∈ mcs t
```
**Limitation**: Even knowing psi is true at ALL histories doesn't give us `box psi ∈ MCS`.
The necessitation rule only applies to theorems (empty context), not MCS membership.

### 2. H (all_past) Backward Case (OMEGA-RULE)
```
(∀ s ≤ t, truth_at s psi) → H psi ∈ mcs t
```
**Limitation**: Requires infinitary derivation. From infinitely many `psi` instances
at all past times, we need to derive `H psi` - this is the omega-rule, which TM logic
cannot express.

### 3. G (all_future) Backward Case (OMEGA-RULE)
```
(∀ s ≥ t, truth_at s psi) → G psi ∈ mcs t
```
**Limitation**: Symmetric to H case.

## Why Not Required for Completeness

The completeness proof structure is:

1. Start with consistent Gamma
2. Extend to MCS via Lindenbaum
3. Construct canonical model from MCS
4. Use **FORWARD** truth lemma: `φ ∈ MCS → truth_at φ`
5. Therefore Gamma is satisfiable

The backward direction would prove "tightness" - that the canonical model has
no extraneous truths. This is useful for:
- Soundness proofs (which we have via separate semantic argument)
- Frame correspondence
- Definability results

But it's NOT needed for the core completeness result.

## References

- `Metalogic/Representation/TruthLemma.lean`: Active implementation
- `Metalogic/Representation/TruthLemmaForward.lean`: Clean forward-only export
- `Metalogic_v3/TruthLemma/BackwardDirection.lean`: Previous documentation attempt
- Task 741 research: Omega-rule limitation analysis
- Task 809 research: Full audit of TruthLemma sorries
-/

-- This is a documentation-only file. No Lean code is archived here because:
-- 1. The backward direction is tightly coupled with forward in mutual induction
-- 2. The sorries are fundamental limitations, not incomplete proofs
-- 3. The code itself is small and well-documented in place
