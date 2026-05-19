# Phase 3 Handoff: Groups A-E (Partial)

## Session
- **Session ID**: sess_1779159757_8a4784
- **Timestamp**: 2026-05-18
- **Phase**: 3 (Fix All Downstream Files)
- **Status**: IN PROGRESS (11 of ~26 files fixed)

## What Was Done

### Files Fixed (11 total)
1. **Syntax/Subformulas.lean** - Removed `all_future`/`all_past` match arms from `subformulas`, induction cases from `subformulas_trans`, rewrote `all_past_inner_mem_subformulas`/`all_future_inner_mem_subformulas` with structural unfolding
2. **Semantics/Validity.lean** - Fixed `valid_of_valid_all_future`/`valid_of_valid_all_past` using `simp only [Truth.future_iff]`/`Truth.past_iff`
3. **BXCanonical/Quasimodel/SubformulaClosure.lean** - Removed 2 pattern arms from `subformulas` Finset function
4. **Decidability/SignedFormula.lean** - Removed all_future/all_past from `subformulas`, `subformulas_trans`, `unexpandedComplexity`
5. **SoundnessLemmas.lean** - HARDEST FILE. Fixed 102 errors across 2464 lines. Key changes:
   - Added 4 `@[simp]` swap_temporal lemmas to Formula.lean
   - Rewrote all axiom validity proofs to use `Truth.future_iff`/`past_iff`/`some_future_iff`/`some_past_iff`
   - Changed existential encoding: old `fun s hts => ...` function-style → new `⟨s, hts, ...⟩` anonymous constructor
   - Fixed swap patterns: use `swap_temporal_all_future` before `Formula.swap_temporal` in simp calls
6. **WeakCanonical/Table.lean** - Removed all_future/all_past from `operator_depth`, `table`, `temporal_truth`, `table_depth_bound`, `table_correctness`
7. **GeneralizedNecessitation.lean** - Added `swap_temporal_all_future` to simp calls for temporal duality proofs
8. **Perpetuity/Helpers.lean** - Added `swap_temporal_all_future` to simp call in `box_to_past`
9. **TemporalDerived.lean** - Fixed `H_transitivity` swap proof (needed explicit `rw [h_inv]` after simp)
10. **Core/MCSProperties.lean** - Fixed `temp_4_past` swap proof
11. **Syntax/Formula.lean** - Added 4 new `@[simp]` theorems:
    - `swap_temporal_some_future`, `swap_temporal_some_past`
    - `swap_temporal_all_future`, `swap_temporal_all_past`

### Key Technical Patterns

**Pattern 1: simp lemma ordering for swap contexts**
```lean
-- CORRECT: unfold swap_temporal_all_future FIRST, then Formula.swap_temporal
simp only [Formula.swap_temporal_all_future, Formula.swap_temporal]
simp only [truth_at, Truth.past_iff]

-- WRONG: Formula.swap_temporal alone doesn't see through all_future def
simp only [Formula.swap_temporal, truth_at]
```

**Pattern 2: Existential proof encoding**
Old (when `some_future` was implicitly `∀ s, t < s → ¬φ(s) → False`):
```lean
intro h_F; exact h_F s hts h_φs
```
New (with `@[simp] Truth.some_future_iff` giving `∃ s, t < s ∧ φ(s)`):
```lean
exact ⟨s, hts, h_φs⟩
```

**Pattern 3: let-binding opacity with swap_temporal_involution**
When `ψ := φ.swap_temporal`, `simp` cannot simplify `ψ.swap_temporal` to `φ`. Need explicit:
```lean
have h_inv : ψ.swap_temporal = φ := Formula.swap_temporal_involution φ
rw [h_inv] at h2
```

## What Remains

### Failing Modules (4)
1. **Syntax/SubformulaClosure.lean** - 63 errors. Heavy use of injection/noConfusion with `all_future`/`all_past` as constructors. Needs major rewrite of closure_* theorems and decidability proofs.
2. **Metalogic/Soundness.lean** - 42 errors. Same patterns as SoundnessLemmas but in the main soundness theorem. Apply same fix patterns.
3. **Theorems/Perpetuity/Principles.lean** - 5 errors. Type mismatches from swap_temporal changes.
4. **Metalogic/Bundle/TemporalContent.lean** - Downstream of Soundness.lean.

### Error Count
- Before this session: 138 errors across 8 files
- After this session: 118 errors across 4 files (8 original files + 3 cascades fixed, 4 new cascades exposed)

### Immediate Next Action
Fix **Soundness.lean** (42 errors) - apply the same patterns used in SoundnessLemmas.lean:
1. Add `swap_temporal_all_future`/`swap_temporal_all_past` to simp calls
2. Add `Truth.future_iff`/`Truth.past_iff`/`Truth.some_future_iff`/`Truth.some_past_iff`
3. Change function-style existential proofs to anonymous constructor style

Then fix **SubformulaClosure.lean** (Syntax, 63 errors) - this is the most complex remaining file due to injection/noConfusion changes.

## Key Decisions
- Added 4 `@[simp]` swap_temporal lemmas to Formula.lean for reuse across all files
- Used two-phase simp approach: first unfold swap_temporal for defs, then unfold truth_at with Truth simp lemmas
- Kept all proofs using `simp only` (not bare `simp`) per stability mandate
