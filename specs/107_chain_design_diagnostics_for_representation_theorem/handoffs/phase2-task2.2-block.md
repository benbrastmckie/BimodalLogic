# Handoff: Task OC_107 Phase 2 Task 2.2 Block

## Context
- **Task**: OC_107 (chain design diagnostics for representation theorem)
- **Phase**: 2 (D0 Seed Consistency)
- **Blocked Task**: 2.2 (`burgess_D0_finite_subset_consistent_incons`)
- **File**: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean`
- **Line**: 1819-1826 (theorem with `sorry`)

## Completed Work
- **Task 2.1** (`d0_a_event_list_mem`, line 1409): Completed (no sorries). Updated plan file to mark [x].
- **Metadata**: Updated `.return-meta.json` to reflect progress.

## Blocking Issue
The theorem `burgess_D0_finite_subset_consistent_incons` requires proving the Burgess D0 seed is consistent when `β.neg ∈ B` (inconsistent case for `{β} ∪ B`). The proof requires:
1. Constructing `F(β.neg) ∈ A` via BX5 + BX14 + BX10 chain
2. Using `burgess_D0_finite_subset_consistent` (line 1606) which requires the `F(β.neg) ∈ A` witness

### Stuck Point
The BX chain for `F(β.neg) ∈ A` when `β.neg ∈ B` is non-trivial:
- `burgessR3 A B C` gives `untl(β.neg, γ₀) ∈ A` for any `γ₀ ∈ C`
- BX5 gives `untl(β.neg ∧ untl(β.neg, γ₀), γ₀) ∈ A`
- BX14 requires `¬untl(r, p) ∈ A` for some `r`, which is not directly available
- Need to extract `¬untl(β₀ ∧ β, γ₀) ∈ A` from maximality (as done in the consistent case)

## Required Next Steps
1. **Extract Until witness**: Use `BurgessR3Maximal_extension_fails` to get `∃ β₀ ∈ B, γ₀ ∈ C, ¬untl(β₀ ∧ β, γ₀) ∈ A` (same as consistent case, since `β ∉ B` holds here too)
2. **Apply BX chain**: Use the witness to construct `F(β.neg) ∈ A` via the same steps as the consistent case (lines 1932-1993)
3. **Call `burgess_D0_finite_subset_consistent`**: Pass the required witnesses (`h_F_beta_neg`, `β₀`, `γ₀`, `h_neg_until₀`) to complete the proof

## Key References
- **Burgess 1982**: Section 2.6 (Lemma 2.6, p. 370-371) for inconsistent case structure
- **Consistent case proof**: Lines 1895-1993 in PointInsertion.lean (shows the BX chain for `F(β.neg) ∈ A`)
- **`burgess_D0_finite_subset_consistent`**: Line 1606 (takes the required witnesses and proves seed consistency)

## Phase 3 Prerequisites
Phase 3 (Lemma 2.7 BX7 Chain) depends on Phase 2 completion. Tasks 3.1-3.5 all modify the same PointInsertion.lean file.

## Verification
- After resolving Task 2.2, run `lake build` to confirm no regressions
- Update plan file task 2.2 to [x]
- Proceed to Phase 3 sequentially (same file)
