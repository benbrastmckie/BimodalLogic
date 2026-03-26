# Implementation Plan: Task #58 - Bundle-Level Temporal Coherence (v6)

- **Task**: 58 - wire_completeness_to_frame_conditions
- **Status**: [NOT STARTED]
- **Effort**: 14 hours
- **Dependencies**: None (all building blocks are sorry-free)
- **Research Inputs**: specs/058_wire_completeness_to_frame_conditions/reports/16_mathematical-strategy.md
- **Artifacts**: plans/06_bundle-coherence.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

This plan implements **bundle-level temporal coherence** to eliminate 3 sorries in `FrameConditions/Completeness.lean`: `dense_completeness_fc` (line 108), `discrete_completeness_fc` (line 151), and `completeness_over_Int` (line 170).

The key insight from research report 16: the blocking sub-case (b) identified in prior attempts is a genuine mathematical obstruction for **family-level** temporal coherence, but can be resolved by adopting **bundle-level** temporal coherence. Instead of requiring F(phi) witnesses to exist within the same family, we allow witnesses to exist in ANY family of the bundle - which is mathematically sound and aligns with standard Jonsson-Tarski completeness techniques.

### Research Integration

From report 16_mathematical-strategy.md:
- **Sub-case (b) is real**: G(neg phi) in M0, H(neg phi) not in M0, F(phi) in backward(n) cannot be resolved within a single chain
- **Bundle coherence is the fix**: F-witnesses can be found in shifted SuccChainFMCS from witness MCS W (from `temporal_theory_witness_exists`)
- **Building blocks are sorry-free**: `temporal_theory_witness_exists`, `past_theory_witness_exists`, `boxClassFamilies_modal_forward`, `boxClassFamilies_modal_backward`
- **No new axioms required**: Uses only existing proven infrastructure

### Prior Plan Analysis

Plan 05 (omega-enumeration) partially completed phases 1-4 but blocked at:
- `Z_chain_forward_F`: sorry - cannot resolve F-obligations in backward portion of chain
- `Z_chain_backward_P`: sorry - symmetric issue
- `Z_chain_forward_G`: sorry - G-propagation across boundary crossing

This plan abandons the single-chain approach in favor of bundle-level coherence.

## Goals & Non-Goals

**Goals**:
- Define `bundle_forward_F` and `bundle_backward_P` predicates for bundle-level temporal coherence
- Prove `boxClassFamilies_bundle_forward_F`: every F(phi) has a witness in SOME family of the bundle
- Prove `boxClassFamilies_bundle_backward_P`: symmetric for P-obligations
- Define `BFMCS_Bundle` structure with bundle-level temporal coherence
- Prove `BFMCS_Bundle_truth_lemma` for F operator using bundle coherence
- Wire `construct_bfmcs_bundle` to completeness theorems
- Eliminate sorries in `dense_completeness_fc`, `discrete_completeness_fc`, `completeness_over_Int`

**Non-Goals**:
- Proving family-level temporal coherence (mathematically blocked by sub-case (b))
- Fixing `SuccChainTemporalCoherent` or `f_nesting_is_bounded` (mathematically impossible)
- Generalizing beyond Int temporal domain (Int is sufficient for completeness)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Truth lemma for F needs family equality | H | M | Standard modal logic uses bundle semantics; verify formulation carefully |
| Shifted witness family not in bundle | H | L | `temporal_theory_witness_exists` gives box_class_agree; construct shifted family explicitly |
| Time point alignment for witnesses | M | M | Use shifted_fmcs with careful offset calculation |
| Bundle truth lemma proof complexity | M | M | Factor into small lemmas; use existing boxClassFamilies infrastructure |
| Integration with existing BFMCS structure | M | L | Create parallel BFMCS_Bundle or extend existing BFMCS with optional bundle coherence |

## Implementation Phases

### Phase 1: Bundle-Level Temporal Coherence Predicates [NOT STARTED]

**Goal**: Define the bundle-level coherence predicates that weaken family-level requirements.

**Tasks**:
- [ ] Define `bundle_forward_F`: F(phi) in fam.mcs(t) implies exists fam' in bundle, exists s > t, phi in fam'.mcs(s)
- [ ] Define `bundle_backward_P`: P(phi) in fam.mcs(t) implies exists fam' in bundle, exists s < t, phi in fam'.mcs(s)
- [ ] Define `BundleTemporallyCoherent`: predicate capturing bundle-level F and P coherence
- [ ] Prove `bundle_coherence_implies_family_F`: bundle coherence gives existential F-witness (not necessarily in same family)
- [ ] Add documentation explaining the distinction from family-level coherence

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` - New section "Bundle-Level Temporal Coherence" after existing temporal coherence

**Verification**:
- `lake build Bimodal.Metalogic.Algebraic.UltrafilterChain`
- All definitions type-check
- `lean_goal` confirms no type errors

---

### Phase 2: Prove boxClassFamilies Satisfies Bundle Coherence [NOT STARTED]

**Goal**: Show that the existing `boxClassFamilies` construction satisfies bundle-level temporal coherence.

**Tasks**:
- [ ] Prove `boxClassFamilies_bundle_forward_F`: For any fam in boxClassFamilies and F(phi) in fam.mcs(t), construct witness family fam' with phi
- [ ] Prove `boxClassFamilies_bundle_backward_P`: Symmetric for P-obligations
- [ ] The key construction: from F(phi), use `temporal_theory_witness_exists` to get MCS W with phi, then build shifted SuccChainFMCS from W at offset t+1
- [ ] Verify the shifted family is in boxClassFamilies (uses box_class_agree transitivity)
- [ ] Prove the witness time point is correct: phi in fam'.mcs(t+1) where t+1 > t

**Timing**: 4 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` - New section "boxClassFamilies Bundle Coherence"

**Proof outline for forward_F**:
```lean
theorem boxClassFamilies_bundle_forward_F (M0 : Set Formula) (h_mcs : SetMaximalConsistent M0)
    (fam : FMCS Int) (hfam : fam ∈ boxClassFamilies M0 h_mcs)
    (t : Int) (phi : Formula) (h_F : Formula.some_future phi ∈ fam.mcs t) :
    ∃ fam' ∈ boxClassFamilies M0 h_mcs, ∃ s > t, phi ∈ fam'.mcs s := by
  -- Step 1: Get witness MCS from temporal_theory_witness_exists
  have h_mcs_t := fam.is_mcs t
  have h_witness := temporal_theory_witness_exists (fam.mcs t) h_mcs_t phi h_F
  obtain ⟨W, h_W_mcs, h_phi_W, h_G_agree, h_box_agree⟩ := h_witness

  -- Step 2: Construct SerialMCS from W
  let W_serial := MCS_to_SerialMCS W h_W_mcs

  -- Step 3: Build shifted SuccChainFMCS from W at offset t+1
  let witness_fam := shifted_fmcs (SuccChainFMCS W_serial) (t + 1)

  -- Step 4: Show witness_fam is in boxClassFamilies
  have h_fam_box : box_class_agree M0 (fam.mcs t) := boxClassFamilies_box_agree_at_time ...
  have h_W_box : box_class_agree M0 W := box_class_agree_trans h_fam_box h_box_agree
  have h_witness_in : witness_fam ∈ boxClassFamilies M0 h_mcs := ⟨W, h_W_mcs, t+1, h_W_box, rfl⟩

  -- Step 5: phi is in witness_fam.mcs(t+1)
  -- By shifted_fmcs_at_offset: witness_fam.mcs(t+1) = SuccChainFMCS(W).mcs(0) = W
  -- And phi ∈ W from h_phi_W
  use witness_fam, h_witness_in, t+1
  constructor
  · omega
  · simp [shifted_fmcs_at_offset]; exact h_phi_W
```

**Verification**:
- `lake build Bimodal.Metalogic.Algebraic.UltrafilterChain`
- `#print axioms boxClassFamilies_bundle_forward_F` shows no `sorryAx`
- This is the mathematical core - verify carefully with `lean_goal`

---

### Phase 3: Create BFMCS_Bundle Structure [NOT STARTED]

**Goal**: Define a BFMCS variant that uses bundle-level temporal coherence.

**Tasks**:
- [ ] Define `BFMCS_Bundle` structure with bundle coherence instead of family coherence
- [ ] Include fields: families, nonempty, modal_forward, modal_backward, bundle_forward_F, bundle_backward_P, eval_family, eval_family_mem
- [ ] Prove `BFMCS_Bundle.reflexivity`: Box phi implies phi (same as BFMCS)
- [ ] Prove `BFMCS_Bundle.diamond_witness`: Diamond(phi) has witness family (same as BFMCS)
- [ ] Define `construct_bfmcs_bundle`: Build BFMCS_Bundle from any MCS using boxClassFamilies

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` - New section "BFMCS with Bundle Coherence"

**Structure definition**:
```lean
structure BFMCS_Bundle (D : Type*) [Preorder D] where
  families : Set (FMCS D)
  nonempty : families.Nonempty
  modal_forward : ∀ fam ∈ families, ∀ φ t, Formula.box φ ∈ fam.mcs t →
    ∀ fam' ∈ families, φ ∈ fam'.mcs t
  modal_backward : ∀ fam ∈ families, ∀ φ t,
    (∀ fam' ∈ families, φ ∈ fam'.mcs t) → Formula.box φ ∈ fam.mcs t
  bundle_forward_F : ∀ fam ∈ families, ∀ φ t, Formula.some_future φ ∈ fam.mcs t →
    ∃ fam' ∈ families, ∃ s > t, φ ∈ fam'.mcs s
  bundle_backward_P : ∀ fam ∈ families, ∀ φ t, Formula.some_past φ ∈ fam.mcs t →
    ∃ fam' ∈ families, ∃ s < t, φ ∈ fam'.mcs s
  eval_family : FMCS D
  eval_family_mem : eval_family ∈ families
```

**Verification**:
- `lake build Bimodal.Metalogic.Algebraic.UltrafilterChain`
- `construct_bfmcs_bundle` type-checks and returns BFMCS_Bundle Int
- `#print axioms construct_bfmcs_bundle` shows no `sorryAx`

---

### Phase 4: Prove Bundle Truth Lemma for F Operator [NOT STARTED]

**Goal**: Prove the truth lemma for F using bundle-level semantics.

**Tasks**:
- [ ] Define `bundle_truth` for BFMCS_Bundle: semantic truth evaluation with bundle quantification for F/P
- [ ] Prove `bundle_truth_lemma_atom`: atoms are true iff in MCS
- [ ] Prove `bundle_truth_lemma_neg`: negation flips truth
- [ ] Prove `bundle_truth_lemma_imp`: implication follows standard semantics
- [ ] Prove `bundle_truth_lemma_box`: Box uses modal_forward/backward (same as BFMCS)
- [ ] Prove `bundle_truth_lemma_F`: F(phi) is true iff exists fam' in bundle with phi true at some s > t
- [ ] Prove `bundle_truth_lemma_G`: G(phi) uses family-level forward_G (FMCS structure)
- [ ] Prove `bundle_truth_lemma`: combine all cases into main truth lemma

**Timing**: 4 hours

**Key insight for F operator**:
```lean
theorem bundle_truth_lemma_F (B : BFMCS_Bundle Int)
    (fam : FMCS Int) (hfam : fam ∈ B.families) (t : Int) (phi : Formula) :
    Formula.some_future phi ∈ fam.mcs t ↔
    ∃ fam' ∈ B.families, ∃ s > t, phi ∈ fam'.mcs s := by
  constructor
  · -- F(phi) in MCS implies witness exists (by bundle_forward_F)
    intro h_F
    exact B.bundle_forward_F fam hfam phi t h_F
  · -- Witness exists implies F(phi) in MCS (by MCS properties)
    intro ⟨fam', hfam', s, h_lt, h_phi⟩
    -- Need: phi at s > t in some family implies F(phi) at t in fam
    -- This uses: if not F(phi) at t, then G(neg phi) at t
    -- G(neg phi) propagates to all families at all times >= t
    -- So neg phi at s in fam', contradicting h_phi
    by_contra h_not_F
    have h_G_neg : Formula.all_future (Formula.neg phi) ∈ fam.mcs t := ...
    -- Use forward_G to propagate to fam'
    -- fam'.forward_G gives neg phi ∈ fam'.mcs s for s > t
    -- But phi ∈ fam'.mcs s, contradiction
```

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` - New section "Bundle Truth Lemma"

**Verification**:
- `lake build Bimodal.Metalogic.Algebraic.UltrafilterChain`
- `#print axioms bundle_truth_lemma` shows no `sorryAx`
- Verify each case with `lean_goal` before proceeding

---

### Phase 5: Wire to Completeness Theorems [NOT STARTED]

**Goal**: Connect bundle construction to completeness theorems and eliminate target sorries.

**Tasks**:
- [ ] Define `construct_bfmcs_bundle_from_consistent`: Given consistent Gamma, build BFMCS_Bundle with Gamma satisfied
- [ ] Prove `bundle_satisfies_consistent`: consistent formula is true in the bundle
- [ ] Update `dense_completeness_fc` to use bundle construction
- [ ] Update `discrete_completeness_fc` to use bundle construction
- [ ] Update `completeness_over_Int` to use bundle construction
- [ ] Add deprecation notice to old `construct_bfmcs` referencing new construction
- [ ] Update module docstring in Completeness.lean to reflect new status

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` - Add `construct_bfmcs_bundle_from_consistent`
- `Theories/Bimodal/FrameConditions/Completeness.lean` - Wire completeness theorems

**Completeness wiring pattern**:
```lean
theorem dense_completeness_fc {φ : Formula} :
    DenseCompletenessStatement φ := by
  intro h_valid
  -- Contrapositive: if not provable, then neg φ consistent
  by_contra h_not_prov
  have h_cons : SetConsistent {Formula.neg φ} := not_provable_implies_neg_consistent h_not_prov
  -- Build BFMCS_Bundle from neg φ
  have ⟨B, fam, hfam, t, h_neg⟩ := construct_bfmcs_bundle_from_consistent h_cons
  -- By truth lemma: neg φ is true at (fam, t)
  have h_true_neg : bundle_truth B fam t (Formula.neg φ) := bundle_truth_lemma ... h_neg
  -- By h_valid: φ is valid over Int, so φ true at (fam, t)
  have h_true_φ : bundle_truth B fam t φ := h_valid ... -- instantiate with bundle model
  -- Contradiction: both φ and neg φ true
  exact truth_neg_contradiction h_true_neg h_true_φ
```

**Verification**:
- `lake build Bimodal.FrameConditions.Completeness`
- `#print axioms dense_completeness_fc` shows no `sorryAx`
- `#print axioms discrete_completeness_fc` shows no `sorryAx`
- `#print axioms completeness_over_Int` shows no `sorryAx`
- Full `lake build` succeeds with no new warnings

## Testing & Validation

- [ ] `lake build` succeeds with no errors
- [ ] `#print axioms construct_bfmcs_bundle` shows only `Classical.choice` (no `sorryAx`)
- [ ] `#print axioms boxClassFamilies_bundle_forward_F` shows no `sorryAx`
- [ ] `#print axioms bundle_truth_lemma` shows no `sorryAx`
- [ ] `#print axioms dense_completeness_fc` shows no `sorryAx`
- [ ] `#print axioms discrete_completeness_fc` shows no `sorryAx`
- [ ] `#print axioms completeness_over_Int` shows no `sorryAx`
- [ ] All new theorems verified with `lean_verify`
- [ ] No regressions in existing sorry-free infrastructure

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` - Extended with bundle coherence predicates, proofs, BFMCS_Bundle, truth lemma
- `Theories/Bimodal/FrameConditions/Completeness.lean` - Updated to use bundle construction, sorries eliminated
- `specs/058_wire_completeness_to_frame_conditions/summaries/06_bundle-coherence-summary.md` - Execution summary (after completion)

## Rollback/Contingency

If implementation fails at any phase:

1. **Phase 1-2 blockers**: The bundle coherence predicates are straightforward definitions; if proofs fail, investigate whether `temporal_theory_witness_exists` properties are insufficient
2. **Phase 3 blockers**: BFMCS_Bundle is a simple structure; blockers likely indicate definition issues
3. **Phase 4 blockers**: Truth lemma is the critical gate; if it fails:
   - Check whether bundle semantics matches standard modal logic formulation
   - Consider whether family-level G/H propagation is sufficient
   - Fall back to documenting the mathematical gap
4. **Phase 5 blockers**: Integration issues; check API compatibility between bundle and completeness infrastructure

**Key lessons from prior attempts**:
- Do NOT attempt to fix family-level temporal coherence (sub-case (b) is mathematically blocked)
- Do NOT rely on `f_nesting_is_bounded` (mathematically false)
- DO verify each phase compiles before proceeding
- DO check `#print axioms` at each phase to catch sorry infection early
- DO use `lean_goal` extensively to catch proof gaps early

## Mathematical Justification

The bundle-level temporal coherence approach is mathematically sound because:

1. **Standard Kripke semantics**: In standard Kripke semantics, F(phi) is true at world w iff exists world w' with w R w' and phi true at w'. The "world w'" need not be in the same "chain" as w.

2. **Jonsson-Tarski technique**: The algebraic completeness proof via ultrafilters inherently uses a bundle structure where witnesses can come from any ultrafilter in the same equivalence class.

3. **Henkin models**: In Henkin-style completeness proofs, the canonical model is a bundle of chains (families), and temporal operators quantify across the bundle.

4. **Existential completeness**: Completeness only requires the EXISTENCE of a satisfying model, not that the model has any particular structure. A bundle model with bundle-level coherence is a valid model.

The key mathematical insight: requiring family-level coherence (F-witnesses in the same family) is STRONGER than necessary for completeness. Bundle-level coherence (F-witnesses in any family of the bundle) suffices.
