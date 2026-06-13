# Backward Direction Analysis for nf_2var_exist_formula_prior

**Session**: sess_1781336159_28ab79
**Date**: 2026-06-13
**Status**: BLOCKED -- deep analysis completed, no code changes

## Summary

Exhaustive analysis of `nf_2var_exist_formula_prior` (NfCharFormula.lean:572) reveals a fundamental mathematical difficulty that cannot be resolved by formula-level tricks. The sorry is genuinely hard for k >= 1.

## What Was Analyzed

### 1. The Sorry Structure

The sorry chain is:
- `nf_2var_exist_formula_prior` (NfCharFormula.lean:572) -- the target
- `nf_exist_formula_nested_backward` (NegationClosure.lean:1712) -- the root blocker
- These are INDEPENDENT sorries with the SAME mathematical content

### 2. Forward Direction (PROVED)

`nf_exist_formula_forward'` proves: if `exists x, nf_eval_nf M k 2 (x, t) sub_nf`, then `temporal_truth M atomMap t (nf_exist_formula ...)`. This works at ALL depths k, for ALL structures (not just Prior). Sorry-free.

### 3. Backward Direction at k=0 (PROVABLE)

At depth 0, `sub_nf : AtomKind sig 2 -> Bool` is purely atomic. The 2-var NF is determined by:
- Predicates at x (from the formula's disjunction over atom-compatible NFs)
- Predicates at t (from parent_atoms + nf_t_compat)
- Order between x and t (from Until/Since placement)

This is already proved as `backward_depth0` (private theorem in NegationClosure.lean:79-197). The proof unfolds `nf_exist_formula`, case-splits on order direction, extracts x from Until/Since, builds the 2-var atom assignment from the extracted data.

### 4. Backward Direction at k >= 1 (BLOCKED)

At depth k+1, `sub_nf = (atoms, quant_assgn)` where `quant_assgn : NormalForm sig k 3 -> Bool`. The formula gives us x with the right 1-var NF (nf_x) plus interval conditions. We need to show:

For each ssn (depth-k 3-var NF): `exists y, nf_eval_nf M k 3 (y, x, t) ssn` iff `sub_nf.2 ssn = true`

**Interval zones (y between t and x)**: Handled by nested Since/Until in the formula. PROVABLE.

**Non-interval zones (y > x, y = x, y = t, y < t)**: The formula does NOT encode these conditions. The v1 filter (`nf_full_compat_right`) returns `true` for atom-compatible non-interval ssns, deferring the quantifier check. The backward direction cannot recover the correct `sub_nf.2(ssn)` from the available data.

**Root cause**: At depth k >= 1, the 3-var NF at (y, x, t) has a quantifier part involving 4-var NFs at (w, y, x, t). This is NOT determined by the 2-var NFs at (y, x) and (x, t) separately. The generalized composition theorem that would provide this decomposition is FALSE on general linear orders (documented counterexample: Z with env1=(0,2), env2=(0,1) in NfComposition.lean header).

## Approaches Considered and Rejected

### A. Strengthen the formula filter
Add non-interval zone checks to `nf_full_compat_right`. At k=0, this works (3-var atoms determined by projection). At k >= 1, the zone check requires model-dependent information (which depth-k 3-var NFs are realized), making a syntactic filter impossible.

### B. Model-theoretic approach (doets_lemma_1_1)
Show Q(M,t) is invariant under depth-(k+1) 1-var NF, then classify NFs and build A as a disjunction. This works in PRINCIPLE but requires P1(k+1) (depth-(k+1) characterization formulas), which is built FROM P2(k) = nf_2var_exist_formula_prior. CIRCULAR.

### C. Use intra_structure_extend
Same circularity: needs higher-depth NF characterization that depends on the theorem being proved.

### D. Use nf_2var_exist_formula_prior_fill from NegationClosure
Has the same sorry (nf_exist_formula_nested_backward). Also blocked by circular imports: NfCharFormula cannot import NegationClosure.

### E. Rabinovich's formula-level translation
Rabinovich Prop 3.5 translates V-exists-forall formulas to TL. But our "exists x, nf_eval_nf M k 2 (x,t) sub_nf" is not directly in V-exists-forall form -- it has NESTED quantifiers (the nf_eval conditions). Converting it requires Prop 4.3 (every FO formula -> V-exists-forall), which requires Prop 4.2 (negation closure), which is the SAME mathematical content as what's blocked.

## Viable Path Forward

### Option 1: Restructure the mutual induction

Move `master_induction` and supporting code from NegationClosure.lean to a new file `MasterInduction.lean` that does NOT import NfCharFormula. Then NfCharFormula can import MasterInduction and use `nf_2var_exist_formula_prior_fill`. This requires:
- Moving ~700 lines of code (backward_depth0, nf_exist_formula_nested, nf_full_compat_right, etc.)
- The moved code must not depend on NfCharFormula (it currently uses nf_exist_formula, nf_t_compat, nf_order_dir, etc.)
- These definitions ARE in NfCharFormula, so they'd need to be moved too, or the mutual induction file would need to define its own versions

### Option 2: Prove nf_exist_formula_nested_backward for ALL k

This is the mathematically hard option. The proof needs to show: for non-interval zones at depth k >= 1, the quantifier conditions are determined by the formula truth. This likely requires:
- A strengthened formula that encodes zone 1/2/4/5 conditions
- Or a proof that the v1 filter (nf_full_compat_right) already implies the correct quantifier conditions on Prior structures specifically (using semantic_prior_UZ/SZ in some way)

### Option 3: Bypass nf_2var_exist_formula_prior entirely

Instead of filling the sorry in NfCharFormula.lean, modify KampPrior.lean to use `nf_2var_exist_formula_prior_fill` from NegationClosure.lean directly (since KampPrior.lean does not have the circular import issue -- NegationClosure imports KampPrior, not the other way around). Wait -- NegationClosure IMPORTS KampPrior, so KampPrior cannot import NegationClosure either.

Actually: KampPrior.lean calls `nf_characterizable_temporal_prior_classical` which is in NfCharFormula.lean. And `nf_characterizable_temporal_prior_classical` calls `nf_2var_exist_formula_prior`. So to bypass, we'd need to inline the master_induction logic into KampPrior.lean or NfCharFormula.lean.

### Recommended Approach

Create a new file `MasterInductionCore.lean` that:
1. Defines the core formula constructions (nf_exist_formula, nf_t_compat, nf_order_dir) -- extracted from NfCharFormula
2. Proves backward_depth0
3. Defines nf_exist_formula_nested  
4. Proves nf_exist_formula_nested_forward
5. Proves nf_exist_formula_nested_backward (with sorry at k >= 1 for non-interval zones)
6. Proves master_induction with P1(k) and P2(k)
7. Exports nf_2var_exist_formula_prior_fill

Then have NfCharFormula import MasterInductionCore and fill the sorry with nf_2var_exist_formula_prior_fill.

This restructuring separates the formula construction (which NfCharFormula can import without cycles) from the KampPrior chain (which creates the cycle).

**Estimated effort**: 3-4 hours for the restructuring, assuming the sorry at k >= 1 remains.

## Key Files

- `NfCharFormula.lean:572` -- the sorry target
- `NegationClosure.lean:1712` -- the root mathematical blocker (nf_exist_formula_nested_backward)
- `NegationClosure.lean:79-197` -- backward_depth0 (sorry-free, handles k=0)
- `NegationClosure.lean:1736-1831` -- master_induction (P1+P2 simultaneous induction)
- `NfComposition.lean` -- documents generalized_composition being FALSE
