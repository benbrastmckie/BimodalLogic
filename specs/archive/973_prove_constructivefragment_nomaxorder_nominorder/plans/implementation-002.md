# Implementation Plan: Task 973 (v2)

- **Task**: 973 - Prove NoMaxOrder/NoMinOrder on ConstructiveQuotient
- **Status**: [BLOCKED]
- **Effort**: 1.5 hours
- **Dependencies**: Task 972 (completed)
- **Research Inputs**: research-001.md, research-002.md (blocker resolution)
- **Artifacts**: plans/implementation-002.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

Complete two sorry placeholders in `ConstructiveFragment.lean` at lines 581 and 586 proving that `ConstructiveQuotient` has no maximum or minimum elements. The proofs use seriality axioms to get forward/backward witnesses, establish strictness via `canonicalR_strict`, and lift to the quotient using `toAntisymmetrization_lt_toAntisymmetrization_iff`.

### Revision Notes (v2)

This plan supersedes implementation-001.md which had incorrect phase status markers. All phases were marked [COMPLETED] or [BLOCKED] despite no work being done. The blocker from task 972 (casing issues with `GContent_subset_*` → `g_content_subset_*`) has been resolved. Research-002.md verified all lemmas are available with correct names.

### Research Integration

Key findings from research-001.md and research-002.md:
- Goal states verified at lines 581 and 586
- Working proof pattern from DiscreteTimeline.lean (lines 247-285)
- Lemma names verified: `SetMaximalConsistent.contains_seriality_future/past` (not `mcs_contains_seriality_*`)
- `canonicalR_strict` and `canonicalR_irreflexive` in CanonicalIrreflexivityAxiom.lean
- All execute functions available in ConstructiveFragment.lean

## Goals & Non-Goals

**Goals**:
- Prove `NoMaxOrder.exists_gt` for `ConstructiveQuotient` (line 581)
- Prove `NoMinOrder.exists_lt` for `ConstructiveQuotient` (line 586)
- Zero sorries remaining in these instances after completion

**Non-Goals**:
- Modifying the preorder definition on ConstructiveFragment
- Adding new lemmas to other files
- Refactoring the existing proof structure

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Implicit argument issues with execute* functions | M | M | Use explicit type annotations; check with lean_hover_info |
| Quotient induction syntax differs from DiscreteTimeline | L | L | Use `Quotient.ind` as shown in research; adjust if needed |

## Sorry Characterization

### Pre-existing Sorries
- 2 sorries in `ConstructiveFragment.lean` at lines 581 and 586 (NoMaxOrder/NoMinOrder instances)

### Expected Resolution
- Phase 1 resolves line 581 sorry via forward seriality witness and canonicalR_strict
- Phase 2 resolves line 586 sorry via backward seriality witness and canonicalR_strict

### New Sorries
- None. NEVER introduce new sorries. If proof cannot be completed:
  - Mark phase [BLOCKED] with requires_user_review: true
  - User decides: revise plan, split task, or change approach
  - DO NOT use sorry and mark task complete

### Remaining Debt
After this implementation:
- 0 sorries expected in NoMaxOrder/NoMinOrder instances
- These instances become publication-ready

## Implementation Phases

### Phase 1: Prove NoMaxOrder.exists_gt [BLOCKED]

- **Dependencies:** None
- **Goal:** Complete the sorry at line 581 proving every quotient element has a strictly greater element

**Verified Proof Sketch** (from research-002.md):
```lean
instance : NoMaxOrder (ConstructiveQuotient M₀ h_mcs₀) where
  exists_gt a := by
    induction a using Quotient.ind with | _ w =>
    -- Get seriality witness
    have h_F := SetMaximalConsistent.contains_seriality_future w.val w.is_mcs
    -- Execute forward step
    let N := executeForwardStep w.val w.is_mcs (Formula.neg Formula.bot) h_F
    have h_N_mcs := executeForwardStep_mcs (h_mcs := w.is_mcs) (h_F := h_F)
    have h_R := executeForwardStep_canonicalR (h_mcs := w.is_mcs) (h_F := h_F)
    -- Strictness via canonicalR_strict
    have h_strict : ¬CanonicalR N w.val :=
      canonicalR_strict w.val N w.is_mcs h_N_mcs h_R
    -- Build reachability for N
    obtain ⟨h_reach⟩ := w.property
    have h_N_reach : Nonempty (ConstructiveReachable M₀ h_mcs₀ N) :=
      ⟨ConstructiveReachable.forward_witness w.val (Formula.neg Formula.bot) h_reach w.is_mcs h_F⟩
    -- Construct successor
    let w' : ConstructiveFragment M₀ h_mcs₀ := ⟨N, h_N_reach⟩
    use toAntisymmetrization (· ≤ ·) w'
    rw [toAntisymmetrization_lt_toAntisymmetrization_iff]
    constructor
    · exact Or.inr h_R
    · intro h_le_back
      cases h_le_back with
      | inl h_eq => exact canonicalR_irreflexive w.val w.is_mcs (h_eq ▸ h_R)
      | inr h_R_back => exact h_strict h_R_back
```

**Tasks:**
- [ ] Navigate to `ConstructiveFragment.lean` line 581
- [ ] Replace `sorry` with the proof sketch above
- [ ] Adjust implicit arguments as needed (use lean_hover_info)
- [ ] Verify no goals remain with `lean_goal`

**Timing:** 45 minutes

**Files to modify:**
- `Theories/Bimodal/Metalogic/Canonical/ConstructiveFragment.lean` - line 581

**Verification:**
- `lean_goal` at end of proof shows "no goals"
- `lake build` compiles without errors for this file

---

### Phase 2: Prove NoMinOrder.exists_lt [BLOCKED]

- **Dependencies:** Phase 1
- **Goal:** Complete the sorry at line 586 proving every quotient element has a strictly lesser element

**Verified Proof Sketch** (from research-002.md):
```lean
instance : NoMinOrder (ConstructiveQuotient M₀ h_mcs₀) where
  exists_lt a := by
    induction a using Quotient.ind with | _ w =>
    have h_P := SetMaximalConsistent.contains_seriality_past w.val w.is_mcs
    let N := executeBackwardStep w.val w.is_mcs (Formula.neg Formula.bot) h_P
    have h_N_mcs := executeBackwardStep_mcs (h_mcs := w.is_mcs) (h_P := h_P)
    have h_R := executeBackwardStep_canonicalR (h_mcs := w.is_mcs) (h_P := h_P)
    -- Note: h_R : CanonicalR N w.val (predecessor -> current)
    have h_strict : ¬CanonicalR w.val N :=
      canonicalR_strict N w.val h_N_mcs w.is_mcs h_R
    obtain ⟨h_reach⟩ := w.property
    have h_N_reach : Nonempty (ConstructiveReachable M₀ h_mcs₀ N) :=
      ⟨ConstructiveReachable.backward_witness w.val (Formula.neg Formula.bot) h_reach w.is_mcs h_P⟩
    let w' : ConstructiveFragment M₀ h_mcs₀ := ⟨N, h_N_reach⟩
    use toAntisymmetrization (· ≤ ·) w'
    rw [toAntisymmetrization_lt_toAntisymmetrization_iff]
    constructor
    · exact Or.inr h_R  -- w' ≤ w via CanonicalR N w.val
    · intro h_le_back
      cases h_le_back with
      | inl h_eq => exact canonicalR_irreflexive N h_N_mcs (h_eq.symm ▸ h_R)
      | inr h_R_back => exact h_strict h_R_back
```

**Tasks:**
- [ ] Navigate to `ConstructiveFragment.lean` line 586
- [ ] Replace `sorry` with the proof sketch above
- [ ] Adjust implicit arguments as needed (use lean_hover_info)
- [ ] Verify no goals remain with `lean_goal`

**Timing:** 45 minutes

**Files to modify:**
- `Theories/Bimodal/Metalogic/Canonical/ConstructiveFragment.lean` - line 586

**Verification:**
- `lean_goal` at end of proof shows "no goals"
- `lake build` compiles without errors for this file

---

### Phase 3: Final Verification [NOT STARTED]

- **Dependencies:** Phase 1, Phase 2
- **Goal:** Verify zero-debt completion and full build success

**Tasks:**
- [ ] Run `lake build` on full project
- [ ] Verify no sorries in modified file: `grep -n "\bsorry\b" ConstructiveFragment.lean`
- [ ] Verify no new axioms introduced: `grep -n "^axiom " ConstructiveFragment.lean`
- [ ] Create implementation summary

**Timing:** 15 minutes

**Files to modify:**
- None (verification only)

**Verification:**
- `lake build` passes with zero errors
- `grep -n "\bsorry\b" Theories/Bimodal/Metalogic/Canonical/ConstructiveFragment.lean` returns empty
- No new axioms in modified file

## Testing & Validation

### For Lean Tasks (Required)
- [ ] `lake build` passes with no errors
- [ ] `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/Canonical/ConstructiveFragment.lean` returns empty (zero-debt gate)
- [ ] `grep -n "^axiom " Theories/Bimodal/Metalogic/Canonical/ConstructiveFragment.lean` shows no new axioms
- [ ] All proofs verified with `lean_goal` showing "no goals"

### Specific Verifications
- [ ] NoMaxOrder instance compiles without errors
- [ ] NoMinOrder instance compiles without errors
- [ ] Both instances properly provide the required witnesses

## Artifacts & Outputs

- `specs/973_prove_constructivefragment_nomaxorder_nominorder/plans/implementation-002.md` (this file)
- `specs/973_prove_constructivefragment_nomaxorder_nominorder/summaries/implementation-summary-YYYYMMDD.md` (after completion)
- Modified: `Theories/Bimodal/Metalogic/Canonical/ConstructiveFragment.lean`

## Rollback/Contingency

If implementation fails:
1. Revert changes to `ConstructiveFragment.lean` via `git checkout`
2. Mark task [BLOCKED] with specific error encountered
3. If proof strategy is fundamentally flawed, request revised research

Both proofs follow a well-established pattern from DiscreteTimeline.lean, so rollback should not be necessary. The main risk is syntax/implicit argument issues which can be resolved with minor adjustments.
