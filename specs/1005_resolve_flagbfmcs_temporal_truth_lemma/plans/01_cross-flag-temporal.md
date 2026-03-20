# Implementation Plan: Task #1005

- **Task**: 1005 - resolve_flagbfmcs_temporal_truth_lemma
- **Status**: [NOT STARTED]
- **Effort**: 3 hours
- **Dependencies**: None (task 1003 infrastructure already in place)
- **Research Inputs**: specs/1005_resolve_flagbfmcs_temporal_truth_lemma/reports/01_temporal-truth-resolution.md
- **Artifacts**: plans/01_cross-flag-temporal.md (this file)
- **Standards**:
  - .claude/context/core/standards/plan.md
  - .claude/context/core/standards/status-markers.md
  - .claude/context/core/system/artifact-management.md
  - .claude/context/core/standards/tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Resolve the 2 remaining sorries in `FlagBFMCSTruthLemma.lean` by implementing Path B from research: **Cross-Flag Temporal Satisfaction Relation**. The current `satisfies_at` definition quantifies temporal operators (G/H) within the same Flag, but F/P witnesses from `canonicalMCS_forward_F` may exist in different Flags. The fix is to redefine temporal satisfaction to quantify across all Flags in `B.flags`, aligning with standard bundle semantics where temporal accessibility relates positions across different histories.

### Research Integration

Key findings from the research report:
1. **Root Cause**: The contrapositive argument fails because `chainFMCS_forward_F_in_CanonicalMCS` provides a witness in CanonicalMCS, not necessarily in the same Flag
2. **Solution**: Modify `satisfies_at` for `.all_future` and `.all_past` to quantify `F' : Flag CanonicalMCS` across `B.flags`
3. **Infrastructure**: Existing lemmas (`canonicalMCS_forward_F`, `canonicalMCS_in_some_flag`, `g_content`, `CanonicalR`) provide all necessary building blocks
4. **New Required**: `g_content_propagation` and `h_content_propagation` lemmas (trivial from definitions)

## Goals & Non-Goals

**Goals**:
- Remove both sorries in `mem_of_satisfies_at_all_future` and `mem_of_satisfies_at_all_past`
- Modify `satisfies_at` definition for temporal operators to use cross-Flag quantification
- Update all theorem statements and proofs to match new definition
- Maintain compatibility with existing Box case proofs (already cross-Flag)

**Non-Goals**:
- Modifying the FlagBFMCS structure itself (no changes to FlagBFMCS.lean)
- Adding temporal saturation requirements (modal saturation suffices)
- Changing the CanonicalR/g_content infrastructure

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Induction hypothesis shape change | M | L | The IH already generalizes over Flags for Box; same pattern applies |
| Backward direction proof complexity | M | M | Use `g_content_propagation` lemma to bridge; proof follows from CanonicalR definition |
| Type unification issues with cross-Flag quantification | L | L | Follow existing Box case pattern which already handles cross-Flag |

## Implementation Phases

### Phase 1: Add Supporting Lemmas [NOT STARTED]

**Goal**: Add `g_content_propagation` and `h_content_propagation` lemmas that bridge temporal accessibility to formula propagation

**Tasks**:
- [ ] Add `g_content_propagation` lemma: `G(phi) in M.world + M < M' -> phi in M'.world`
- [ ] Add `h_content_propagation` lemma: `H(phi) in M.world + M' < M -> phi in M'.world`
- [ ] Verify lemmas compile with `lake build`

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/FlagBFMCSTruthLemma.lean` - Add lemmas before `satisfies_at` definition

**Verification**:
- Both lemmas compile without sorry
- Lemmas use only existing `CanonicalR` and `canonical_forward_G`/`canonical_backward_H`

**Proof Sketch**:
```lean
theorem g_content_propagation (M M' : CanonicalMCS) (φ : Formula)
    (h_G : φ.all_future ∈ M.world) (h_R : M < M') : φ ∈ M'.world := by
  -- M < M' means CanonicalR M.world M'.world (from Preorder definition)
  -- CanonicalR M.world M'.world means g_content M.world ⊆ M'.world
  -- G(φ) ∈ M.world means φ ∈ g_content M.world
  -- Therefore φ ∈ M'.world
  have h_lt : CanonicalR M.world M'.world := lt_to_canonicalR h_R
  exact canonical_forward_G M.world M'.world h_lt φ h_G
```

---

### Phase 2: Modify satisfies_at Definition [NOT STARTED]

**Goal**: Change temporal operator cases to quantify across all Flags in B.flags

**Tasks**:
- [ ] Modify `.all_future` case to quantify over `F' : Flag CanonicalMCS` and `hF' : F' ∈ B.flags`
- [ ] Modify `.all_past` case similarly
- [ ] Keep atom, bot, imp, box cases unchanged (box already cross-Flag)

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/FlagBFMCSTruthLemma.lean` - Lines 56-65 (`satisfies_at` definition)

**Current Definition** (lines 64-65):
```lean
| .all_future φ => ∀ (x' : ChainFMCSDomain F), x < x' → satisfies_at B F hF x' φ
| .all_past φ => ∀ (x' : ChainFMCSDomain F), x' < x → satisfies_at B F hF x' φ
```

**New Definition**:
```lean
| .all_future φ => ∀ (F' : Flag CanonicalMCS) (hF' : F' ∈ B.flags)
    (x' : ChainFMCSDomain F'), x.val < x'.val → satisfies_at B F' hF' x' φ
| .all_past φ => ∀ (F' : Flag CanonicalMCS) (hF' : F' ∈ B.flags)
    (x' : ChainFMCSDomain F'), x'.val < x.val → satisfies_at B F' hF' x' φ
```

**Verification**:
- Definition compiles (syntax check)
- Note: Existing proofs will break temporarily; fixed in Phase 3-4

---

### Phase 3: Update Backward Direction Proofs [NOT STARTED]

**Goal**: Fix `satisfies_at_all_future_of_mem` and `satisfies_at_all_past_of_mem` for new definition

**Tasks**:
- [ ] Update `satisfies_at_all_future_of_mem` to quantify over `F'`, `hF'`, `x'`
- [ ] Use `g_content_propagation` to bridge from `G(phi) in x.val.world` to `phi in x'.val.world`
- [ ] Update `satisfies_at_all_past_of_mem` similarly using `h_content_propagation`

**Timing**: 45 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/FlagBFMCSTruthLemma.lean` - Lines 216-224 and 262-270

**Proof Sketch for `satisfies_at_all_future_of_mem`**:
```lean
theorem satisfies_at_all_future_of_mem ... (h_mem : φ.all_future ∈ (chainFMCS F).mcs x) :
    satisfies_at B F hF x φ.all_future := by
  simp only [satisfies_at]
  intro F' hF' x' h_lt
  -- Need: φ ∈ (chainFMCS F').mcs x'
  -- From h_mem: G(φ) ∈ x.val.world
  -- From h_lt: x.val < x'.val
  -- By g_content_propagation: φ ∈ x'.val.world
  -- Since (chainFMCS F').mcs x' = x'.val.world (by chainFMCS_mcs definition)
  have h_phi : φ ∈ x'.val.world := g_content_propagation x.val x'.val φ h_mem h_lt
  simp only [chainFMCS, chainFMCS_mcs]
  exact h_phi
```

**Verification**:
- Both backward direction theorems compile without sorry
- `lake build Bimodal.Metalogic.Bundle.FlagBFMCSTruthLemma` passes

---

### Phase 4: Update Forward Direction Proofs (Remove Sorries) [NOT STARTED]

**Goal**: Fix `mem_of_satisfies_at_all_future` and `mem_of_satisfies_at_all_past` - the main blocked theorems

**Tasks**:
- [ ] Implement `mem_of_satisfies_at_all_future` using contraposition with cross-Flag witness
- [ ] Implement `mem_of_satisfies_at_all_past` symmetrically
- [ ] Remove both `sorry` statements

**Timing**: 45 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/FlagBFMCSTruthLemma.lean` - Lines 247-257 and 285-295

**Proof Sketch for `mem_of_satisfies_at_all_future`**:
```lean
theorem mem_of_satisfies_at_all_future ... (h_sat : satisfies_at B F hF x φ.all_future) :
    φ.all_future ∈ (chainFMCS F).mcs x := by
  have h_mcs := chainFMCS_is_mcs F x
  rcases SetMaximalConsistent.negation_complete h_mcs φ.all_future with h_G | h_neg_G
  · exact h_G
  · -- Contrapositive: neg(G phi) in MCS at x, derive contradiction
    -- Step 1: neg(G phi) implies F(neg phi) by temporal duality
    have h_F : (φ.neg).some_future ∈ x.val.world :=
      neg_all_future_to_some_future_neg x.val.world x.val.is_mcs φ h_neg_G

    -- Step 2: Get witness s in CanonicalMCS with neg(phi) in s.world
    obtain ⟨s, h_lt, h_neg_phi⟩ := canonicalMCS_forward_F x.val φ.neg h_F

    -- Step 3: s is in some Flag F' in B.flags (by canonicalMCS_in_some_flag)
    -- CRITICAL: We need s in B.flags, not just any Flag
    -- For canonical bundle: closedFlags contains all MCSes reachable from root
    -- Alternative: use that closedFlags is witness-closed
    obtain ⟨F', hF', hs⟩ := canonicalMCS_in_some_closedFlag B s h_lt
    let x' : ChainFMCSDomain F' := ⟨s, hs⟩

    -- Step 4: By h_sat (cross-Flag), phi must be satisfied at x'
    have h_sat_x' : satisfies_at B F' hF' x' φ := h_sat F' hF' x' h_lt

    -- Step 5: By IH, phi ∈ s.world
    have h_phi : φ ∈ s.world := (ih F' hF' x').mp h_sat_x'

    -- Step 6: Contradiction: both phi and neg(phi) in s.world
    exact absurd h_phi (set_consistent_not_both s.is_mcs.1 φ · h_neg_phi)
```

**Key Insight**: The proof now works because:
1. `h_sat` quantifies over ALL Flags in B.flags, not just F
2. The witness from `canonicalMCS_forward_F` can be placed in some Flag F' in B.flags
3. The IH also generalizes over all Flags (this must be adjusted in main theorem)

**Verification**:
- Both forward direction theorems compile without sorry
- `lake build Bimodal.Metalogic.Bundle.FlagBFMCSTruthLemma` passes with no sorries

---

### Phase 5: Update Main Theorem and IH Structure [NOT STARTED]

**Goal**: Adjust `satisfies_at_iff_mem` main theorem to use generalized IH over all Flags

**Tasks**:
- [ ] Modify IH in `all_future` and `all_past` cases to quantify over `F'`, `hF'`, `x'`
- [ ] Verify theorem statement and proof structure matches new definition
- [ ] Ensure all cases (atom, bot, imp, box, all_future, all_past) compile

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/FlagBFMCSTruthLemma.lean` - Lines 413-437

**Current IH Pattern** (lines 429-432):
```lean
| all_future ψ ih =>
  constructor
  · exact mem_of_satisfies_at_all_future B F hF x ψ (fun x' => ih F hF x')
  · exact satisfies_at_all_future_of_mem B F hF x ψ (fun x' => ih F hF x')
```

**New IH Pattern**:
```lean
| all_future ψ ih =>
  constructor
  · exact mem_of_satisfies_at_all_future B F hF x ψ (fun F' hF' x' => ih F' hF' x')
  · exact satisfies_at_all_future_of_mem B F hF x ψ (fun F' hF' x' => ih F' hF' x')
```

**Note**: The `induction φ generalizing F x` already generalizes over F and x, so the IH `ih` has the correct shape: `∀ (F' : Flag CanonicalMCS) (hF' : F' ∈ B.flags) (x' : ChainFMCSDomain F'), ...`

**Verification**:
- Main theorem compiles without sorry
- `lake build Bimodal.Metalogic.Bundle.FlagBFMCSTruthLemma` passes completely clean
- Run `grep -c sorry` on file returns 0

---

## Testing & Validation

- [ ] `lake build Bimodal.Metalogic.Bundle.FlagBFMCSTruthLemma` completes with no errors
- [ ] `grep -c 'sorry' FlagBFMCSTruthLemma.lean` returns 0
- [ ] All 6 cases in `satisfies_at_iff_mem` have complete proofs (atom, bot, imp, box, all_future, all_past)
- [ ] Run full `lake build` to ensure no downstream breakages

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/Bundle/FlagBFMCSTruthLemma.lean` - Modified with no sorries
- `specs/1005_resolve_flagbfmcs_temporal_truth_lemma/summaries/01_cross-flag-temporal-summary.md` - Implementation summary

## Rollback/Contingency

If Phase 4 encounters unforeseen difficulties with witness membership in B.flags:
1. **Interim Option**: Document the precise gap (witness in CanonicalMCS but not proven in B.flags)
2. **Fallback**: Use Path C (accept partial completeness for modal-only fragment)
3. **Alternative**: Strengthen FlagBFMCS to include temporal witness closure property

The most likely issue is proving that the F-witness is in a Flag in B.flags (not just any Flag). The `closedFlags` construction provides modal saturation but may need verification that it also captures temporal witnesses reachable from root.
