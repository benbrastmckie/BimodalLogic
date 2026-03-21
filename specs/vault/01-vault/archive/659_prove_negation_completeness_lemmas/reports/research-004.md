# Research Report: Task #659 (Symmetry Analysis)

**Task**: 659 - Prove negation completeness lemmas
**Started**: 2026-01-29
**Completed**: 2026-01-29
**Effort**: 1 hour (focused analysis)
**Priority**: Low
**Dependencies**: None
**Sources/Inputs**: CoherentConstruction.lean deep analysis
**Artifacts**: specs/659_prove_negation_completeness_lemmas/reports/research-004.md
**Standards**: report-format.md
**Focus**: Why forward_H is fundamentally different from backward_H/forward_G/backward_G

## Executive Summary

- **The construction DOES have perfect G-H symmetry** in its design
- **The asymmetry is NOT between G and H, but between SOURCE and TARGET**
- `backward_G` is proven because the source (t') is built BEFORE the target (t) in the construction
- `forward_H` cannot be proven because the source (t') is built AFTER the target (t)
- **Key insight**: Persistence works along the construction direction, not against it

## Context & Scope

The question asked why `forward_H` is fundamentally different when there should be perfect symmetry between:
- `forward_G` and `backward_G`
- `forward_H` and `backward_H`

## Findings

### The Four Coherence Conditions

| Condition | Statement | Direction |
|-----------|-----------|-----------|
| `forward_G` | `Gφ ∈ mcs(t) → φ ∈ mcs(t')` for `t < t'` | Past → Future |
| `backward_G` | `Gφ ∈ mcs(t') → φ ∈ mcs(t)` for `t' < t` | Past → Future |
| `forward_H` | `Hφ ∈ mcs(t') → φ ∈ mcs(t)` for `t < t'` | Future → Past |
| `backward_H` | `Hφ ∈ mcs(t) → φ ∈ mcs(t')` for `t' < t` | Future → Past |

### The Construction Direction

```
Backward Chain (t < 0)          Gamma = mcs(0)          Forward Chain (t ≥ 0)
                                     |
... ← mcs(-2) ← mcs(-1) ← -------Gamma------- → mcs(1) → mcs(2) → ...
       ↑           ↑                                ↑           ↑
  H-formulas  H-formulas                       G-formulas  G-formulas
   persist     persist                          persist     persist
```

- **Forward chain**: Built with `forward_seed` which extracts from G-formulas
- **Backward chain**: Built with `backward_seed` which extracts from H-formulas

### Why backward_G Works (Case 1: both ≥ 0)

```
backward_G: Gφ ∈ mcs(t') → φ ∈ mcs(t) where t' < t (both ≥ 0)

Construction order: mcs(t') is built BEFORE mcs(t)
                    t' ----construction----> t

Proof:
1. Gφ ∈ mcs(t')
2. By G-4 axiom: GGφ ∈ mcs(t')
3. G-formulas PERSIST forward: Gφ ∈ mcs(t-1)
4. By forward_seed definition: φ ∈ forward_seed(mcs(t-1))
5. By seed containment: φ ∈ mcs(t) ✓

KEY: Source (t') is built BEFORE target (t), so persistence brings
     the G-formula to where it's needed.
```

### Why forward_H Fails (Case with both ≥ 0)

```
forward_H: Hφ ∈ mcs(t') → φ ∈ mcs(t) where t < t' (both ≥ 0)

Construction order: mcs(t) is built BEFORE mcs(t')
                    t ----construction----> t'

Would-be proof attempt:
1. Hφ ∈ mcs(t')
2. We need φ ∈ mcs(t), but t was built BEFORE t'
3. The Lindenbaum extension at t' could have ADDED Hφ
4. No mechanism brings φ back to mcs(t)

KEY: Source (t') is built AFTER target (t), so we can't use persistence
     to bring information backward in the construction.
```

### Why forward_H Also Fails (Case with both < 0)

```
forward_H: Hφ ∈ mcs(t') → φ ∈ mcs(t) where t < t' (both < 0)

Since t < t' < 0:
- t is farther from origin (e.g., t = -5)
- t' is closer to origin (e.g., t' = -2)

Construction order (backward chain builds away from origin):
  Gamma = mcs(0) → mcs(-1) → mcs(-2) → ... → mcs(-5)
                               ↑              ↑
                              t' (source)    t (target)

So mcs(t') is built BEFORE mcs(t) in the backward chain!

Would-be proof attempt:
1. Hφ ∈ mcs(t') = mcs(-2)
2. We need φ ∈ mcs(t) = mcs(-5)
3. H-formulas persist BACKWARD (away from origin): Hφ ∈ mcs(-4)
4. φ ∈ backward_seed(mcs(-4))
5. φ ∈ mcs(-5) ✓

Wait - this SHOULD work!
```

### Critical Discovery: forward_H Case 4 (both < 0) IS Provable!

Re-examining the code at line 681, the sorry covers ALL cases without case analysis. But the symmetric argument to `backward_G` DOES work for `forward_H` when both t and t' are negative!

**The proof**:
```lean
-- forward_H: t < t' → Hφ ∈ mcs(t') → φ ∈ mcs(t)
-- Case 4: Both t < 0 and t' < 0

-- Since t < t' < 0, we have |t| > |t'|, so (-t).toNat > (-t').toNat
-- In backward chain indexing: mcs(t') = mcs_backward_chain(-t').toNat
--                             mcs(t)  = mcs_backward_chain(-t).toNat
-- And (-t').toNat < (-t).toNat

-- This is EXACTLY the symmetric situation to backward_G Case 1!
-- 1. Hφ ∈ mcs_backward_chain((-t').toNat)
-- 2. By H-4: HHφ ∈ mcs_backward_chain((-t').toNat)
-- 3. By H-persistence: Hφ ∈ mcs_backward_chain((-t).toNat - 1)
-- 4. φ ∈ backward_seed(mcs_backward_chain((-t).toNat - 1))
-- 5. φ ∈ mcs_backward_chain((-t).toNat) = mcs(t) ✓
```

### The Real Asymmetry Table

| Condition | Case | Construction Relation | Provable? |
|-----------|------|----------------------|-----------|
| `forward_G` | both ≥ 0 | Source BEFORE Target | **YES** |
| `forward_G` | cross-origin | Different chains | sorry |
| `backward_G` | both ≥ 0 | Source BEFORE Target | **YES** |
| `backward_G` | cross-origin | Different chains | sorry |
| `backward_H` | both < 0 | Source BEFORE Target | **YES** |
| `backward_H` | cross-origin | Different chains | sorry |
| `forward_H` | both < 0 | Source BEFORE Target | **SHOULD BE YES** |
| `forward_H` | both ≥ 0 | Source AFTER Target | **NO** |
| `forward_H` | cross-origin | Different chains | sorry |

### The Core Principle

**Coherence conditions are provable when the SOURCE MCS is built BEFORE the TARGET MCS in the construction order.**

This gives us a 2x2x2 matrix:
- Operator (G or H)
- Direction (forward or backward in time)
- Sign region (both ≥ 0, both < 0, or cross-origin)

The construction direction creates an asymmetry within each sign region:
- Forward chain (≥ 0): G-formulas persist, H-formulas don't
- Backward chain (< 0): H-formulas persist, G-formulas don't

## Decisions

1. **forward_H Case 4 (both < 0) can be proven** using the symmetric H-persistence argument
2. **forward_H Cases with t ≥ 0 are fundamentally hard** because H doesn't persist in the forward chain
3. The construction has inherent asymmetry based on which chain is used

## Recommendations

### Immediate: Fix forward_H Case 4

Replace the blanket sorry at line 681 with case analysis:
```lean
· intro h_lt φ hH
  unfold mcs_unified_chain at hH ⊢
  by_cases h_t_nonneg : 0 ≤ t <;> by_cases h_t'_nonneg : 0 ≤ t' <;>
    simp only [h_t_nonneg, h_t'_nonneg] at hH ⊢
  · -- Case 1: t ≥ 0 and t' ≥ 0 - HARD (H doesn't persist in forward chain)
    sorry
  · -- Case 2: t ≥ 0 and t' < 0: contradiction since t < t'
    simp only [not_le] at h_t'_nonneg
    have : t' < t := lt_of_lt_of_le h_t'_nonneg h_t_nonneg
    exact absurd h_lt (asymm this)
  · -- Case 3: t < 0 and t' ≥ 0: cross-origin
    sorry
  · -- Case 4: Both t < 0 and t' < 0 - PROVABLE!
    simp only [not_le] at h_t_nonneg h_t'_nonneg
    have h_nat_lt : (-t').toNat < (-t).toNat := by omega
    have h_t_pos : 0 < (-t).toNat := by omega
    set m := (-t).toNat - 1 with hm_def
    have ht_eq : (-t).toNat = m + 1 := by omega
    have h_le : (-t').toNat ≤ m := by omega
    have hH_m := mcs_backward_chain_H_persistence Gamma h_mcs h_no_H_bot (-t').toNat m h_le φ hH
    have h_in_seed : φ ∈ backward_seed (mcs_backward_chain Gamma h_mcs h_no_H_bot m) := hH_m
    have h_result := mcs_backward_chain_seed_containment Gamma h_mcs h_no_H_bot m h_in_seed
    rw [ht_eq]
    exact h_result
```

### Longer-term: Document the Fundamental Limitation

The cases where source is built AFTER target cannot be proven with the current construction:
- `forward_H` when t ≥ 0 (source t' built after target t in forward chain)
- Cross-origin cases (different chains, no persistence connection)

These would require:
1. A modified construction that considers both G and H in each chain
2. Or accepting them as axioms/hypotheses
3. Or a completely different approach (e.g., back-and-forth construction)

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| forward_H Case 4 proof more complex | Low | Direct adaptation of backward_G proof |
| Still leaves Cases 1, 3 unproven | Low | Not needed for completeness |

## Appendix

### Proof of forward_H Case 4 Feasibility

The key is that `mcs_backward_chain_H_persistence` already exists and is symmetric to `mcs_forward_chain_G_persistence`:

```lean
lemma mcs_backward_chain_H_persistence (Gamma : Set Formula) (h_mcs : SetMaximalConsistent Gamma)
    (h_no_H_bot : Formula.all_past Formula.bot ∉ Gamma)
    (n m : ℕ) (h_le : n ≤ m) (φ : Formula)
    (hH : Formula.all_past φ ∈ mcs_backward_chain Gamma h_mcs h_no_H_bot n) :
    Formula.all_past φ ∈ mcs_backward_chain Gamma h_mcs h_no_H_bot m
```

This provides exactly what's needed for the proof.

### Summary of Asymmetry Source

The asymmetry is NOT between G and H operators. It's between:
1. **Construction order** (which MCS is built first)
2. **Information flow** (which direction formulas persist)

When these align (source built before target), the condition is provable.
When they conflict (source built after target), the condition requires external information flow.
