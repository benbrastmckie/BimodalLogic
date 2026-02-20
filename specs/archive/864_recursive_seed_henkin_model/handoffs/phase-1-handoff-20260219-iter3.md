# Handoff: Task 864 - Phase 1F (Iteration 3)

## Immediate Next Action

Fix the remaining errors in `processWorkItem_preserves_closure` for the boxPositive, boxNegative, futurePositive, futureNegative, pastPositive, and pastNegative cases. The boxPositive box-closure sub-case has been partially restructured but has a fundamental proof strategy issue (see Key Decision #3 below). The G/H sub-cases of boxPositive and all of the other 5 formula cases need similar `change`/`_general` fixes.

## Current State

- **File**: `Theories/Bimodal/Metalogic/Bundle/RecursiveSeed/Closure.lean` (approx 3500 lines)
- **First error**: Line 1324 (all lines before 1277 compile cleanly, including new helper lemmas)
- **Error count**: 103 errors (same count as iteration 2, but different distribution)
- **New helper lemmas added** (lines 322-477, all compile):
  - `mem_getFormulas_after_foldl_fam_general` (line 332) - backward foldl reasoning with arbitrary query time
  - `foldl_addFormula_fam_hasPosition_backward` (line 430) - backward hasPosition through foldl
  - `Formula.ne_box_self` (line 459) - phi != Box phi
  - `Formula.ne_all_future_self` (line 464) - phi != G phi
  - `Formula.ne_all_past_self` (line 469) - phi != H phi

## Key Decisions Made

### 1. `mem_getFormulas_after_foldl_fam_general` (NEW LEMMA)

The existing `mem_getFormulas_after_foldl_fam` requires the query time `t` to match the foldl time. The new `_general` version allows arbitrary query time:

```
phi in (fams.foldl ... seed).getFormulas f t =>
  phi in seed.getFormulas f t  OR  (phi = psi AND f in fams AND t = addTime)
```

This is essential because `h_box` (and `h_G`, `h_H`) have formulas at arbitrary time `t`, while the foldl operates at `item.timeIdx`.

### 2. `foldl_addFormula_fam_hasPosition_backward` (NEW LEMMA)

Backward hasPosition reasoning through foldl over families:

```
(fams.foldl ... seed).hasPosition f t = true =>
  seed.hasPosition f t = true  OR  (f in fams AND t = addTime)
```

Needed for reasoning about which positions are "new" (created by foldl) vs "old" (from seed).

### 3. Fundamental proof strategy issue for boxPositive box-closure

**The Problem**: When `Box theta` was in the old seed and the old invariant says "closed" (theta at all families with position at time t), the new seed creates NEW positions at time `item.timeIdx` via the foldl. These new positions have only `psi` (the formula added by the foldl), not `theta`. So the "closed" property doesn't extend.

**Why it happens**: The foldl iterates over `seed1.familyIndices` and adds `psi` at `(fam, item.timeIdx)` for each family. If a family `fam` had entries at other times but NOT at `item.timeIdx`, the foldl's `addFormula` creates a new entry at `(fam, item.timeIdx)`. This new position has only `psi`, not `theta`.

**The gap**: When `t = item.timeIdx` and `theta != psi`, the old "closed" invariant doesn't give theta at new positions, and there's no pending work item for `Box theta`.

**Possible fixes**:
1. **Show the case is unreachable**: Maybe `state.seed.hasPosition f' item.timeIdx` is always true for `f' in seed1.familyIndices`? This would require that `familyIndices` only contains families with entries at ALL times, which is unlikely.
2. **Weaken the invariant**: Change `∀ f', state.seed.hasPosition f' t` to `∀ f' ∈ old_positions_at_t, ...`. But this would require significant restructuring.
3. **Switch proof strategy**: Don't commit to left/right based on old invariant. Instead, determine left/right based on whether closure extends. When it doesn't (new positions without theta), use the "right" branch. But there's no pending work item for `Box theta` in this case, so this doesn't help either.
4. **Strengthen the algorithm**: Ensure that when `Box psi` is processed, work items are created for ALL Box formulas in the seed that need re-checking. This would be an algorithm change.
5. **Prove the gap doesn't affect final correctness**: Show that by the time the worklist is empty, all positions DO have the right formulas. This would require a different invariant.

**Recommended approach**: Option (1) - prove that for any `f' in seed1.familyIndices` where `f' != item.famIdx`, `state.seed.hasPosition f' item.timeIdx = true`. This would follow if the `familyIndices` function only returns families that have entries at the time being queried. Check the definition of `familyIndices` - if it's time-independent (just all families in any entry), then option (1) fails and a deeper fix is needed.

### 4. Structure projection simplification pattern

The hypothesis `h_box`, `h_G`, `h_H` have types like:
```
{seed := {seed := foldl_result, worklist := ..., processed := ...}.seed, ...}.seed.getFormulas f t
```

This reduces to `foldl_result.getFormulas f t` via `change`:
```lean
change Formula.box theta ∈ (seed1.familyIndices.foldl ...).getFormulas f t at h_box
```

Similarly, the GOAL has structure projections that need `show`:
```lean
show theta ∈ (seed1.familyIndices.foldl ...).getFormulas f' t
```

Both `change` and `show` are needed for each sub-case.

### 5. `addFormula_preserves_mem_getFormulas` vs `_same`

The original code uses `addFormula_preserves_mem_getFormulas_same` which requires query position = add position. The correct version is `addFormula_preserves_mem_getFormulas` (general) which works for any positions:

```lean
addFormula_preserves_mem_getFormulas state.seed f' t theta (Formula.box psi) item.famIdx item.timeIdx .universal_target h_mem
```

This is needed because we add at `(item.famIdx, item.timeIdx)` but query at `(f', t)`.

## What NOT to Try

### 1. Do NOT use `mem_getFormulas_after_foldl_fam` (without `_general`)
The non-general version requires matching times. Always use `mem_getFormulas_after_foldl_fam_general`.

### 2. Do NOT assume `Box theta = psi` is always a contradiction
When the foldl adds `psi` to all families, and `psi = Box theta`, this is a legitimate case (not a noConfusion). Handle it via the "right" (pending work item) branch.

### 3. Do NOT use `Formula.noConfusion` for `Box theta = psi`
`psi` is an arbitrary formula; it COULD be `Box theta`. Use `Formula.ne_box_self` only when you know `psi = Box psi` (structural inequality).

### 4. Do NOT rewrite `foldl_addFormula_fam_preserves_hasPosition_not_in` at hypothesis with different time
This lemma equates hasPosition at the SAME time as the foldl. For different times, use `foldl_addFormula_fam_hasPosition_backward` instead.

## Critical Context

1. **Invariant definition** (lines 38-51): `WorklistClosureInvariant` has 3 conjuncts (Box, G, H). Each says: for formula in seed at (f,t), either closed OR pending work item.

2. **boxPositive processing** (Worklist.lean lines 194-202): Creates `seed1 = addFormula(Box psi)`, then `seed2 = foldl addFormula(psi) over seed1.familyIndices`. New work items = map psi over seed1.familyIndices.

3. **familyIndices** is ALL family indices in ALL entries, regardless of time. So `f in familyIndices` does NOT mean `hasPosition f t` for any specific `t`.

4. **Error patterns for G/H sub-cases** (lines 1458+): Same `change`/`_general` fixes needed, plus the `_same` -> general fix. But G/H sub-cases should be simpler because they don't create new TIME positions (Box only creates new family positions).

5. **Other 5 formula cases** (boxNegative 1559+, futurePositive, futureNegative, pastPositive, pastNegative): All have similar error patterns to boxPositive. The futurePositive/pastPositive cases will have analogous "new position" issues but for times instead of families.

## References

- Plan: `specs/864_recursive_seed_henkin_model/plans/implementation-007.md`
- File: `Theories/Bimodal/Metalogic/Bundle/RecursiveSeed/Closure.lean`
- Builder lemmas: `Theories/Bimodal/Metalogic/Bundle/RecursiveSeed/Builder.lean`
- Worklist definition: `Theories/Bimodal/Metalogic/Bundle/RecursiveSeed/Worklist.lean`
- Previous handoff: `specs/864_recursive_seed_henkin_model/handoffs/phase-1-handoff-20260218-iter2.md`
