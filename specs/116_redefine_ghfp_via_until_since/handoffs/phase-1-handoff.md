# Phase 1 Handoff: Core Redefinition

**Session**: sess_1779159757_8a4784
**Phase**: 1 of 5
**Status**: COMPLETED
**Date**: 2026-05-18

## What Was Done

### Formula.lean
- Removed `all_past` and `all_future` as constructors from `inductive Formula`
- Formula now has exactly 6 constructors: `atom`, `bot`, `imp`, `box`, `untl`, `snce`
- Added `def top`, moved `def neg` earlier in file
- Added `def some_future`, `def some_past`, `def all_future`, `def all_past` as derived abbreviations
- Removed all pattern-match arms for `all_past`/`all_future` from:
  - `complexity`, `beq_refl`, `eq_of_beq`, `modalDepth`, `temporalDepth`, `countImplications`
  - `swap_temporal`, `swap_temporal_involution`, `atoms`, `atoms_swap_temporal`, `predFormulas`
  - `needsPositiveHypotheses` simp lemmas, `beq_all_past_eq`/`beq_all_future_eq` helpers
- Updated docstrings to reflect 6-constructor design

### Truth.lean
- Removed `| all_past` and `| all_future` cases from `truth_at` definition
- Proved 4 `@[simp]` characterization theorems:
  - `Truth.some_future_iff`: `truth_at M Omega τ t (some_future φ) ↔ ∃ s, t < s ∧ truth_at M Omega τ s φ`
  - `Truth.some_past_iff`: `truth_at M Omega τ t (some_past φ) ↔ ∃ s, s < t ∧ truth_at M Omega τ s φ`
  - `Truth.future_iff`: `truth_at M Omega τ t φ.all_future ↔ ∀ s, t < s → truth_at M Omega τ s φ`
  - `Truth.past_iff`: `truth_at M Omega τ t φ.all_past ↔ ∀ s, s < t → truth_at M Omega τ s φ`
- Removed `| all_past` and `| all_future` induction arms from `truth_double_shift_cancel` and `time_shift_preserves_truth`

## Verification
- `lake build Bimodal.Syntax.Formula` passes with zero errors
- `lake build Bimodal.Semantics.Truth` passes with zero errors
- Zero sorries in either file

## Key Decisions
1. Definitions placed early in file (after `top`) so downstream defs (`always`, `weak_future`, etc.) can use dot notation
2. `some_future φ = untl φ top` (Burgess convention: event first)
3. `all_future φ = (some_future φ.neg).neg` (double negation of existential dual)
4. `swap_temporal` now only handles 6 constructors; `untl ↔ snce` swap handles temporal duality at the constructor level

## Immediate Next Action
Phase 2: Derive `temp_k_dist` and `temp_4` from BX axioms, remove axiom constructors.
Phase 3 (parallel): Fix all 26 downstream files that break due to missing constructor arms.

## Deviations
- Task 1.3 altered: `@[simp]` complexity lemmas not added since `all_future`/`all_past` are now defs that expand to `imp`/`untl`/`snce` structurally, so `complexity` handles them via the `imp` case automatically.
