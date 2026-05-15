# Phase 1 Handoff — Infrastructure

## Completed
- `operator_depth` fixed: Until/Since now add 2 (not 1), matching Reynolds 2-quantifier translation
- `MonadicFormula.lift` and `MonadicFormula.weaken` defined in NEquivalence.lean using De Bruijn lift with cutoff
- `finLift`, `insertEnv`, `insertEnv_zero_eq_cons` proven
- `weaken_eval` stated and proven (modulo `lift_eval` sorry)
- `Formula.predFormulas` defined in Formula.lean
- `mkSigFrom`/`mkAtomMap` redesigned in Transfer.lean using `predFormulas`

## Key Decisions
- Used `lift c` with cutoff approach instead of simple `Fin.succ`/`Fin.castSucc` for `weaken`. This is necessary because `all`/`ex` cases need to preserve bound variable 0 while shifting free variables.
- `insertEnv_succ_cons`, `insertEnv_finLift`, and `lift_eval` are maintained as sorry by user (Task 141 scope). `weaken_eval` propagates these sorries.
- `predFormulas` collects both `Formula.atom a` and `Formula.box φ` subformulas into a `Finset Formula`, providing `Fintype` for the signature.

## Next Action
Phase 2: Implement `table` body. The `table` function needs an `atomMap : Formula → sig.preds` parameter and case-by-case translation following Reynolds Section 6.
