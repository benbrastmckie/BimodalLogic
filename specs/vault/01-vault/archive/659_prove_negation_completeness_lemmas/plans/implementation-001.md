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
**Status**: [BLOCKED]

**Block Reason**: Witness extraction requires semantic bridge properties not available in current architecture.

**Analysis Findings**:
The witness extraction lemmas require proving: if `some_past (¬ψ) ∈ mcs(t)`, then `∃ s < t. (¬ψ) ∈ mcs(s)`.
This is an **existential witness** property that does not follow from the current coherence conditions.

The current `IndexedMCSFamily` coherence conditions provide **universal propagation**:
- `forward_G`: `G φ ∈ mcs(t) → φ ∈ mcs(t')` for `t < t'`
- `backward_H`: `H φ ∈ mcs(t) → φ ∈ mcs(t')` for `t' < t`

But NOT existential witness extraction:
- Need: `some_past φ ∈ mcs(t) → ∃ s < t. φ ∈ mcs(s)`

The `forward_H` property in CoherentConstruction.lean (line 681) that would help has a sorry.

**Options Identified**:
1. **Option A**: Add `witness_past` coherence to IndexedMCSFamily (major architecture change)
2. **Option B**: Prove from construction properties (requires proving forward_H first)
3. **Option C**: Leave as sorry (documented as not required for completeness)

**Recommendation**: Defer to a future architecture task. The backward Truth Lemma is explicitly documented as NOT REQUIRED for the representation theorem or completeness proof.

---

### Phase 2: Proof Analysis - Determine if Additional Coherence is Needed

**Estimated effort**: 1-2 hours (already completed inline with Phase 1)
**Status**: [COMPLETED]

**Findings**:
1. **CoherentConstruction.lean analysis**: The construction has a sorry at `forward_H` (line 681). This means "looking back from the future" is not proven.

2. **Negation + coherence analysis**:
   - Given: `H ψ ∉ mcs t` → `¬(H ψ) ∈ mcs t` by negation completeness
   - `¬(H ψ) = some_past (¬ψ)` by temporal De Morgan
   - But extracting witness from `some_past (¬ψ) ∈ mcs t` requires the semantic bridge

3. **Temporal K axiom approach**: `H (ψ → χ) → (H ψ → H χ)` gives distribution, not witness

**Decision**: The task requires architecture changes beyond the current scope.
- The backward Truth Lemma cases are NOT required for completeness
- Pursuing them would require proving `forward_H` in CoherentConstruction.lean first
- This is documented in Boneyard/Metalogic_v3/TruthLemma/BackwardDirection.lean

**Verification**:
- [x] Clear determination: Need architectural changes to prove
- [x] Documented reasoning in analysis above

---

### Phase 3: Complete Backward all_past Case

**Estimated effort**: 1-2 hours
**Status**: [BLOCKED]

**Block Reason**: Depends on Phase 1 witness extraction lemmas which require architecture changes.

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
**Status**: [BLOCKED]

**Block Reason**: Depends on Phase 1 witness extraction lemmas which require architecture changes.

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
**Status**: [BLOCKED]

**Block Reason**: Depends on completion of Phases 3-4.

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

## Implementation Status: BLOCKED

**Reason**: The backward Truth Lemma cases require witness extraction from temporal "sometime" formulas,
which depends on the `forward_H` coherence property that has a sorry in CoherentConstruction.lean.

**Prerequisites for Unblocking**:
1. Prove `forward_H` in `CoherentConstruction.lean` (line 681)
2. Or add explicit `witness_past` and `witness_future` properties to `IndexedMCSFamily`

**Alternative**: Accept that backward Truth Lemma is not required for completeness (current state).

## Success Criteria (DEFERRED)

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
