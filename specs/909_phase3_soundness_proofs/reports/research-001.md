# Research Report: Task #909

**Task**: Phase 3 - Soundness Proofs Update (Omega Parameter Threading)
**Date**: 2026-02-19
**Focus**: Study all elements required to thread Omega = Set.univ through SoundnessLemmas.lean and Soundness.lean

## Summary

Task 907 added an `Omega : Set (WorldHistory F)` parameter to `truth_at` in Truth.lean, and task 908 updated Validity.lean to use `Set.univ` for Omega. Both SoundnessLemmas.lean (35 theorems) and Soundness.lean (20 theorems) now fail to compile with 51+ errors. All errors are mechanical: they require inserting `Set.univ` as the Omega argument to `truth_at` calls, and providing `Set.univ_shift_closed` to `time_shift_preserves_truth` calls. No mathematical or structural changes are needed to any proof.

## Findings

### 1. Current Build Status

SoundnessLemmas.lean has **51 compilation errors** and Soundness.lean will have similar errors (cannot be tested until SoundnessLemmas.lean compiles since it imports it). The errors fall into exactly two categories:

**Category A: "Application type mismatch" (4 errors)**
- Lines 78, 91, 102 (x2): `truth_at M tau t phi` needs to become `truth_at M Set.univ tau t phi`
- These are in the `is_valid` definition and `valid_at_triple` / `truth_at_swap_swap` theorem signatures

**Category B: "introN failed / No goals to be solved" (47 errors)**
- All proofs that begin with `intro F M tau t` now fail because `truth_at` has a new `Omega` argument between `M` and `tau`
- The `is_valid` definition quantifies over `F M tau t`, but with Omega in `truth_at`, the proof goals have different shapes
- Proofs using `simp only [truth_at]` may also need adjustment since `truth_at` now has an extra parameter

### 2. SoundnessLemmas.lean - Complete Theorem Inventory

#### Local Definition (1 change)
- **Line 76-78: `is_valid`** - Must insert `Set.univ` as Omega parameter to `truth_at`

  Current: `truth_at M tau t phi`
  Required: `truth_at M Set.univ tau t phi`

#### Utility Theorems (2 theorems)
- **Line 89-91: `valid_at_triple`** - Insert `Set.univ` in `truth_at` calls (signature + body)
- **Line 100-138: `truth_at_swap_swap`** - Insert `Set.univ` in all `truth_at` calls. The proof uses structural induction with `simp only [truth_at]` and manual intro/constructor patterns. Omega needs threading through the signature, and the box case may need an additional `intro` for the `sigma in Omega` membership proof.

#### Swap Axiom Validity Theorems (8 theorems)
All follow the pattern: `intro F M tau t` then `simp only [Formula.swap_temporal, truth_at]`.
Each needs `Set.univ` in `is_valid` unfolding. With `Set.univ`, the box case unfolds to `forall sigma, sigma in Set.univ -> ...` which can be simplified via `simp [Set.mem_univ]`.

| # | Theorem | Line | Uses time_shift? | Special Handling |
|---|---------|------|-------------------|------------------|
| 1 | `swap_axiom_mt_valid` | 199 | No | Mechanical |
| 2 | `swap_axiom_m4_valid` | 217 | No | Mechanical |
| 3 | `swap_axiom_mb_valid` | 233 | No | Mechanical |
| 4 | `swap_axiom_t4_valid` | 253 | No | Mechanical |
| 5 | `swap_axiom_ta_valid` | 278 | No | Mechanical |
| 6 | `swap_axiom_tl_valid` | 306 | No | Mechanical (uses classical logic) |
| 7 | `swap_axiom_mf_valid` | 360 | **Yes** | Must supply `Set.univ_shift_closed` |
| 8 | `swap_axiom_tf_valid` | 386 | **Yes** | Must supply `Set.univ_shift_closed` |

#### Rule Preservation Theorems (5 theorems)
| # | Theorem | Line | Special Handling |
|---|---------|------|------------------|
| 1 | `mp_preserves_swap_valid` | 416 | Mechanical |
| 2 | `modal_k_preserves_swap_valid` | 432 | Mechanical (box case) |
| 3 | `temporal_k_preserves_swap_valid` | 448 | Mechanical |
| 4 | `weakening_preserves_swap_valid` | 465 | Trivial (identity function) |
| 5 | (implicit in `derivable_implies_valid_and_swap_valid`) | 848 | See below |

#### Axiom Swap Master Theorem (1 theorem)
- **Line 483: `axiom_swap_valid`** - Cases dispatch to individual swap_axiom theorems. Once individual theorems compile, this should work with minimal changes. The proof bodies for prop_k, prop_s, modal_5_collapse, ex_falso, peirce, modal_k_dist, temp_k_dist cases will need `Set.univ` threading.

#### Local Axiom Validity Theorems (17 theorems)
All are `private theorem` with the pattern `intro F M tau t` then `simp only [truth_at]`:

| # | Theorem | Line | Uses time_shift? |
|---|---------|------|-------------------|
| 1 | `axiom_prop_k_valid` | 598 | No |
| 2 | `axiom_prop_s_valid` | 606 | No |
| 3 | `axiom_modal_t_valid` | 614 | No |
| 4 | `axiom_modal_4_valid` | 622 | No |
| 5 | `axiom_modal_b_valid` | 630 | No |
| 6 | `axiom_modal_5_collapse_valid` | 639 | No |
| 7 | `axiom_ex_falso_valid` | 651 | No |
| 8 | `axiom_peirce_valid` | 660 | No |
| 9 | `axiom_modal_k_dist_valid` | 675 | No |
| 10 | `axiom_temp_k_dist_valid` | 685 | No |
| 11 | `axiom_temp_4_valid` | 695 | No |
| 12 | `axiom_temp_a_valid` | 706 | No |
| 13 | `axiom_temp_l_valid` | 719 | No |
| 14 | `axiom_modal_future_valid` | 747 | **Yes** |
| 15 | `axiom_temp_future_valid` | 760 | **Yes** |
| 16 | `axiom_temp_t_future_valid` | 778 | No |
| 17 | `axiom_temp_t_past_valid` | 795 | No |

#### Master Axiom Validity Theorem (1 theorem)
- **Line 805: `axiom_locally_valid`** - Dispatches to individual axiom_*_valid theorems. Mechanical once those compile.

#### Combined Soundness+Swap Theorem (1 theorem)
- **Line 848: `derivable_implies_valid_and_swap_valid`** - Uses derivation induction. Each case needs `Set.univ` threading. The `axiom` case dispatches to `axiom_locally_valid` and `axiom_swap_valid`. The `modus_ponens`, `necessitation`, `temporal_necessitation`, `temporal_duality`, `weakening` cases need proof body updates for the new `truth_at` signature.

#### Derived Theorems (2 theorems)
- **Line 952: `soundness_from_empty`** - Term-mode, likely compiles once `derivable_implies_valid_and_swap_valid` compiles
- **Line 962: `derivable_implies_swap_valid`** - Same as above

### 3. Soundness.lean - Complete Theorem Inventory

All 20 theorems need the same mechanical update pattern. The `valid` and `semantic_consequence` definitions from Validity.lean already embed `Set.univ`, but the intro patterns and proof bodies reference `truth_at` directly.

| # | Theorem | Line | Uses time_shift? | Special Handling |
|---|---------|------|-------------------|------------------|
| 1 | `prop_k_valid` | 86 | No | Mechanical |
| 2 | `prop_s_valid` | 101 | No | Mechanical |
| 3 | `modal_t_valid` | 116 | No | Mechanical |
| 4 | `modal_4_valid` | 135 | No | Mechanical |
| 5 | `modal_b_valid` | 158 | No | Mechanical |
| 6 | `modal_5_collapse_valid` | 197 | No | Mechanical |
| 7 | `ex_falso_valid` | 250 | No | Mechanical |
| 8 | `peirce_valid` | 278 | No | Mechanical |
| 9 | `modal_k_dist_valid` | 308 | No | Mechanical |
| 10 | `temp_k_dist_valid` | 331 | No | Mechanical |
| 11 | `temp_4_valid` | 353 | No | Mechanical |
| 12 | `temp_a_valid` | 378 | No | Mechanical |
| 13 | `temp_l_valid` | 435 | No | Mechanical |
| 14 | `modal_future_valid` | 489 | **Yes** | Must supply `Set.univ_shift_closed` |
| 15 | `temp_future_valid` | 527 | **Yes** | Must supply `Set.univ_shift_closed` |
| 16 | `temp_t_future_valid` | 557 | No | Mechanical |
| 17 | `temp_t_past_valid` | 576 | No | Mechanical |
| 18 | `axiom_valid` | 590 | No | Dispatches to above |
| 19 | `soundness` | 625 | No | Main theorem, uses `truth_at` directly |
| 20 | `and_of_not_imp_not` | 73 | No | Pure logic helper, no truth_at |

### 4. Detailed Update Patterns

#### Pattern 1: Local `is_valid` Definition (SoundnessLemmas.lean only)

Current (line 76-78):
```lean
private def is_valid (D : Type*) [...] (phi : Formula) : Prop :=
  forall (F : TaskFrame D) (M : TaskModel F) (tau : WorldHistory F) (t : D),
    truth_at M tau t phi
```

Required:
```lean
private def is_valid (D : Type*) [...] (phi : Formula) : Prop :=
  forall (F : TaskFrame D) (M : TaskModel F) (tau : WorldHistory F) (t : D),
    truth_at M Set.univ tau t phi
```

#### Pattern 2: Proofs Starting with `intro F M tau t` (Most Common)

The `is_valid` definition unfolds to `forall F M tau t, truth_at M Set.univ tau t phi`. After `intro F M tau t`, the goal will be `truth_at M Set.univ tau t phi`. Then `simp only [truth_at]` or `unfold truth_at` should work.

For the **box case**, `truth_at M Set.univ tau t (box phi)` unfolds to `forall sigma, sigma in Set.univ -> truth_at M Set.univ sigma t phi`. After simplification with `Set.mem_univ` and `true_implies`, this becomes `forall sigma, truth_at M Set.univ sigma t phi`, recovering the original shape.

**Key insight**: Many proofs can be fixed by simply adding `simp only [Set.mem_univ, true_implies]` after `simp only [truth_at]` (or `simp only [Formula.swap_temporal, truth_at]`), or equivalently `simp only [truth_at, Set.mem_univ, true_implies]`.

Alternatively, the pattern `simp only [truth_at]` followed by `intro sigma` changes to `simp only [truth_at]` followed by `intro sigma _` (introducing the trivial `sigma in Set.univ` hypothesis) or `intro sigma h_mem` then ignoring `h_mem`. However, the cleaner approach is to use `simp` to eliminate the `Set.mem_univ` obligation.

#### Pattern 3: `truth_at_swap_swap` (Special Case)

This theorem uses structural induction on formulas. The box case currently has:
```lean
| box phi ih =>
    simp only [Formula.swap_temporal, truth_at]
    constructor <;> intro h sigma
    ...
```

With Omega, the box case of `truth_at` expands to `forall sigma, sigma in Omega -> ...`. Since we use `Set.univ`, after simplifying `Set.mem_univ`, the proof structure should be preserved.

#### Pattern 4: time_shift_preserves_truth Callers (4 theorems)

Current pattern in SoundnessLemmas.lean (lines 372, 397):
```lean
exact (TimeShift.time_shift_preserves_truth M sigma t s phi.swap_past_future).mp h_at_shifted
```

New signature requires Omega and ShiftClosed proof:
```lean
exact (TimeShift.time_shift_preserves_truth M Set.univ Set.univ_shift_closed sigma t s phi.swap_past_future).mp h_at_shifted
```

Same for Soundness.lean (lines 506, 544):
```lean
have h_preserve := TimeShift.time_shift_preserves_truth M sigma t s phi
```
Becomes:
```lean
have h_preserve := TimeShift.time_shift_preserves_truth M Set.univ Set.univ_shift_closed sigma t s phi
```

#### Pattern 5: Soundness.lean Validity Theorems

Each uses the `valid` notation which expands to:
```lean
forall (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
  (F : TaskFrame D) (M : TaskModel F) (tau : WorldHistory F) (t : D),
  truth_at M Set.univ tau t phi
```

Current proofs start with `intro T _ _ _ F M tau t`. After `unfold truth_at`, the box modality now includes membership check. The fix is the same: add `Set.mem_univ` simplification or adjust intro patterns.

#### Pattern 6: Soundness Main Theorem

The `soundness` theorem (line 625) uses derivation induction and references `truth_at` in multiple places. The `temporal_duality` case references `SoundnessLemmas.derivable_implies_swap_valid` which returns a local `is_valid` - once SoundnessLemmas.lean is fixed, this should work.

### 5. Theorems Using `time_shift_preserves_truth` (Critical Path)

These 4 theorems need `ShiftClosed` discharge, all with `Set.univ_shift_closed`:

| File | Theorem | Line | Call Pattern |
|------|---------|------|-------------|
| SoundnessLemmas.lean | `swap_axiom_mf_valid` | 372 | `TimeShift.time_shift_preserves_truth M sigma t s ...` |
| SoundnessLemmas.lean | `swap_axiom_tf_valid` | 397 | `TimeShift.time_shift_preserves_truth M sigma t s ...` |
| SoundnessLemmas.lean | `axiom_modal_future_valid` | 756 | `TimeShift.time_shift_preserves_truth M sigma t s phi` |
| SoundnessLemmas.lean | `axiom_temp_future_valid` | 769 | `TimeShift.time_shift_preserves_truth M sigma t s phi` |
| Soundness.lean | `modal_future_valid` | 506 | `TimeShift.time_shift_preserves_truth M sigma t s phi` |
| Soundness.lean | `temp_future_valid` | 544 | `TimeShift.time_shift_preserves_truth M sigma t s phi` |

All 6 call sites are fixed identically: insert `Set.univ` after `M` and `Set.univ_shift_closed` after `Set.univ`.

### 6. Dependency Analysis

- **Task 907 (COMPLETED)**: Changed `truth_at` signature. All changes propagated to Truth.lean.
- **Task 908 (COMPLETED)**: Updated Validity.lean. `valid` and `semantic_consequence` now embed `Set.univ`. `satisfiable` now takes existential Omega.
- **No blocking issues from 907/908**: Both are fully committed. The Omega parameter in `truth_at` and `Set.univ` in Validity.lean are the foundation this task builds on.
- **Downstream impact**: After Phase 3 completes, Soundness.lean importers (listed below) may need updates:
  - `Metalogic/Completeness.lean`
  - `Metalogic/Bundle/SeedCompletion.lean`
  - `Metalogic/Decidability/Correctness.lean`
  - `Metalogic/FMP/SemanticCanonicalModel.lean`
  - `Metalogic/Metalogic.lean` (aggregator)
  - Boneyard files (should NOT be updated per convention)

### 7. Non-Mechanical Cases

After careful analysis, **there are zero non-mechanical cases**. Every change falls into one of the patterns above:

1. Insert `Set.univ` as Omega parameter to `truth_at` in `is_valid` definition
2. Add `Set.mem_univ`/`true_implies` simplification in proofs where box modality unfolds
3. Supply `Set.univ_shift_closed` to `time_shift_preserves_truth` calls

No proof strategies, lemma selections, or mathematical arguments need to change. The proofs are structurally identical; only the explicit parameters differ.

### 8. truth_at Box Modality Unfolding Detail

The critical detail for all box-related proofs: with `Omega = Set.univ`, after `simp only [truth_at]`:

**Old unfolding**: `forall (sigma : WorldHistory F), truth_at M sigma t phi`
**New unfolding**: `forall (sigma : WorldHistory F), sigma in Set.univ -> truth_at M Set.univ sigma t phi`

After `simp only [Set.mem_univ, true_implies]` (or `forall_true_left` / `implies_true_iff`):
**Simplified**: `forall (sigma : WorldHistory F), truth_at M Set.univ sigma t phi`

This recovers the exact same shape as before, so all subsequent proof steps work unchanged.

**Alternative approach**: Instead of `simp only [truth_at]` then `simp only [Set.mem_univ, true_implies]`, use `simp only [truth_at, Set.mem_univ, true_implies]` in a single call.

**Another alternative**: In intro patterns, write `intro sigma _` instead of `intro sigma` to absorb the `Set.mem_univ` hypothesis silently.

### 9. Estimated Effort

| Component | Theorems | Estimated Time |
|-----------|----------|---------------|
| SoundnessLemmas.lean: is_valid + utility (3) | 3 | 10 min |
| SoundnessLemmas.lean: swap axioms (8) | 8 | 20 min |
| SoundnessLemmas.lean: rule preservation (5) | 5 | 10 min |
| SoundnessLemmas.lean: axiom_swap_valid (1) | 1 | 10 min |
| SoundnessLemmas.lean: local axiom validity (17) | 17 | 25 min |
| SoundnessLemmas.lean: axiom_locally_valid (1) | 1 | 5 min |
| SoundnessLemmas.lean: combined theorem (1) | 1 | 15 min |
| SoundnessLemmas.lean: derived theorems (2) | 2 | 5 min |
| Soundness.lean: all theorems (20) | 20 | 30 min |
| Build verification | - | 10 min |
| **Total** | **58** | **~2.5 hours** |

## Recommendations

1. **Start with the `is_valid` definition change** (line 76-78). This single change propagates to all 35 SoundnessLemmas theorems, establishing the correct goal shapes for proof fixes.

2. **Fix theorems top-to-bottom** to avoid cascading error confusion. Each theorem is independent once `is_valid` is fixed.

3. **Use the `simp only [truth_at, Set.mem_univ, true_implies]` pattern** as the primary fix for box modality proofs. This cleanly eliminates the `Set.univ` membership obligation.

4. **For time_shift_preserves_truth callers**, the fix is always: insert `Set.univ Set.univ_shift_closed` as arguments 2-3 (after M, before sigma).

5. **Build incrementally**: After fixing SoundnessLemmas.lean, verify it compiles before moving to Soundness.lean.

6. **Do NOT update Boneyard files** - they are historical and expected to break.

## References

- `Theories/Bimodal/Semantics/Truth.lean` - Updated truth_at with Omega parameter (task 907)
- `Theories/Bimodal/Semantics/Validity.lean` - Updated valid/semantic_consequence with Set.univ (task 908)
- `specs/906_box_admissible_histories_omega_closure/plans/implementation-002.md` - Parent plan, Phase 3 specification
- `specs/907_phase1_truth_omega_parameter/summaries/implementation-summary-20260219.md` - Phase 1 completion details
- `specs/908_phase2_validity_definitions/summaries/implementation-summary-20260219.md` - Phase 2 completion details

## Next Steps

1. Create implementation plan for task 909
2. Implement Phase 3 changes to SoundnessLemmas.lean (fix is_valid, then all 35 theorems)
3. Implement Phase 3 changes to Soundness.lean (fix all 20 theorems)
4. Build verify both files
5. Check downstream compilation (Phase 4-5 of parent task 906 handles Representation.lean and other files)
