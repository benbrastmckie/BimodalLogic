# Research Report: Task #880

**Task**: augmented_extension_seed_approach - Sorry-Free Path Analysis
**Date**: 2026-02-13
**Focus**: Verify Approach 3 viability for eliminating 6 sorries in buildSeedAux_preserves_seedConsistent

## Summary

The 6 sorries at lines 3908, 3993, 4074, 4158, 4224, 4288 in RecursiveSeed.lean claim FALSE hypotheses about single-family/single-time invariants. However, the comments labeling these as "DEAD CODE" are **incorrect**. A case-split approach (Approach 3) is viable but requires more careful analysis than originally anticipated. The sorries can be eliminated by explicitly case-splitting on `inner` and handling each branch appropriately.

## Findings

### 1. Pattern Matching Structure of buildSeedAux

The `buildSeedAux` function (lines 494-543) uses Lean's pattern matching with specific cases before a catch-all:

```lean
def buildSeedAux : Formula -> Nat -> Int -> ModelSeed -> ModelSeed
  | Formula.atom s, ...           => addFormula ...      -- Case 1
  | Formula.bot, ...              => addFormula ...      -- Case 2
  | Formula.box psi, ...          => recursive           -- Case 3: positive Box
  | Formula.all_future psi, ...   => recursive           -- Case 4: positive G
  | Formula.all_past psi, ...     => recursive           -- Case 5: positive H
  | Formula.imp (Formula.box psi) Formula.bot, ...       => recursive  -- Case 6: neg-Box
  | Formula.imp (Formula.all_future psi) Formula.bot, ... => recursive -- Case 7: neg-G
  | Formula.imp (Formula.all_past psi) Formula.bot, ...   => recursive -- Case 8: neg-H
  | Formula.imp psi1 psi2, ...    => addFormula ...      -- Case 9: generic imp (catch-all)
```

**Key insight**: Cases 6-8 match BEFORE Case 9. So `inner.neg = inner.imp .bot`:
- Matches Case 6 if `inner = Formula.box psi`
- Matches Case 7 if `inner = Formula.all_future psi`
- Matches Case 8 if `inner = Formula.all_past psi`
- Matches Case 9 otherwise

### 2. Why Comments Are Wrong

The sorry comments state "DEAD CODE: inner.neg is imp, Box/G/H cases unreachable in recursion". This is **incorrect**:

- `inner.neg` IS syntactically an implication (`inner.imp .bot`)
- BUT if `inner` itself is `box psi`, `all_future psi`, or `all_past psi`, then `inner.neg` matches the SPECIAL neg-Box/neg-G/neg-H cases, NOT the generic implication case
- In these cases, recursion CONTINUES and the IH hypotheses WOULD BE USED

**Example**: Processing `neg(Box(Box phi))`:
1. First call: `buildSeedAux (Box phi).neg` where `inner = Box phi`
2. `inner.neg = (Box phi).imp .bot` matches Case 6 (neg-Box)
3. Recursion continues with `inner2.neg = phi.neg = phi.imp .bot`
4. `phi.neg` matches Case 6/7/8 if phi is box/all_future/all_past, else Case 9

### 3. Sorry Location Analysis

| Line | Context | Goal | Fix Approach |
|------|---------|------|--------------|
| 3908 | neg-Box | `result.1.familyIndices = [result.2]` | Case split on inner |
| 3993 | neg-G | `seed2.timeIndices famIdx = [newTime]` | Case split on inner |
| 4074 | neg-H | `seed2.timeIndices famIdx = [newTime]` | Case split on inner |
| 4158 | dup neg-Box | `result.1.familyIndices = [result.2]` | Case split on inner |
| 4224 | dup neg-G | `seed2.timeIndices famIdx = [newTime]` | Case split on inner |
| 4288 | dup neg-H | `seed2.timeIndices famIdx = [newTime]` | Case split on inner |

**Goal state at line 3908**:
```lean
inner : Formula
result : ModelSeed x Nat := seed1.createNewFamily timeIdx inner.neg
h_seed1_single : seed1.familyIndices = [famIdx]
|- result.1.familyIndices = [result.2]
```

This is FALSE because `result.1.familyIndices = [famIdx, result.2]` after createNewFamily.

### 4. Approach 3: Case Split on inner

**Strategy**: Before calling IH, case split on `inner`:

```lean
match inner with
| Formula.box psi =>
    -- inner.neg = (box psi).imp .bot matches neg-Box case
    -- Need to handle nested recursion with proper hypotheses
    ...
| Formula.all_future psi =>
    -- inner.neg matches neg-G case
    ...
| Formula.all_past psi =>
    -- inner.neg matches neg-H case
    ...
| Formula.atom _ | Formula.bot | Formula.imp _ _ =>
    -- inner.neg matches generic imp case (Case 9)
    -- buildSeedAux inner.neg ... = addFormula ...
    -- DON'T need IH - use addFormula_seed_preserves_consistent directly
    ...
```

**Why this works for terminal cases (atom/bot/imp)**:
When `inner` is not box/all_future/all_past, then `inner.neg = inner.imp .bot` matches the generic implication case (Case 9), which reduces to:
```lean
buildSeedAux (inner.imp .bot) famIdx timeIdx seed = seed.addFormula famIdx timeIdx (inner.imp .bot) ...
```
No recursion occurs, so we don't need the IH at all. We can directly apply `addFormula_seed_preserves_consistent`.

### 5. The Deep Problem: Nested Modalities

For cases where `inner = box psi` or `inner = all_future psi` or `inner = all_past psi`:
- `buildSeedAux inner.neg` makes recursive calls
- These calls use `h_single_family` and `h_single_time` hypotheses
- After `createNewFamily`/`createNewTime`, these hypotheses are FALSE

**This reveals the fundamental issue**: The theorem `buildSeedAux_preserves_seedConsistent` has hypotheses that are TOO STRONG for nested modalities.

### 6. Solution Options

**Option A: Weaken the theorem hypotheses**

Change:
```lean
(h_single_family : seed.familyIndices = [famIdx])
(h_single_time : seed.timeIndices famIdx = [timeIdx])
```

To:
```lean
(h_family_valid : famIdx < seed.nextFamilyIdx)
(h_entry_exists : seed.findEntry famIdx timeIdx <> none)
```

This requires significant refactoring but is the "correct" fix.

**Option B: Case split with direct proofs**

For each sorry location:
1. Case split on `inner`
2. For non-modal `inner` (atom/bot/imp): bypass IH entirely, use `addFormula_seed_preserves_consistent`
3. For modal `inner` (box/all_future/all_past): prove consistency directly without using the general IH

This is a local fix that doesn't require changing the theorem signature.

**Option C: Prove a specialized lemma**

Prove that when `inner` is modal, the specific recursive structure still preserves consistency, even though the general hypotheses don't hold. This would be a supporting lemma specific to the neg-Box/neg-G/neg-H cases.

## Recommendations

1. **Implement Option B (Case Split with Direct Proofs)** as the primary approach
   - At each sorry location, case split: `cases inner with | box psi => ... | all_future psi => ... | all_past psi => ... | _ => ...`
   - For the `_ =>` case (catch-all): `buildSeedAux inner.neg` reduces to `addFormula`, so apply `addFormula_seed_preserves_consistent` directly
   - For modal cases: prove consistency using domain-specific reasoning about how createNewFamily/createNewTime interact with buildSeedAux

2. **Effort estimate**:
   - Option B: 4-6 hours per sorry location (24-36 hours total)
   - Option A: 8-12 hours for theorem restructuring + 2-3 hours per usage site
   - Option C: 12-16 hours for specialized lemmas

3. **Confidence level**: 75%
   - High confidence that Option B works for non-modal `inner` cases
   - Medium confidence for modal `inner` cases - may require additional lemmas

## Next Steps

1. Start with one sorry location (e.g., line 3908)
2. Implement case split on `inner`
3. Verify that the non-modal cases are provable with `addFormula_seed_preserves_consistent`
4. For modal cases, analyze what additional lemmas are needed
5. If modal cases prove difficult, consider Option A (theorem restructuring)

## References

- Handoff document: `specs/880_augmented_extension_seed_approach/handoffs/phase-2-handoff-20260212.md`
- Plan v004: `specs/880_augmented_extension_seed_approach/plans/implementation-004.md`
- RecursiveSeed.lean: Lines 3341-4363 for `buildSeedAux_preserves_seedConsistent`
