# Implementation Plan: Task #659

**Task**: Prove negation completeness lemmas
**Version**: 001
**Created**: 2026-01-29
**Language**: lean
**Session**: sess_1738127234_0ddfe6

## Overview

This plan addresses the two tractable backward direction cases in the truth lemma: `all_past` (line 423) and `all_future` (line 441) in TruthLemma.lean. The box cases (lines 382, 405) are deferred to a separate architectural task due to fundamental semantic limitations.

**Approach**: Use contrapositive proofs combined with witness extraction from the indexed family coherence conditions. The key insight is that if `Hψ ∉ mcs(t)`, then by negation completeness `¬(Hψ) ∈ mcs(t)`, and by contrapositive of the "forward_H" coherence condition, there must exist some `s < t` where `ψ ∉ mcs(s)`.

**Scope Boundaries**:
- IN SCOPE: Lines 423, 441 (temporal backward cases)
- OUT OF SCOPE: Lines 382, 405 (box cases - require semantic architecture changes)

## Phases

### Phase 1: Witness Extraction Lemmas

**Estimated effort**: 2-3 hours
**Status**: [NOT STARTED]

**Objectives**:
1. Prove witness extraction lemma for `all_past` negation
2. Prove witness extraction lemma for `all_future` negation

**Files to modify**:
- `Theories/Bimodal/Metalogic/Representation/IndexedMCSFamily.lean` - Add witness extraction lemmas

**Steps**:

1. **Add `neg_H_implies_witness` lemma**:
   ```lean
   /--
   Witness extraction for negated all_past: If H ψ is not in the MCS at time t,
   then there exists some time s < t where ψ is not in the MCS.

   **Proof Strategy**: Contrapositive of universal property.
   If ψ ∈ mcs(s) for all s < t, then by forward_H coherence looking back from any future time,
   combined with MCS closure properties, we can construct H ψ ∈ mcs(t).

   This uses the classical fact that if ψ holds at all past times and at t (by T-axiom),
   then H ψ must hold at t.
   -/
   lemma neg_H_implies_witness (family : IndexedMCSFamily D) (t : D) (ψ : Formula)
       (h : Formula.all_past ψ ∉ family.mcs t) : ∃ s, s < t ∧ ψ ∉ family.mcs s := by
     -- Contrapositive: assume ∀ s < t, ψ ∈ mcs s
     by_contra h_all
     push_neg at h_all
     -- Need to show: H ψ ∈ mcs t
     -- Strategy: Use the fact that if ψ holds at all s ≤ t, then H ψ ∈ mcs t
     -- This requires the indexed family construction's "coherent extension" property
     sorry
   ```

2. **Add `neg_G_implies_witness` lemma** (symmetric):
   ```lean
   /--
   Witness extraction for negated all_future: If G ψ is not in the MCS at time t,
   then there exists some time s > t where ψ is not in the MCS.
   -/
   lemma neg_G_implies_witness (family : IndexedMCSFamily D) (t : D) (ψ : Formula)
       (h : Formula.all_future ψ ∉ family.mcs t) : ∃ s, t < s ∧ ψ ∉ family.mcs s := by
     by_contra h_all
     push_neg at h_all
     sorry
   ```

3. **Investigate coherent construction properties**:
   - Read `CoherentConstruction.lean` for additional properties that might help
   - The key challenge: proving `∀ s < t, ψ ∈ mcs s` implies `H ψ ∈ mcs t`
   - This is essentially the converse of backward_H coherence

**Key Insight**: The witness extraction may require an additional property of the indexed family:
```lean
-- "Completeness" of temporal operators in the family
-- If ψ ∈ mcs(s) for all s < t, then H ψ ∈ mcs(t)
coherent_H : ∀ t ψ, (∀ s, s < t → ψ ∈ mcs s) → (∀ s, s ≤ t → ψ ∈ mcs s) → Formula.all_past ψ ∈ mcs t
```

If this property doesn't exist, we may need to:
- Add it as a hypothesis to the witness extraction lemmas
- Or derive it from existing coherence conditions

**Verification**:
- [ ] `lake build` succeeds with no new errors
- [ ] Lemma types match the required signatures
- [ ] Proof compiles (even if with sorry initially)

---

### Phase 2: Proof Analysis - Determine if Additional Coherence is Needed

**Estimated effort**: 1-2 hours
**Status**: [NOT STARTED]

**Objectives**:
1. Determine if existing coherence conditions suffice for witness extraction
2. If not, identify the minimal additional property needed

**Files to analyze**:
- `Theories/Bimodal/Metalogic/Representation/CoherentConstruction.lean`
- `Theories/Bimodal/Metalogic/Representation/IndexedMCSFamily.lean`

**Steps**:

1. **Analyze CoherentConstruction.lean**:
   - Check if the construction provides the "completeness" property
   - The construction builds MCS at each time from seeds + Lindenbaum extension
   - Question: Does the construction ensure `∀ s < t, ψ ∈ mcs s` → `H ψ ∈ mcs t`?

2. **Check if negation + coherence suffices**:
   - Given: `H ψ ∉ mcs t` (by assumption)
   - By negation completeness: `¬(H ψ) ∈ mcs t`
   - The key question: Does `¬(H ψ) ∈ mcs t` give us a witness?

3. **Alternative approach - use temporal K axiom**:
   - `H (ψ → χ) → (H ψ → H χ)` (temporal K distribution)
   - Combined with negation completeness, this might give witness

**Decision Point**: Based on analysis, choose one of:
- A: Existing coherence conditions suffice (proceed to Phase 3)
- B: Need to add coherence property to IndexedMCSFamily (add Phase 2b)
- C: Use derivation-based approach with temporal axioms (modify Phase 1)

**Verification**:
- [ ] Clear determination of which approach to use
- [ ] Documented reasoning in code comments

---

### Phase 3: Complete Backward all_past Case

**Estimated effort**: 1-2 hours
**Status**: [NOT STARTED]

**Objectives**:
1. Fill the `sorry` at line 423 of TruthLemma.lean
2. Use contrapositive + witness extraction + forward IH

**Files to modify**:
- `Theories/Bimodal/Metalogic/Representation/TruthLemma.lean` - Line 423

**Steps**:

1. **Replace the sorry with contrapositive proof**:
   ```lean
   · -- Backward: (∀ s ≤ t, truth_at s psi) → H psi ∈ mcs t
     intro h_all_past
     -- Contrapositive: assume H psi ∉ mcs t, derive contradiction
     by_contra h_not_H
     -- By witness extraction: ∃ s < t, psi ∉ mcs s
     obtain ⟨s, hs_lt, h_psi_not⟩ := neg_H_implies_witness family t psi h_not_H
     -- By negation completeness at s: ¬psi ∈ mcs s
     have h_neg_psi : Formula.neg psi ∈ family.mcs s := by
       cases set_mcs_negation_complete (family.is_mcs s) psi with
       | inl h => exact absurd h h_psi_not
       | inr h => exact h
     -- Apply forward IH at s to get truth_at s (¬psi)
     have h_neg_truth : truth_at ... s (Formula.neg psi) := (ih s).mp h_neg_psi
     -- This contradicts h_all_past at s (need s ≤ t, have s < t)
     have hs_le : s ≤ t := le_of_lt hs_lt
     -- h_all_past gives truth_at s psi, but we have truth_at s (¬psi)
     -- Need to derive contradiction from truth_at s psi ∧ truth_at s (¬psi)
     sorry -- Final contradiction step
   ```

2. **Handle the truth_at contradiction**:
   - Need to show `truth_at s psi ∧ truth_at s (neg psi) → False`
   - This follows from the semantics: `neg psi = psi → bot`
   - `truth_at (psi → bot)` means `truth_at psi → truth_at bot`
   - `truth_at bot = False`
   - So `truth_at psi` and `truth_at (psi → bot)` is contradictory

**Verification**:
- [ ] `lake build` succeeds
- [ ] No `sorry` remains at line 423
- [ ] Proof is complete and compiles

---

### Phase 4: Complete Backward all_future Case

**Estimated effort**: 1 hour
**Status**: [NOT STARTED]

**Objectives**:
1. Fill the `sorry` at line 441 of TruthLemma.lean
2. Use symmetric proof to all_past case

**Files to modify**:
- `Theories/Bimodal/Metalogic/Representation/TruthLemma.lean` - Line 441

**Steps**:

1. **Apply symmetric proof structure**:
   ```lean
   · -- Backward: (∀ s ≥ t, truth_at s psi) → G psi ∈ mcs t
     intro h_all_future
     by_contra h_not_G
     obtain ⟨s, hs_gt, h_psi_not⟩ := neg_G_implies_witness family t psi h_not_G
     have h_neg_psi : Formula.neg psi ∈ family.mcs s := by
       cases set_mcs_negation_complete (family.is_mcs s) psi with
       | inl h => exact absurd h h_psi_not
       | inr h => exact h
     have h_neg_truth : truth_at ... s (Formula.neg psi) := (ih s).mp h_neg_psi
     have hs_ge : t ≤ s := le_of_lt hs_gt
     -- Derive contradiction
     sorry
   ```

2. **Complete the contradiction derivation** (same as Phase 3)

**Verification**:
- [ ] `lake build` succeeds
- [ ] No `sorry` remains at line 441
- [ ] Proof is complete and compiles

---

### Phase 5: Final Verification and Documentation

**Estimated effort**: 0.5 hours
**Status**: [NOT STARTED]

**Objectives**:
1. Verify all changes build successfully
2. Update documentation
3. Document remaining box case limitations

**Files to modify**:
- `Theories/Bimodal/Metalogic/Representation/TruthLemma.lean` - Update comments

**Steps**:

1. **Run full build**:
   ```bash
   lake build
   ```

2. **Update TruthLemma.lean header documentation**:
   - Note that temporal backward cases are now complete
   - Document that box cases remain as architectural limitation

3. **Update BackwardDirection.lean in Boneyard**:
   - Mark temporal cases as RESOLVED
   - Keep box case documentation for future reference

**Verification**:
- [ ] `lake build` succeeds with no errors
- [ ] All temporal backward cases complete (no sorry at lines 423, 441)
- [ ] Box cases documented as out of scope

---

## Dependencies

- Task 654 (representation theorem) - provides IndexedMCSFamily structure
- Task 656 (truth lemma forward direction) - provides forward IH

## Risks and Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Witness extraction requires additional coherence property | Medium | Phase 2 analyzes this; may need to add property to IndexedMCSFamily |
| Existing coherence conditions are insufficient | High | Fall back to derivation-based approach using temporal K axiom |
| Truth contradiction step is more complex than expected | Low | Truth semantics are well-defined; may need helper lemma |
| CoherentConstruction doesn't provide needed property | Medium | May need to strengthen the construction or add hypothesis |

## Success Criteria

- [ ] `sorry` at line 423 (all_past backward) is eliminated
- [ ] `sorry` at line 441 (all_future backward) is eliminated
- [ ] `lake build` succeeds with no new errors
- [ ] Witness extraction lemmas are proven (possibly with additional hypothesis)
- [ ] Box cases remain documented as architectural limitation (explicitly out of scope)

## Notes

### Why Box Cases Are Deferred

The box cases (lines 382, 405) require showing that `ψ` is true at time `t` for ALL world histories `σ`, not just the canonical history. This is impossible with current architecture because:

1. Truth depends on world state via valuation
2. Canonical model defines `valuation w p = (atom p) ∈ w.mcs`
3. Arbitrary histories can assign ANY world state to time t
4. The IH only applies to the canonical history

Resolution requires semantic architecture changes (Kripke-style accessibility, canonical history restriction, or modal accessibility predicate).

### Coherence Condition Intuition

- `forward_G`: If `G ψ ∈ mcs(t)`, then for any `t' > t`, `ψ ∈ mcs(t')` (propagation forward)
- `backward_H`: If `H ψ ∈ mcs(t)`, then for any `t' < t`, `ψ ∈ mcs(t')` (propagation backward)
- `forward_H`: If `H ψ ∈ mcs(t')` and `t < t'`, then `ψ ∈ mcs(t)` (looking back from future)
- `backward_G`: If `G ψ ∈ mcs(t')` and `t' < t`, then `ψ ∈ mcs(t)` (looking forward from past)

The witness extraction uses the contrapositive of these: if temporal operator is NOT in MCS, then some witness must exist where the formula fails.
