# Research Report: Task #864

**Task**: Recursive seed construction for Henkin model completeness
**Date**: 2026-02-18
**Focus**: Closure.lean error analysis and remediation path

## Summary

Closure.lean (`Theories/Bimodal/Metalogic/Bundle/RecursiveSeed/Closure.lean`) has **77 build errors** falling into **7 distinct error categories**. The majority are systematic and fixable with mechanical transformations. Only 1 sorry exists in the file (the Dershowitz-Manna termination argument at line 3518). This report categorizes every error, explains its root cause, and provides a concrete remediation path ordered by dependency.

## Error Inventory

### Category 1: Duplicate Declarations (10 errors, Lines 288-893)

**Root Cause**: When RecursiveSeed.lean was split into 5 files, certain helper lemmas were duplicated in both Worklist.lean and Closure.lean. The declarations in Worklist.lean are public (not `private`), while Closure.lean has copies marked `private`. However, `private` in Lean 4 still generates a namespace-scoped declaration that clashes with the imported one.

**Affected Lemmas** (all at Closure.lean, all duplicated from Worklist.lean):

| Line | Lemma Name |
|------|------------|
| 288 | `foldl_addFormula_fam_puts_phi_in_all` |
| 318 | `foldl_addFormula_fam_self_hasPosition` |
| 546 | `foldl_compound_future_preserves_mem` |
| 565 | `foldl_compound_past_preserves_mem` |
| 673 | `foldl_compound_future_puts_psi_in_all` |
| 725 | `foldl_compound_past_puts_psi_in_all` |
| 776 | `foldl_compound_future_preserves_hasPosition` |
| 793 | `foldl_compound_past_preserves_hasPosition` |
| 883 | `foldl_compound_future_self_hasPosition` |
| 893 | `foldl_compound_past_self_hasPosition` |

**Fix**: Delete these 10 lemma blocks entirely from Closure.lean. They are already available via `import Bimodal.Metalogic.Bundle.RecursiveSeed.Worklist`. All downstream code in Closure.lean already references them by unqualified name, so the imports will resolve correctly.

**Estimated effort**: 15 minutes. Delete ~600 lines of duplicated code.

**Important**: The versions in Closure.lean and Worklist.lean are NOT identical. The Closure.lean versions include additional lemmas like `foldl_compound_future_puts_gpsi_in_all` (line 700) and `foldl_compound_past_puts_hpsi_in_all` (line 751) that do NOT exist in Worklist.lean. These must be preserved. Additionally, the compound foldl variants in Closure.lean handle more complex patterns (adding both psi AND G/H psi) vs. the Worklist.lean versions. The `foldl_compound_future_puts_psi_in_all` and `foldl_compound_past_puts_psi_in_all` duplicates have different proof structures between the two files.

**Careful fix**: For each of the 10 duplicated lemmas, verify the Worklist.lean version has the same signature. If identical, delete from Closure.lean. If different, rename in Closure.lean to avoid the clash (e.g., prefix with `closure_` or change scope). But the simplest approach: since these are all `private`, change them to non-`private` in Closure.lean with unique names, OR just delete them and use the Worklist.lean versions (preferred).

### Category 2: `Prod.mk.injEq.mp` Unknown Constant (11 pairs = 22 errors, Lines 973-3002)

**Root Cause**: `Prod.mk.injEq` is a simp lemma of type `((a, b) = (c, d)) = (a = c ∧ b = d)`. It is not a theorem with an `.mp` method -- it's a propositional equality between `Prop`s (an `Eq` on `Prop`), not an `Iff`. Calling `.mp` on an `Eq` does not work. This was likely a Mathlib API change where `Prod.mk.injEq` changed from `Iff` to `Eq`.

**Affected Lines**: 973, 1088, 1190, 1292, 1403, 1661, 1820, 2346, 2551, 3002 (each produces 2 errors: the `.mp` call and the cascading `rcases` failure).

**Pattern in code**:
```lean
obtain ⟨h_newWork, h_state'⟩ := Prod.mk.injEq.mp h_proc
```

**Fix**: Replace with either:
```lean
-- Option A: Use simp to rewrite h_proc, then obtain
simp only [Prod.mk.injEq] at h_proc
obtain ⟨h_newWork, h_state'⟩ := h_proc
```
or:
```lean
-- Option B: Use Prod.mk.inj directly
obtain ⟨h_newWork, h_state'⟩ := Prod.mk.inj h_proc
```

**Estimated effort**: 20 minutes. Mechanical replacement at 11 locations.

### Category 3: `List.find?_append` Rewrite Failures (5 errors, Lines 172, 204, 243, 280, 3444, 3478)

**Root Cause**: After `unfold ModelSeed.addFormula ModelSeed.getFormulas ModelSeed.findEntry`, the term `seed.entries ++ [newEntry]` is wrapped inside a struct constructor: `{entries := seed.entries ++ [...], ...}.entries`. The rewrite `rw [List.find?_append]` expects to see `List.find? p (xs ++ ys)` directly, but the goal contains `List.find? p ({entries := xs ++ ys, ...}.entries)` where the struct projection blocks pattern matching.

**Fix**: Add `simp only [ModelSeed.entries]` or `dsimp only` before the `rw [List.find?_append]` to reduce the struct projection, exposing the raw `xs ++ ys` term. Alternatively, use `simp only [List.find?_append]` instead of `rw` since `simp` handles definitional equality better.

**Note**: Lines 3444 and 3478 have different root causes -- they are in `processWorklistAux_preserves_closure` and the pattern is `state.processed` vs `result.2.processed`. These are cascading from Category 7 (downstream proof structure errors).

**Estimated effort**: 20 minutes for lines 172-280. Lines 3444/3478 are part of Category 7.

### Category 4: `List.find?_eq_some_iff_getElem` and Related API Renames (3 errors, Lines 275, 449, 538)

**Root Cause**: Multiple Lean/Mathlib API name changes:

| Line | Used Name | Correct Name |
|------|-----------|--------------|
| 275 | `List.find?_eq_getElem?_find` | Does not exist. Need different approach. |
| 449 | `List.findIdx?_eq_some_iff` | `List.findIdx?_eq_some_iff_getElem` |
| 538 | `List.mem_eraseDups` | `List.mem_dedup` |

**Line 275 context**: The code uses `List.find?_eq_getElem?_find` to convert `find?` to `getElem?`-based form, then `List.findIdx_modify_of_eq_false` to show modifying at idx doesn't change `findIdx` for a different predicate. Neither `List.find?_eq_getElem?_find` nor `List.findIdx_modify_of_eq_false` exist in current Mathlib. This entire proof approach for the `some idx` case of `mem_getFormulas_after_addFormula` (showing find? is unchanged when modify happens at a different predicate's idx) needs to be reworked.

**Fix for line 449**: Replace `List.findIdx?_eq_some_iff` with `List.findIdx?_eq_some_iff_getElem`.

**Fix for line 538**: Replace `List.mem_eraseDups` with `List.mem_dedup`.

**Fix for line 275**: The approach at lines 273-280 needs a complete rewrite. Instead of trying to show `find? p (modify idx ...) = find? p original`, prove it element-by-element using `List.find?_eq_some_iff_append` or by showing `modify` at position `idx` where `p idx = false` does not affect elements matched by `p`. One approach:
```lean
have h_find_unchanged : ... := by
  apply List.find?_eq_find? -- or manual induction on the list
  intro i hi
  rw [List.getElem_modify]
  split
  · -- i = idx: but p idx = false, so this entry is skipped by find? anyway
    omega
  · -- i ≠ idx: entry unchanged
    rfl
```

**Estimated effort**: 30 minutes (mostly for the line 275 rewrite).

### Category 5: Invalid `▸` Notation (4 errors, Lines 612, 615, 657, 660)

**Root Cause**: Lines 612/615/657/660 use `▸` to substitute equalities in complex `Or` goals. The `▸` tactic has become stricter in recent Lean 4 versions and fails when the target type involves dependent types or when the substitution target is ambiguous.

**Pattern**:
```lean
exact Or.inr (Or.inl ⟨h_eq, List.mem_cons_of_mem time (ht ▸ hf ▸ List.mem_cons_self t rest), hf⟩)
```

**Fix**: Replace `▸` with explicit `subst` before the `exact`, or use `rw` to rewrite in context:
```lean
subst ht; subst hf
exact Or.inr (Or.inl ⟨h_eq, List.mem_cons_of_mem time (List.mem_cons_self f rest), rfl⟩)
```
Or, if the equalities are in the wrong direction, use `rw [ht, hf]` at the appropriate subgoal.

**Estimated effort**: 15 minutes.

### Category 6: Type Mismatches and `simp`/`constructor` Failures (15 errors, Lines 184-513)

These are scattered errors in the `mem_getFormulas_after_addFormula` proof and the `foldl_addFormula_fam_preserves_hasPosition_not_in` proof:

| Line | Error | Root Cause |
|------|-------|------------|
| 184 | Type mismatch | `h_spec.2.1` structure changed due to `findIdx?_eq_some_iff_getElem` return type |
| 191 | Type mismatch | Same cascading |
| 238 | Invalid projection `.1` on non-struct | `hp.1` fails because `Bool.and_eq_true` changed simp behavior |
| 239 | Invalid projection `.2` on non-struct | Same |
| 263 | Type mismatch | `p' seed.entries[idx]` - predicate application type |
| 267 | `simp` made no progress | `Bool.not_eq_false` no longer simplifies this term |
| 337, 347 | Application type mismatch | `addFormula_preserves_getFormulas_diff_fam` argument count/type changed |
| 348 | No goals to be solved | Cascading from 347 |
| 384, 413, 440 | Function expected | Same cascading |
| 513 | Constructor failed | `hasPosition` is not a structure with `constructor` |

**Root Cause Analysis**: Most of these cascade from the `mem_getFormulas_after_addFormula` proof (lines 161-282), which is the foundational lemma. The proof manipulates raw `List.find?`, `List.findIdx?`, and `List.modify` operations on the entries list, and several Lean/Mathlib APIs have changed since the proof was written.

**Fix strategy**: The `mem_getFormulas_after_addFormula` lemma (lines 161-282) needs to be rewritten almost entirely. It's the first non-trivial lemma in the file and nearly all subsequent code depends on it. The approach should use the current APIs:
- `List.findIdx?_eq_some_iff_getElem` instead of the old form
- `List.find?_eq_some_iff_append` for `find?` on appended lists
- Direct `simp` on struct projections before rewriting
- `List.getElem_modify` for modify-related reasoning

**Estimated effort**: 2-3 hours for the full rewrite of this lemma.

### Category 7: `processWorklistAux_preserves_closure` Proof Structure (15 errors, Lines 3214-3537)

These errors are in the main proof loop `processWorklistAux_preserves_closure` (lines 3275-3548):

| Line | Error | Root Cause |
|------|-------|------------|
| 3214 | `rfl` expected `True` | `initial_pos_invariant` goal changed after simp |
| 3307 | `rfl` vs filter expression | `h_ne rfl` doesn't match the refined filter type |
| 3322 | `h_not` wrong type | `decide (w ∉ state.processed) = true` vs `w ∉ state.processed` |
| 3324 | Function expected at `List.not_mem_nil` | Cascading from 3322 |
| 3376, 3387, 3397 | Unknown identifier `h` | `cases hw` doesn't introduce `h` anymore (naming changed) |
| 3410 | `simp` no progress | `WorklistState.worklist`/`.processed` no longer simp lemmas |
| 3423 | `List.mem_cons_self` applied as function | API changed: now takes no explicit arguments |
| 3444 | rewrite failed | `processWorkItem ... .processed` pattern missing |
| 3465 | Function expected | Cascading |
| 3478 | rewrite failed | `state.processed` vs `result.2.processed` |
| 3537 | `unfold processWorklist` failed | `processWorklist` already unfolded |

**Root Cause**: These are a mix of:
1. Lean 4 API changes (`List.mem_cons_self` no longer takes explicit args)
2. `decide` wrapping changes (membership in `Finset` now uses `decide`)
3. `simp`/`unfold` behavior changes for structure field projections
4. Case/match naming changes

**Fix strategy**: Each fix is relatively local. The `processWorklistAux_preserves_closure` theorem structure is sound -- these are purely syntactic issues with tactic invocations. Key fixes:
- Line 3214: Replace `exact ⟨rfl, rfl⟩` with `exact ⟨trivial, trivial⟩` or similar
- Line 3307: Use `simp` to normalize the filter expression before the contradiction
- Line 3322: Add `simp only [decide_eq_true_eq]` or `decide` to bridge the gap
- Lines 3376/3387/3397: Use `rename_i` or explicit match to bind the case variable
- Line 3423: Remove explicit arguments from `List.mem_cons_self`
- Line 3537: Remove the `unfold processWorklist` (goal already expanded)

**Estimated effort**: 2 hours.

## Remediation Path

### Phase 1: Delete Duplicate Declarations (Category 1)

**Priority**: Highest (blocks everything, simplest fix)
**Time**: 15 minutes
**Lines to delete**: ~600 lines covering 10 lemma blocks
**Impact**: Reduces error count by 10, removes ~600 lines of dead code

Delete these lemma blocks from Closure.lean (keep unique lemmas like `foldl_compound_future_puts_gpsi_in_all`):
1. Lines 288-315: `foldl_addFormula_fam_puts_phi_in_all`
2. Lines 317-323: `foldl_addFormula_fam_self_hasPosition`
3. Lines 546-563: `foldl_compound_future_preserves_mem`
4. Lines 565-584: `foldl_compound_past_preserves_mem`
5. Lines 673-695: `foldl_compound_future_puts_psi_in_all`
6. Lines 725-768: `foldl_compound_past_puts_psi_in_all`
7. Lines 776-790: `foldl_compound_future_preserves_hasPosition`
8. Lines 793-810: `foldl_compound_past_preserves_hasPosition`
9. Lines 883-891: `foldl_compound_future_self_hasPosition`
10. Lines 893-901: `foldl_compound_past_self_hasPosition`

**Verification needed**: After deletion, check that no unique lemma depended on a local version. The compound foldl lemmas in Closure.lean may have slightly different argument types than Worklist.lean versions.

### Phase 2: Fix `mem_getFormulas_after_addFormula` (Categories 3, 4, 6)

**Priority**: High (most downstream code depends on this)
**Time**: 2-3 hours
**Lines**: 161-282 (+ scattered fixes at 325-528)

This is the hardest fix. The proof manipulates raw list operations and has been broken by multiple API changes. The recommended approach:

1. **Rewrite the `none` branch** (lines 170-179): Fix `List.find?_append` rewrite by first simplifying struct projections with `simp only [ModelSeed.entries]` or `dsimp only`.

2. **Rewrite the `some idx` branch** (lines 180-224): Replace the `List.find?_eq_some_iff_getElem` approach (which doesn't exist) with a proof that proceeds by showing the modified list's `find?` result equals the original's, using `List.find?_eq_some_iff_append` and element-by-element reasoning via `List.getElem_modify`.

3. **Rewrite the `h_pos = false` branch** (lines 225-282): Fix the `List.find?_eq_getElem?_find` (nonexistent) usage at line 275. Replace with an induction-based proof or use `List.find?_ext` if available.

4. **Fix downstream lemmas**: Lines 325-528 have cascading errors from the compound foldl lemmas. After Category 1 deletions and the `mem_getFormulas_after_addFormula` rewrite, many of these will resolve automatically.

### Phase 3: Fix `Prod.mk.injEq.mp` Errors (Category 2)

**Priority**: Medium (blocks main proof but fix is mechanical)
**Time**: 20 minutes
**Lines**: 973, 1088, 1190, 1292, 1403, 1661, 1820, 2346, 2551, 3002

Replace all 11 occurrences of:
```lean
obtain ⟨h_newWork, h_state'⟩ := Prod.mk.injEq.mp h_proc
```
with:
```lean
simp only [Prod.mk.injEq] at h_proc
obtain ⟨h_newWork, h_state'⟩ := h_proc
```

### Phase 4: Fix `▸` Notation Errors (Category 5)

**Priority**: Medium
**Time**: 15 minutes
**Lines**: 612, 615, 657, 660

Replace `ht ▸ hf ▸ expr` with explicit `subst` followed by the simplified expression.

### Phase 5: Fix `processWorklistAux_preserves_closure` (Category 7)

**Priority**: Lower (depends on Phases 1-4)
**Time**: 2 hours
**Lines**: 3214-3537

Fix the remaining syntactic issues in the main proof loop. These are mostly:
- API name changes (e.g., `List.mem_cons_self`)
- `decide` wrapping for Finset membership
- Structure field projection simplification
- Case naming

### Phase 6: Address the Termination Sorry (Line 3518)

**Priority**: Separate concern (not a build error)
**Time**: 3-5 hours
**Lines**: 3518

The single sorry at line 3518 is the Dershowitz-Manna multiset ordering termination argument. This is mathematically valid but requires formalization. Options:

1. **Use Mathlib's `Multiset.lt`**: Import `Mathlib.Data.Multiset.DershowitzManna` (already imported!) and prove that processing a work item strictly decreases the multiset of pending complexities under the DM ordering.

2. **Well-founded recursion**: Restructure `processWorklistAux` to use well-founded recursion on the multiset ordering instead of fuel.

3. **Document as technical debt**: If the DM formalization is too complex, the sorry is well-isolated and does not affect the correctness of the mathematical argument.

## Dependency Order

```
Phase 1 (duplicates) ──→ Phase 2 (mem_getFormulas) ──→ Phase 3 (Prod.mk)
                                                    ──→ Phase 4 (▸ notation)
                                                    ──→ Phase 5 (processWorklist)
                                                    ──→ Phase 6 (termination)
```

Phase 1 should be done first because duplicate declarations block Lean from processing subsequent code correctly. Phase 2 is the most critical because `mem_getFormulas_after_addFormula` is foundational. Phases 3-5 can be done in any order after Phase 2. Phase 6 is independent.

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| `mem_getFormulas_after_addFormula` rewrite takes longer than expected | Medium | High | Consider a simpler proof strategy using `addFormula_preserves_mem_getFormulas` from Builder.lean instead of reproving from scratch |
| Worklist.lean versions of deleted lemmas have incompatible signatures | Low | Medium | Verify signatures match before deleting; if different, rename instead |
| `processWorklistAux` proof structure unsound after fixes | Low | High | The mathematical structure is correct; only tactic invocations need updating |
| DM termination sorry blocks downstream consumers | Low | Low | The sorry is well-isolated; `buildSeedComplete_closed` would still type-check modulo the sorry |

## Recommendations

1. **Start with Phase 1**: Deleting duplicates is risk-free and immediately reduces noise by 10 errors and ~600 lines.

2. **Consider alternative proof for `mem_getFormulas_after_addFormula`**: Instead of fighting the low-level List API, consider proving this via `addFormula_preserves_mem_getFormulas` and `addFormula_formula_in_getFormulas` (both exist in Builder.lean, lines 6018 and 2576 respectively). These higher-level lemmas may provide a cleaner proof path.

3. **Fix `Prod.mk.injEq.mp` with global search-replace**: This is perfectly mechanical -- a single regex replacement across the file.

4. **For the termination sorry**: The Dershowitz-Manna import is already present. The key lemma needed is `Multiset.lt_wf` or similar well-foundedness proof. Use `Finsupp.lt_wf` as an alternative if multiset ordering is hard to apply.

5. **Maintain sorry-free and axiom-free goal**: All errors are syntactic/API issues, not mathematical gaps. The 1 sorry (DM termination) is the only genuine proof obligation remaining.

## References

- `Theories/Bimodal/Metalogic/Bundle/RecursiveSeed/Closure.lean` -- Target file (3,577 lines, 77 errors, 1 sorry)
- `Theories/Bimodal/Metalogic/Bundle/RecursiveSeed/Worklist.lean` -- Contains duplicated lemma definitions (builds clean)
- `Theories/Bimodal/Metalogic/Bundle/RecursiveSeed/Builder.lean` -- Contains `addFormula_*` infrastructure (builds clean)
- `specs/864_recursive_seed_henkin_model/plans/implementation-007.md` -- Current implementation plan (v7)
- `specs/864_recursive_seed_henkin_model/summaries/implementation-summary-20260218.md` -- Latest session summary

## Next Steps

1. Implement Phase 1 (delete duplicates) and rebuild to get a clearer error count
2. Implement Phase 2 (rewrite `mem_getFormulas_after_addFormula`) -- this is the critical path
3. Implement Phases 3-5 (mechanical fixes)
4. Rebuild and verify 0 errors (excluding the 1 sorry)
5. Address the DM termination sorry (Phase 6)
6. Proceed to Phase 5 of implementation-007.md (barrel file + build graph integration)
