# Implementation Plan: Task #55 (Revised v3)

- **Task**: 55 - Prove SuccChain Temporal Coherence Directly
- **Status**: [NOT STARTED]
- **Effort**: 5 hours
- **Dependencies**: None (supersedes tasks 36, 37, 53)
- **Research Inputs**: reports/04_resolving-chain-detailed.md
- **Artifacts**: plans/03_resolving-chain-implementation.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true
- **Supersedes**: plans/01_temporal-coherence-implementation.md (restriction-based, abandoned), plans/02_algebraic-temporal-coherence.md (phases 1-2 completed, phase 3 blocked)

## Overview

Replace the sorry chain (`f_nesting_is_bounded` -> `f_nesting_boundary` -> `succ_chain_forward_F` -> `SuccChainTemporalCoherent` -> `boxClassFamilies_temporally_coherent`) with a ResolvingChain approach. The key insight from research is the **per-obligation architecture**: `forward_F` only needs to resolve ONE specific phi per invocation. We use the proven `temporal_theory_witness_consistent` to force F-resolution at controlled points by including `{phi}` in the successor seed.

### Research Integration

- **Report 04 (resolving-chain-detailed.md)**: Complete specification for ResolvingChainFMCS approach with ~500 line estimate
- **Key insight**: DeferralDisjunctions are automatically in any MCS extension (F-step for non-target formulas is free)
- **Consistency**: The seed `{phi} ∪ temporal_box_seed M ∪ deferralDisjunctions M ∪ p_step_blocking_formulas M` is consistent when `F(phi) ∈ M`
- **Phases 1-2 infrastructure**: `temporal_theory_witness_consistent`, `temporal_theory_witness_exists`, `past_theory_witness_consistent`, `past_theory_witness_exists` are all proven (no sorry)

### Why This Supersedes Plan v2

Plan v2's phase 3 was blocked because the temporal witness W from `temporal_theory_witness_exists` lives in a DIFFERENT chain than `succ_chain_fam M0`. The resolving chain approach builds the witness INTO the chain at a controlled position, making `forward_F` trivially true by construction.

## Goals & Non-Goals

**Goals**:
- Define `resolving_successor_seed(M, phi)` that forces phi into the successor
- Prove `resolving_successor_seed_consistent` using `temporal_theory_witness_consistent` + extension argument
- Show resolving successor satisfies full Succ relation (G-persistence, F-step, P-step)
- Define `ResolvingChainFMCS` as replacement for `SuccChainFMCS`
- Prove `resolving_chain_forward_F` by construction (trivially true)
- Rewire `boxClassFamilies_temporally_coherent` to use resolving chains
- Remove dependency on `f_nesting_is_bounded` (mathematically FALSE for arbitrary MCS)

**Non-Goals**:
- Proving `f_nesting_is_bounded` for arbitrary MCS (mathematically impossible)
- Fixing boundary sorries in `DeferralRestrictedMCS` (abandoned approach)
- Modifying the Succ relation definition (it remains unchanged)
- Changing the BFMCS truth lemma (it continues to use temporal coherence as hypothesis)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Extended seed consistency proof is complex | Medium | Medium | Use the proven `temporal_theory_witness_consistent` as base, show deferralDisjunctions preserve consistency via MCS extension properties |
| P-step backward requires H-formulas in seed | Medium | Low | Include `p_step_blocking_formulas M` in seed; these are subsets of M, so consistency preserved |
| ResolvingChain may not satisfy all FMCS requirements | High | Low | Follow SuccChainFMCS pattern exactly; only change is successor seed |
| Chain parameterization by phi complicates boxClassFamilies | Medium | Medium | Use per-obligation proof: for each `F(phi)` query, construct witness using that specific phi |

## Implementation Phases

### Phase 1: Define Resolving Successor Seed and Prove Consistency [PARTIAL]

**Goal**: Define the resolving seed that forces a specific phi and prove it is consistent when `F(phi) ∈ M`.

**Tasks**:
- [ ] Define `resolving_successor_seed (M : Set Formula) (phi : Formula) : Set Formula` as `{phi} ∪ temporal_box_seed M ∪ deferralDisjunctions M ∪ p_step_blocking_formulas M`
- [ ] Prove `resolving_successor_seed_consistent`: If `F(phi) ∈ M` (MCS), then the seed is consistent
  - Strategy: All elements except `{phi}` are subsets of M (already proven for each component)
  - The full seed is subset of `{phi} ∪ M`
  - Use `temporal_theory_witness_consistent` for base case `{phi} ∪ temporal_box_seed M`
  - Show adding `deferralDisjunctions M ∪ p_step_blocking_formulas M` (subsets of M) preserves consistency via the MCS extension argument
- [ ] Prove helper lemmas as needed:
  - `resolving_seed_extends_temporal_box_seed`: The resolving seed extends the temporal box seed
  - `resolving_seed_subset_phi_union_M`: Full seed ⊆ {phi} ∪ M

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` - Add resolving seed definition and consistency proof (after temporal_theory_witness section around line 1200)

**Verification**:
- `lake build` succeeds
- `resolving_successor_seed_consistent` compiles without sorry
- All helper lemmas compile without sorry

---

### Phase 2: Prove Resolving Successor Satisfies Succ Relation [PARTIAL]

**Goal**: Show that a Lindenbaum extension of the resolving seed satisfies the full Succ relation.

**Tasks**:
- [ ] Define `resolving_successor_from_seed`: Lindenbaum extension of resolving seed
- [ ] Prove `resolving_successor_G_persistence`: `g_content M ⊆ W`
  - G(a) ∈ M → G(a) ∈ G_theory M → G(a) ∈ W (from seed extension)
  - G(a) ∈ W → a ∈ W (by temp_t_future axiom and MCS closure)
- [ ] Prove `resolving_successor_F_step`: `f_content M ⊆ W ∪ f_content W`
  - For target phi: `phi ∈ W` by construction (singleton in seed)
  - For other psi: W is MCS, so `psi ∈ W` or `neg(psi) ∈ W`, which gives `psi ∨ F(psi) ∈ W` automatically (deferralDisjunction)
- [ ] Prove `resolving_successor_P_step`: `p_content W ⊆ M ∪ p_content M`
  - Uses p_step_blocking_formulas in seed to block bad P-formulas
- [ ] Prove `resolving_successor_succ`: Full `Succ M W` combining above
- [ ] Prove `resolving_successor_box_class_agree`: `box_class_agree M W`
  - From box_theory in temporal_box_seed

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` - Add Succ relation proofs after resolving seed section

**Verification**:
- `lake build` succeeds
- `resolving_successor_succ` compiles without sorry
- `resolving_successor_box_class_agree` compiles without sorry

---

### Phase 3: Define ResolvingChainFMCS and Prove forward_F [NOT STARTED]

**Goal**: Build the full chain structure and prove temporal coherence by construction.

**Tasks**:
- [ ] Define `ResolvingForwardChainElement` structure (MCS with F_top, tracking target phi)
- [ ] Define `resolving_chain_fam (M0 : SerialMCS) (phi : Formula) (query_n : Int) : Int → Set Formula`
  - For n ≤ query_n: return `succ_chain_fam M0 n` (use existing chain up to query point)
  - For n = query_n + 1: return resolving successor forcing phi
  - For n > query_n + 1: continue with standard constrained successors
- [ ] Prove `resolving_chain_fam_mcs`: Chain elements are MCS
- [ ] Prove `resolving_chain_forward_F_direct`:
  ```lean
  theorem resolving_chain_forward_F_direct (M0 : SerialMCS) (n : Int) (phi : Formula)
      (h_F : Formula.some_future phi ∈ resolving_chain_fam M0 phi n n) :
      ∃ m : Int, n < m ∧ phi ∈ resolving_chain_fam M0 phi n m
  ```
  - Trivial: m = n + 1, phi is forced by construction
- [ ] Define symmetric `resolving_chain_backward_P` using `past_theory_witness_exists`
- [ ] Define `ResolvingChainFMCS` wrapper (FMCS Int structure)
- [ ] Define `ResolvingChainTemporalCoherent` proving temporal coherence

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` - Add ResolvingChainFMCS after existing SuccChainFMCS section (around line 1200)

**Verification**:
- `lake build` succeeds
- `resolving_chain_forward_F_direct` compiles without sorry
- `ResolvingChainTemporalCoherent` compiles without sorry

---

### Phase 4: Rewire boxClassFamilies_temporally_coherent [NOT STARTED]

**Goal**: Replace the sorry-dependent proof with direct resolving chain argument.

**Tasks**:
- [ ] Create new theorem `boxClassFamilies_temporally_coherent_via_resolving`:
  ```lean
  theorem boxClassFamilies_temporally_coherent_via_resolving (M0 : Set Formula)
      (h_mcs : SetMaximalConsistent M0) :
      ∀ fam ∈ boxClassFamilies M0 h_mcs,
        (∀ t φ, Formula.some_future φ ∈ fam.mcs t → ∃ s, t < s ∧ φ ∈ fam.mcs s) ∧
        (∀ t φ, Formula.some_past φ ∈ fam.mcs t → ∃ s, s < t ∧ φ ∈ fam.mcs s)
  ```
  - For each `F(phi) ∈ fam.mcs t`, construct resolving chain that forces phi at t+1
  - Use per-obligation insight: different chains for different phi queries
  - The resolving chain is in boxClassFamilies (box_class_agree preservation)
- [ ] **Alternative approach** (if above is complex): Prove forward_F directly for existing `succ_chain_fam` by showing resolving witness is reachable
- [ ] Update `boxClassFamilies_temporally_coherent` to use new proof (or deprecate old proof)
- [ ] Verify `construct_bfmcs` still compiles
- [ ] Verify `succ_chain_completeness` still compiles

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` - Rewire boxClassFamilies_temporally_coherent (around line 1668)

**Verification**:
- `lake build` succeeds
- `boxClassFamilies_temporally_coherent` compiles without sorry
- `construct_bfmcs` compiles without additional sorry
- `succ_chain_completeness` compiles without additional sorry

---

### Phase 5: Cleanup and Deprecation [NOT STARTED]

**Goal**: Remove false theorems and document the new approach.

**Tasks**:
- [ ] Mark `f_nesting_is_bounded` as deprecated with comment: "Mathematically FALSE for arbitrary MCS. Superseded by resolving chain approach."
- [ ] Mark `p_nesting_is_bounded` as deprecated (symmetric)
- [ ] Mark `f_nesting_boundary` as deprecated (depends on false theorem)
- [ ] Mark `p_nesting_boundary` as deprecated (symmetric)
- [ ] If `succ_chain_forward_F` uses sorry: mark deprecated and point to `resolving_chain_forward_F_direct`
- [ ] Add docstrings explaining the resolving chain approach
- [ ] Run `lake build` to verify no regressions
- [ ] Check `#print axioms construct_bfmcs` shows no sorryAx from f_nesting chain

**Timing**: 0.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` - Deprecation annotations (lines 731-847)
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` - Documentation

**Verification**:
- `lake build` succeeds
- Deprecated theorems have clear annotations
- `#print axioms construct_bfmcs` shows no f_nesting-related sorryAx
- `#print axioms succ_chain_completeness` shows expected axioms only

## Testing & Validation

- [ ] `lake build` succeeds with no new sorries
- [ ] `resolving_successor_seed_consistent` compiles without sorry
- [ ] `resolving_successor_succ` compiles without sorry
- [ ] `resolving_chain_forward_F_direct` compiles without sorry
- [ ] `boxClassFamilies_temporally_coherent` no longer depends on `f_nesting_is_bounded`
- [ ] `construct_bfmcs` and `succ_chain_completeness` remain functional
- [ ] `#print axioms construct_bfmcs` does not include sorryAx from f_nesting chain
- [ ] `f_nesting_is_bounded` and related theorems are marked deprecated

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean`:
  - `resolving_successor_seed` definition
  - `resolving_successor_seed_consistent` theorem
  - `resolving_successor_succ` theorem
  - Rewired `boxClassFamilies_temporally_coherent`
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean`:
  - `ResolvingChainFMCS` structure
  - `resolving_chain_forward_F_direct` theorem
  - Deprecated `f_nesting_is_bounded` and related theorems

## Rollback/Contingency

**If Phase 1 seed consistency fails** (extended seed inconsistent):
- Fall back to minimal seed `{phi} ∪ temporal_box_seed M`
- Accept partial F-step (only target phi resolved)
- Prove forward_F per-query without full Succ relation

**If Phase 3 chain construction fails** (ResolvingChainFMCS doesn't satisfy FMCS requirements):
- Use per-query families instead of single parameterized chain
- For each `F(phi)` query, construct ad-hoc family that resolves phi
- This is mathematically correct but less elegant

**If Phase 4 rewiring fails** (boxClassFamilies structure incompatible):
- Extend boxClassFamilies definition to include resolving chains
- Add union: `boxClassFamilies' = boxClassFamilies ∪ ResolvingFamilies`
- Prove temporal coherence for extended bundle

**Git safety**: Work on feature branch. Preserve all existing theorems until replacements verified. Only mark deprecated after new proofs compile.
