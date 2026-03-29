# Implementation Plan: Task #67 - Dovetailed OmegaFMCS Construction

- **Task**: 67 - prove_bundle_validity_implies_provability
- **Status**: [PARTIAL] (Phases 1-2 complete, Phase 3 blocked)
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

### Phase 1: Define Dovetailed Forward Chain [COMPLETED]

**Goal**: Create the core `omega_chain_dovetailed_forward` that enumerates and resolves F-obligations fairly.

**Tasks**:
- [x] Define `F_unresolved : (Nat -> Set Formula) -> Nat -> Formula -> Prop` - F(phi) is in chain but phi is not
- [x] Define `has_unresolved_F : (Nat -> Set Formula) -> Nat -> Prop` - there exists an unresolved F-formula
- [x] Define `select_unresolved_F` using Classical.choose to pick an unresolved F-formula
- [x] Define `resolution_target_time` using Nat.unpair to select time index
- [x] Define `omega_chain_true_dovetailed_forward_with_inv` skeleton (still uses F_top)
- [x] Prove basic properties: MCS, box_class, G_theory propagation
- [x] **COMPLETED**: Implement TRUE dovetailing using Denumerable.ofNat for formula enumeration
- [x] **COMPLETED**: Use formula index k from unpair(n) = (t, k) to select specific F-formulas
- [x] **COMPLETED**: Add `Infinite Formula` and `Denumerable Formula` instances to Formula.lean
- [x] **COMPLETED**: Define `enumFormula`, `selectFormulaToResolve`, `selectFormulaToResolve_has_F`
- [x] **COMPLETED**: Prove `omega_chain_true_dovetailed_forward_resolves` - selected formula is in chain(n+1)

**Key Insight Applied**: Formulas are `Countable` (Formula.lean) and `Infinite` (via injection from Atom), so we can use `nonempty_denumerable` to get `Denumerable Formula`, enabling enumeration via `Denumerable.ofNat : Nat -> Formula`.

**Dovetailing Strategy Implemented**:
1. At step n, decode (_, k) = Nat.unpair n
2. Let psi = Denumerable.ofNat k (the k-th formula)
3. If F(psi) ∈ chain(n), use resolving_witness for psi
4. Otherwise, use F_top to extend
5. By Denumerable surjectivity, every formula is eventually enumerated
6. `omega_chain_true_dovetailed_forward_resolves` proves the selected formula is included

**Files modified**:
- `Theories/Bimodal/Syntax/Formula.lean` - Added `Infinite Formula` and `Denumerable Formula` instances
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` - Added dovetailed chain infrastructure

**Verification**:
- `lake build` succeeds
- New definitions are noncomputable (use choice for witnesses)
- `omega_chain_true_dovetailed_forward_resolves` proves resolution property

---

### Phase 2: Prove Dovetailed Chain Properties [COMPLETED]

**Goal**: Establish that the dovetailed chain is MCS at each index and preserves box-class.

**Tasks**:
- [x] Prove `omega_chain_true_dovetailed_forward_mcs` - MCS at each index (done in Phase 1)
- [x] Prove `omega_chain_true_dovetailed_forward_box_class` - box_class_agree preserved (done in Phase 1)
- [x] Prove `omega_chain_true_dovetailed_forward_G_theory` - G-formulas propagate (done in Phase 1)
- [x] Prove `omega_chain_true_dovetailed_forward_zero` - chain(0) = M0 (done in Phase 1)
- [x] Prove `omega_chain_true_dovetailed_forward_resolves` - selected formula in chain(n+1) (done in Phase 1)

**Note**: These properties were already proven as part of Phase 1 using the `OmegaForwardInvariant` structure.
The theorems use `omega_chain_true_dovetailed_` prefix (not `omega_chain_dovetailed_`).

**Files modified**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean`

**Verification**:
- All theorems compile without sorry
- Proofs use the invariant structure from `omega_chain_true_dovetailed_forward_with_inv`

---

### Phase 3: Prove Fairness Lemma [BLOCKED]

**Goal**: Prove that every F-obligation is eventually resolved via `Nat.unpair` fairness.

**Tasks**:
- [x] Prove `unpair_surjective` - Available as `Nat.unpair_pair` in Mathlib
- [ ] **BLOCKED** Prove `obligation_eventually_resolved : F(phi) ∈ chain(t) -> ∃ s > t, phi ∈ chain(s)`

**Blocker**: F-formula persistence is NOT guaranteed in the chain construction.

**Why this fails**:
1. The witness construction (`temporal_theory_witness_exists`) does NOT preserve arbitrary F-formulas
2. Witness W extends `{phi} ∪ G_theory(M) ∪ box_theory(M)` - no F-formulas in seed
3. For F(psi) ∈ M with psi ≠ target, G(neg(psi)) might be added during Lindenbaum extension
4. If G(neg(psi)) ∈ W, then F(psi) ∉ W (since F = neg G neg)
5. This means F-obligations can be "lost" during chain extension

**Consequence**: Dovetailing ensures we CHECK for F(phi) at infinitely many steps (via Nat.unpair), but F(phi) might not persist from chain(t) to those steps.

**Potential fixes**:
1. Modify witness construction to include all F-formulas in seed (guarantee Succ relation)
2. Use different chain construction that explicitly tracks F-obligations
3. Accept bundle-level coherence instead of family-level (bundle_forward_F is sorry-free)

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
