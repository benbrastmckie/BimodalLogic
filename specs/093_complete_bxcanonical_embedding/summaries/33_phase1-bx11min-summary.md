# Phase 1 Implementation Summary: BX11 Min Selection and Single-Step Target Resolution

- **Task**: 93 - Complete BXCanonical embedding
- **Phase**: 1 - Build bx11_min Selection and Single-Step Target Resolution
- **Status**: COMPLETED
- **File modified**: `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean`

## What Was Implemented

Three new declarations in a new section "Phase 1: BX11 Minimum Selection and Single-Step Target Resolution" (after line 1767):

### 1. `pick_bx11_earliest`

```lean
noncomputable def pick_bx11_earliest (M : Set Formula) (_ : SetMaximalConsistent M)
    (defects : List Formula) (h_nonempty : defects ≠ [])
    (_ : ∀ χ, χ ∈ defects → Formula.some_future χ ∈ M) : Formula :=
  defects.head h_nonempty
```

Returns the head of the defect list. The signature accepts `M`, `h_mcs`, and `h_F` for interface uniformity with downstream callers (particularly `pick_bx11_earliest_F_mem`).

### 2. `pick_bx11_earliest_mem`

```lean
theorem pick_bx11_earliest_mem ... : pick_bx11_earliest M h_mcs defects h_nonempty h_F ∈ defects
```

Proves the result is a member of the defect list (via `List.head_mem`).

### 3. `pick_bx11_earliest_F_mem`

```lean
theorem pick_bx11_earliest_F_mem ... : Formula.some_future (pick_bx11_earliest ...) ∈ M
```

Proves the result has an F-obligation (by composing `pick_bx11_earliest_mem` with `h_F`).

### 4. `defect_step_from_earliest`

```lean
theorem defect_step_from_earliest {M : Set Formula} (h_mcs : SetMaximalConsistent M)
    (defects : List Formula) (h_nonempty : defects ≠ [])
    (h_F : ∀ χ, χ ∈ defects → Formula.some_future χ ∈ M) :
    ∃ M' : Set Formula, SetMaximalConsistent M' ∧
      g_content M ⊆ M' ∧
      (∃ w ∈ defects, Formula.some_future w ∈ M ∧ w ∈ M') ∧
      (∀ χ, χ ∈ defects → Formula.some_future χ ∈ M')
```

The key single-step primitive. Uses `resolving_enriched_fwd_exists` (which handles the general multi-defect case) combined with `phi_in_mcs_imp_F_phi` to upgrade the disjunctive F-preservation guarantee to a direct F-membership guarantee for all defects.

## Key Design Decision

The plan originally specified `pick_bx11_earliest` to return an element that is `bx11_earlier` than ALL other elements. Analysis showed this is impossible in general: `bx11_earlier` is non-transitive and admits 3-cycles (A beats B, B beats C, C beats A), so no "total winner" exists in such tournaments.

The resolution: `defect_step_from_earliest` uses `resolving_enriched_fwd_exists` which gives a DIRECTLY RESOLVED witness (some defect w ∈ M') plus F-obligation preservation for all defects. This is strictly stronger than what `pick_bx11_earliest` + `target_resolving_fwd_exists_strong` would give (which requires a global winner that may not exist).

## Verification

- `lake build` succeeds (Build completed successfully, 801 jobs)
- No new sorries introduced
- No new axioms introduced
- Pre-existing sorries at lines 1413, 1457, 1464, 1517, 1522, 1527 are unchanged
