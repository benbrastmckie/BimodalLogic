# Research Report: Task 973 (Supplementary)

## Executive Summary

**Blocker Resolved**: Task 972 has been completed, fixing the casing issues that blocked task 973. The file `ConstructiveFragment.lean` now builds successfully with only the two target sorries remaining.

**Implementation Ready**: All required lemmas exist and are accessible. The proof strategy from research-001.md is valid with minor naming adjustments.

## Blocker Resolution

Task 973 was blocked on:
> Pre-existing build errors in ConstructiveFragment.lean - file uses undefined identifiers (GContent_subset_* etc.) that need casing fixes (task 972 Phase 1)

**Status after Task 972**:
- `GContent_subset_*` renamed to `g_content_subset_*` (snake_case)
- `HContent_subset_*` renamed to `h_content_subset_*` (snake_case)
- File compiles successfully with `lake build Bimodal.Metalogic.Canonical.ConstructiveFragment`

## Verified Lemma Availability

All lemmas required by research-001.md are available:

### Seriality Witnesses
| Research Name | Actual Name | Location |
|---------------|-------------|----------|
| `mcs_contains_seriality_future` | `SetMaximalConsistent.contains_seriality_future` | CanonicalTimeline.lean:84-86 |
| `mcs_contains_seriality_past` | `SetMaximalConsistent.contains_seriality_past` | CanonicalTimeline.lean:91-93 |

### Strictness
| Research Name | Actual Name | Location |
|---------------|-------------|----------|
| `canonicalR_strict` | `canonicalR_strict` | CanonicalIrreflexivityAxiom.lean:95-99 |
| `canonicalR_irreflexive` | `canonicalR_irreflexive` | CanonicalIrreflexivityAxiom.lean:76-78 |

### Execute Functions (in ConstructiveFragment.lean)
- `executeForwardStep` (line 63-66)
- `executeBackwardStep` (line 72-75)
- `executeForwardStep_canonicalR` (line 81-84)
- `executeBackwardStep_canonicalR` (line 91-96)
- `executeForwardStep_mcs` (line 98-101)
- `executeBackwardStep_mcs` (line 103-106)

### Reachability Constructors (in ConstructiveFragment.lean)
- `ConstructiveReachable.forward_witness` (line 120-124)
- `ConstructiveReachable.backward_witness` (line 125-129)

### Mathlib
- `toAntisymmetrization_lt_toAntisymmetrization_iff` - available via `Mathlib.Order.Antisymmetrization`

## Current Goal States

**Line 581 (NoMaxOrder.exists_gt)**:
```lean
case a
M₀ : Set Formula
h_mcs₀ : SetMaximalConsistent M₀
w : ConstructiveFragment M₀ h_mcs₀
⊢ ∃ b, ⟦w⟧ < b
```

**Line 586 (NoMinOrder.exists_lt)**:
```lean
case a
M₀ : Set Formula
h_mcs₀ : SetMaximalConsistent M₀
w : ConstructiveFragment M₀ h_mcs₀
⊢ ∃ b, b < ⟦w⟧
```

## Updated Proof Sketches

### NoMaxOrder (line 581)

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

### NoMinOrder (line 586)

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

## Plan Status Corrections

The implementation plan (implementation-001.md) has phases incorrectly marked:
- Phase 1: Marked [COMPLETED] but sorry still present - should be [NOT STARTED]
- Phase 2: Marked [COMPLETED] but sorry still present - should be [NOT STARTED]
- Phase 3: Marked [BLOCKED] - should be [NOT STARTED] (depends on 1 & 2)

## Recommendations

1. **Unblock task 973** - blocker from task 972 is resolved
2. **Update plan status** - correct the phase markers
3. **Proceed to implementation** - all prerequisites verified
4. **Estimated effort**: 1-2 hours (proof pattern established)

## Dependencies

No additional dependencies discovered. All required lemmas available via existing imports.
