/-!
# Cross-Origin Coherence Cases (Boneyard)

This file documents the coherence cases from `CoherentConstruction.lean` that are
**NOT REQUIRED for the completeness theorem**.

## Why These Cases Are Not Needed

The completeness proof path only exercises two specific cases:

1. **forward_G Case 1** (both t, t' >= 0): PROVEN via `mcs_forward_chain_coherent`
2. **backward_H Case 4** (both t, t' < 0): PROVEN via `mcs_backward_chain_coherent`

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

### forward_H: All cases (t < t' → Hφ ∈ mcs(t') → φ ∈ mcs(t))

```lean
-- This says: "if φ has always been true from perspective of t', then φ is true at t"
-- where t is in the past of t'.
--
-- Proof strategy:
-- 1. By T-axiom: Hφ ∈ mcs(t') → φ ∈ mcs(t') (via mcs_closed_temp_t_past)
-- 2. Need to show formulas propagate "backward" from mcs(t') to mcs(t)
--
-- This is fundamentally different from forward_G:
-- - forward_G: Gφ forces φ to appear in FUTURE times
-- - forward_H: Hφ at t' asserts φ was true at PAST times
--
-- The second step requires that the chain construction preserves this relationship.
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
