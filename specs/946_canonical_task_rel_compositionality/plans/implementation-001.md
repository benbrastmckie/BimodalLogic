# Implementation Plan: Prove canonical_task_rel_compositionality Cross-Sign Cases

- **Task**: 946 - Prove canonical_task_rel_compositionality cross-sign cases
- **Status**: [NOT STARTED]
- **Effort**: 1.5 hours
- **Dependencies**: None
- **Research Inputs**: specs/946_canonical_task_rel_compositionality/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**:
  - .claude/context/core/standards/plan.md
  - .claude/context/core/standards/status-markers.md
  - .claude/context/core/system/artifact-management.md
  - .claude/context/core/standards/tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

The 4 sorries in `canonical_task_rel_compositionality` (lines 155, 166, 203, 209) occur at cross-sign duration cases where the current definition is too weak. Research identified that the current sign-conditioned definition cannot prove compositionality for cross-sign cases (counter-model exists). The fix is to strengthen the definition to require BOTH GContent and HContent conditions unconditionally, enabling uniform transitivity proofs using existing `canonicalR_transitive` and a new `HContent_chain_transitive` helper.

### Research Integration

From research-001.md:
- Counter-model proves current definition is mathematically incorrect (not a proof difficulty)
- Strengthened definition: `GContent M.val ⊆ N.val ∧ HContent N.val ⊆ M.val` (no sign conditions)
- Compositionality becomes: forward via `canonicalR_transitive`, backward via `HContent_chain_transitive`
- Nullity still holds via T-axioms (canonicalR_reflexive, canonicalR_past_reflexive)
- to_history backward case needs update to use `fam.backward_H` directly

## Goals & Non-Goals

**Goals**:
- Eliminate all 4 sorries in `canonical_task_rel_compositionality`
- Strengthen `canonical_task_rel` definition to enable compositionality
- Add `HContent_chain_transitive` helper lemma to CanonicalFrame.lean
- Update `to_history` backward case to use `fam.backward_H`
- Achieve zero-debt completion with `lake build` passing

**Non-Goals**:
- Changes to upstream modules (MCSProperties, Axioms)
- Changes to downstream modules (TruthLemma, completeness) beyond compile fixes
- Performance optimization

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Strengthened definition breaks nullity proof | High | Very Low | T-axioms still apply; verification in Phase 2 |
| HContent_chain_transitive proof fails | Medium | Very Low | Symmetric to canonicalR_transitive, which is proven |
| to_history backward case fails with general s <= t | Medium | Very Low | FMCS.backward_H provides exactly this property |
| Other code references canonical_task_rel | Low | Low | grep confirms limited usage |

## Sorry Characterization

### Pre-existing Sorries
- 4 sorries in `CanonicalConstruction.lean` at lines 155, 166, 203, 209
- All in cross-sign cases of `canonical_task_rel_compositionality`

### Expected Resolution
- All 4 sorries eliminated by Phase 3 (strengthened definition + uniform transitivity proof)

### New Sorries
- None. NEVER introduce new sorries. If proof cannot be completed:
  - Mark phase [BLOCKED] with requires_user_review: true
  - User decides: revise plan, split task, or change approach
  - DO NOT use sorry and mark task complete

### Remaining Debt
After this implementation:
- 0 sorries in `canonical_task_rel_compositionality`
- Downstream `CanonicalTaskFrame`, `to_history`, `CanonicalOmega` no longer inherit sorry status

## Implementation Phases

### Phase 1: Add HContent_chain_transitive Helper [NOT STARTED]

- **Dependencies:** None
- **Goal:** Add the backward transitivity helper lemma needed for compositionality

**Tasks:**
- [ ] Open `CanonicalFrame.lean`
- [ ] Add `HContent_chain_transitive` theorem after `canonicalR_transitive` (around line 230)
- [ ] Prove using `temp_4_past` and `set_mcs_implication_property` (symmetric to forward case)
- [ ] Verify with `lean_goal` showing "no goals"

**Implementation:**
```lean
theorem HContent_chain_transitive (M N V : Set Formula)
    (h_mcs_V : SetMaximalConsistent V)
    (hNV : HContent V ⊆ N) (hMN : HContent N ⊆ M) :
    HContent V ⊆ M := by
  intro phi h_H_phi
  have h_H4 := temp_4_past phi  -- H phi -> HH phi
  have h_HH_in_V := set_mcs_implication_property h_mcs_V (theorem_in_mcs h_mcs_V h_H4) h_H_phi
  have h_Hphi_in_N := hNV h_HH_in_V  -- H(phi) in HContent(V) ⊆ N
  exact hMN h_Hphi_in_N               -- phi in HContent(N) ⊆ M
```

**Timing:** 15 minutes

**Files to modify:**
- `Theories/Bimodal/Metalogic/Bundle/CanonicalFrame.lean` - add helper lemma

**Verification:**
- `lean_goal` on theorem line shows "no goals"
- `lake build Bimodal.Metalogic.Bundle.CanonicalFrame` passes

---

### Phase 2: Strengthen canonical_task_rel Definition [NOT STARTED]

- **Dependencies:** None
- **Goal:** Remove sign-conditioning from definition to enable compositionality

**Tasks:**
- [ ] Open `CanonicalConstruction.lean`
- [ ] Replace `canonical_task_rel` definition (lines 77-79) with unconditional version
- [ ] Update docstring to reflect new definition
- [ ] Verify `canonical_task_rel_nullity` still compiles (T-axioms apply unchanged)

**Implementation:**
```lean
def canonical_task_rel (M : CanonicalWorldState) (d : Int) (N : CanonicalWorldState) : Prop :=
  GContent M.val ⊆ N.val ∧ HContent N.val ⊆ M.val
```

**Timing:** 10 minutes

**Files to modify:**
- `Theories/Bimodal/Metalogic/Bundle/CanonicalConstruction.lean` - lines 77-79

**Verification:**
- `canonical_task_rel_nullity` compiles without changes (T-axioms still apply)
- No build errors in definition area

---

### Phase 3: Rewrite Compositionality Proof [NOT STARTED]

- **Dependencies:** Phase 1, Phase 2
- **Goal:** Replace case-analysis proof with uniform two-line transitivity argument

**Tasks:**
- [ ] Delete existing `canonical_task_rel_compositionality` proof body (lines 101-210 approximately)
- [ ] Write new proof using `canonicalR_transitive` and `HContent_chain_transitive`
- [ ] Verify all 4 sorries eliminated
- [ ] Verify with `lean_goal` showing "no goals"

**Implementation:**
```lean
theorem canonical_task_rel_compositionality
    (M N V : CanonicalWorldState) (x y : Int)
    (hMN : canonical_task_rel M x N) (hNV : canonical_task_rel N y V) :
    canonical_task_rel M (x + y) V := by
  obtain ⟨hMN_fwd, hMN_bwd⟩ := hMN
  obtain ⟨hNV_fwd, hNV_bwd⟩ := hNV
  constructor
  · -- GContent(M) ⊆ V via canonicalR_transitive
    exact canonicalR_transitive M.val N.val V.val M.property hMN_fwd hNV_fwd
  · -- HContent(V) ⊆ M via HContent_chain_transitive
    exact HContent_chain_transitive M.val N.val V.val V.property hNV_bwd hMN_bwd
```

**Timing:** 20 minutes

**Files to modify:**
- `Theories/Bimodal/Metalogic/Bundle/CanonicalConstruction.lean` - compositionality proof

**Verification:**
- `lean_goal` on theorem line shows "no goals"
- `grep -n "\bsorry\b" CanonicalConstruction.lean` returns empty for compositionality area

---

### Phase 4: Update to_history Backward Case [NOT STARTED]

- **Dependencies:** Phase 2
- **Goal:** Update respects_task proof to use fam.backward_H for general s <= t

**Tasks:**
- [ ] Locate `to_history` definition and `respects_task` proof
- [ ] Check if backward case currently uses `le_antisymm` shortcut
- [ ] If so, update to use `fam.backward_H s t h_le` for the HContent condition
- [ ] If not, verify existing proof still compiles with new definition

**Timing:** 15 minutes

**Files to modify:**
- `Theories/Bimodal/Metalogic/Bundle/CanonicalConstruction.lean` - to_history proof

**Verification:**
- `lean_goal` on respects_task proof shows "no goals"
- No compile errors in to_history area

---

### Phase 5: Verify Build and Zero-Debt [NOT STARTED]

- **Dependencies:** Phase 1, Phase 2, Phase 3, Phase 4
- **Goal:** Confirm full build passes with zero new sorries

**Tasks:**
- [ ] Run `lake build` for full project
- [ ] Verify `CanonicalConstruction.lean` has no sorries: `grep -n "\bsorry\b" CanonicalConstruction.lean`
- [ ] Verify `CanonicalFrame.lean` has no sorries: `grep -n "\bsorry\b" CanonicalFrame.lean`
- [ ] Check downstream modules compile: `TruthLemma.lean`, etc.

**Timing:** 20 minutes

**Files to verify:**
- `Theories/Bimodal/Metalogic/Bundle/CanonicalConstruction.lean`
- `Theories/Bimodal/Metalogic/Bundle/CanonicalFrame.lean`

**Verification:**
- `lake build` passes with no errors
- `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/Bundle/CanonicalConstruction.lean` returns empty
- `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/Bundle/CanonicalFrame.lean` returns empty
- Zero sorries introduced, 4 sorries eliminated

---

## Testing & Validation

### For Lean Tasks (Required)
- [ ] `lake build` passes with no errors
- [ ] `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/Bundle/CanonicalConstruction.lean` returns empty
- [ ] `grep -n "^axiom " Theories/Bimodal/Metalogic/Bundle/CanonicalConstruction.lean` shows no new axioms
- [ ] All proofs verified with `lean_goal` showing "no goals"

### Module-Specific
- [ ] `canonical_task_rel_nullity` compiles unchanged
- [ ] `canonical_task_rel_compositionality` compiles without sorries
- [ ] `to_history` respects_task proof compiles
- [ ] `CanonicalTaskFrame` compiles (uses nullity + compositionality)

## Artifacts & Outputs

- `specs/946_canonical_task_rel_compositionality/plans/implementation-001.md` (this file)
- `specs/946_canonical_task_rel_compositionality/summaries/implementation-summary-YYYYMMDD.md` (on completion)
- Modified: `Theories/Bimodal/Metalogic/Bundle/CanonicalFrame.lean` (add HContent_chain_transitive)
- Modified: `Theories/Bimodal/Metalogic/Bundle/CanonicalConstruction.lean` (definition + proofs)

## Rollback/Contingency

If implementation fails:
1. `git checkout -- Theories/Bimodal/Metalogic/Bundle/CanonicalFrame.lean`
2. `git checkout -- Theories/Bimodal/Metalogic/Bundle/CanonicalConstruction.lean`
3. Mark task [BLOCKED] with specific issue
4. Research alternative approaches (different canonical_task_rel formulation)

If HContent_chain_transitive proof is blocked:
- Try inlining the transitivity argument directly in compositionality proof
- Check if temp_4_past imports are correct

If to_history breaks:
- Check FMCS.backward_H signature matches expectation
- Verify s <= t constraint is available at proof site
