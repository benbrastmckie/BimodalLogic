# Implementation Summary: Split NEquivalence.lean, Redesign KType, Close k_equiv_monotone

- **Task**: 145
- **Status**: Implemented
- **Session**: sess_1778871141_a24716
- **Date**: 2026-05-15

## Changes

### New File: MonadicFO.lean (400 lines)
- Extracted pure monadic FO definitions from NEquivalence.lean
- Contains: MonadicSignature, MonadicFormula, MonadicSentence, quantifier_depth, MonadicStructure, OrderedMonadicStructure, subinterval theorems, ZStructure, eval, finLift, lift, weaken, insertEnv + all proved lemmas, lift_eval, weaken_eval, atomCount, nfCount, nfCount_pos, NormalFormIdx
- Imports: Mathlib only (no Bimodal.Syntax or Bimodal.ProofSystem)
- Zero sorries (all insertEnv/lift_eval lemmas were already proved by task 147)

### Rewritten: NEquivalence.lean (660 lines -> 205 lines)
- Removed extracted FO definitions
- Added imports: MonadicFO, NormalForm (breaks circular import)
- **KType redesign**: `NormalFormIdx sig k 0 -> Bool` changed to `NormalForm sig k 0 -> Bool`
- **Deleted nf_rep**: vacuous Classical.choice mapping no longer needed
- **Rewrote k_type_of**: uses `nf_eval_nf` (concrete semantic evaluation) instead of `eval + nf_rep`
- **CLOSED k_equiv_monotone**: proved via `nf_agreement_monotone` from NormalForm.lean
- Sorry count: 4 -> 3 (net -1: k_equiv_monotone closed)

### Modified: NormalForm.lean
- Import changed from NEquivalence to MonadicFO
- Docstring updated to reference MonadicFO

### Modified: Table.lean
- Import changed from NEquivalence to MonadicFO + Bimodal.Syntax.Formula
- Removed unused `open Bimodal.ProofSystem`

### Modified: WeakCanonical.lean
- Added explicit MonadicFO import

## Sorry Accounting

| File | Before | After | Change |
|------|--------|-------|--------|
| MonadicFO.lean | (new) | 0 | -- |
| NEquivalence.lean | 4 | 3 | -1 (k_equiv_monotone closed) |
| NormalForm.lean | 0 | 0 | 0 |
| Table.lean | 6 | 6 | 0 |

Net change: -1 sorry

## k_equiv_monotone Proof Strategy

The proof uses:
1. `unfold k_equiv k_type_of` to expose the `decide (nf_eval_nf ...)` structure
2. `funext nf_m` for pointwise equality on `NormalForm sig m 0`
3. `congr_fun h_equiv nf` + `decide_eq_decide` to extract depth-k Iff agreement
4. `nf_agreement_monotone m k 0 hkm M Fin.elim0 N Fin.elim0 h_agree_k nf_m` to step down
5. `decide_eq_decide` to convert the Iff back to Bool equality

## Plan Deviations

- Phase 1: Added 3 extra Mathlib imports (`Finset.Basic`, `Finite.Card`, `Tactic.Positivity`) needed because MonadicFO.lean lacks transitive imports from ReflexiveCanonical
- Phase 1: `nfCount_pos` proof changed from `simp [nfCount]` to `simp only [nfCount]; positivity`
- Phase 2: Removed unused `open Bimodal.ProofSystem` from Table.lean (failed without transitive import)
- Phase 4: MonadicFO.lean has 0 sorries (plan expected 4 from task 141; task 147 already closed them)

## Verification

- `lake build` passes (full project, 1648 jobs)
- `k_equiv_monotone` is sorry-free
- `nf_rep` is deleted
- `finite_types` proof unchanged and compiles
- All chronicle instances compile
- All downstream files (OrderedSum, IntegerModel, Transfer) compile unchanged
