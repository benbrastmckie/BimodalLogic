# Phase 2 Handoff: RecursiveSeed IH Hypothesis Restructuring

**Date**: 2026-02-12
**Session**: sess_1770949979_849b84
**Status**: Phase 1 complete, Phase 2 analysis complete but blocked

## Immediate Next Action

The Phase 2 sorries are at lines 3908, 3993, 4074, 4158, 4224, 4288 in RecursiveSeed.lean. They all claim false hypotheses like `result.1.familyIndices = [result.2]` or `seed2.timeIndices famIdx = [newTime]` which are FALSE as stated.

**Next step**: Determine whether the theorem `buildSeedAux_preserves_seedConsistent` can be proven with a WEAKER hypothesis, or if the hypothesis structure needs to be changed.

## Current State

**File**: `Theories/Bimodal/Metalogic/Bundle/RecursiveSeed.lean`
**Function**: `buildSeedAux_preserves_seedConsistent` (line 3341)

### What was proven

- `filter_modify_eq_modify_filter` (lines 823-852) - fixed with additional hypotheses `h_idx` and `h_passes`
- `map_modify_eq_map_of_eq` (lines 855-858) - fixed with `ext i; simp [List.getElem?_modify]; split_ifs <;> simp [hf]`

### What remains

6 sorries at lines 3908, 3993, 4074, 4158, 4224, 4288, all of the form:
```lean
have h_seed2_single : result.1.familyIndices = [result.2] := by
  sorry  -- FALSE
```

## Key Finding: The Comments Are Misleading

The comments claim these hypotheses are "dead code" because `inner.neg` is always an implication. However:

1. `inner.neg = inner.imp .bot` is always syntactically an implication (`.imp`)
2. BUT the `buildSeedAux` pattern matcher has special cases for:
   - `psi.box.imp .bot` (neg-Box case)
   - `psi.all_future.imp .bot` (neg-G case)
   - `psi.all_past.imp .bot` (neg-H case)
   - `psi1.imp psi2` (generic implication - catch-all)

3. So `inner.imp .bot` matches the SPECIAL cases if `inner` is of the form `psi.box`, `psi.all_future`, or `psi.all_past`

**Example**: If the original formula is `neg(Box(Box phi))`, then:
- First recursion processes `neg(Box(Box phi))` with inner = `Box phi`
- We call IH on `inner.neg = (Box phi).neg = (Box phi).imp .bot`
- This matches the neg-Box case again, NOT the generic imp case!

## Attempted Approaches

### Approach 1: Direct addFormula (FAILED)

Tried to bypass IH by observing that `buildSeedAux (p.imp q) = addFormula ...` for generic implication. But `inner.imp .bot` doesn't necessarily hit the generic case - it depends on what `inner` is.

### Approach 2: Weaken theorem (NOT ATTEMPTED)

Could modify `buildSeedAux_preserves_seedConsistent` to use weaker hypotheses:
```lean
(h_single_family : seed.familyIndices = [famIdx] ∨ isTerminalFormula phi)
```
But this requires significant refactoring.

### Approach 3: Case split on inner (RECOMMENDED)

In each sorry location, case split on `inner` to determine which `buildSeedAux` branch will be taken:
- If `inner` matches `.box`, `.all_future`, or `.all_past`, handle those cases explicitly
- Otherwise, use the fact that `buildSeedAux` just does `addFormula`

## References

- Plan: `specs/880_augmented_extension_seed_approach/plans/implementation-004.md`
- Research: `specs/880_augmented_extension_seed_approach/reports/research-006.md`

## Critical Context

1. The `buildSeedAux` function uses pattern matching with specific cases before catch-all
2. The induction hypothesis requires `h_single_family` and `h_single_time` for ALL calls
3. After `createNewFamily`, familyIndices has TWO elements, not one
4. After `createNewTime`, timeIndices has TWO elements, not one
5. The theorem may need restructuring - either weaker hypotheses or conditional hypotheses
