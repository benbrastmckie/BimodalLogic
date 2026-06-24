# Phase 3 Dispatch 1 Handoff — Task 305

## Immediate Next Action

Prove the k+1 case of `nf_nvar_exist_all_depths` at KampPrior.lean:355. This requires constructing a temporal formula for the n-variable existential `∃ env, nf_eval_nf M (k+1) (n+1) (insertEnv env t) sub_nf` using the IH at depth k (which handles all arities).

## Current State

- **Phase 3**: IN PROGRESS (Tasks 3.1-3.5 done, Task 3.6 blocked)
- **Sorry count**: 1 in KampPrior.lean (nf_nvar_exist_all_depths k+1 case, line 355)
- **Build status**: passes (lake build succeeds)
- **Previous sorry (line 287)**: ELIMINATED — nf_characterizable_temporal_prior now handles all depths k

## What Was Accomplished

1. Added import for NfDepth0Generalized.lean
2. Defined `nf_nvar_exist_all_depths` — generalized all-depth all-arity existential converter
3. Defined `nf_nvar_exist_all_depths_fn` and `nf_nvar_exist_all_depths_fn_correct` wrappers
4. Rewrote `nf_characterizable_temporal_prior` to use the new framework:
   - No more `match k` — all depths handled uniformly
   - At depth k+1: uses `nf_nvar_exist_all_depths_fn atomMap h_surj k 1` as exist_tl_fn
   - Proved `insertEnv env t = Fin.cons (env 0) (fun _ => t)` bridge (for Fin 1 env)
5. Verified build passes, old sorry eliminated

## Key Decisions

- **∃-valued function** (not subtype): `nf_nvar_exist_all_depths` returns `∃ A, ...` rather than `{ A // ... }`. This simplifies Classical.choice extraction via `.choose` / `.choose_spec`.
- **insertEnv/Fin.cons bridge**: The IH's existential form uses `insertEnv env t` while `nf_succ_char_formula_correct` expects `Fin.cons x (fun _ => t)`. Bridge proved by case analysis on `i < 1` vs `i = 1`.
- **VecEA_m import not needed**: NfDepth0Generalized.lean transitively imports what's needed.

## The Remaining Sorry — Analysis

The sorry at line 355 requires: given depth k+1, arity n+1, NF sub_nf, produce ∃ A such that temporal_truth M atomMap t A ↔ ∃ env : Fin n, nf_eval_nf M (k+1) (n+1) (insertEnv env t) sub_nf.

The IH gives: for all m and qnf at depth k, ∃ A' such that temporal_truth M atomMap t A' ↔ ∃ env' : Fin m, nf_eval_nf M k (m+1) (insertEnv env' t) qnf.

### Why It's Hard

The n-variable existential at depth k+1 decomposes into:
```
∃ env, [atoms match sub_nf.1] ∧ [∀ qnf, (∃ x, nf_eval_nf M k (n+2) (Fin.cons x (insertEnv env t)) qnf) ↔ sub_nf.2 qnf]
```

The atoms and quantifiers share the SAME env. The quantifier conditions involve 1-variable existentials with FIXED env (from the outer existential), not unconditional existentials. The IH provides unconditional (n+1)-variable existentials, which is too weak for the negative direction and too strong for the positive direction.

### Three Viable Approaches (Not Yet Implemented)

**Approach A: Extended translateEF1.** Extend the translateEF1 framework to use `Formula` (not `TemporalPred`) for alpha/beta parameters. At each chain point, the alpha captures both predicates AND quantifier conditions (which are themselves temporal formulas). The quantifier conditions at point x use nested Since/Until to reference points y relative to both x and t.

**Approach B: Recursive nested Since/Until.** Define the formula directly as a nested Since/Until tree. At depth 0, the tree has nesting depth 0 (pure translateEF1). At depth k+1, each chain point has additional nested S/U for quantifier conditions. Total nesting depth = k+1.

**Approach C: NF type enumeration.** Enumerate all possible depth-(k+1) arity-(n+1) NF types. For each type equal to sub_nf, check if the depth-0 existential for the atoms is satisfiable. Build disjunction. The quantifier conditions are automatically satisfied because the NF uniquely determines everything. But this approach requires expressing "∃ env with exactly this NF type" which is the same problem.

### Recommendation

Approach A or B is most likely to succeed. The key insight: the formula AT POINT x (inside a Since/Until chain) can express "∃ y with Q(y,x,t)" using further nested S/U, because the temporal language evaluated at x has access to all points before/after x (which includes t). At depth 0 within this nesting, the conditions are pure atoms (handled by translateEF1). The nesting terminates because depth decreases at each level.

## References

- KampPrior.lean lines 252-355 (nf_nvar_exist_all_depths)
- KampPrior.lean lines 415-458 (rewritten nf_characterizable_temporal_prior)
- NfDepth0Generalized.lean lines 1300-1315 (nf_nvar_exist_depth0_tl_fn)
- ExistsForallNF.lean lines 284-330 (translateEF1, buildRight, buildLeft)
- NormalForm.lean lines 198-207 (nf_eval_nf definition)
