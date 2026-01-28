# Implementation Plan: Task #681 (Revised v5)

- **Task**: 681 - Redesign construct_indexed_family with coherent approach
- **Version**: 005 (Plug remaining gaps based on research-003.md)
- **Status**: [NOT STARTED]
- **Priority**: Medium
- **Dependencies**: None (unblocks Task 658)
- **Previous Plan**: plans/implementation-004.md (partial progress)
- **Previous Summary**: summaries/implementation-summary-20260128-v3.md
- **Research Source**: reports/research-003.md
- **Type**: lean
- **Lean Intent**: true

## Executive Summary

This plan addresses the 10 remaining sorries in CoherentConstruction.lean based on the analysis in research-003.md. The key insight from research is:

1. **The completeness theorem only needs the forward direction of the Truth Lemma**
2. **The forward direction uses forward_G Case 1 (both ≥ 0) and backward_H Case 4 (both < 0)**
3. **Both of these cases are ALREADY PROVEN**

Therefore, the remaining 10 sorries represent gaps in the *backward direction* of the Truth Lemma and cross-modal/cross-origin cases that are **not required for basic completeness**. The recommended approach (from research-003.md) is **Approach A: Accept Boneyard-matching gaps**.

However, this plan also provides a **hybrid strategy**: prove what is reasonably provable (seed consistency, plain formula propagation) and document the rest as Boneyard-matching theoretical limitations.

## Current Sorry Inventory (10 total)

| # | Line | Location | Type | Provable? |
|---|------|----------|------|-----------|
| 1 | 380 | `mcs_forward_chain` | Seed consistency (G⊥ absence) | Maybe (T-axiom + induction) |
| 2 | 393 | `mcs_backward_chain` | Seed consistency (H⊥ absence) | Maybe (symmetric) |
| 3 | 641 | forward_G Case 3 | Cross-origin (t < 0, t' ≥ 0) | Hard (needs bridge) |
| 4 | 654 | forward_G Case 4 | G toward origin in backward chain | Hard (cross-modal) |
| 5 | 662 | backward_H Case 1 | H through forward chain | Hard (cross-modal) |
| 6 | 665 | backward_H Case 2 | Cross-origin (t ≥ 0, t' < 0) | Hard (needs bridge) |
| 7 | 691 | forward_H | All cases | Hard (backward propagation) |
| 8 | 721 | backward_G Case 3 | Cross-origin | Hard (needs bridge) |
| 9 | 724 | backward_G Case 4 | G through backward chain | Hard (cross-modal) |

### Classification

**Potentially Provable (2 sorries)**:
- Sorries 1-2: Seed consistency via T-axiom reasoning

**Fundamentally Hard (8 sorries)**:
- Cross-origin (3, 6, 8): Require bridging backward and forward chains
- Cross-modal (4, 5, 9): Require G through H-preserving chain or vice versa
- Backward propagation (7): Forward chain only guarantees forward propagation

## Implementation Phases

### Phase 1: Document Sufficient Infrastructure [2 hours]

**Goal**: Add explicit documentation that the current state is sufficient for completeness.

**File**: `Theories/Bimodal/Metalogic/Representation/CoherentConstruction.lean`

**Tasks**:
- [ ] Add section header explaining which cases are proven and why they suffice
- [ ] Document each remaining sorry with:
  - Why it's architecturally hard
  - What it would enable (backward Truth Lemma, not needed for completeness)
  - Boneyard reference if applicable

**Documentation Template**:
```lean
/-!
## Proven Cases (Sufficient for Completeness)

The completeness theorem requires the **forward direction** of the Truth Lemma:
  `φ ∈ MCS → truth_at φ`

This uses two coherence conditions:
- `forward_G` for `all_future` formulas (TruthLemma.lean:417)
- `backward_H` for `all_past` formulas (TruthLemma.lean:396)

**Proven cases**:
- forward_G Case 1: Both t, t' ≥ 0 ✅ (via mcs_forward_chain_coherent)
- backward_H Case 4: Both t, t' < 0 ✅ (via mcs_backward_chain_coherent)

These are exactly the cases the Truth Lemma's forward direction uses.

## Remaining Gaps (Not Required for Completeness)

The remaining sorries would complete the backward direction of the Truth Lemma
(`truth_at → φ ∈ MCS`), which enables:
- Soundness of the canonical model
- Frame correspondence theorems
- Tightness of the canonical model

These are Boneyard-matching gaps (lines 2412-2415, 2507).
-/
```

**Verification**: Build succeeds, documentation is clear.

---

### Phase 2: Attempt Seed Consistency [3 hours]

**Goal**: Try to close sorries 1-2 (lines 380, 393) using T-axiom + induction.

**File**: `Theories/Bimodal/Metalogic/Representation/CoherentConstruction.lean`

**Strategy**: The G⊥ (and H⊥) absence can potentially be proven inductively using:
1. Base case: G⊥ ∉ Gamma (given hypothesis h_no_G_bot)
2. Inductive step: G⊥ ∉ mcs(n) → G⊥ ∉ mcs(n+1)

The inductive step argument:
- mcs(n+1) = extendToMCS(forward_seed(mcs(n)))
- If G⊥ ∈ mcs(n+1), either:
  - G⊥ ∈ forward_seed(mcs(n)): Means GG⊥ ∈ mcs(n), which implies G⊥ ∈ mcs(n) by T-axiom. Contradiction with IH.
  - G⊥ derivable from forward_seed: Needs careful analysis of closure under derivation.

**Tasks**:
- [ ] Investigate `extendToMCS` to understand what formulas end up in the result
- [ ] Define helper `forward_chain_no_G_bot`:
  ```lean
  lemma forward_chain_no_G_bot (Gamma : Set Formula) (h_mcs : SetMaximalConsistent Gamma)
      (h_no_G_bot : Formula.all_future Formula.bot ∉ Gamma) (n : ℕ) :
      Formula.all_future Formula.bot ∉ mcs_forward_chain Gamma h_mcs h_no_G_bot n := by
    induction n with
    | zero => exact h_no_G_bot
    | succ n ih =>
      -- If G⊥ ∈ mcs(n+1) = extendToMCS(forward_seed(mcs(n)))
      intro h_G_bot_in
      -- Case 1: G⊥ ∈ forward_seed(mcs(n)) means GG⊥ ∈ mcs(n)
      -- Case 2: G⊥ derivable from forward_seed
      -- Either way, contradicts ih using T-axiom and G-4
      sorry -- If full proof too complex, document as Boneyard match
  ```
- [ ] Apply same pattern for backward chain with H⊥
- [ ] If proofs complete: use them in mcs_forward_chain and mcs_backward_chain
- [ ] If not: document as Boneyard-matching gap with clear explanation

**Note**: This is exploratory. If the `extendToMCS` internals make this too complex, accept the gap.

**Verification**:
- If proven: sorries at lines 380, 393 eliminated
- If not proven: clear documentation added

---

### Phase 3: Create Sufficiency Wrapper [1 hour]

**Goal**: Create explicit types/theorems showing the proven cases suffice for completeness.

**File**: `Theories/Bimodal/Metalogic/Representation/CoherentConstruction.lean`

**Tasks**:
- [ ] Define a predicate for "sufficient coherence":
  ```lean
  /-- A family has sufficient coherence for the completeness theorem if it satisfies
      forward_G for non-negative times and backward_H for negative times. -/
  structure CompletenessCoherent (family : ℤ → Set Formula) : Prop where
    forward_G_nonneg : ∀ t t' : ℤ, 0 ≤ t → 0 ≤ t' → t < t' →
      ∀ φ, Formula.all_future φ ∈ family t → φ ∈ family t'
    backward_H_neg : ∀ t t' : ℤ, t < 0 → t' < 0 → t' < t →
      ∀ φ, Formula.all_past φ ∈ family t → φ ∈ family t'
  ```

- [ ] Prove the unified chain satisfies this:
  ```lean
  theorem mcs_unified_chain_completeness_coherent
      (Gamma : Set Formula) (h_mcs : SetMaximalConsistent Gamma)
      (h_no_G_bot : Formula.all_future Formula.bot ∉ Gamma)
      (h_no_H_bot : Formula.all_past Formula.bot ∉ Gamma) :
      CompletenessCoherent (mcs_unified_chain Gamma h_mcs h_no_G_bot h_no_H_bot) := by
    constructor
    · -- forward_G for non-negative times: proven in Case 1
      intro t t' ht ht' hlt φ hG
      exact mcs_forward_chain_coherent Gamma h_mcs h_no_G_bot t.toNat t'.toNat
        (by omega : t.toNat < t'.toNat) φ (by simp [mcs_unified_chain, ht]; exact hG)
    · -- backward_H for negative times: proven in Case 4
      intro t t' ht ht' hlt φ hH
      exact mcs_backward_chain_coherent Gamma h_mcs h_no_H_bot (-t).toNat (-t').toNat
        (by omega : (-t).toNat < (-t').toNat) φ (by simp [mcs_unified_chain, ht]; exact hH)
  ```

**Verification**: `CompletenessCoherent` is proven without sorries.

---

### Phase 4: Update IndexedMCSFamily Integration [1 hour]

**Goal**: Ensure Task 658 can use the coherent construction with documented limitations.

**File**: `Theories/Bimodal/Metalogic/Representation/IndexedMCSFamily.lean`

**Tasks**:
- [ ] Review where `construct_indexed_family` uses coherence conditions
- [ ] Add documentation about which sorries propagate vs which are self-contained
- [ ] Verify that the completeness path (representation theorem → truth lemma → coherence) uses only proven cases

**Verification**: Clear path from coherent construction to completeness without hitting unprovable sorries.

---

### Phase 5: Final Documentation and Summary [1 hour]

**Goal**: Create comprehensive summary documenting the resolution.

**File**: `specs/681_redesign_construct_indexed_family_coherent_approach/summaries/implementation-summary-20260128-v4.md`

**Tasks**:
- [ ] Document all changes made
- [ ] List which sorries were closed vs documented as Boneyard gaps
- [ ] Explain sufficiency for completeness theorem
- [ ] Provide roadmap for future work (if anyone wants to close remaining gaps)

**Summary Structure**:
```markdown
# Implementation Summary: Task #681 (v4)

## Resolution Strategy

Based on research-003.md, we adopted a hybrid approach:
1. Document that current proofs are sufficient for completeness
2. Attempt seed consistency proofs where feasible
3. Accept remaining gaps as Boneyard-matching limitations

## What's Proven (Sufficient for Completeness)

| Case | Status | Used By |
|------|--------|---------|
| forward_G (both ≥ 0) | ✅ Proven | Truth Lemma forward direction |
| backward_H (both < 0) | ✅ Proven | Truth Lemma forward direction |

## What Remains (Not Needed for Completeness)

| Gap Type | Count | Blocks |
|----------|-------|--------|
| Cross-origin | 3 | Backward Truth Lemma |
| Cross-modal | 3 | Backward Truth Lemma |
| Seed consistency | 2 | More complete proofs |
| Backward propagation | 1 | forward_H condition |

These match Boneyard gaps at lines 2412-2415, 2507.

## Completeness Path

Representation Theorem → Truth Lemma (forward) → forward_G Case 1 ✅ → Completeness
                                              → backward_H Case 4 ✅ → Completeness
```

**Verification**: Summary is complete and accurate.

---

## Risk Analysis

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Seed consistency unprovable | Low | Medium | Document as Boneyard gap |
| extendToMCS internals opaque | Medium | Medium | Accept gap with explanation |
| Integration issues with Task 658 | Medium | Low | Verify completeness path |

## Success Criteria

- [ ] Clear documentation that proven cases suffice for completeness
- [ ] Each sorry has explicit documentation of why it's hard
- [ ] `CompletenessCoherent` predicate proven without sorries
- [ ] Lake build succeeds
- [ ] Task 658 can proceed with documented limitations

## Time Estimate

| Phase | Hours |
|-------|-------|
| Phase 1: Documentation | 2 |
| Phase 2: Seed consistency attempt | 3 |
| Phase 3: Sufficiency wrapper | 1 |
| Phase 4: Integration | 1 |
| Phase 5: Summary | 1 |
| **Total** | **8 hours** |

## References

- research-003.md: Methods for eliminating gaps, explains sufficiency
- Boneyard gaps: lines 2412-2415 (cross-modal), 2507 (seed consistency)
- TruthLemma.lean: lines 396 (backward_H), 417 (forward_G)
- UniversalCanonicalModel.lean: lines 86-87 (uses truth_lemma_forward only)
