# Implementation Plan: Task 67 - Bypass Z-chain via Restricted TC Family

- **Task**: 67 - prove_bundle_validity_implies_provability
- **Status**: [NOT STARTED]
- **Effort**: 6-10 hours
- **Dependencies**: None (builds on existing infrastructure)
- **Research Inputs**: specs/067_prove_bundle_validity_implies_provability/reports/09_team-research.md
- **Artifacts**: plans/04_bypass-z-chain-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true
- **Previous Plans**: 03_termination-first-plan.md (phases 1-3 completed, phase 4 blocked)

## Overview

This plan abandons the Z-chain approach and follows the restricted coherence path identified by team research (09_team-research.md). The key insight: `build_restricted_tc_family` provides sorry-free same-chain F/P witnesses for formulas within `deferralClosure(phi)`. The Z-chain sorry (`Z_chain_forward_F`) is fundamental and should be bypassed entirely.

### Critical Team Research Findings

1. **`build_restricted_tc_family` provides same-chain F/P** (SuccChainFMCS.lean:4642)
   - `forward_F`: F(psi) at position n implies psi at position m > n
   - `backward_P`: P(psi) at position n implies psi at position m < n
   - Uses `restricted_forward_chain_forward_F` (sorry-free) and cross-chain helpers (have sorries in some cases)

2. **Z_chain_forward_F cannot be filled** (UltrafilterChain.lean:2424)
   - `omega_chain_forward` only resolves `F_top` at each step
   - Would require complete Henkin-style fair-scheduling redesign

3. **Same-family = same-history** (semantic requirement)
   - Task relation is g_content containment
   - `truth_at` quantifies over positions of the same history
   - Other-family witnesses don't help for same-history truth

### Path: Restricted Lindenbaum → Restricted TC Family → Truth Lemma → Completeness

```
1. neg(phi) consistent (by contrapositive of completeness)
       |
       v (deferral_restricted_lindenbaum)
2. DeferralRestrictedMCS containing neg(phi)
       |
       v (extend to serial)
3. DeferralRestrictedSerialMCS containing neg(phi)
       |
       v (build_restricted_tc_family)
4. RestrictedTemporallyCoherentFamily with same-chain F/P
       |
       v (restricted truth lemma)
5. neg(phi) TRUE at (chain, 0) ⟺ neg(phi) ∈ chain(0)
       |
       v (contradiction with validity)
6. phi is provable
```

## Goals & Non-Goals

**Goals**:
- Eliminate the sorry in `bundle_validity_implies_provability` (Completeness.lean:176)
- Construct `DeferralRestrictedSerialMCS` from `{neg(phi)}` consistent
- Connect `RestrictedTemporallyCoherentFamily` to truth lemma
- Wire to `valid_over Int` contradiction

**Non-Goals**:
- Proving Z_chain_forward_F (fundamental gap)
- Full family-level coherence for arbitrary MCS (impossible)
- Dense completeness (separate Rat canonical model)
- Fixing cross-chain sorries in SuccChainFMCS.lean (not on critical path if we evaluate at t=0)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Cross-chain sorries in `restricted_backward_to_combined_F_witness` block critical path | High | Medium | Evaluate truth lemma at t=0 where seed is; forward chain suffices |
| Extending DRM to DeferralRestrictedSerialMCS requires F_top/P_top membership proof | Medium | Low | Use theorem that F_top/P_top are theorems, hence in any consistent extension |
| Truth lemma for restricted family requires adapting parametric truth lemma | Medium | Medium | Define restricted variant scoped by subformulaClosure(phi) |
| Contradicting validity requires building TaskModel from restricted chain | Low | Medium | Use `parametric_to_history` pattern from existing infrastructure |

## Implementation Phases

### Phase 1: Build DeferralRestrictedSerialMCS from Consistent neg(phi) [BLOCKED]

**Goal**: Construct a `DeferralRestrictedSerialMCS phi` containing `neg(phi)` from `SetConsistent {neg(phi)}`

**BLOCKING ISSUE IDENTIFIED**:

The construction requires F_top and P_top to be in `deferralClosure(phi)`. However:

1. `F_top = F(neg bot)` and `P_top = P(neg bot)` are fixed formulas
2. `some_future_in_deferralClosure_is_in_closureWithNeg` (SubformulaClosure.lean:919) proves:
   `F(chi) ∈ deferralClosure(phi) → F(chi) ∈ closureWithNeg(phi)`
3. `closureWithNeg(phi)` only contains subformulas of phi and their negations
4. Therefore `F_top ∈ deferralClosure(phi)` requires phi to contain `F(neg bot)` as a subformula

**For general phi, F_top is NOT in deferralClosure(phi)**. This makes the plan fundamentally blocked.

**Example**: For phi = `box p`, deferralClosure(phi) contains:
- `box p`, `neg(box p)`, `p`, `neg p`
- Deferral disjunctions for any F-formulas in closureWithNeg (none for this phi)
- F_top = `F(neg bot)` is NOT in this closure

**Tasks (blocked)**:
- [x] Verify `neg(phi) ∈ deferralClosure phi` ✓ (by definition)
- [x] Apply `deferral_restricted_lindenbaum` to extend `{neg(phi)}` to DeferralRestrictedMCS ✓
- [ ] Prove F_top ∈ extension - **BLOCKED: F_top ∉ deferralClosure(phi) for general phi**
- [ ] Prove P_top ∈ extension - **BLOCKED: P_top ∉ deferralClosure(phi) for general phi**
- [ ] Package as `DeferralRestrictedSerialMCS phi`
- [ ] Prove `neg(phi) ∈ DeferralRestrictedSerialMCS.world`

**Key infrastructure**:
- `deferral_restricted_lindenbaum` (RestrictedMCS.lean:714) - extends consistent set to DRM
- `DeferralRestrictedSerialMCS` structure (SuccChainFMCS.lean:2272)
- `neg_mem_closureWithNeg` (ClosureWithNeg.lean) - neg(phi) ∈ closureWithNeg
- `theorem_in_drm` (RestrictedMCS.lean:1322) - theorems in closure are in DRM
- `some_future_in_deferralClosure_is_in_closureWithNeg` (SubformulaClosure.lean:919) - **THE BLOCKING LEMMA**

**Potential Resolutions**:
1. Extend deferralClosure to always include seriality formulas (requires significant infrastructure)
2. Prove completeness only for "seriality-compatible" formulas (where F_top ∈ deferralClosure(phi))
3. Find an alternative proof path that doesn't require DeferralRestrictedSerialMCS

**Files to modify**:
- N/A (blocked)

**Timing**: Blocked - requires alternative approach

**Verification**:
- N/A (blocked)

---

### Phase 2: Restricted Truth Lemma at Position 0 [NOT STARTED]

**Goal**: Prove truth lemma for `RestrictedTemporallyCoherentFamily` at the seed position

**Key insight**: At position 0, the chain equals the seed DeferralRestrictedSerialMCS. For formulas in `subformulaClosure(phi)`, we can prove:

```lean
theorem restricted_truth_lemma_at_zero
    (phi : Formula) (fam : RestrictedTemporallyCoherentFamily phi)
    (psi : Formula) (h_sub : psi ∈ subformulaClosure phi) :
    psi ∈ restricted_succ_chain_fam phi fam.seed 0 ↔
    truth_at (restricted_canonical_model fam) 0 psi
```

**Tasks**:
- [ ] Define `restricted_canonical_valuation` using chain membership for atoms
- [ ] Define `restricted_canonical_model` (Omega, valuation, history from chain)
- [ ] Prove truth lemma by induction on formula structure:
  - [ ] atom: by valuation definition
  - [ ] bot: both sides False
  - [ ] imp: bidirectional using both IH directions (requires psi, chi ∈ subformulaClosure)
  - [ ] box: by modal coherence (DRM has T-axiom closure)
  - [ ] G: forward by `forward_G` (g_content ⊆ mcs); backward by contrapositive using `forward_F`
  - [ ] H: forward by `backward_H`; backward by contrapositive using `backward_P`
- [ ] Handle the backward G/H cases using `fam.forward_F` and `fam.backward_P`
- [ ] Verify no cross-chain sorries are required for t=0 evaluation

**Critical detail for backward G case**:
```
G(psi) ∉ chain(0) → F(neg(psi)) ∈ chain(0) [MCS negation + temporal duality]
                  → neg(psi) ∈ chain(m) for some m > 0 [fam.forward_F]
                  → contradiction with truth(psi) at m [IH]
```

The F-witness m is in the **forward chain** (m > 0), so `restricted_forward_chain_forward_F` applies (sorry-free).

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/RestrictedTruthLemma.lean`

**Timing**: 2-3 hours

**Verification**:
- `restricted_truth_lemma_at_zero` compiles without sorry
- `lake build Bimodal.Metalogic.Algebraic.RestrictedTruthLemma` passes

---

### Phase 3: Completeness Wiring [NOT STARTED]

**Goal**: Complete `bundle_validity_implies_provability` using restricted construction

**Tasks**:
- [ ] Use `not_provable_implies_neg_consistent` (sorry-free) to get consistency of neg(phi)
- [ ] Apply Phase 1 construction to get `DeferralRestrictedSerialMCS phi` with neg(phi)
- [ ] Apply `build_restricted_tc_family` to get `RestrictedTemporallyCoherentFamily`
- [ ] Build TaskModel from restricted chain (valuation + omega + history)
- [ ] Apply Phase 2 truth lemma at position 0
- [ ] Show: neg(phi) ∈ chain(0) ↔ neg(phi) TRUE at (model, 0)
- [ ] Since neg(phi) ∈ chain(0) (by construction), neg(phi) is TRUE
- [ ] Derive contradiction with validity hypothesis (phi TRUE everywhere)
- [ ] Complete the by_contra proof

**Proof outline**:
```lean
theorem bundle_validity_implies_provability (φ : Formula)
    (h_valid : valid_over Int φ) : Nonempty ([] ⊢ φ) := by
  by_contra h_not_prov
  push_neg at h_not_prov
  -- Step 1: neg(φ) is consistent
  have h_neg_cons := not_provable_implies_neg_consistent φ h_not_prov
  -- Step 2: Build DeferralRestrictedSerialMCS with neg(φ)
  obtain ⟨seed, h_neg_in_seed⟩ := build_restricted_serial_mcs_from_neg_consistent φ h_neg_cons
  -- Step 3: Build RestrictedTemporallyCoherentFamily
  let fam := build_restricted_tc_family φ seed
  -- Step 4: Build TaskModel from restricted chain
  let model := restricted_canonical_model fam
  -- Step 5: neg(φ) is TRUE at (model, 0)
  have h_neg_true : truth_at model 0 φ.neg := by
    exact (restricted_truth_lemma_at_zero φ fam φ.neg h_neg_sub).mp h_neg_in_seed
  -- Step 6: φ is TRUE at (model, 0) by validity
  have h_phi_true : truth_at model 0 φ := h_valid model 0
  -- Step 7: Contradiction
  exact truth_neg_contra h_phi_true h_neg_true
```

**Files to modify**:
- `Theories/Bimodal/FrameConditions/Completeness.lean` - replace sorry

**Timing**: 2-3 hours

**Verification**:
- `bundle_validity_implies_provability` compiles without sorry
- `#print axioms bundle_validity_implies_provability` shows no `sorryAx`
- `lake build Bimodal.FrameConditions.Completeness` passes

---

### Phase 4: Cleanup and Verification [NOT STARTED]

**Goal**: Update documentation and verify sorry-free status

**Tasks**:
- [ ] Update docstrings in Completeness.lean to reflect proven status
- [ ] Update module documentation in RestrictedTruthLemma.lean
- [ ] Verify: `grep sorry Theories/Bimodal/FrameConditions/Completeness.lean` shows only `dense_completeness_fc`
- [ ] Verify: `#print axioms completeness_over_Int` shows no `sorryAx`
- [ ] Run full `lake build` to ensure no regressions
- [ ] Clean up any unused helper lemmas from previous plan attempts
- [ ] Update specs/067 summary with final status

**Files to modify**:
- `Theories/Bimodal/FrameConditions/Completeness.lean` - documentation updates
- `Theories/Bimodal/Metalogic/Algebraic/RestrictedTruthLemma.lean` - documentation updates

**Timing**: 1-1.5 hours

**Verification**:
- `lake build` passes completely
- Documentation accurately reflects proof status
- No `sorryAx` in completeness-related axiom prints

---

## Testing & Validation

- [ ] Phase 1: `build_restricted_serial_mcs_from_neg_consistent` compiles
- [ ] Phase 2: `restricted_truth_lemma_at_zero` compiles without sorry
- [ ] Phase 3: `bundle_validity_implies_provability` compiles without sorry
- [ ] Phase 4: `#print axioms bundle_validity_implies_provability` shows no `sorryAx`
- [ ] Full build: `lake build` completes without errors

## Artifacts & Outputs

- `plans/04_bypass-z-chain-plan.md` (this file)
- Modified: `Theories/Bimodal/FrameConditions/Completeness.lean`
- Modified: `Theories/Bimodal/Metalogic/Algebraic/RestrictedTruthLemma.lean`
- `summaries/04_completeness-final-summary.md` (post-implementation)

## Rollback/Contingency

If implementation fails:
1. `git checkout HEAD -- Theories/Bimodal/` to restore original state
2. Document failure point in errors.json
3. If Phase 1 fails: verify deferralClosure membership and Lindenbaum termination
4. If Phase 2 fails (cross-chain sorries still needed): consider evaluating truth lemma for all non-negative positions only, or prove a variant that avoids backward chain
5. If Phase 3 fails (type mismatches): verify TaskModel construction compatibility

## Technical Notes

### Why This Plan Differs from Plan 03

| Plan 03 Approach | Plan 04 Approach |
|------------------|------------------|
| Uses Z-chain temporal coherence | Bypasses Z-chain entirely |
| Requires proving Z_chain_forward_F | Uses RestrictedTemporallyCoherentFamily.forward_F |
| Goes through BFMCS_Bundle | Goes directly through DeferralRestrictedSerialMCS |
| Blocked on family-level coherence | Same-chain coherence suffices |

### Critical Path Analysis

The proof succeeds if:
1. `neg(phi)` can be extended to `DeferralRestrictedSerialMCS`
2. The restricted truth lemma works at position 0
3. The forward_F from `RestrictedTemporallyCoherentFamily` suffices for backward G case

Key observation: At t=0, the chain equals the seed. Forward F-witnesses are at positions > 0, which are in the forward chain where `restricted_forward_chain_forward_F` is sorry-free. The cross-chain sorries (`restricted_backward_to_combined_F_witness` etc.) are NOT on the critical path for evaluation at t=0.

### Infrastructure Status Summary

| Component | Status | Notes |
|-----------|--------|-------|
| `deferral_restricted_lindenbaum` | Sorry-free | RestrictedMCS.lean:714 |
| `build_restricted_tc_family` | Has cross-chain sorries | But forward chain is sorry-free |
| `restricted_forward_chain_forward_F` | Sorry-free | SuccChainFMCS.lean:2887 |
| `restricted_backward_chain_backward_P` | Sorry-free | SuccChainFMCS.lean:4238 |
| `restricted_backward_to_combined_F_witness` | Has sorry | Not on critical path for t=0 |
| `not_provable_implies_neg_consistent` | Sorry-free | UltrafilterChain.lean:2966 |
| `Z_chain_forward_F` | Fundamental sorry | BYPASSED |
