# Handoff: Task 303 Phase 1 Analysis

## Current State

Phase 1 IN PROGRESS. No code changes yet. Deep analysis completed confirming the plan's approach is correct and necessary.

## Sorry Sites

Both at `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampBypass.lean`:
- Line 636: Until zone (t < x) backward direction, quantifier part
- Line 688: Since zone (x < t) backward direction, quantifier part

Both have the same goal:
```
forall ssn : NormalForm sig (k'+1) (1+1+1),
  (exists y, nf_eval_nf M (k'+1) (1+1+1) (Fin.cons y (Fin.cons x (fun _ => t))) ssn)
  <-> sub_nf.2 ssn = true
```

## Analysis Summary

### Why the sorry cannot be closed with existing infrastructure

1. **1-var NF transfer is FALSE**: Two environments `[x, t]` and `[x', t']` with the same individual 1-var NFs and order can have DIFFERENT 2-var NFs. Counterexample: Z with uniform predicate, `[0, 2]` vs `[0, 1]` -- same 1-var NFs at both components, same order (t < x), but different 2-var NFs because there is an integer between 0 and 2 but not between 0 and 1. This counterexample holds on Prior structures (Z satisfies semantic_prior_UZ and semantic_prior_SZ).

2. **Current GeneralExistPart produces top/bot**: The existing `generalExistPart_zero` and `generalExistPart_succ` use a classical satisfiability argument: if the existential is satisfiable on ANY structure with matching full r-var NF, the formula is `Formula.top`; otherwise `Formula.bot`. This is mathematically correct but the formulas carry NO information when embedded in an enriched Until/Since formula. The quantifier conjunction from top/bot is trivially `True` and cannot close the sorry.

3. **The enriched formula approach requires ACTUAL temporal formulas**: To close the sorry, the Until/Since formula must include a quantifier conjunction whose individual conjuncts encode `exists y, nf_eval M (k'+1) 3 [y, x, t] ssn` as a temporal formula evaluated at x. This requires zone decomposition at depth k'+1 with 1-var NF preconditions for x and t.

4. **nf_extend_fwd/nf_extend_bwd require full r-var NF agreement**: These theorems transfer existentials from one structure to another but require depth-(K+1) r-var NF agreement as input. Establishing this agreement IS the problem being solved.

5. **Induction on depth within the proof does NOT work**: Attempting to build 2-var NF agreement from 1-var agreements by induction on depth K fails because at each step, the gap increases: depth-K agreement gives depth-(K-1) existential transfer, not depth-K.

### What IS needed

A `GeneralExistPartIndiv` definition with individual 1-var NF parameters:

```lean
abbrev GeneralExistPartIndiv {sig : MonadicSignature}
    (atomMap : Formula -> sig.preds) (k : Nat) : Prop :=
  forall (r : Nat) (_ : r >= 1)
    (char_k : NormalForm sig k 1 -> Formula)
    (char_k_correct : ...)
    (env_nfs : Fin r -> NormalForm sig (k+1) 1)
    (ssn : NormalForm sig k (r+1)),
    exists (A : Formula),
      forall (M : OrderedMonadicStructure sig) (h_UZ h_SZ)
        (e : Fin r -> M.carrier),
        (forall i, nf_eval_nf M (k+1) 1 (fun _ => e i) (env_nfs i)) ->
        (temporal_truth M atomMap (e 0) A <->
         exists y, nf_eval_nf M k (r+1) (Fin.cons y e) ssn)
```

Key difference from GeneralExistPart: the precondition is `forall i, nf_eval_nf M (k+1) 1 (fun _ => e i) (env_nfs i)` (individual 1-var NFs) instead of `nf_eval_nf M (k+1) r e env_nf` (full r-var NF). The individual 1-var NF precondition IS satisfiable at the sorry site (from `h_x_eval` and `h_t_eval`).

The formula A must be an ACTUAL temporal formula (not top/bot) because the existential's truth value is NOT determined by individual 1-var NFs alone.

### Implementation Path

#### Phase 1: GeneralExistPartIndiv definition + base case (k=0)

At depth 0, `nf_eval_nf M 0 (r+1) (Fin.cons y e) ssn` is purely atomic. The formula A for each ssn is built by zone decomposition over y's position relative to the environment elements. The existing depth-0 zone infrastructure in KampForward.lean, VecEADecomp.lean, and ZoneBridge.lean provides the building blocks.

Estimated: 200-400 lines for the r=2 specialization.

#### Phase 2: GeneralExistPartIndiv inductive step (k+1)

At depth k+1, `nf_eval_nf M (k+1) (r+1) (Fin.cons y e) ssn` = atoms + quantifiers. The atoms are encoded via zone decomposition + char_(k+1) formulas. The quantifiers use GeneralExistPartIndiv(k) at arity r+1.

Estimated: 200-400 lines.

#### Phase 3: Integration into KampBypass.lean

Change the Until/Since formulas to include the quantifier conjunction from GeneralExistPartIndiv. Update `existPart_succ_n1_bypass` signature to take GeneralExistPartIndiv as a parameter instead of (or in addition to) GeneralExistPart.

Estimated: 100-200 lines.

#### Phase 4: Close sorries

With the enriched formula, the backward direction extracts x from Until/Since with both 1-var NF and quantifier conjunction truth. The quantifier conjunction directly gives the needed iff for each ssn.

Estimated: 50-100 lines.

#### Phase 5: Completeness verification

Verify `completeness_discrete` is sorry-free. Clean up.

## Key Decisions

1. **Approach**: GeneralExistPartIndiv with 1-var NF parameters and actual temporal formulas (not top/bot)
2. **Scope**: Specialize to r=2 (the immediate need) per plan contingency
3. **Formula construction**: Zone decomposition (Rabinovich Prop 3.5)
4. **Induction structure**: Mutual induction with CharPart and ExistPart, adding GeneralExistPartIndiv as third conjunct

## Immediate Next Action

Start implementing GeneralExistPartIndiv definition and depth-0 base case. Use existing zone infrastructure from KampForward.lean/VecEADecomp.lean/ZoneBridge.lean.

## Sorry Inventory

| File | Line | Statement | Assumption | Why Deferred | Next Dispatch |
|------|------|-----------|------------|--------------|---------------|
| KampBypass.lean | 636 | existPart_succ_n1_bypass Until zone quant | 1-var NF agreement insufficient for 2-var transfer | Requires GeneralExistPartIndiv with actual temporal formulas | Implement GeneralExistPartIndiv + enriched formula |
| KampBypass.lean | 688 | existPart_succ_n1_bypass Since zone quant | Mirror of line 636 | Same as above | Same as above |
| NfCharFormula.lean | 542 | Dead code | Not on critical path | Non-goal | N/A |
| NfCharFormula.lean | 651 | Dead code | Not on critical path | Non-goal | N/A |
