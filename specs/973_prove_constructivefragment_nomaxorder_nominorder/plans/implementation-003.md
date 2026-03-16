# Implementation Plan: Task 973 (v3)

- **Task**: 973 - Prove NoMaxOrder/NoMinOrder on ConstructiveQuotient
- **Status**: [NOT STARTED]
- **Effort**: 2 hours
- **Dependencies**: Task 972 (completed)
- **Research Inputs**: research-001.md, research-002.md, research-003.md (import conflict analysis)
- **Artifacts**: plans/implementation-003.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

Complete two sorry placeholders for `NoMaxOrder` and `NoMinOrder` on `ConstructiveQuotient` by creating a **new file** `CanonicalSerialFrameInstance.lean` that imports `ConstructiveFragment` and `CanonicalIrreflexivityAxiom` without triggering the diamond dependency issue. The sorry'd instances in `ConstructiveFragment.lean` will be removed after the new file provides the implementations.

### Revision Notes (v3)

This plan supersedes implementation-002.md which attempted to add imports directly to `ConstructiveFragment.lean`, causing an elaboration-order sensitivity bug (diamond dependency through `CanonicalFMCS` chain). Research-003.md identified that `DiscreteTimeline.lean` avoids this by importing `CanonicalIrreflexivityAxiom` **directly** without the `CanonicalFMCS` chain.

**Solution 2 (File Extraction)**: Create `CanonicalSerialFrameInstance.lean` that:
1. Imports `ConstructiveFragment` (for `ConstructiveQuotient` and its `Preorder`)
2. Imports `CanonicalIrreflexivityAxiom` (for `canonicalR_strict`, `canonicalR_irreflexive`)
3. Defines the `NoMaxOrder` and `NoMinOrder` instances

This approach foreshadows task 978's typeclass architecture where `NoMaxOrder`/`NoMinOrder` become `SerialFrame` instances.

### Research Integration

Key findings from research-003.md:
- Diamond dependency forms when `ConstructiveFragment` imports both `CanonicalTimeline` -> `CanonicalFMCS` -> `CanonicalFrame` and `CanonicalIrreflexivityAxiom` -> `CanonicalIrreflexivity` -> `CanonicalFrame`
- `DiscreteTimeline.lean` works because it imports `CanonicalIrreflexivityAxiom` directly
- File split cleanly separates "concrete representation concerns" from "frame condition concerns"
- No downstream dependencies currently use `ConstructiveQuotient`'s `NoMaxOrder`/`NoMinOrder`

## Goals & Non-Goals

**Goals**:
- Create `CanonicalSerialFrameInstance.lean` with `NoMaxOrder` and `NoMinOrder` instances
- Remove sorry'd instances from `ConstructiveFragment.lean`
- Zero sorries in both files after completion

**Non-Goals**:
- Modifying the `Preorder` definition on `ConstructiveFragment`
- Implementing the full `SerialFrame` typeclass (task 978)
- Hardening proofs in `ConstructiveFragment.lean` (Solution 1 rejected)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| New file import order triggers same bug | H | L | Import `CanonicalIrreflexivityAxiom` before `ConstructiveFragment`; test early |
| Missing required lemmas in new file scope | M | L | Verified proof sketches work in research-002.md |
| Downstream files need to import new file | L | L | No current downstream users of these instances |

## Sorry Characterization

### Pre-existing Sorries
- 2 sorries in `ConstructiveFragment.lean` at lines 581 and 586 (`NoMaxOrder`/`NoMinOrder` instances)

### Expected Resolution
- Phase 2 implements `NoMaxOrder.exists_gt` in new file
- Phase 3 implements `NoMinOrder.exists_lt` in new file
- Phase 4 removes sorry'd instances from `ConstructiveFragment.lean`

### New Sorries
- None. NEVER introduce new sorries. If proof cannot be completed:
  - Mark phase [BLOCKED] with `requires_user_review: true`
  - User decides: revise plan, split task, or change approach
  - DO NOT use sorry and mark task complete

### Remaining Debt
After this implementation:
- 0 sorries in `CanonicalSerialFrameInstance.lean`
- 0 sorries in `ConstructiveFragment.lean` for `NoMaxOrder`/`NoMinOrder`

## Implementation Phases

### Phase 1: Create New File with Module Structure [NOT STARTED]

- **Dependencies:** None
- **Goal:** Create `CanonicalSerialFrameInstance.lean` with imports and module structure

**Tasks:**
- [ ] Create file `Theories/Bimodal/Metalogic/Canonical/CanonicalSerialFrameInstance.lean`
- [ ] Add copyright header and module documentation
- [ ] Add import for `Bimodal.Metalogic.Canonical.CanonicalIrreflexivityAxiom`
- [ ] Add import for `Bimodal.Metalogic.Canonical.ConstructiveFragment`
- [ ] Add namespace `Bimodal.Metalogic.Canonical`
- [ ] Add variable block for `M₀` and `h_mcs₀`
- [ ] Verify imports compile with `lake build`

**File structure:**
```lean
/-
Copyright (c) 2025-2026 Benjamin Bumpus. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Bumpus, Claude
-/
import Bimodal.Metalogic.Canonical.CanonicalIrreflexivityAxiom
import Bimodal.Metalogic.Canonical.ConstructiveFragment

/-!
# Serial Frame Instances for ConstructiveQuotient

This file provides `NoMaxOrder` and `NoMinOrder` instances for `ConstructiveQuotient`,
establishing that the quotient has no maximum or minimum elements.

## Main Results

- `NoMaxOrder (ConstructiveQuotient M₀ h_mcs₀)`: Every element has a strictly greater element
- `NoMinOrder (ConstructiveQuotient M₀ h_mcs₀)`: Every element has a strictly lesser element

## Design Note

These instances are defined in a separate file to avoid an elaboration-order conflict
that occurs when `ConstructiveFragment.lean` imports `CanonicalIrreflexivityAxiom`.
The separation also foreshadows task 978's `SerialFrame` typeclass architecture.
-/

namespace Bimodal.Metalogic.Canonical

variable {M₀ : Set Formula} {h_mcs₀ : SetMaximalConsistent M₀}

end Bimodal.Metalogic.Canonical
```

**Timing:** 20 minutes

**Files to create:**
- `Theories/Bimodal/Metalogic/Canonical/CanonicalSerialFrameInstance.lean`

**Verification:**
- `lake build Bimodal.Metalogic.Canonical.CanonicalSerialFrameInstance` passes
- No sorry or axiom in file

---

### Phase 2: Implement NoMaxOrder Instance [NOT STARTED]

- **Dependencies:** Phase 1
- **Goal:** Implement `NoMaxOrder` instance proving every quotient element has a strictly greater element

**Verified Proof** (from research-002.md):
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
- [ ] Add `NoMaxOrder` instance to `CanonicalSerialFrameInstance.lean`
- [ ] Adjust implicit arguments if needed (use `lean_hover_info`)
- [ ] Verify with `lean_goal` that no goals remain
- [ ] Verify with `lake build` that file compiles

**Timing:** 30 minutes

**Files to modify:**
- `Theories/Bimodal/Metalogic/Canonical/CanonicalSerialFrameInstance.lean`

**Verification:**
- `lean_goal` at end of proof shows "no goals"
- `lake build Bimodal.Metalogic.Canonical.CanonicalSerialFrameInstance` passes

---

### Phase 3: Implement NoMinOrder Instance [NOT STARTED]

- **Dependencies:** Phase 2
- **Goal:** Implement `NoMinOrder` instance proving every quotient element has a strictly lesser element

**Verified Proof** (from research-002.md):
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
- [ ] Add `NoMinOrder` instance to `CanonicalSerialFrameInstance.lean`
- [ ] Adjust implicit arguments if needed (use `lean_hover_info`)
- [ ] Verify with `lean_goal` that no goals remain
- [ ] Verify with `lake build` that file compiles

**Timing:** 30 minutes

**Files to modify:**
- `Theories/Bimodal/Metalogic/Canonical/CanonicalSerialFrameInstance.lean`

**Verification:**
- `lean_goal` at end of proof shows "no goals"
- `lake build Bimodal.Metalogic.Canonical.CanonicalSerialFrameInstance` passes

---

### Phase 4: Remove Sorry Instances from ConstructiveFragment.lean [NOT STARTED]

- **Dependencies:** Phase 3
- **Goal:** Remove the sorry'd `NoMaxOrder` and `NoMinOrder` instances from `ConstructiveFragment.lean`

**Tasks:**
- [ ] Navigate to `ConstructiveFragment.lean` lines 575-587
- [ ] Remove the `NoMaxOrder` instance (lines 575-581)
- [ ] Remove the `NoMinOrder` instance (lines 583-586)
- [ ] Remove the comment block above (lines 567-573 approximately)
- [ ] Verify `lake build` passes for `ConstructiveFragment.lean`

**Timing:** 15 minutes

**Files to modify:**
- `Theories/Bimodal/Metalogic/Canonical/ConstructiveFragment.lean`

**Verification:**
- `lake build Bimodal.Metalogic.Canonical.ConstructiveFragment` passes
- `grep -n "\bsorry\b" Theories/Bimodal/Metalogic/Canonical/ConstructiveFragment.lean` returns empty

---

### Phase 5: Final Verification [NOT STARTED]

- **Dependencies:** Phase 4
- **Goal:** Verify zero-debt completion and full build success

**Tasks:**
- [ ] Run `lake build` on full project
- [ ] Verify no sorries in new file: `grep -n "\bsorry\b" CanonicalSerialFrameInstance.lean`
- [ ] Verify no sorries in modified file: `grep -n "\bsorry\b" ConstructiveFragment.lean`
- [ ] Verify no new axioms: `grep -n "^axiom " CanonicalSerialFrameInstance.lean`
- [ ] Create implementation summary

**Timing:** 15 minutes

**Files to modify:**
- None (verification only)

**Verification:**
- `lake build` passes with zero errors
- `grep -n "\bsorry\b"` returns empty for both files
- No new axioms in either file

## Testing & Validation

### For Lean Tasks (Required)
- [ ] `lake build` passes with no errors
- [ ] `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/Canonical/CanonicalSerialFrameInstance.lean` returns empty (zero-debt gate)
- [ ] `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/Canonical/ConstructiveFragment.lean` returns empty (zero-debt gate)
- [ ] `grep -n "^axiom " Theories/Bimodal/Metalogic/Canonical/CanonicalSerialFrameInstance.lean` shows no new axioms
- [ ] All proofs verified with `lean_goal` showing "no goals"

### Specific Verifications
- [ ] `NoMaxOrder` instance compiles without errors
- [ ] `NoMinOrder` instance compiles without errors
- [ ] Both instances properly provide the required witnesses
- [ ] No downstream files broken by removing instances from `ConstructiveFragment.lean`

## Artifacts & Outputs

- `specs/973_prove_constructivefragment_nomaxorder_nominorder/plans/implementation-003.md` (this file)
- `specs/973_prove_constructivefragment_nomaxorder_nominorder/summaries/implementation-summary-YYYYMMDD.md` (after completion)
- Created: `Theories/Bimodal/Metalogic/Canonical/CanonicalSerialFrameInstance.lean`
- Modified: `Theories/Bimodal/Metalogic/Canonical/ConstructiveFragment.lean`

## Rollback/Contingency

If implementation fails:
1. Delete `CanonicalSerialFrameInstance.lean` if created
2. Revert changes to `ConstructiveFragment.lean` via `git checkout`
3. Mark task [BLOCKED] with specific error encountered
4. If file extraction approach fails, revisit Solution 1 (hardening proofs)

The file extraction approach has lower risk than Solution 1 because:
- It avoids modifying fragile existing proofs
- The proof sketches work in isolation (verified in research-002.md)
- Import order in new file can be controlled explicitly
