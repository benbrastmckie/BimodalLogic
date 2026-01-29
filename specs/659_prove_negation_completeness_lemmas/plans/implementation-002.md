# Implementation Plan: Task #659

**Task**: Prove negation completeness lemmas
**Version**: 002
**Created**: 2026-01-29
**Language**: lean
**Session**: sess_1769662734_4fa29c
**Previous Version**: implementation-001.md (BLOCKED - wrong assessment)

## Overview

This revised plan incorporates the key discovery from research-004.md: **forward_H Case 4 (both t, t' < 0) IS PROVABLE** using the symmetric H-persistence argument. The previous plan incorrectly assessed all `forward_H` cases as blocked.

**Key Insight**: The asymmetry in CoherentConstruction.lean is NOT between G and H operators, but between **construction order** and **information flow**. Coherence conditions are provable when the SOURCE MCS is built BEFORE the TARGET MCS.

**Revised Scope**:
- Phase 1: Prove `forward_H` Case 4 in CoherentConstruction.lean (NEW - UNBLOCKED!)
- Phase 2: Assess if this enables backward Truth Lemma cases
- Phase 3-4: Complete backward Truth Lemma if enabled

**Out of Scope** (documented limitations):
- `forward_H` Case 1 (both ≥ 0): Source built AFTER target - fundamentally hard
- `forward_H` Case 3 (cross-origin): Different chains - no persistence connection
- Box cases (lines 382, 405): Require semantic architecture changes

## Phases

### Phase 1: Prove forward_H Case 4 in CoherentConstruction.lean

**Estimated effort**: 1-2 hours
**Status**: [COMPLETED]

**Objective**: Replace the blanket sorry at line 681 with case analysis, proving Case 4 (both < 0).

**Why This Works** (from research-004.md):
```
forward_H: Hφ ∈ mcs(t') → φ ∈ mcs(t) where t < t' (both < 0)

Since t < t' < 0:
- t is farther from origin (e.g., t = -5)
- t' is closer to origin (e.g., t' = -2)
- In backward chain: mcs(t') is built BEFORE mcs(t)

This is EXACTLY symmetric to backward_G Case 1!
H-persistence brings Hφ to where it's needed.
```

**Files to modify**:
- `Theories/Bimodal/Metalogic/Representation/CoherentConstruction.lean` - Lines 677-681

**Steps**:

1. **Locate the forward_H sorry** (line 681)

2. **Replace with case analysis**:
   ```lean
   · intro h_lt φ hH
     unfold mcs_unified_chain at hH ⊢
     by_cases h_t_nonneg : 0 ≤ t <;> by_cases h_t'_nonneg : 0 ≤ t' <;>
       simp only [h_t_nonneg, h_t'_nonneg] at hH ⊢
     · -- Case 1: t ≥ 0 and t' ≥ 0 - H doesn't persist in forward chain
       -- NOT REQUIRED FOR COMPLETENESS - see Boneyard/Metalogic_v3/Coherence/CrossOriginCases.lean
       sorry
     · -- Case 2: t ≥ 0 and t' < 0: contradiction since t < t'
       simp only [not_le] at h_t'_nonneg
       have : t' < t := lt_of_lt_of_le h_t'_nonneg h_t_nonneg
       exact absurd h_lt (asymm this)
     · -- Case 3: t < 0 and t' ≥ 0: cross-origin
       -- NOT REQUIRED FOR COMPLETENESS - see Boneyard/Metalogic_v3/Coherence/CrossOriginCases.lean
       sorry
     · -- Case 4: Both t < 0 and t' < 0 - PROVABLE!
       simp only [not_le] at h_t_nonneg h_t'_nonneg
       -- Since t < t' < 0, we have |t| > |t'|, so (-t).toNat > (-t').toNat
       have h_nat_lt : (-t').toNat < (-t).toNat := by omega
       -- Since t < 0, we have (-t).toNat > 0
       have h_t_pos : 0 < (-t).toNat := by omega
       -- Let m = (-t).toNat - 1, so (-t).toNat = m + 1
       set m := (-t).toNat - 1 with hm_def
       have ht_eq : (-t).toNat = m + 1 := by omega
       have h_le : (-t').toNat ≤ m := by omega
       -- Hφ persists from (-t').toNat to m
       have hH_m := mcs_backward_chain_H_persistence Gamma h_mcs h_no_H_bot (-t').toNat m h_le φ hH
       -- Hφ ∈ mcs(m) → φ ∈ backward_seed(mcs(m)) → φ ∈ mcs(m+1)
       have h_in_seed : φ ∈ backward_seed (mcs_backward_chain Gamma h_mcs h_no_H_bot m) := hH_m
       have h_result := mcs_backward_chain_seed_containment Gamma h_mcs h_no_H_bot m h_in_seed
       -- Rewrite the goal using ht_eq
       rw [ht_eq]
       exact h_result
   ```

3. **Verify build**:
   ```bash
   lake build Bimodal.Metalogic.Representation.CoherentConstruction
   ```

**Verification**:
- [ ] `lake build` succeeds
- [ ] Case 4 is fully proven (no sorry in that branch)
- [ ] Cases 1, 2, 3 have appropriate documentation

---

### Phase 2: Assess Backward Truth Lemma Enablement

**Estimated effort**: 1 hour
**Status**: [NOT STARTED]

**Objective**: Determine if the proven `forward_H` Case 4 enables the backward Truth Lemma cases.

**Analysis**:

The backward Truth Lemma cases (lines 423, 441) use witness extraction:
- If `Hψ ∉ mcs(t)`, need to find `s < t` where `ψ ∉ mcs(s)`
- If `Gψ ∉ mcs(t)`, need to find `s > t` where `ψ ∉ mcs(s)`

**Key Question**: Does proving `forward_H` Case 4 give us witness extraction?

**Reasoning**:
- `forward_H` Case 4: `Hφ ∈ mcs(t') → φ ∈ mcs(t)` for t < t' < 0
- Contrapositive: `φ ∉ mcs(t) → Hφ ∉ mcs(t')` for t < t' < 0
- This is UNIVERSAL (for all t'), not EXISTENTIAL (exists some t')

**Assessment Steps**:

1. **Check if witness extraction follows**:
   - Can we prove: `Hψ ∉ mcs(t) → ∃ s < t. ψ ∉ mcs(s)`?
   - The contrapositive of forward_H is: `∀ t'. (t < t' ∧ t' < 0) → (φ ∉ mcs(t) → Hφ ∉ mcs(t'))`
   - This doesn't directly give witness extraction

2. **Alternative approach - semantic argument**:
   - If `Hψ ∉ mcs(t)` and `ψ ∈ mcs(s)` for all s ≤ t
   - By backward_H coherence (repeatedly): should imply Hψ ∈ mcs(t)
   - Contradiction → must have some s ≤ t where ψ ∉ mcs(s)

3. **Document findings for Phase 3**

**Decision Point**: If witness extraction is achievable, proceed to Phase 3. Otherwise, document as blocked.

---

### Phase 3: Complete Backward all_past Case (Conditional)

**Estimated effort**: 2-3 hours
**Status**: [NOT STARTED]
**Dependency**: Phase 2 assessment must show witness extraction is achievable

**Objective**: Fill the `sorry` at line 423 of TruthLemma.lean

**Files to modify**:
- `Theories/Bimodal/Metalogic/Representation/TruthLemma.lean` - Line 423

**Approach** (if Phase 2 succeeds):

```lean
· -- Backward: (∀ s ≤ t, truth_at s psi) → H psi ∈ mcs t
  intro h_all_past
  -- Contrapositive: assume H psi ∉ mcs t, derive contradiction
  by_contra h_not_H
  -- By negation completeness: ¬(Hψ) ∈ mcs(t)
  have h_neg_H := (set_mcs_negation_complete (family.is_mcs t) (Formula.all_past psi)).resolve_left h_not_H
  -- Need witness extraction: ∃ s ≤ t. ψ ∉ mcs(s)
  -- [Strategy depends on Phase 2 findings]
  -- ...
  -- Once we have witness s with ψ ∉ mcs(s):
  -- By negation completeness at s: ¬ψ ∈ mcs(s)
  -- By forward IH: truth_at s (¬ψ)
  -- But h_all_past gives truth_at s ψ
  -- Contradiction: truth_at s ψ ∧ truth_at s (¬ψ)
```

**Verification**:
- [ ] `lake build` succeeds
- [ ] No `sorry` at line 423
- [ ] Proof is complete

---

### Phase 4: Complete Backward all_future Case (Conditional)

**Estimated effort**: 1-2 hours
**Status**: [NOT STARTED]
**Dependency**: Phase 3 must succeed (symmetric proof)

**Objective**: Fill the `sorry` at line 441 of TruthLemma.lean

**Files to modify**:
- `Theories/Bimodal/Metalogic/Representation/TruthLemma.lean` - Line 441

**Approach**: Symmetric to Phase 3, using G instead of H.

**Verification**:
- [ ] `lake build` succeeds
- [ ] No `sorry` at line 441
- [ ] Proof is complete

---

### Phase 5: Update Documentation

**Estimated effort**: 0.5 hours
**Status**: [NOT STARTED]

**Objective**: Update documentation to reflect what was proven and what remains.

**Files to modify**:
- `Theories/Bimodal/Metalogic/Representation/CoherentConstruction.lean` - Update module docstring
- `Theories/Bimodal/Boneyard/Metalogic_v3/Coherence/CrossOriginCases.lean` - Update status

**Documentation Updates**:

1. **CoherentConstruction.lean header**: Add to the gaps table:
   ```
   | forward_H Case 4 | line 681 | PROVEN - uses H-persistence |
   ```

2. **CrossOriginCases.lean**: Note that forward_H Case 4 was proven

3. **TruthLemma.lean** (if Phases 3-4 succeed): Update header to note temporal backward cases complete

---

## Dependencies

- Task 654 (representation theorem) - provides IndexedMCSFamily structure
- Task 656 (truth lemma forward direction) - provides forward IH

## Risks and Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| forward_H Case 4 proof has unexpected complexity | Low | Research-004 provides detailed proof sketch |
| Witness extraction doesn't follow from forward_H | High | Phase 2 assesses this before investing in Phases 3-4 |
| Omega tactics fail on integer arithmetic | Low | Fall back to explicit Nat lemmas |

## Success Criteria

**Minimum Success** (Phase 1 only):
- [ ] `forward_H` Case 4 in CoherentConstruction.lean is proven
- [ ] Cases 1, 2, 3 have appropriate documentation
- [ ] `lake build` succeeds

**Full Success** (All Phases):
- [ ] All of the above
- [ ] `sorry` at line 423 (all_past backward) is eliminated
- [ ] `sorry` at line 441 (all_future backward) is eliminated
- [ ] Documentation updated

## Key Changes from v001

| Aspect | v001 | v002 |
|--------|------|------|
| `forward_H` assessment | All cases blocked | Case 4 is PROVABLE |
| Plan status | BLOCKED | ACTIONABLE |
| Phase 1 | Witness extraction (blocked) | Prove forward_H Case 4 |
| Phase 2 | Analysis (completed) | Assess enablement |
| Phases 3-4 | Blocked | Conditional on Phase 2 |

## Notes

### Why This Plan Works

The research-004.md discovery that forward_H Case 4 is provable changes the situation:

1. **Symmetric structure exists**: `mcs_backward_chain_H_persistence` mirrors `mcs_forward_chain_G_persistence`
2. **Construction order aligns**: For t < t' < 0, source (t') is built BEFORE target (t)
3. **H-formulas persist in backward chain**: Just like G-formulas persist in forward chain

### Remaining Architectural Limitations

These cases remain fundamentally blocked:
- `forward_H` Case 1 (both ≥ 0): H doesn't persist in forward chain
- `forward_H` Case 3 (cross-origin): No persistence connection between chains
- Box cases: Require semantic architecture changes

### Comparison to backward_G Proof

The proven `backward_G` Case 1 (lines 687-704) provides the template:
```lean
-- backward_G: Gφ ∈ mcs(t') → φ ∈ mcs(t) for t' < t (both ≥ 0)
have h_nat_lt : t'.toNat < t.toNat := by omega
have h_t_pos : 0 < t.toNat := by omega
set m := t.toNat - 1 with hm_def
have ht_eq : t.toNat = m + 1 := by omega
have h_le : t'.toNat ≤ m := by omega
have hG_m := mcs_forward_chain_G_persistence ... t'.toNat m h_le φ hG
have h_in_seed : φ ∈ forward_seed (...) := hG_m
have h_result := mcs_forward_chain_seed_containment ... m h_in_seed
rw [ht_eq]
exact h_result
```

The forward_H Case 4 proof is exactly symmetric, using backward chain and H-persistence.
