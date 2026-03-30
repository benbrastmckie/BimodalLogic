# Implementation Plan: Close Z_chain_forward_F via F-Preserving Seeds

- **Task**: 69 - close_z_chain_forward_f
- **Status**: [PLANNED]
- **Effort**: 6-8 hours
- **Dependencies**: None (team research complete)
- **Research Inputs**:
  - specs/069_close_z_chain_forward_f/reports/01_z-chain-forward-research.md
  - specs/069_close_z_chain_forward_f/reports/02_team-research.md
- **Artifacts**: plans/04_f-preserving-seeds-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md
- **Type**: lean4
- **Parent Task**: 58 (Wire completeness to FrameConditions)
- **Plan Version**: 2 (supersedes plans/02_z-chain-forward-plan.md)

## Overview

Close `Z_chain_forward_F` by implementing **F-preserving seeds** — a modified extension seed that includes unresolved F-formulas. This prevents Lindenbaum from adding G(neg phi) when F(phi) is present, ensuring F-obligations persist until resolved by the dovetailed enumeration.

### Root Cause (from team research)

The current `temporal_theory_witness_exists` uses seed:
```
seed = {witness_formula} ∪ G_theory(M) ∪ box_theory(M)
```

F-formulas are excluded, allowing Lindenbaum to add G(neg phi) = neg(F(phi)) when consistent with the seed. Once G(neg phi) enters the chain, F(phi) vanishes.

### Solution: F-Preserving Seeds

Modify the seed to include unresolved F-formulas:
```
f_preserving_seed(M, phi) = {phi} ∪ G_theory(M) ∪ box_theory(M) ∪ F_unresolved(M)

where F_unresolved(M) = {F(psi) | F(psi) ∈ M ∧ psi ∉ M}
```

**Consistency argument**: If G(neg psi) were derivable from the original seed, then G(neg psi) ∈ M by the G-lift argument. But F(psi) ∈ M means neg(G(neg psi)) ∈ M, contradiction. Therefore adding F(psi) to the seed is safe.

## Goals & Non-Goals

**Goals**:
- Prove `f_preserving_seed_consistent`: The augmented seed is consistent
- Create `temporal_theory_witness_F_preserving`: MCS extension that preserves F-obligations
- Prove `F_persistence_lemma`: F(psi) persists in chain until resolved
- Prove `omega_true_dovetailed_forward_F_resolution`: F-resolution for dovetailed chain
- Close `Z_chain_forward_F` and downstream sorries

**Non-Goals**:
- Modifying the dovetailed enumeration (already correct)
- Proving backward direction via same mechanism (can use symmetric approach)
- Redesigning truth lemma architecture

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| G-lift argument doesn't extend | H | L | Core argument verified by 3 teammates; uses existing `some_future_excludes_all_future_neg` |
| Consistency proof too complex | M | M | Build incrementally; test with explicit examples |
| Invariant cascade issues | M | L | Create F_preserving variant rather than modifying existing theorem |
| Nested F-formulas (F(F(psi))) | L | M | Dovetailed enumeration handles each F-formula independently |

## Implementation Phases

### Phase 1: F-Unresolved Theory Definitions [NOT STARTED]

**Goal**: Define `F_unresolved_theory` and `f_preserving_seed`

**Tasks**:
- [ ] Define `F_unresolved_theory(M) : Set Formula := {F(psi) | F(psi) ∈ M ∧ psi ∉ M}`
- [ ] Define `f_preserving_seed(M, phi) := {phi} ∪ G_theory M ∪ box_theory M ∪ F_unresolved_theory M`
- [ ] Prove basic membership lemmas (element in G_theory, box_theory, F_unresolved_theory implies in seed)

**Timing**: 0.75 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` (after line ~1150)

**Verification**:
- [ ] `lake build` succeeds
- [ ] Definitions typecheck

### Phase 2: F-Preserving Seed Consistency [NOT STARTED]

**Goal**: Prove the augmented seed is consistent

**Key Lemma**: `f_preserving_seed_consistent`
```lean
theorem f_preserving_seed_consistent (M : Set Formula) (hM : SetMaximalConsistent M)
    (phi : Formula) (hphi : phi ∈ temporal_theory_forward M) :
    SetConsistent (f_preserving_seed M phi) := by
  -- Strategy: Show G(neg psi) not derivable from original seed when F(psi) ∈ M
  -- Use: some_future_excludes_all_future_neg + G-lift argument
  sorry
```

**Tasks**:
- [ ] Prove helper: `G_neg_not_derivable_from_seed`: For F(psi) ∈ M, G(neg psi) not derivable from G_theory ∪ box_theory
- [ ] Prove main: `f_preserving_seed_consistent` using `temporal_theory_witness_consistent` as base
- [ ] Handle F_unresolved being finite (follows from finite formula encoding)

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean`

**Verification**:
- [ ] `lake build` succeeds
- [ ] Consistency lemma proves without sorry

### Phase 3: F-Preserving Extension Theorem [NOT STARTED]

**Goal**: Create `temporal_theory_witness_F_preserving` — MCS extension that preserves F-obligations

**Tasks**:
- [ ] State theorem: Given MCS M and phi ∈ temporal_theory_forward M, produce MCS W with:
  - phi ∈ W
  - G_theory M ⊆ W
  - box_theory M ⊆ W
  - **NEW**: F_unresolved_theory M ⊆ W (F-preservation)
- [ ] Prove using Lindenbaum on `f_preserving_seed M phi`
- [ ] Derive F-persistence corollary: F(psi) ∈ M ∧ psi ∉ M → F(psi) ∈ W

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean`

**Verification**:
- [ ] `lake build` succeeds
- [ ] Extension theorem proves without sorry
- [ ] F-persistence corollary follows directly

### Phase 4: Wire to Omega Chain Construction [NOT STARTED]

**Goal**: Integrate F-preserving extension into the omega chain

**Tasks**:
- [ ] Create `omega_chain_true_dovetailed_F_preserving`: Omega chain using F-preserving extensions
- [ ] Prove `F_persistence_in_chain`: F(psi) ∈ chain(n) ∧ psi ∉ chain(n) → F(psi) ∈ chain(n+1)
- [ ] Verify existing `omega_chain_true_dovetailed_forward_resolves` still applies

**Alternative**: Modify existing `omega_chain_true_dovetailed_forward` to use F-preserving extensions (cleaner but higher risk)

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` (lines ~3818-3897)

**Verification**:
- [ ] `lake build` succeeds
- [ ] F-persistence invariant proven for chain

### Phase 5: F-Resolution and Z_chain Closure [NOT STARTED]

**Goal**: Prove F-resolution and close all downstream sorries

**Tasks**:
- [ ] Close `omega_true_dovetailed_forward_F_resolution` (remove sorry in vanishing case)
  - F(psi) persists by Phase 4 invariant
  - At n0 = Nat.pair t (encode psi), F(psi) still present
  - Resolution occurs at n0+1 by `omega_chain_true_dovetailed_forward_resolves`
- [ ] Close `omega_forward_F_bounded_persistence` (line 3611)
- [ ] Close `Z_chain_forward_F` (line 2486) and `Z_chain_forward_F'` (line 3666)
- [ ] Handle backward direction (P-formulas): Apply symmetric F-preserving seed approach to backward chain

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` (lines 2486, 3593, 3611, 3666, 3989)

**Verification**:
- [ ] `lake build` succeeds with zero sorries in Z_chain_forward_F chain
- [ ] `grep -n "sorry" UltrafilterChain.lean` shows reduction

### Phase 6: Verification and Cleanup [NOT STARTED]

**Goal**: Verify completeness path and clean up

**Tasks**:
- [ ] Verify `bfmcs_from_mcs_temporally_coherent` can close
- [ ] Verify `bundle_validity_implies_provability` unblocked
- [ ] Verify `completeness_over_Int` dependency chain clean
- [ ] Remove any TODO comments left during implementation
- [ ] Run full `lake build` to confirm no regressions

**Timing**: 0.5 hours

**Verification**:
- [ ] Zero new sorries introduced
- [ ] Completeness path to `completeness_over_Int` verified

## Testing & Validation

- [ ] `lake build` succeeds after each phase
- [ ] `grep -n "sorry" UltrafilterChain.lean` shows decreasing count
- [ ] Use `lean_goal` to inspect proof states at key lemmas
- [ ] Verify downstream theorems typecheck without change

## Artifacts & Outputs

- plans/04_f-preserving-seeds-plan.md (this file)
- Modified: `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean`
- summaries/05_f-preserving-implementation-summary.md (post-implementation)

## Rollback/Contingency

If F-preserving seed approach fails:

1. **Phase 2 failure (consistency)**: If G-lift argument doesn't extend, investigate "excluding Lindenbaum" variant (Strategy 2 from team research)

2. **Phase 3-4 failure (integration)**: If wiring causes invariant breakage, create isolated module with new chain construction

3. **Ultimate fallback**: Bundle-level coherence only (accepts that truth lemma uses bundle witnesses instead of family witnesses; requires major architectural change)

## Key References

### Codebase (from team research)
- `UltrafilterChain.lean:1154` — `temporal_theory_witness_exists` (current extension)
- `UltrafilterChain.lean:1083` — `some_future_excludes_all_future_neg` (F/G exclusion proof)
- `UltrafilterChain.lean:2012` — `OmegaForwardInvariant` (chain invariant)
- `MaximalConsistent.lean:291` — `set_lindenbaum` (Lindenbaum extension)

### Team Research Findings
- Consistency argument: G(neg psi) derivable from seed → G(neg psi) ∈ M → contradicts F(psi) ∈ M
- Implementation sequence: definitions → consistency → extension → chain → resolution
- Risk assessment: 60-70% success probability for primary approach
