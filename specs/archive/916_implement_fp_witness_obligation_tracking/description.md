# Task 916: Implement F/P witness obligation tracking to close DovetailingChain sorries

## Objective

Close the 4 remaining sorries in `DovetailingChain.lean` by implementing F/P witness obligation tracking in the chain construction and resolving the cross-sign propagation gap.

## Background

The DovetailingChain constructs a BFMCS (Bundled Family of MCS) — a temporally coherent chain of MCSes indexed by ℤ. The construction currently proves same-sign coherence (forward_G for non-negative indices, backward_H for non-positive indices) but has 4 sorries:

1. **Cross-sign forward_G** (line 606): G φ ∈ MCS_t for t < 0 must propagate to MCS_{t'} for t' > 0
2. **Cross-sign backward_H** (line 617): H φ ∈ MCS_t for t ≥ 0 must propagate to MCS_{t'} for t' < 0
3. **forward_F** (line 633): F(ψ) ∈ MCS_t → ∃ s > t, ψ ∈ MCS_s
4. **backward_P** (line 640): P(ψ) ∈ MCS_t → ∃ s < t, ψ ∈ MCS_s

## Proof Strategy

### Phase 1: Unify the chain construction (closes sorries 1-2)

**Problem**: The current construction builds two independent half-chains (forward and backward) sharing only MCS_0. G φ at a negative time cannot propagate to positive times because the chains are independently Lindenbaum-extended.

**Solution**: Replace the split forward/backward chains with a single interleaved chain construction that builds MCSes in dovetailing order: M_0, M_1, M_{-1}, M_2, M_{-2}, ...

At each step n, the seed for MCS_t (where t = dovetailIndex(n)) is:
- If t-1 was already constructed: GContent(MCS_{t-1}) — ensures forward_G
- If t+1 was already constructed: HContent(MCS_{t+1}) — ensures backward_H
- By the dovetailing property, exactly one neighbor is always available

This ensures G φ propagates across the sign boundary through the shared chain. The proof uses:
- `dovetail_neighbor_constructed` (already proven): at step n > 0, one neighbor exists
- `dovetailForwardChainMCS_GContent_extends` pattern: GContent of predecessor is in successor
- Transitivity via `dovetailForwardChain_G_propagates_le` pattern

### Phase 2: Add F/P witness scheduling (closes sorries 3-4)

**Problem**: Lindenbaum extension can add F(ψ) formulas without placing the witness ψ at any specific future time. Each BFMCS requires that every F-obligation has a witness.

**Solution**: Augment the seed at each construction step with a scheduled witness formula.

**Construction**: Maintain a dovetailing enumeration over all (time, formula_index) pairs via Cantor pairing. At construction step n:
1. Decode n to (time_index, formula_index) via Nat.unpair
2. Look up the formula_index-th formula ψ such that F(ψ) ∈ MCS_{time_index}
3. If such a formula exists AND time_index < t (current time being constructed), include ψ in the seed

The seed for MCS_t at step n becomes:
```
seed_t = GContent(MCS_{t-1}) ∪ {ψ}   -- if resolving F-obligation at this step
seed_t = GContent(MCS_{t-1})           -- otherwise
```

**Consistency**: `temporal_witness_seed_consistent` (already proven) guarantees GContent(M) ∪ {ψ} is consistent whenever F(ψ) ∈ M. The key requirement is that F(ψ) ∈ MCS_{t-1} (the immediate predecessor), not just in the original MCS where the obligation arose.

**Ensuring F(ψ) persists to MCS_{t-1}**: Two approaches:
- **(A) Direct resolution**: Only resolve F(ψ) ∈ MCS_s at time s+1 (the very next step). This avoids persistence issues since F(ψ) ∈ MCS_s directly, and GContent(MCS_s) ∪ {ψ} is consistent. The dovetailing ensures every (s, ψ) pair is eventually processed by scheduling resolution at the right time.
- **(B) Obligation persistence**: Include F(ψ) in the seed of each intermediate MCS to keep it alive. This requires proving GContent(M) ∪ {F(ψ₁), ..., F(ψ_k)} ∪ {ψ_j} is consistent — harder but more flexible.

**Recommended**: Approach (A) — resolve each obligation exactly one step after it arises. This is simpler and leverages the proven `temporal_witness_seed_consistent` directly.

**Subtlety with Approach (A)**: Not every F(ψ) in MCS_s was present in the original seed; Lindenbaum can add F-formulas. The dovetailing must enumerate ALL formulas in ALL MCSes, not just the seed. Since the formula language is countable and the times are countable, the set of all obligations is countable and can be enumerated.

### Phase 3: Prove the full coherence theorem

Combine the unified chain (Phase 1) with witness scheduling (Phase 2) to produce a `buildDovetailingChainFamily` that satisfies all 4 properties without sorry.

## Key Lemmas Already Proven

| Lemma | File | What it gives |
|-------|------|---------------|
| `temporal_witness_seed_consistent` | TemporalCoherentConstruction.lean | GContent(M) ∪ {ψ} consistent when F(ψ) ∈ M |
| `past_temporal_witness_seed_consistent` | DovetailingChain.lean | HContent(M) ∪ {ψ} consistent when P(ψ) ∈ M |
| `dovetail_GContent_consistent` | DovetailingChain.lean | GContent(M) consistent for any MCS M |
| `dovetail_HContent_consistent` | DovetailingChain.lean | HContent(M) consistent for any MCS M |
| `dovetailRank_dovetailIndex` | DovetailingChain.lean | Dovetailing indexing is bijective |
| `dovetail_neighbor_constructed` | DovetailingChain.lean | At each step, one neighbor is already built |
| `dovetailForwardChain_forward_G` | DovetailingChain.lean | Same-sign G propagation (Nat-indexed) |
| `dovetailBackwardChain_backward_H` | DovetailingChain.lean | Same-sign H propagation (Nat-indexed) |
| `set_mcs_all_future_all_future` | MCSProperties | G φ ∈ M → G(G φ) ∈ M (4_G axiom in MCS) |
| `set_mcs_all_past_all_past` | MCSProperties | H φ ∈ M → H(H φ) ∈ M (4_H axiom in MCS) |

## Key Formulas / Non-Derivabilities

- **G φ → G(G φ)**: DERIVABLE (4_G axiom). This is why G-content propagates inductively through seeds.
- **F(ψ) → G(F(ψ))**: NOT DERIVABLE. Semantically invalid (ψ could hold at exactly one future time). This is why F-obligations don't propagate automatically and need explicit tracking.
- **F(ψ) → F(F(ψ))**: The converse F(F(ψ)) → F(ψ) IS derivable (from 4_G contrapositive), but F(ψ) → F(F(ψ)) is NOT.
- **φ → G(P φ)**: DERIVABLE (axiom A). Relates forward and backward directions.

## Dependencies
- Task 914 (rename, for consistency — but can proceed in parallel)
- Task 915 (documentation, for reference — but can proceed in parallel)

## Relation to Other Tasks
- Supersedes the 4 sorries that tasks 843, 864, 870, 880, 881, 882, 888 have all been orbiting
- If successful, eliminates the core blocking issue for sorry-free completeness
- The modal saturation question (task 881) is orthogonal — that's BMCS-level, not BFMCS-level

## Language
lean

## Estimated Effort
12-20 hours
