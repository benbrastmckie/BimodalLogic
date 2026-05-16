# Phase 2 Debug v2 Results

**Status**: PARTIAL — `eM`/`eN` fixed (typechecks), `agree`/`consistent` still have errors

## What Was Established

1. **Phase 1 fix works**: Restoring explicit `(orderedSum sig I ms).carrier` type annotation (not `_`) in `show` fixes the 4 Phase 1 errors.

2. **`h ▸ Fin.cons a Fin.elim0` does NOT work**: The `▸` operator in term mode cannot bridge `Fin (if i = i then 1 else 0)` to `Fin 1` because `DecidableEq` from `LinearOrder I` doesn't reduce definitionally for free variables.

3. **Original opaque `show ... from by rw ...` is the only working eM/eN approach**: This creates Eq.mpr chains but at least typechecks.

4. **Negative case `agree` direct proof works**: `h_comp (k+1 - (if j' = i then 1 else 0)) (by omega) j' nf` unifies directly (line 804-805 compiled with empty goals_after), suggesting Lean can unify `0` with `if j' = i then 1 else 0` in certain contexts.

5. **Positive case `agree` partially works**: `convert h_eval using 2 <;> simp` closes the main goals but `<;> simp` generates `False` on sub-goals from `convert` that simp shouldn't touch.

## Remaining Issues

### Positive case agree (2 errors: `False` goals)
The `<;> simp` in `convert h_eval using 2 <;> simp` applies simp to ALL goals from convert, including some that produce `False`. Fix: use structured proof with `· simp` on individual goals instead of `<;> simp`.

### Consistent field (1 error)
`(fun q ↦ a) = Fin.cons a Fin.elim0` — provable by `funext q; fin_cases q; rfl`

### Negative case agree
`h_comp (k + 1 - (if j' = i then 1 else 0)) (by omega) j' nf` appears to work as `exact` at the tactic level (empty goals_after). If this is correct, the whole negative case is just:
```lean
· intro nf
  exact (h_comp (k + 1 - (if j' = i then 1 else 0)) (by omega) j' nf).mp_iff.mpr
    (h_comp (k + 1 - (if j' = i then 1 else 0)) (by omega) j' nf)
```
But this needs verification via `lake build`.

## Key Insight

The fundamental difficulty is that `if j' = i then 1 else 0` (with `DecidableEq` from `LinearOrder I`) does NOT reduce definitionally — not even after `subst` makes it `if j' = j' then 1 else 0`. This forces all proofs through propositional casts (`convert`, `cast`, `simp`), creating fragile proof states.

The cleanest fix would be a helper lemma: `nf_eval_nf_cast` that relates `nf_eval_nf` under propositionally-equal type indices.
