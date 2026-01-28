# Research Report: Task #716

**Task**: 716 - Fix SoundnessLemmas type mismatches
**Started**: 2026-01-28T17:55:45Z
**Completed**: 2026-01-28T18:04:30Z
**Effort**: 2-3 hours
**Priority**: High
**Dependencies**: None
**Sources/Inputs**: Lean MCP tools, git history, Bimodal/Semantics/Truth.lean
**Artifacts**: specs/716_fix_soundnesslemmas_type_mismatches/reports/research-001.md
**Standards**: report-format.md

## Executive Summary

- The errors stem from a semantics change in task 658 that updated temporal operators from strict (`<`) to reflexive (`≤`) ordering
- SoundnessLemmas.lean in Boneyard was not updated and still uses strict ordering patterns
- 5 type mismatch errors at lines 263, 287, 288, 339, 363 all require adapting proofs to reflexive semantics
- 2 `sorry` placeholders at lines 590-591 and 791-792 for `temp_t_future` and `temp_t_past` axioms are now provable with reflexive semantics

## Context & Scope

### Background

Task 658 (commit a454f293) changed the `truth_at` semantics for temporal operators from strict to reflexive ordering:

**Before (strict):**
```lean
| Formula.all_past φ => ∀ (s : D), s < t → truth_at M τ s φ
| Formula.all_future φ => ∀ (s : D), t < s → truth_at M τ s φ
```

**After (reflexive):**
```lean
| Formula.all_past φ => ∀ (s : D), s ≤ t → truth_at M τ s φ
| Formula.all_future φ => ∀ (s : D), t ≤ s → truth_at M τ s φ
```

This change aligns with the paper reference (def:BL-semantics) and enables temporal T axioms (`Gφ → φ`, `Hφ → φ`).

### File Location

`Theories/Bimodal/Boneyard/Metalogic/Soundness/SoundnessLemmas.lean`

The file is in the Boneyard folder, indicating it's legacy code that wasn't updated during the semantics refactoring.

## Findings

### Error Analysis

| Line | Theorem | Error | Root Cause |
|------|---------|-------|------------|
| 263 | `swap_axiom_t4_valid` | `h_r_lt_t : r ≤ t` but expected `r < t` | Uses `lt_trans` instead of `le_trans` |
| 287 | `swap_axiom_ta_valid` | `h_s_lt_t : s ≤ t` but expected `s < t` | Comment says "s < t" but simp gives `s ≤ t` |
| 288 | `swap_axiom_ta_valid` | `h_t_gt_s : s < t` but expected `s ≤ t` | Derived strict inequality used in reflexive context |
| 339 | `swap_axiom_tl_valid` | `h_ut : u < t` but expected `u ≤ t` | Uses `h_past u h_ut` where h_past requires `≤` |
| 363 | `swap_axiom_tl_valid` | `h_gt : t < u` but expected `t ≤ u` | Uses `h_fut_all u h_gt` where h_fut_all requires `≤` |

### Key Observations

1. **swap_temporal behavior**: When `all_future φ` is swapped, it becomes `all_past (swap φ)`, which now uses `s ≤ t` instead of `s < t`.

2. **Proof pattern changes needed**:
   - Replace `lt_trans` with `le_trans` for transitivity
   - Use `le_of_lt` to convert strict inequalities to non-strict when needed
   - Update hypothesis names from `h_*_lt_*` to `h_*_le_*` for clarity

3. **New axioms now provable**: The `temp_t_future` and `temp_t_past` axioms (temporal reflexivity) are trivially valid with reflexive semantics:
   - `Gφ → φ`: From `∀ s. t ≤ s → φ(s)`, instantiate with `s = t` using `le_refl t`
   - `Hφ → φ`: From `∀ s. s ≤ t → φ(s)`, instantiate with `s = t` using `le_refl t`

### Relevant Mathlib Lemmas

| Lemma | Type | Purpose |
|-------|------|---------|
| `le_trans` | `a ≤ b → b ≤ c → a ≤ c` | Replace `lt_trans` in transitivity proofs |
| `le_of_lt` | `a < b → a ≤ b` | Convert strict to non-strict inequality |
| `lt_of_lt_of_le` | `a < b → b ≤ c → a < c` | Mixed transitivity |
| `lt_of_le_of_lt` | `a ≤ b → b < c → a < c` | Mixed transitivity |
| `le_refl` | `a ≤ a` | Reflexivity for temporal T axioms |

### Theorem-by-Theorem Fix Strategy

#### 1. `swap_axiom_t4_valid` (lines 253-264)

**Current (broken):**
```lean
intro h_past_swap r h_r_lt_t u h_u_lt_r
have h_u_lt_t : u < t := lt_trans h_u_lt_r h_r_lt_t
exact h_past_swap u h_u_lt_t
```

**Fix:**
```lean
intro h_past_swap r h_r_le_t u h_u_le_r
-- h_r_le_t : r ≤ t, h_u_le_r : u ≤ r
have h_u_le_t : u ≤ t := le_trans h_u_le_r h_r_le_t
exact h_past_swap u h_u_le_t
```

#### 2. `swap_axiom_ta_valid` (lines 278-288)

**Issue:** The proof uses `h_s_lt_t` as if it were `s < t`, but the reflexive semantics gives `s ≤ t`.

The swapped formula `P(sometime_future(swap φ))` means:
- For all `s ≤ t`, there exists `u` with `t ≤ u` where `swap φ` holds

**Fix:** Use `t` as the witness for `u`, since `t ≤ t` (reflexivity).

```lean
intro h_swap_φ s h_s_le_t
-- Goal: ¬(∀ u. t ≤ u → ¬ truth_at M τ u φ.swap)
intro h_all_not_future
-- Choose u = t, since t ≤ t by reflexivity
exact h_all_not_future t (le_refl t) h_swap_φ
```

#### 3. `swap_axiom_tl_valid` (lines 310-363)

**Issue:** The case analysis uses strict inequalities but the semantic clauses now use `≤`.

**Fix:** Adapt case analysis to use `le_or_lt` pattern:
- Case `u ≤ t`: Further split into `u < t` or `u = t`
- Case `u > t`: Use `le_of_lt` to convert

Actually, simpler approach - since `always φ` means `φ` holds at all times, and we have reflexive quantification, we can use `le_refl` for the present case and appropriate transitivity for other cases.

#### 4. Temporal T axioms (lines 590-591, 791-792)

**Current:**
```lean
| temp_t_future ψ => sorry
| temp_t_past ψ => sorry
```

**Fix for `temp_t_future`:**
```lean
| temp_t_future ψ =>
  intro F M τ t
  simp only [Formula.swap_temporal, truth_at]
  -- swap(Gφ → φ) = swap(Gφ) → swap(φ) = H(swap φ) → swap φ
  -- Goal: (∀ s. s ≤ t → truth_at ... swap φ) → truth_at ... swap φ
  intro h_past_swap
  exact h_past_swap t (le_refl t)
```

**Fix for `temp_t_past`:**
```lean
| temp_t_past ψ =>
  intro F M τ t
  simp only [Formula.swap_temporal, truth_at]
  -- swap(Hφ → φ) = swap(Hφ) → swap(φ) = G(swap φ) → swap φ
  -- Goal: (∀ s. t ≤ s → truth_at ... swap φ) → truth_at ... swap φ
  intro h_future_swap
  exact h_future_swap t (le_refl t)
```

Same pattern for `axiom_locally_valid` cases.

## Decisions

1. **Update all proofs to reflexive semantics** rather than reverting Truth.lean - the reflexive semantics is the correct interpretation per the paper reference.

2. **Use consistent naming convention**: Rename `h_*_lt_*` variables to `h_*_le_*` in affected proofs for clarity.

3. **Fill in sorry placeholders**: The temporal T axioms are now provable and should be completed.

## Recommendations

1. **Update `swap_axiom_t4_valid`**: Replace `lt_trans` with `le_trans`

2. **Update `swap_axiom_ta_valid`**: Use `le_refl t` instead of deriving `s < t`

3. **Update `swap_axiom_tl_valid`**: Adapt case analysis to use `le_of_lt` conversions

4. **Complete `temp_t_future` and `temp_t_past`**: Both in `axiom_swap_valid` and `axiom_locally_valid`, use reflexivity `le_refl t`

5. **Update proof comments**: Change references from `s < t` to `s ≤ t` throughout

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Proof structure changes break downstream theorems | Medium | Run full `lake build` after each theorem fix |
| `always` encoding in TL case is complex | Low | Test with `lean_multi_attempt` before committing |
| MCP tools timing out during implementation | Medium | Use direct proof attempts, verify with `lake build` |

## Appendix

### Search Queries Used

- `?x ≤ ?y → ?y < ?z → ?x < ?z` → `lt_of_le_of_lt`
- `?x < ?y → ?y ≤ ?z → ?x < ?z` → `lt_of_lt_of_le`
- `le_trans` → Found in Batteries, Mathlib
- `le_of_lt` → Found in Init.Grind.Ordered.Order

### Git History

- Task 658 (commit a454f293): Changed semantics to reflexive
- Task 658 Phase 3 (commit 4d790e3b): Fixed time-shift theorems
- Task 658 Phase 5 (commit 495e4fa1): Updated documentation

### References

- `Theories/Bimodal/Semantics/Truth.lean:108-114` - truth_at definition
- `Theories/Bimodal/Syntax/Formula.lean:289-295` - swap_temporal definition
- `Theories/Bimodal/ProofSystem/Axioms.lean:262,275` - temp_t_future/past axioms

## Next Steps

Proceed to `/plan 716` to create a phased implementation plan with:
- Phase 1: Fix transitivity errors (lines 263, 339, 363)
- Phase 2: Fix reflexivity errors (lines 287, 288)
- Phase 3: Complete sorry placeholders (lines 590-591, 791-792)
- Phase 4: Update comments and verify build
