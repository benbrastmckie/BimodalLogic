# Phase 7 Handoff: reduceElimLast_correct PROVED, Atom Elimination Remains

**Date**: 2026-05-17 (fifth attempt)
**Session**: sess_1779003456_c5b522
**Status**: BLOCKED (reduceElimLast elaboration issue RESOLVED; atom elimination pipeline remaining)

## What Was Accomplished This Session

1. **RESOLVED the Lean 4 elaboration blocker** that blocked all previous sessions:
   - The issue was using `fun M env t => by intro H1 H2` with non-dependent arrows
   - Solution: use `appendLast` (custom env-with-last-value function) instead of `Fin.snoc`
   - `cons_appendLast` proves `Fin.cons x (appendLast env t) = appendLast (Fin.cons x env) t`
   - `appendLast_singleton` proves `appendLast (fun _ => z) t = Fin.cons z (fun _ => t)`

2. **Proved `reduceElimLast_correct_succ`** (full structural recursion, all 6 cases):
   - `.not`, `.and`: by not_congr/and_congr + IH
   - `.all`, `.ex`: using `cons_appendLast` to commute Fin.cons with appendLast, then IH
   - `.atom p i`: case split on `i.val < m+1` (interior var vs last var)
   - `.lt i j`: 4-way case split (both interior, i<last, last<j, both last)
   - Compiles without sorry for ALL n = m+1 >= 1

3. **Proved `reduceElimLast_correct_at_one`** (the corollary needed by the main proof):
   ```lean
   eval (int_to_ordered sig M) (Fin.cons z (fun _ => t)) alpha ↔
   eval (int_to_ordered (extSignature sig) (extIntStruct M t)) (fun _ => z) (reduceElimLast 1 alpha)
   ```

4. **Verified lake build passes** with the new infrastructure (994 jobs, 3.1s for this file)

## What Remains (Atom Elimination Pipeline)

The two remaining sorries at lines 667, 685 in `expressiveness_fixed_atomMap` (.all, .ex cases) require the full GHR94 atom elimination pipeline. This is NOT a Lean elaboration issue -- it's a genuine formalization task requiring ~500 LOC.

### The Problem

After applying `reduceElimLast_correct_at_one` + IH at `extSignature sig`, we get formula `A_ext` that works in model `to_int_struct (extIntStruct M t) (extAtomMap atomMap)`. We need formula `RESULT` that works in model `to_int_struct M atomMap`.

The models differ on three types of "extended atoms":
- `extAtomMap atomMap (.const_at_ref p)`: constant value `M.interp p t` (depends on t!)
- `extAtomMap atomMap (.lt_ref)`: value `{s | s < t}` (position-dependent)
- `extAtomMap atomMap (.gt_ref)`: value `{s | t < s}` (position-dependent)

### Required Implementation (3 sub-tasks)

#### Sub-task A: const_at_ref elimination (case-split, ~150 LOC)
- For each `sigma : sig.preds -> Bool` (finitely many by `Fintype`):
  - `guard_sigma` = conjunction of `atom(atomMap p)` (if sigma p) or `neg(atom(atomMap p))` (if not)
  - Substitute all `const_at_ref_p` atoms with `neg bot` (if sigma p) or `bot`
  - Correctness: at time t, exactly one sigma matches (the one where sigma(p) = M.interp p t), and the guard selects it
- Result: formula using only orig-atoms + lt_ref + gt_ref

#### Sub-task B: lt_ref/gt_ref elimination (level-aware substitution, ~200 LOC)
- For properly separated formulas (guaranteed by `h_sep`):
  - In past-only sub-formulas (inside `all_past`, `snce`): lt_ref is CONSTANT True (since all eval times s < t); gt_ref is CONSTANT False
  - In future-only sub-formulas (inside `all_future`, `untl`): lt_ref is CONSTANT False; gt_ref is CONSTANT True
  - At present level: both are False (t < t = False)
- Define `elimOrderAtomsSep` that walks separated structure applying appropriate substitutions
- Prove correctness using `past_only_is_pure_past`, `future_only_is_pure_future`, and `subst_preserves_if_match`

#### Sub-task C: extAtomMap_injective (~50 LOC)
- Needs hypothesis that atomMap's range is disjoint from extended atom ranges
- For the specific atomMap in `separation_implies_expressiveness` (base "p"): all bases differ ("p" vs "const_ref" vs "lt_ref" vs "gt_ref")
- May need to add disjointness hypothesis to `expressiveness_fixed_atomMap` or prove it only for the specific atomMap

### Key Existing Infrastructure (already proved)
- `reduceElimLast_correct_at_one`: semantic correctness of variable elimination
- `qdepth_reduceElimLast_le`: quantifier depth doesn't increase
- `q_exists_correct`: temporal existential quantification
- `past_only_is_pure_past`: past-only formulas depend only on past values
- `future_only_is_pure_future`: dual for future
- `past_only_subst_correct`: substitution correctness in past-only context
- `future_only_subst_correct`: substitution correctness in future-only context
- `subst_correctness` (in FormulaOps.lean): basic substitution lemma
- `extIntStruct`, `extAtomMap`: extended model constructions

### Suggested Implementation Strategy

1. Add `subst_preserves_when_match` lemma (if replacement's truth matches atom's value, subst is identity)
2. Add `int_truth_model_ext` lemma (models with same val give same int_truth)
3. Implement `elimConstAtoms` using Finset.fold over sig.preds
4. Implement `elimOrderAtomsSep` walking the separated structure
5. Assemble: h_sep gives separated B, eliminate all atoms from B, prove equivalence
6. Fill in .ex case, derive .all from .ex via negation

### Alternative Approach

Restructure `separation_implies_expressiveness` to use WF induction on qdepth directly (not through `expressiveness_fixed_atomMap`). This avoids the fixed-atomMap structural recursion constraint. The quantifier-free cases are identical. The quantifier case calls the IH at `extSignature sig` (with a FRESHLY CHOSEN atomMap), then applies atom elimination. The advantage: we can choose atomMap_ext to guarantee injectivity at each recursion level.

## Files Modified

- `Theories/Bimodal/Metalogic/WeakCanonical/ExpressiveCompleteness.lean` (added ~120 LOC of infrastructure)

## Immediate Next Action

Implement Sub-task B (level-aware substitution for lt_ref/gt_ref in separated formulas) first, as it's the most well-understood piece. Then Sub-task A (const_at_ref case-split). Then Sub-task C (injectivity) and assembly.
