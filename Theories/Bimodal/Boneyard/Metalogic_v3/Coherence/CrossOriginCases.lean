/-!
# Cross-Origin Coherence Cases (Boneyard)

This file documents the coherence cases from `CoherentConstruction.lean` that are
**NOT REQUIRED for the completeness theorem**.

## Why These Cases Are Not Needed

The completeness proof path only exercises three specific cases:

1. **forward_G Case 1** (both t, t' >= 0): PROVEN via `mcs_forward_chain_coherent`
2. **backward_H Case 4** (both t, t' < 0): PROVEN via `mcs_backward_chain_coherent`
3. **forward_H Case 4** (both t, t' < 0): PROVEN via `mcs_backward_chain_H_persistence` (Task 659)

The canonical model construction centers the MCS Gamma at time 0 and evaluates formulas
from there. Since:
- `all_future` (G) formulas at t >= 0 only need phi at t' >= 0
- `all_past` (H) formulas at t < 0 only need phi at t' < 0

The cross-origin cases (where t and t' have opposite signs) are never exercised.

## Extracted Cases

### forward_G Case 3: t < 0 and t' >= 0 (cross-origin)

```lean
-- hG : Gφ ∈ mcs_backward_chain(..., (-t).toNat)
-- Goal: φ ∈ mcs_forward_chain(..., t'.toNat)
--
-- Proof strategy (if needed):
-- 1. From Gφ ∈ mcs(t), use T-axiom to get φ ∈ mcs(t)
-- 2. Show φ propagates from mcs(t) through backward chain to Gamma = mcs(0)
-- 3. Then φ propagates through forward chain to mcs(t')
--
-- This requires backward-to-origin propagation, which needs additional infrastructure.
```

### forward_G Case 4: t < 0 and t' < 0, going toward origin

```lean
-- Since t < t' < 0, we have (-t).toNat > (-t').toNat (|t| > |t'|).
-- So mcs(t) is FURTHER from origin than mcs(t').
-- We need Gφ ∈ mcs(t) → φ ∈ mcs(t'), going toward origin.
--
-- This is the cross-modal case: backward chain preserves H-formulas going away
-- from origin, but G-formulas going toward origin requires additional reasoning.
```

### backward_H Case 1: Both t' >= 0 and t >= 0

```lean
-- H-propagation through forward chain requires additional infrastructure.
-- The forward chain is built to preserve G-formulas, not H-formulas.
```

### backward_H Case 2: t >= 0 and t' < 0 (cross-origin)

```lean
-- Cross-origin requires connecting chains through Gamma.
-- Similar to forward_G Case 3 but in opposite direction.
```

### forward_H Cases (t < t' → Hφ ∈ mcs(t') → φ ∈ mcs(t))

**Case 4 (both t, t' < 0): PROVEN** (Task 659)

```lean
-- Since t < t' < 0, we have |t| > |t'|, so (-t).toNat > (-t').toNat.
-- In backward chain: mcs(t') is built BEFORE mcs(t) (going away from origin).
-- This is symmetric to backward_G Case 1:
-- - Hφ persists from (-t').toNat to m = (-t).toNat - 1
-- - φ ∈ backward_seed(mcs(m)) → φ ∈ mcs(m+1) = mcs((-t).toNat)
-- Uses: mcs_backward_chain_H_persistence, mcs_backward_chain_seed_containment
```

**Cases 1, 2, 3: SORRY**

```lean
-- Case 1 (both >= 0): H doesn't persist in forward chain
-- Case 2 (t >= 0, t' < 0): Contradiction (t < t' impossible)
-- Case 3 (t < 0, t' >= 0): Cross-origin, not exercised by completeness proof
--
-- Note: Only Case 4 is needed for the backward Truth Lemma temporal cases,
-- but it does NOT directly enable them (see Task 659 assessment).
```

### backward_G Case 3: t' < 0 and t >= 0 (cross-origin)

```lean
-- Gφ in backward chain, goal in forward chain.
-- Cross-origin backward_G requires infrastructure connecting chains through Gamma.
```

### backward_G Case 4: Both t' < 0 and t < 0

```lean
-- Backward chain G-coherence not yet implemented.
-- Would need to show G-formulas propagate through the backward chain.
```

## If You Need These Cases

These cases would enable:

1. **Backward Truth Lemma** (`truth_at → φ ∈ MCS`):
   - Proves the canonical model is "tight" (no extraneous truths)
   - Useful for soundness, frame correspondence, definability results

2. **Full bidirectional coherence across the timeline**:
   - Would allow reasoning about formulas that start in the past and extend to the future
   - More mathematically elegant

**Estimated effort**: 15-25 hours to close all gaps, requiring:
- Cross-origin bridge lemmas (connect chains at Gamma)
- Bidirectional propagation infrastructure
- Possibly dependent choice for full generality

## Reference

- Original location: `Bimodal/Metalogic/Representation/CoherentConstruction.lean` lines 620-724
- Gap analysis: `specs/681_redesign_construct_indexed_family_coherent_approach/reports/research-004.md`
- Task: 681
-/

-- This file is documentation only. No compilable Lean code here.
-- The sorries remain in CoherentConstruction.lean with documentation comments
-- pointing to this file for details on what would be needed to prove them.
