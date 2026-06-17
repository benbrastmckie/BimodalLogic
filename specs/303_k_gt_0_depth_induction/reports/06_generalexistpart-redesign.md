# Research Report: GeneralExistPart Redesign for k>0 Depth Induction

**Task**: 303 (k_gt_0_depth_induction)
**Session**: sess_1781704640_6cac16
**Mode**: hard (H2, H3, H4, H5)
**Date**: 2026-06-17

## Summary

The current GeneralExistPart implementation (full r-var NF precondition, Formula.top/bot construction) is provably unusable at the KampBypass sorry sites due to circular precondition. This report details the required redesign with individual 1-var NF parameters and zone-decomposition formula construction.

## H3 Reference Grounding Table

| Source | Prop/Location | Lean Identifier | Status |
|--------|--------------|-----------------|--------|
| Rabinovich 2014, Prop 3.5 | V-EA with one free var -> TL formula via nested Until/Since | `enriched_vecEA2_until/since` | Implemented (k=0 only) |
| Rabinovich 2014, Prop 4.2 | Closure under negation for EA formulas | `existPart_succ` + `charPart_succ` | Implemented (sorry at k>0) |
| Rabinovich 2014, Sec 5, Lemma 5.1 | Interval splitting: negate EA formula by decomposing zones | `ssn_zone_until/since` | Implemented (k=0 only) |
| NfComposition.lean | Counterexample: 1-var NFs + order do NOT determine 2-var NF | Documented in file header | Confirmed |

## Finding 1: Current GeneralExistPart is Provably Unusable

The current definition at `GeneralExistPart.lean:48-69` takes `env_nf : NormalForm sig (k + 1) r` (full r-var NF). Its precondition requires `nf_eval_nf M (k + 1) r e env_nf`.

At sorry sites (KampBypass.lean:636, :688), using `ih_general_exist` at r=2 requires `nf_eval_nf M (k'+2) 2 (Fin.cons x (fun _ => t)) sub_nf` as precondition — which IS the goal being proved. Circularity is ironclad.

The Formula.top/Formula.bot construction proves existence but carries no information.

## Finding 2: Exact Sorry Goal

Both sorry sites have identical structure. At line 636:

```
forall (sub_nf_1 : NormalForm sig (k' + 1) (1 + 1 + 1)),
    (exists x_1, nf_eval_nf M (k' + 1) (1 + 1 + 1)
      (Fin.cons x_1 (Fin.cons x (fun x => t))) sub_nf_1) <->
    sub_nf.2 sub_nf_1 = true
```

Available hypotheses: `h_x_agree` (1-var NF at x), `h_t_agree` (1-var NF at t), `h_atom_agree` (2-var atom agreement), `h_eval0_quant` (M0 answer for all 3-var existentials).

## Finding 3: Required Redesign

Change GeneralExistPart to take individual 1-var NF parameters:

```lean
abbrev GeneralExistPart {sig : MonadicSignature}
    (atomMap : Formula -> sig.preds)
    (k : Nat) : Prop :=
  forall (r : Nat) (_ : r >= 1)
    (char_k : NormalForm sig k 1 -> Formula)
    (char_k_correct : ...)
    (env_nfs : Fin r -> NormalForm sig (k + 1) 1)  -- CHANGED: individual 1-var NFs
    (ssn : NormalForm sig k (r + 1)),
    exists (A : Formula),
      forall (M : OrderedMonadicStructure sig)
        (h_UZ : semantic_prior_UZ M atomMap)
        (h_SZ : semantic_prior_SZ M atomMap)
        (e : Fin r -> M.carrier),
        (forall i, nf_eval_nf M (k + 1) 1 (fun _ => e i) (env_nfs i)) ->  -- CHANGED
        (temporal_truth M atomMap (e 0) A <->
         exists y, nf_eval_nf M k (r + 1) (Fin.cons y e) ssn)
```

Precondition `forall i, nf_eval_nf M (k+1) 1 (fun _ => e i) (env_nfs i)` IS satisfiable from `h_x_agree` and `h_t_agree`.

## Finding 4: Zone Decomposition Required (NOT Formula.top/bot)

Formula.top/bot CANNOT work because individual 1-var NFs do NOT determine the full r-var NF. Counterexample (NfComposition.lean): Z with [0,2] vs [0,1] — same 1-var NFs, same order, but different 2-var NFs.

The formula must perform actual temporal construction via zone decomposition (Rabinovich Prop 3.5):
- Zone y = e_i: check tau_y at e_i using char formulas
- Zone y in (e_i, e_{i+1}): `NOT(NOT(char_0(tau_y)) Until char_0(env_nfs(i+1)))` from e_i
- Zone y > max(env): `Until(char_0(tau_y), top)` from max
- Zone y < min(env): `Since(char_0(tau_y), top)` from min

## Finding 5: Induction Structure

**GeneralExistPart(0)**: NF(0, r+1) is purely atomic. Existential decomposes into zone classification + temporal encoding via nested Until/Since.

**GeneralExistPart(k+1)** from CharPart(k+1) + GeneralExistPart(k): depth-(k+1) existential decomposes into atom conditions (zone + tau_y) and quantifier conditions. Quantifier conditions are `exists z, nf_eval M k (r+2) [z, y, e] sub` — this is GeneralExistPart(k) at arity r+1. Depth decreases (k+1 -> k), so recursion terminates.

## Finding 6: Third Mutual Induction Conjunct

```
CharPart(0): unchanged (sorry-free)
ExistPart(0): unchanged (sorry-free)
GeneralExistPart(0): NEW base case (zone decomposition, all arities)

CharPart(k+1): from CharPart(k) + ExistPart(k) (unchanged)
ExistPart(k+1): from CharPart(k+1) + ExistPart(k) + GeneralExistPart(k) (sorry closes)
GeneralExistPart(k+1): from CharPart(k+1) + GeneralExistPart(k) (new)
```

No circularity: all dependencies are at LOWER depth k.

## Finding 7: How the Sorry Closes

With redesigned GeneralExistPart, the enriched Until formula changes to include quant_conj:

```lean
let quant_formula : NF(k'+1, 3) -> Formula := fun ssn =>
  (ih_general_exist 2 (by omega) char_k char_k_correct
    ![nf_x0, nf_t0] ssn).choose
let quant_conj := formula_conjList
  (NF(k'+1, 3).list.map fun ssn =>
    if sub_nf.2 ssn then quant_formula ssn
    else (quant_formula ssn).neg)
let enriched_x_type := Formula.and (char_kp1 nf_x0) quant_conj
```

Backward proof: extract x from Until, extract quant_conj truth at x, apply GeneralExistPart correctness with h_x_agree/h_t_agree as preconditions.

## H4 Adversarial Verification

| Challenge | Verdict |
|-----------|---------|
| Can Formula.top/bot work with ANY modification? | NO — Z counterexample is definitive |
| Is zone decomposition provable at depth k > 0? | YES — temporal formulas probe interval structure that 1-var NFs cannot |
| Does VecEA2 generalize to arbitrary arity? | UNCERTAIN (60%) — may need direct encoding instead |
| Does quant_conj evaluation point work? | YES — evaluated at x (Until witness), matching GeneralExistPart e(0) |

## Estimated Implementation

| Component | Lines |
|-----------|-------|
| GeneralExistPart definition (redesigned) | 30 |
| generalExistPart_zero (k=0, zone decomposition) | 300-500 |
| generalExistPart_succ (k+1 step) | 300-500 |
| Zone decomposition helpers | 150-250 |
| Modified kamp_mutual_induction | 50-80 |
| KampBypass.lean integration | 100-150 |
| **Total** | **930-1510** |
