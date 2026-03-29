# Implementation Plan: Task #67 - Dovetailed OmegaFMCS Construction

- **Task**: 67 - prove_bundle_validity_implies_provability
- **Status**: [NOT STARTED]
- **Effort**: 10-14 hours
- **Dependencies**: None (builds on existing sorry-free infrastructure)
- **Research Inputs**: reports/22_team-research.md
- **Artifacts**: plans/08_dovetailed-omega-fmcs.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

This plan implements the dovetailed OmegaFMCS construction recommended by the team research (report 22). The current `omega_chain_forward` resolves only `F_top` at each step, leaving arbitrary F-obligations unresolved. The dovetailed construction enumerates ALL F-obligations round-robin using `Nat.unpair`, guaranteeing every obligation is eventually resolved.

The approach achieves temporal coherence by construction rather than through fuel-bound or transfer-back arguments, following Segerberg's "bulldozing" technique (1970).

### Research Integration

Key findings from report 22:
- Plan 07's approach has hidden sorries in backward chain (lines 3944, 4001) and integration gaps
- The actual gap is family-level temporal coherence: F(phi) in fam.mcs(t) needs phi in fam.mcs(s) for same family
- Bundle-level coherence is already sorry-free (`boxClassFamilies_bundle_forward_F`)
- Dovetailing provides family-level coherence by construction, avoiding all previous blockers

## Goals & Non-Goals

**Goals**:
- Replace `omega_chain_forward` with `omega_chain_dovetailed` that resolves ALL F-obligations fairly
- Prove `Z_chain_forward_F` (line 2424-2485) using the dovetailed construction
- Prove `Z_chain_backward_P` symmetrically for P-obligations
- Close the sorry in `bfmcs_from_mcs_temporally_coherent` (Completeness.lean:220-226)
- Achieve sorry-free completeness over Int

**Non-Goals**:
- Dense completeness (requires separate canonical model over Rat)
- Modifying the bundle-level coherence infrastructure (already sorry-free)
- Changing the BFMCS_Bundle structure

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Obligation enumeration complexity | H | M | Use `Nat.unpair` standard technique, well-documented in Mathlib |
| Backward chain symmetry issues | M | M | Design forward and backward chains with identical structure |
| G-theory crossing gap (line 2347) | H | L | Dovetailing should resolve by symmetric construction |
| Proof term size explosion | M | L | Use `sorry`-free helper lemmas, avoid nested tactics |

## Implementation Phases

### Phase 1: Define Dovetailed Forward Chain [PARTIAL]

**Goal**: Create the core `omega_chain_dovetailed_forward` that enumerates and resolves F-obligations fairly.

**Tasks**:
- [ ] Define `F_obligations : Set Formula -> Set Formula` to extract F-formulas from an MCS
- [ ] Define `F_obligations_at : (Nat -> Set Formula) -> Nat -> List Formula` to enumerate F-obligations at each time index
- [ ] Define `resolve_obligation : Set Formula -> SetMaximalConsistent -> Formula -> Set Formula` that finds witness for one F-formula
- [ ] Define `omega_chain_dovetailed_forward_step : (Nat -> Set Formula) -> Nat -> Set Formula` using `Nat.unpair` to select (time, obligation_index)
- [ ] Define `omega_chain_dovetailed_forward : SerialMCS -> Nat -> Set Formula` as the full forward chain

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` (new section after line 2020)

**Timing**: 2-3 hours

**Verification**:
- `lake build` succeeds
- New definitions are noncomputable (use choice for witnesses)
- Type signatures match: `omega_chain_dovetailed_forward : SerialMCS -> Nat -> Set Formula`

---

### Phase 2: Prove Dovetailed Chain Properties [NOT STARTED]

**Goal**: Establish that the dovetailed chain is MCS at each index and preserves box-class.

**Tasks**:
- [ ] Prove `omega_chain_dovetailed_forward_mcs : ∀ n, SetMaximalConsistent (omega_chain_dovetailed_forward M0 n)`
- [ ] Prove `omega_chain_dovetailed_forward_box_class : ∀ n, box_class_agree M0.world (omega_chain_dovetailed_forward M0 n)`
- [ ] Prove `omega_chain_dovetailed_forward_succ : ∀ n, Succ (omega_chain_dovetailed_forward M0 n) (omega_chain_dovetailed_forward M0 (n+1))`
- [ ] Prove `omega_chain_dovetailed_forward_G_persist : G(phi) ∈ chain(n) -> G(phi) ∈ chain(n+1)`

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean`

**Timing**: 2-3 hours

**Verification**:
- All four theorems compile without sorry
- Proofs use `temporal_theory_witness_exists` (sorry-free) for witness construction

---

### Phase 3: Prove Fairness Lemma [NOT STARTED]

**Goal**: Prove that every F-obligation is eventually resolved via `Nat.unpair` fairness.

**Tasks**:
- [ ] Prove `unpair_surjective : ∀ a b, ∃ n, Nat.unpair n = (a, b)` (should be in Mathlib)
- [ ] Prove `obligation_eventually_resolved : F(phi) ∈ chain(t) -> ∃ s > t, phi ∈ chain(s)`
  - Key insight: F(phi) at time t means obligation_index i exists at time t
  - By unpair surjectivity: ∃ n, unpair(n) = (t, i)
  - At step n, we resolve this obligation, placing phi in successor
- [ ] Handle the case where phi might already be resolved before step n

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean`

**Timing**: 2-3 hours

**Verification**:
- `obligation_eventually_resolved` compiles without sorry
- Proof uses `Nat.unpair_surj` or equivalent from Mathlib

---

### Phase 4: Symmetric Backward Chain [NOT STARTED]

**Goal**: Create symmetric dovetailed backward chain for P-obligations.

**Tasks**:
- [ ] Define `P_obligations : Set Formula -> Set Formula` to extract P-formulas
- [ ] Define `omega_chain_dovetailed_backward_step` using same unpair technique
- [ ] Define `omega_chain_dovetailed_backward : SerialMCS -> Nat -> Set Formula`
- [ ] Prove `omega_chain_dovetailed_backward_mcs`
- [ ] Prove `omega_chain_dovetailed_backward_box_class`
- [ ] Prove `P_obligation_eventually_resolved : P(phi) ∈ chain(t) -> ∃ s < t, phi ∈ chain(s)`

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean`

**Timing**: 2-3 hours

**Verification**:
- Backward chain mirrors forward chain structure
- `P_obligation_eventually_resolved` compiles without sorry

---

### Phase 5: Wire Dovetailed Chain to Z_chain [NOT STARTED]

**Goal**: Replace or augment current Z_chain with dovetailed version to close sorries.

**Tasks**:
- [ ] Define `Z_chain_dovetailed : Set Formula -> SetMaximalConsistent M -> Int -> Set Formula`
  - Positive indices: `omega_chain_dovetailed_forward`
  - Negative indices: `omega_chain_dovetailed_backward`
  - Zero: M itself
- [ ] Prove `Z_chain_dovetailed_forward_F` using Phase 3 fairness lemma
- [ ] Prove `Z_chain_dovetailed_backward_P` using Phase 4 fairness lemma
- [ ] Close `Z_chain_forward_G` crossing sorry (line 2347) via symmetric construction
- [ ] Close `Z_chain_backward_H` sorry (line 2383)

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean`

**Timing**: 1.5-2 hours

**Verification**:
- `Z_chain_dovetailed_forward_F` and `Z_chain_dovetailed_backward_P` compile without sorry
- Crossing sorries (lines 2347, 2383) are closed

---

### Phase 6: Connect to BFMCS and Completeness [NOT STARTED]

**Goal**: Wire dovetailed Z_chain to close `bfmcs_from_mcs_temporally_coherent`.

**Tasks**:
- [ ] Define `DovetailedFMCS : Set Formula -> SetMaximalConsistent M -> FMCS Int` using `Z_chain_dovetailed`
- [ ] Prove `DovetailedFMCS_forward_F : forward_F (DovetailedFMCS M h_mcs)`
- [ ] Prove `DovetailedFMCS_backward_P : backward_P (DovetailedFMCS M h_mcs)`
- [ ] Prove `DovetailedFMCS_temporally_coherent`
- [ ] Update `boxClassFamilies` to use `DovetailedFMCS` instead of `SuccChainFMCS` (or prove SuccChainFMCS inherits)
- [ ] Close `bfmcs_from_mcs_temporally_coherent` in Completeness.lean

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean`
- `Theories/Bimodal/FrameConditions/Completeness.lean`

**Timing**: 1-2 hours

**Verification**:
- `bfmcs_from_mcs_temporally_coherent` compiles without sorry
- `lake build` succeeds on full project
- `bundle_validity_implies_provability` is now sorry-free

## Testing & Validation

- [ ] `lake build` succeeds after each phase
- [ ] Run `lake build Bimodal.FrameConditions.Completeness` to verify completeness
- [ ] Check sorry count in UltrafilterChain.lean decreases from current state
- [ ] Verify `Z_chain_forward_F` and `Z_chain_backward_P` are sorry-free
- [ ] Verify `bfmcs_from_mcs_temporally_coherent` is sorry-free
- [ ] Final verification: `grep -c "sorry" Theories/Bimodal/FrameConditions/Completeness.lean` returns 1 (only dense_completeness_fc)

## Artifacts & Outputs

- `plans/08_dovetailed-omega-fmcs.md` (this file)
- Modified `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean`
- Modified `Theories/Bimodal/FrameConditions/Completeness.lean`
- `summaries/09_dovetailed-omega-summary.md` (after completion)

## Rollback/Contingency

If the dovetailed approach encounters unforeseen blockers:
1. Preserve all new definitions in a separate section marked with `-- DOVETAILED APPROACH (EXPERIMENTAL)`
2. Keep existing Z_chain and sorries unchanged
3. Document the specific blocker in the summary
4. Consider hybrid approach: dovetailed for forward_F, existing for G/H

If `Nat.unpair` fairness proof is difficult:
- Use explicit pairing function definition rather than Mathlib's
- Or use well-founded recursion on obligation count
