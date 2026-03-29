# Implementation Plan: Task 67 - Wire Restricted Chain to Z_chain

- **Task**: 67 - prove_bundle_validity_implies_provability
- **Status**: [NOT STARTED]
- **Effort**: 8-12 hours
- **Dependencies**: Phases 1-5 of Plan 05 (COMPLETED), Plan 06 analysis (BLOCKED at Phase 2)
- **Research Inputs**:
  - specs/067_prove_bundle_validity_implies_provability/reports/21_fair-scheduling-research.md (primary)
  - specs/067_prove_bundle_validity_implies_provability/reports/20_team-research.md
- **Artifacts**: plans/07_wire-restricted-chain.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true
- **Previous Plans**:
  - 05_extend-deferral-closure.md (Phases 1-5 complete)
  - 06_well-founded-recursion.md (BLOCKED: well-founded termination proof intractable)

## Overview

This plan wires the already sorry-free `restricted_forward_chain_forward_F` theorem to `bfmcs_from_mcs_temporally_coherent` via bridge lemmas. The key insight from research report 21 is that the restricted chain infrastructure is already complete - the gap is connecting restricted chain membership to full MCS membership through Lindenbaum extension.

The approach avoids the blocked well-founded recursion path (Plan 06) by leveraging existing sorry-free theorems rather than eliminating the fuel=0 sorry directly.

### Research Integration

From report 21_fair-scheduling-research.md:
- **Primary recommendation**: Option B (Wire Restricted Chain) - lower complexity than well-founded restructuring
- **Key theorem**: `restricted_forward_chain_forward_F` (SuccChainFMCS.lean:3067-3075) is SORRY-FREE
- **Gap**: Transfer-back lemma connecting restricted chain to full MCS via Lindenbaum extension
- **Infrastructure exists**: `DeferralRestrictedSerialMCS.extendToMCS` (line 3116) provides extension
- **Backward chain**: Needs symmetric construction following forward pattern

## Goals & Non-Goals

**Goals**:
- Prove transfer-back lemma: `psi in deferralClosure -> psi in extendToMCS -> psi in M.world`
- Define `restricted_Z_chain` as `n -> (restricted_forward_chain M0 n).extendToMCS`
- Prove `restricted_Z_chain_forward_F` by lifting `restricted_forward_chain_forward_F`
- Build backward chain construction (symmetric to forward)
- Complete `bfmcs_from_mcs_temporally_coherent` using restricted Z_chain
- Eliminate sorry in `bundle_validity_implies_provability`

**Non-Goals**:
- Eliminating the fuel=0 sorry in `restricted_bounded_witness_wf` (approached differently)
- Restructuring with well-founded recursion (Plan 06 approach blocked)
- Implementing full fair scheduling / dovetailing (unnecessary with this approach)
- Dense completeness (separate concern)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Transfer-back lemma harder than expected | Medium | Low | Argument sketched in code (lines 3136-3146) |
| Backward chain requires significant work | Medium | Medium | Follow forward pattern exactly |
| Box-class agreement through extension | Low | Low | Already proven for forward direction |
| Integration with existing BFMCS structure | Low | Low | Clean interface via bundle_to_bfmcs |
| Lindenbaum extension not unique | Low | Low | Only need membership preservation, not uniqueness |

## Implementation Phases

### Phase 1: Prove Transfer-Back Lemma [NOT STARTED]

**Goal**: Prove that formulas in deferralClosure transfer back from Lindenbaum extension to original DRM

**Tasks**:
- [ ] Locate `DeferralRestrictedSerialMCS.extendToMCS` (SuccChainFMCS.lean:3116)
- [ ] Verify `extendToMCS_extends` lemma exists (M.world ⊆ extendToMCS)
- [ ] Prove key transfer-back theorem:
  ```lean
  theorem extendToMCS_transfer_back (phi psi : Formula)
      (M : DeferralRestrictedSerialMCS phi)
      (h_psi_dc : psi ∈ deferralClosure phi)
      (h_psi_ext : psi ∈ M.extendToMCS) :
      psi ∈ M.world
  ```
- [ ] Proof strategy (from research):
  - Suppose psi not in M.world
  - By DRM maximality: {psi} ∪ M.world is inconsistent with deferralClosure phi
  - But extendToMCS ⊇ M.world ∪ {psi} and extendToMCS is consistent
  - Contradiction
- [ ] Verify lemma compiles and is sorry-free

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean`

**Timing**: 2-3 hours

**Verification**:
- `extendToMCS_transfer_back` compiles without sorry
- `lake build Bimodal.Metalogic.Bundle.SuccChainFMCS` passes

---

### Phase 2: Define Restricted Z_chain Construction [NOT STARTED]

**Goal**: Create Z-indexed chain from restricted forward chain via Lindenbaum extension

**Tasks**:
- [ ] Define `restricted_Z_chain`:
  ```lean
  noncomputable def restricted_Z_chain (phi : Formula)
      (M0 : DeferralRestrictedSerialMCS phi) : Int → Set Formula
    | n => if n >= 0 then
             (restricted_forward_chain phi M0 n.toNat).extendToMCS
           else
             (restricted_backward_chain phi M0 (-n).toNat).extendToMCS
  ```
  Note: Initially define forward direction only; backward added in Phase 3
- [ ] Prove `restricted_Z_chain_mcs`: each point is a full MCS
  ```lean
  theorem restricted_Z_chain_mcs (phi : Formula)
      (M0 : DeferralRestrictedSerialMCS phi) (t : Int) :
      SetMaximalConsistent (restricted_Z_chain phi M0 t)
  ```
- [ ] Prove `restricted_Z_chain_box_class`: box-class agrees with M0
  ```lean
  theorem restricted_Z_chain_box_class (phi : Formula)
      (M0 : DeferralRestrictedSerialMCS phi) (t : Int) :
      box_class_agree M0.extendToMCS (restricted_Z_chain phi M0 t)
  ```
- [ ] Prove `restricted_Z_chain_G_theory`: G-formulas propagate forward
  ```lean
  theorem restricted_Z_chain_G_theory (phi : Formula)
      (M0 : DeferralRestrictedSerialMCS phi) (t t' : Int)
      (h_le : t ≤ t') (psi : Formula)
      (h_G : Formula.always_future psi ∈ restricted_Z_chain phi M0 t) :
      psi ∈ restricted_Z_chain phi M0 t'
  ```

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` or new file

**Timing**: 2-3 hours

**Verification**:
- All theorems compile without sorry
- `lake build` passes

---

### Phase 3: Build Backward Chain Construction [NOT STARTED]

**Goal**: Create symmetric backward chain construction for P-obligations

**Tasks**:
- [ ] Review existing backward chain infrastructure (SuccChainFMCS.lean:3077-3108)
- [ ] Define `constrained_predecessor_restricted` (symmetric to `constrained_successor_restricted`):
  - Uses h_content (analogous to g_content for backward direction)
  - Uses pastDeferralDisjunctions (analogous to deferralDisjunctions)
- [ ] Define `restricted_backward_chain`:
  ```lean
  noncomputable def restricted_backward_chain (phi : Formula)
      (M0 : DeferralRestrictedSerialMCS phi) : Nat → Set Formula
  ```
- [ ] Prove `restricted_backward_chain_forward_P` (symmetric to forward_F):
  ```lean
  theorem restricted_backward_chain_backward_P (phi : Formula)
      (M0 : DeferralRestrictedSerialMCS phi) (n : Nat) (psi : Formula)
      (h_P : Formula.some_past psi ∈ restricted_backward_chain phi M0 n) :
      ∃ m : Nat, n < m ∧ psi ∈ restricted_backward_chain phi M0 m
  ```
- [ ] Wire into `restricted_Z_chain` definition for negative indices

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean`

**Timing**: 2-3 hours

**Verification**:
- `restricted_backward_chain_backward_P` compiles without sorry
- `lake build` passes

---

### Phase 4: Prove restricted_Z_chain_forward_F [NOT STARTED]

**Goal**: Lift `restricted_forward_chain_forward_F` to full MCS level

**Tasks**:
- [ ] Prove `restricted_Z_chain_forward_F`:
  ```lean
  theorem restricted_Z_chain_forward_F (phi : Formula)
      (M0 : DeferralRestrictedSerialMCS phi) (t : Int) (psi : Formula)
      (h_F : Formula.some_future psi ∈ restricted_Z_chain phi M0 t) :
      ∃ t' : Int, t < t' ∧ psi ∈ restricted_Z_chain phi M0 t'
  ```
- [ ] Proof strategy:
  1. Given: `F(psi) ∈ restricted_Z_chain t = (restricted_forward_chain t).extendToMCS`
  2. If `F(psi) ∈ deferralClosure phi`: by transfer-back, `F(psi) ∈ restricted_forward_chain t`
  3. By `restricted_forward_chain_forward_F`: `∃ m > t, psi ∈ restricted_forward_chain m`
  4. By extension: `psi ∈ (restricted_forward_chain m).extendToMCS = restricted_Z_chain m`
  5. If `F(psi) ∉ deferralClosure phi`: need alternative argument (may not be in closure scope)
- [ ] Similarly prove `restricted_Z_chain_backward_P` using backward chain

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean`

**Timing**: 2-3 hours

**Verification**:
- `restricted_Z_chain_forward_F` and `restricted_Z_chain_backward_P` compile without sorry
- `lake build` passes

---

### Phase 5: Complete bfmcs_from_mcs_temporally_coherent [NOT STARTED]

**Goal**: Wire restricted Z_chain to complete family-level coherence proof

**Tasks**:
- [ ] Locate `bfmcs_from_mcs_temporally_coherent` (Completeness.lean)
- [ ] The theorem needs to prove:
  ```lean
  -- forward_F: F(psi) in fam.mcs(t) implies exists t' > t with psi in fam.mcs(t')
  -- backward_P: P(psi) in fam.mcs(t) implies exists t' < t with psi in fam.mcs(t')
  ```
- [ ] Create family from `restricted_Z_chain`:
  ```lean
  def restricted_Z_chain_family (phi : Formula)
      (M0 : DeferralRestrictedSerialMCS phi) : FMCS :=
    { mcs := restricted_Z_chain phi M0
    , is_mcs := restricted_Z_chain_mcs phi M0
    , box_agreement := restricted_Z_chain_box_class phi M0
    , G_theory := restricted_Z_chain_G_theory phi M0
    , forward_F := restricted_Z_chain_forward_F phi M0
    , backward_P := restricted_Z_chain_backward_P phi M0
    }
  ```
- [ ] Wire to `bfmcs_from_mcs_temporally_coherent`
- [ ] Remove sorry from `bfmcs_from_mcs_temporally_coherent`

**Files to modify**:
- `Theories/Bimodal/FrameConditions/Completeness.lean`
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean`

**Timing**: 1-2 hours

**Verification**:
- `bfmcs_from_mcs_temporally_coherent` compiles without sorry
- `lake build Bimodal.FrameConditions.Completeness` passes

---

### Phase 6: Complete bundle_validity_implies_provability [NOT STARTED]

**Goal**: Wire sorry-free family coherence into main completeness theorem

**Tasks**:
- [ ] With `bfmcs_from_mcs_temporally_coherent` sorry-free, verify proof structure:
  1. `not_provable_implies_neg_consistent` (sorry-free)
  2. `neg_consistent_gives_mcs_without_phi` (sorry-free)
  3. `construct_bfmcs_bundle` + `bundle_to_bfmcs` (sorry-free)
  4. `bfmcs_from_mcs_temporally_coherent` (NOW sorry-free from Phase 5)
  5. `construct_bfmcs_bundle_eval_at_zero` (sorry-free)
  6. Truth lemma and contradiction (sorry-free)
- [ ] Remove sorry from `bundle_validity_implies_provability`
- [ ] Verify `#print axioms bundle_validity_implies_provability` shows no sorryAx

**Files to modify**:
- `Theories/Bimodal/FrameConditions/Completeness.lean`

**Timing**: 1-2 hours

**Verification**:
- `bundle_validity_implies_provability` compiles without sorry
- `#print axioms bundle_validity_implies_provability` shows no sorryAx

---

### Phase 7: Verification and Cleanup [NOT STARTED]

**Goal**: Full build verification and documentation

**Tasks**:
- [ ] Run `lake build` for complete build
- [ ] Verify sorry elimination:
  ```bash
  grep -r "sorry" Theories/Bimodal/FrameConditions/Completeness.lean
  # Should only show dense_completeness_fc (separate concern)
  ```
- [ ] Run axiom check: `#print axioms completeness_over_Int`
- [ ] Update docstrings explaining the restricted chain approach
- [ ] Document relationship between restricted chain and full Z_chain
- [ ] Create implementation summary

**Files to modify**:
- Documentation updates across modified files

**Timing**: 1 hour

**Verification**:
- Full `lake build` passes
- Axiom check shows no sorryAx in completeness theorems
- Summary created at `summaries/07_wire-restricted-chain-summary.md`

---

## Testing & Validation

- [ ] Phase 1: `extendToMCS_transfer_back` sorry-free
- [ ] Phase 2: `restricted_Z_chain_*` theorems sorry-free
- [ ] Phase 3: `restricted_backward_chain_backward_P` sorry-free
- [ ] Phase 4: `restricted_Z_chain_forward_F` and `backward_P` sorry-free
- [ ] Phase 5: `bfmcs_from_mcs_temporally_coherent` sorry-free
- [ ] Phase 6: `bundle_validity_implies_provability` sorry-free
- [ ] Phase 7: Full build passes, no sorryAx in completeness

## Artifacts & Outputs

- `plans/07_wire-restricted-chain.md` (this file)
- Modified: `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean`
- Modified: `Theories/Bimodal/FrameConditions/Completeness.lean`
- `summaries/07_wire-restricted-chain-summary.md` (post-implementation)

## Technical Notes

### Why This Approach Works

The key insight is that `restricted_forward_chain_forward_F` (SuccChainFMCS.lean:3067-3075) is already sorry-free:

```lean
theorem restricted_forward_chain_forward_F (phi : Formula)
    (M0 : DeferralRestrictedSerialMCS phi) (n : Nat) (psi : Formula)
    (h_F : Formula.some_future psi ∈ restricted_forward_chain phi M0 n) :
    ∃ m : Nat, n < m ∧ psi ∈ restricted_forward_chain phi M0 m
```

This theorem proves F-resolution within the restricted chain (formulas in `deferralClosure phi`). The gap is only in connecting this to full MCS membership via Lindenbaum extension.

### Transfer-Back Argument

For DeferralRestrictedMCS `M` with extension `ext`:

```
Given: psi ∈ deferralClosure phi, psi ∈ ext
Goal: psi ∈ M

Proof by contradiction:
- Suppose psi ∉ M
- By DRM maximality: {psi} ∪ M is inconsistent with deferralClosure phi
- But ext ⊇ M ∪ {psi} and ext is consistent
- Contradiction (any consistent extension would be inconsistent)
```

This argument is already sketched at SuccChainFMCS.lean:3136-3146.

### Comparison with Plan 06

| Plan 06 (Blocked) | Plan 07 (This Plan) |
|-------------------|---------------------|
| Eliminate fuel=0 sorry | Bypass via existing sorry-free theorem |
| Well-founded recursion restructuring | Bridge lemmas to Lindenbaum extension |
| Modify `restricted_bounded_witness_wf` | Use `restricted_forward_chain_forward_F` as-is |
| Complex termination proof | Simpler membership transfer |

### Scope Considerations

The transfer-back lemma only works for formulas in `deferralClosure phi`. For the completeness theorem, we only need F-resolution for formulas that appear in the proof of validity - these are all in the closure of the formula being proved. If an F(psi) appears where psi is outside the closure, it comes from the full MCS extension, not the restricted chain.

## Rollback/Contingency

If the transfer-back lemma proves more difficult than expected:
1. Check if the DRM maximality property is already formalized
2. Consider proving a weaker version that only handles the specific cases needed for completeness
3. Fall back to Plan 06 backup (fair scheduling / dovetailing) if bridge lemma approach fails entirely
