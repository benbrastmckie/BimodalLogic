# Handoff: Task 864 - Phase 1F (Iteration 2)

## Immediate Next Action

Fix the `processWorkItem_preserves_closure` theorem for the boxPositive, futurePositive, pastPositive, boxNegative, futureNegative, and pastNegative formula cases (lines 1188-3200+ of Closure.lean). The theorem currently has 103 errors, all in these cases.

## Current State

- **File**: `Theories/Bimodal/Metalogic/Bundle/RecursiveSeed/Closure.lean` (3448 lines, 1 sorry for DM termination)
- **First error**: Line 1210 (all lines before 1210 compile cleanly)
- **Error count**: 103 errors (all in lines 1210-2483+)
- **Formula cases with errors**: boxPositive (line 1188), boxNegative (1458), futurePositive (1630), futureNegative (2169), pastPositive (2387), pastNegative (2851)

## Key Decisions Made

### 1. hasPosition proof simplified (lines 371-390)
Replaced complex manual proof (unfolding hasPosition as List.any, using constructor on Bool equality) with high-level reasoning using `addFormula_preserves_hasPosition` (forward) and `addFormula_hasPosition_backward` (backward) via `Bool.eq_iff_iff`.

### 2. foldl_addFormula_times_puts_phi_in_all simplified (lines 274-285)
Replaced nested inner induction with inline sufficiency proof using `addFormula_preserves_mem_getFormulas`.

### 3. Triangle notation fixed (lines 460, 463, 505, 508)
Replaced `ht ▸ hf ▸ .head _` with `subst hf ht; exact Or.inr (... ⟨..., .head _, rfl⟩)`. The `▸` notation failed because the cast target types didn't match.

### 4. Unknown identifier `time` fixed (lines 599, 602, 635, 638)
After `subst hf ht`, the variable `time` from `cons time rest ih` is substituted away (replaced by `t`). Changed `List.mem_cons_of_mem time (.head _)` to `.head _`.

### 5. addFormula_preserves_mem_getFormulas (lines 732+)
Replaced `addFormula_preserves_mem_getFormulas_same state.seed f' t psi item.formula ...` with `addFormula_preserves_mem_getFormulas state.seed f' t psi item.formula item.famIdx item.timeIdx ...`. The `_same` variant adds and queries at the same position, but the proof needs to add at `(item.famIdx, item.timeIdx)` and query at `(f', t)`.

### 6. Worklist membership (lines 755+)
Replaced `List.mem_append_left _ hw_in` with `hw_in`. The new state's worklist is `state.worklist ++ newWork.filter (...)`, so `hw_in : w ∈ state.worklist` suffices via `List.mem_append_left` already applied at the right level. Actually `hw_in` works directly when the worklist projection reduces.

### 7. Finset.mem_insert pattern (lines 756+)
Replaced `fun h_mem => hw_eq.2.2.2 (Set.mem_insert_of_mem item h_mem)` with proper Finset.mem_insert handling. The old pattern was wrong: it tried to grow the set instead of decomposing membership. The correct pattern:
```lean
by intro h_mem
   rcases Finset.mem_insert.mp h_mem with rfl | h_old
   · simp_all [classifyFormula]  -- w = item: contradicts formula class
   · exact hw_eq.2.2.2 h_old     -- w ∈ state.processed: contradicts hw_eq
```
This works for all 12 simple cases (atomic, bottom, implication, negation x 3 invariants) but NOT for the positive cases where `w.formula` could structurally match `item.formula`.

## What NOT to Try

### 1. Do NOT use `Set.mem_insert_of_mem` for the processed set pattern
This was the original code's approach and it's fundamentally wrong - it grows the set instead of decomposing.

### 2. Do NOT apply `mem_getFormulas_after_foldl_fam` with mismatched time parameters
The lemma requires `h_mem : phi ∈ (fams.foldl ... seed).getFormulas f t` where `t` matches the time in the foldl lambda. When the queried time differs from the foldl time, you need `by_cases h_time : t = item.timeIdx` and handle separately.

### 3. Do NOT assume `h_box` (or similar hypothesis) has simplified types
The hypothesis types include structure projections like `{ seed := ..., worklist := ..., processed := ... }.seed.getFormulas`. Use `change` to simplify: `change Formula.box theta ∈ (foldl ... seed1).getFormulas f t at h_box`.

## Critical Context

### Error Categories in Remaining Errors (lines 1210+)

1. **Structure projection mismatch** (~30 errors): `h_box`/`h_G`/`h_H` hypotheses have `{seed := ..., ...}.seed.getFormulas` instead of the simplified form. Fix with `change` tactic.

2. **Wrong time parameter in foldl lemma** (~20 errors): `mem_getFormulas_after_foldl_fam` applied with `item.timeIdx` but hypothesis is about time `t`. Need `by_cases h_time : t = item.timeIdx`.

3. **Missing backward foldl lemma for diff time** (~15 errors): When `t ≠ item.timeIdx`, need to show foldl at `item.timeIdx` doesn't affect `getFormulas f t`. Need new helper lemma or use `addFormula_preserves_getFormulas_diff_time` iteratively through foldl.

4. **addFormula_preserves_mem_getFormulas_same vs _general** (~20 errors): In positive cases, the seed is `foldl ... seed1`, not just `seed1.addFormula ...`. Need `foldl_addFormula_fam_preserves_mem_general` (private in Builder.lean) or inline the proof.

5. **Unknown identifier `psi`** (2 errors at ~1297, ~1347): Variable naming issue after case split. The `psi` from the outer match is shadowed or renamed.

6. **Finset.mem_insert in positive cases** (~6 errors): When formula types match (boxPositive checking Box, futurePositive checking G, pastPositive checking H), `simp_all [classifyFormula]` doesn't close the `rfl` case. Need structural argument about `w ≠ item` using position or other distinguishing information.

### Key Available Lemmas (in Builder.lean)

| Lemma | Line | Signature |
|-------|------|-----------|
| `addFormula_preserves_mem_getFormulas` | 6018 | `phi ∈ seed.getFormulas f t → phi ∈ (seed.addFormula addF addT psi ty).getFormulas f t` |
| `addFormula_preserves_mem_getFormulas_same` | 2840 | Same position only |
| `addFormula_preserves_hasPosition` | 5527 | Forward: old pos → new pos |
| `addFormula_hasPosition_backward` | 5546 | Backward: new pos → old pos ∨ added pos |
| `addFormula_preserves_getFormulas_diff_time` | (exists) | When times differ, getFormulas unchanged |
| `addFormula_preserves_getFormulas_diff_fam_general` | (exists) | When families differ |
| `foldl_addFormula_fam_preserves_mem_general` | 4316 | Public: preserves mem through foldl over families |
| `foldl_addFormula_preserves_mem_general` | 4296 | **Private**: preserves mem through foldl over times |

### Suggested New Infrastructure

Consider adding these helper lemmas to Builder.lean or Closure.lean:

1. **`foldl_addFormula_fam_backward_diff_time`**: If `phi ∈ (fams.foldl addFormula seed).getFormulas f t` and `t ≠ addTime`, then `phi ∈ seed.getFormulas f t`.

2. **`foldl_addFormula_fam_backward`**: If `phi ∈ (fams.foldl addFormula seed).getFormulas f t`, then `phi ∈ seed.getFormulas f t ∨ (phi = psi ∧ f ∈ fams ∧ t = addTime)`.

## References

- Plan: `specs/864_recursive_seed_henkin_model/plans/implementation-007.md`
- File: `Theories/Bimodal/Metalogic/Bundle/RecursiveSeed/Closure.lean`
- Builder lemmas: `Theories/Bimodal/Metalogic/Bundle/RecursiveSeed/Builder.lean`
- Worklist: `Theories/Bimodal/Metalogic/Bundle/RecursiveSeed/Worklist.lean`
