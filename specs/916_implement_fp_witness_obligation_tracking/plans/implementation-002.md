# Implementation Plan: Task #916 (Version 002)

- **Task**: 916 - Implement F/P witness obligation tracking to close DovetailingChain sorries
- **Status**: [PARTIAL]
- **Effort**: 35 hours
- **Dependencies**: None
- **Research Inputs**: specs/916_implement_fp_witness_obligation_tracking/reports/research-002.md
- **Artifacts**: plans/implementation-002.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

This plan replaces the [BLOCKED] phases 3-4 from implementation-001.md with a viable sub-chain approach (Option A' from research-002.md). The key insight is that joint F-witness consistency fails (F(p) and F(neg p) can coexist), so we must add witnesses **one at a time** via iterative extension. At each time t, we build an inner chain M_t^(0), M_t^(1), ..., where each step adds one F-witness using `temporal_witness_seed_consistent`. The final Lindenbaum preserves all witnesses (seed is subset of MCS). This creates an omega-squared (inner formula enumeration, outer time steps) construction.

### Research Integration

From research-002.md:
- **Key discovery**: G-derivability independence does NOT hold (temp_a: phi -> G(P(phi)))
- **Joint consistency failure**: F(p) and F(neg p) can coexist, so adding all F-witnesses at once is inconsistent
- **Viable approach**: Build M_t via iterative one-witness-at-a-time extension
- **Key lemma**: `temporal_witness_seed_consistent` (proven) - if F(psi) in M, then {psi} union GContent(M) is consistent
- **Current state**: 2 sorries remain (forward_F line 919, backward_P line 926); cross-sign propagation already resolved in implementation-001.md phases 1-2

## Goals & Non-Goals

**Goals**:
- Close the remaining 2 sorries in `DovetailingChain.lean` (forward_F, backward_P)
- Replace current Lindenbaum-based MCS construction with witness-accumulating sub-chain
- Prove forward_F via coverage argument (every F-formula eventually enumerated and witnessed)
- Prove backward_P via symmetric argument using `past_temporal_witness_seed_consistent`
- Maintain existing API: `buildDovetailingChainFamily`, `temporal_coherent_family_exists_theorem`

**Non-Goals**:
- Modifying cross-sign propagation (already resolved in implementation-001.md)
- Changing the BFMCS structure
- Constructive Lindenbaum (Option A from research was rejected as infeasible)
- Full canonical model construction beyond temporal chain

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Omega-squared indexing complexity | H | M | Use `Nat.pair` for inner/outer indices; leverage Mathlib `Encodable` infrastructure |
| Chain union consistency proof | H | M | Each inner step adds one formula; use `temporal_witness_seed_consistent` directly |
| Final Lindenbaum killing witnesses | H | L | Witnesses are in seed; seed is subset of MCS; MCS consistency prevents G(neg psi) |
| Recursion termination proof | M | M | Inner chain terminates by formula enumeration bound; outer chain uses dovetail index |
| Countable formula enumeration | M | L | Formula derives Countable; use `Set.enumerateCountable` |

## Sorry Characterization

### Pre-existing Sorries
- 2 sorries in `DovetailingChain.lean`:
  - Line 919: `buildDovetailingChainFamily_forward_F` (F-witness existence)
  - Line 926: `buildDovetailingChainFamily_backward_P` (P-witness existence)

### Expected Resolution
- Phase 3 resolves forward_F via sub-chain witness accumulation + coverage argument
- Phase 4 resolves backward_P via symmetric sub-chain for P-witnesses

### New Sorries
- None expected. The sub-chain approach with one-witness-at-a-time consistency is mathematically sound.

### Remaining Debt
After this implementation:
- 0 sorries expected in `DovetailingChain.lean`
- `temporal_coherent_family_exists_theorem` becomes fully proven
- Downstream completeness theorem no longer inherits sorry debt from temporal chain

## Implementation Phases

### Phase 1: Inner Chain Construction Infrastructure [BLOCKED]

- **Dependencies:** None
- **Goal:** Define the witness-accumulating inner chain that builds a consistent set containing all F-witnesses at a given time

**Key Insight**: At each time t, instead of one Lindenbaum call, we build:
```
M_t^(0) = GContent(M_{t-1})                                    -- base seed
M_t^(1) = Lindenbaum(M_t^(0) union {psi_0}) where F(psi_0) in MCS extending M_t^(0)
M_t^(2) = Lindenbaum(M_t^(1) union {psi_1}) where F(psi_1) in M_t^(1)
...
M_t = final MCS containing all needed witnesses
```

**Tasks**:
- [ ] Define `FWitnessSet (M : Set Formula) : Set Formula` = {psi | F(psi) in M}
- [ ] Define `PWitnessSet (M : Set Formula) : Set Formula` = {psi | P(psi) in M}
- [ ] Prove `FWitnessSet_countable` using Formula.countable
- [ ] Define `innerChainStep`: given consistent set S and formula psi with F(psi) in Lindenbaum(S), produce consistent S' = S union {psi}
- [ ] Prove `innerChainStep_consistent`: uses `temporal_witness_seed_consistent` on the intermediate MCS
- [ ] Define `buildInnerChain (base : Set Formula) (h_cons : SetConsistent base) (n : Nat) : Set Formula` via recursion on formula enumeration
- [ ] Prove `buildInnerChain_monotone`: buildInnerChain base h_cons n subset buildInnerChain base h_cons (n+1)
- [ ] Prove `buildInnerChain_consistent`: union of inner chain is consistent (chain union of consistent sets)
- [ ] Prove `buildInnerChain_preserves_base`: base subset buildInnerChain base h_cons n for all n

**Timing**: 8 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/DovetailingChain.lean` - Add inner chain infrastructure

**Verification**:
- `buildInnerChain` compiles with no sorry
- `buildInnerChain_consistent` proven
- `lake build Bimodal.Metalogic.Bundle.DovetailingChain` succeeds

**Progress:**

**Session: 2026-02-20, sess_1771630142_572e90** (no progress)
- Attempted: Inner chain construction with GContent-based stepping and F-witness accumulation
- Result: Mathematical obstruction identified. Three independent failure modes:
  1. Combined seed `{psi} union FPreservingSeed(M)` can be inconsistent (counterexample: psi = G(neg chi) with F(chi) in M)
  2. F-formula persistence through Zorn-based Lindenbaum is unprovable (Lindenbaum can add G(neg psi) at any step)
  3. Inner chain witnesses don't accumulate through GContent-based stepping (psi_k in MCS_{k+1} but not in MCS_{k+2})
- Also proved: FPreservingSeed(M) = GContent(M) union {F-formulas in M} is consistent (subset of M) and preserves all F-obligations, but cannot be combined with witness formulas
- No changes committed
- Handoff: `specs/916_implement_fp_witness_obligation_tracking/handoffs/phase-1-handoff-20260220.md`

---

### Phase 2: Outer Chain Integration [NOT STARTED]

- **Dependencies:** Phase 1
- **Goal:** Integrate inner chain into the time-indexed family, replacing simple Lindenbaum calls

**Key Structure Change**: The current `dovetailForwardChainMCS` builds M_n directly via Lindenbaum(GContent(M_{n-1})). We modify this to:
1. Compute base seed = GContent(M_{n-1})
2. Run `buildInnerChain` on base seed to accumulate F-witnesses
3. Apply final Lindenbaum to the inner chain limit
4. The resulting MCS contains all F-witnesses from M_{n-1}

**Tasks**:
- [ ] Define `buildAugmentedMCS (base : Set Formula) (h_cons : SetConsistent base) : Set Formula` using inner chain + final Lindenbaum
- [ ] Prove `buildAugmentedMCS_mcs`: result is an MCS
- [ ] Prove `buildAugmentedMCS_extends_base`: base subset result
- [ ] Prove `buildAugmentedMCS_contains_F_witnesses`: for each F(psi) in the intermediate MCS, psi is in result
- [ ] Modify `dovetailForwardChainMCS` to use `buildAugmentedMCS` instead of plain Lindenbaum
- [ ] Modify `dovetailBackwardChainMCS` symmetrically for P-witnesses using `past_temporal_witness_seed_consistent`
- [ ] Prove `dovetailForwardChainMCS_preserves_F_witnesses`: F-obligations from predecessor are witnessed
- [ ] Prove `dovetailBackwardChainMCS_preserves_P_witnesses`: P-obligations from successor are witnessed

**Timing**: 10 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/DovetailingChain.lean` - Integrate inner chain into outer construction

**Verification**:
- `dovetailForwardChainMCS` and `dovetailBackwardChainMCS` compile with no sorry
- Existing lemmas (GContent propagation, etc.) still hold
- `lake build Bimodal.Metalogic.Bundle.DovetailingChain` succeeds

---

### Phase 3: Forward_F Proof (Coverage Argument) [NOT STARTED]

- **Dependencies:** Phase 2
- **Goal:** Prove `buildDovetailingChainFamily_forward_F` using the coverage argument

**Proof Strategy**:
Given F(psi) in M_t, we need to find s > t with psi in M_s.

1. F(psi) is in M_t (given)
2. M_t was built from the augmented chain at step dovetailRank(t)
3. At M_{t+1}, the inner chain processes all F-formulas from the seed's intermediate MCS
4. Since F(psi) is in M_t, and M_{t+1}'s seed includes GContent(M_t), the intermediate MCS at step 0 of the inner chain for M_{t+1} may contain F(psi)
5. **Key**: Even if F(psi) is NOT in M_{t+1}, it will eventually be witnessed somewhere

**Coverage Lemma** (the heart of the proof):
For any F(psi) in M_t:
- psi has encoding index k = Encodable.encode psi
- The inner chain at M_{t+1} processes formula k (among others)
- If F(psi) is in the intermediate MCS at step k of M_{t+1}'s inner chain, psi is added
- By construction, psi is in M_{t+1}

**Tasks**:
- [ ] Prove `F_in_mcs_implies_F_in_immediate_successor_intermediate`: If F(psi) in M_t, then either psi in M_{t+1} OR F(psi) in M_{t+1} (persistence or witness)
- [ ] Prove `F_persistence_or_witness_induction`: F(psi) from M_t eventually witnessed by some M_{t+k}
- [ ] Prove `forward_F_coverage`: For any F(psi) in M_t, exists s > t with psi in M_s
- [ ] Wire `buildDovetailingChainFamily_forward_F` to use `forward_F_coverage`
- [ ] Remove sorry from `buildDovetailingChainFamily_forward_F`

**Timing**: 8 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/DovetailingChain.lean` - Add coverage argument and close forward_F sorry

**Verification**:
- `buildDovetailingChainFamily_forward_F` proven without sorry
- `#check buildDovetailingChainFamily_forward_F` shows no sorry warning
- `lake build` succeeds

---

### Phase 4: Backward_P Proof (Symmetric Argument) [NOT STARTED]

- **Dependencies:** Phase 3
- **Goal:** Prove `buildDovetailingChainFamily_backward_P` using symmetric coverage argument

**Proof Strategy**:
Given P(psi) in M_t, we need to find s < t with psi in M_s.

This is symmetric to forward_F:
1. Use `past_temporal_witness_seed_consistent` instead of `temporal_witness_seed_consistent`
2. Use HContent instead of GContent for the backward chain
3. The inner chain for backward direction accumulates P-witnesses

**Tasks**:
- [ ] Verify `past_temporal_witness_seed_consistent` is available and proven
- [ ] Prove `P_in_mcs_implies_P_in_immediate_predecessor_intermediate`: Symmetric to F case
- [ ] Prove `P_persistence_or_witness_induction`: P(psi) from M_t eventually witnessed by some M_{t-k}
- [ ] Prove `backward_P_coverage`: For any P(psi) in M_t, exists s < t with psi in M_s
- [ ] Wire `buildDovetailingChainFamily_backward_P` to use `backward_P_coverage`
- [ ] Remove sorry from `buildDovetailingChainFamily_backward_P`

**Timing**: 6 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/DovetailingChain.lean` - Add symmetric P-coverage argument and close backward_P sorry

**Verification**:
- `buildDovetailingChainFamily_backward_P` proven without sorry
- `#check buildDovetailingChainFamily_backward_P` shows no sorry warning
- `lake build` succeeds

---

### Phase 5: Verification and Cleanup [NOT STARTED]

- **Dependencies:** Phase 4
- **Goal:** Verify all sorries eliminated, clean up code, verify downstream theorems

**Tasks**:
- [ ] Run `grep -n "sorry" DovetailingChain.lean` to confirm 0 sorries remain
- [ ] Run `#print axioms temporal_coherent_family_exists_theorem` to verify only standard axioms
- [ ] Use `lean_verify` MCP tool on `temporal_coherent_family_exists_theorem`
- [ ] Add documentation comments to new inner chain definitions
- [ ] Update module header to reflect 0-sorry status
- [ ] Run `lake build` on full project to catch downstream breaks
- [ ] Run `grep -c "sorry" Theories/Bimodal/Metalogic/Bundle/*.lean` to check sorry delta
- [ ] Create implementation summary

**Timing**: 3 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/DovetailingChain.lean` - Documentation and cleanup
- `specs/916_implement_fp_witness_obligation_tracking/summaries/implementation-summary-YYYYMMDD.md` - Summary

**Verification**:
- `grep -c "sorry" DovetailingChain.lean` returns 0
- `lake build` succeeds with no errors
- `#print axioms temporal_coherent_family_exists_theorem` shows only propext, Classical.choice, Quot.sound

---

## Testing & Validation

- [ ] `lake build Bimodal.Metalogic.Bundle.DovetailingChain` compiles without error
- [ ] `lake build` full project succeeds
- [ ] `grep -c "sorry" Theories/Bimodal/Metalogic/Bundle/DovetailingChain.lean` returns 0
- [ ] `#print axioms temporal_coherent_family_exists_theorem` shows only standard axioms
- [ ] Verify via MCP `lean_verify` tool that theorem is sound
- [ ] Cross-sign propagation (from implementation-001.md phases 1-2) still works

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/Bundle/DovetailingChain.lean` (modified) - Sub-chain witness accumulation
- `specs/916_implement_fp_witness_obligation_tracking/plans/implementation-002.md` (this file)
- `specs/916_implement_fp_witness_obligation_tracking/summaries/implementation-summary-YYYYMMDD.md` (on completion)

## Rollback/Contingency

1. **Preserve existing code**: Do not delete current Lindenbaum-based construction until new approach is proven
2. **Incremental approach**: Each phase builds on the previous; partial progress is valuable
3. **Alternative for Phase 1**: If inner chain construction proves too complex, try "immediate witness only" approach (add one witness at immediate successor, prove F-persistence separately)
4. **Alternative for Phase 3**: If coverage argument fails, consider finite approximation argument or compactness-based proof
5. **Git revert**: Can revert to pre-implementation state if fundamental design flaw discovered

## Technical Notes

### Why One-Witness-At-A-Time Works

The key insight from research-002.md is that `temporal_witness_seed_consistent` guarantees:
- If F(psi) in M, then {psi} union GContent(M) is consistent

But adding multiple witnesses can fail:
- F(p) and F(neg p) can both be in M
- {p, neg p} is inconsistent

So we add one witness at a time:
1. Start with M_t^(0) = GContent(M_{t-1})
2. Extend to MCS M_t^(0)'
3. For each psi_k with F(psi_k) in M_t^(k-1)', add psi_k to seed
4. Extend to MCS M_t^(k)'
5. Final MCS contains all needed witnesses

Each step is consistent by `temporal_witness_seed_consistent` applied to the intermediate MCS.

### Why Final Lindenbaum Preserves Witnesses

When we Lindenbaum-extend a seed S:
- S subset MCS (by construction of Lindenbaum)
- If psi is in S, then psi is in MCS
- If psi is in MCS, then G(neg psi) is NOT in MCS (by T-axiom: G(neg psi) -> neg psi contradicts psi)
- Therefore F(psi) is in MCS (since F(psi) = neg G(neg psi))

So witnesses placed in the seed are preserved AND their F-obligations persist.

### Omega-Squared Structure

The construction has two levels of recursion:
1. **Outer (time)**: n = 0, 1, 2, ... indexing time points
2. **Inner (witness)**: k = 0, 1, 2, ... indexing formula enumeration at each time

Total construction is omega x omega = omega steps, but each step is a finite Lindenbaum extension.
