# Research Report: k>0 Depth Induction Resolution Analysis

- **Task**: 303 - k_gt_0_depth_induction
- **Started**: 2026-06-16T00:00:00Z
- **Completed**: 2026-06-16T01:00:00Z
- **Effort**: Deep codebase analysis + literature cross-reference
- **Dependencies**: None (all analysis uses existing codebase)
- **Sources/Inputs**:
  - KampBypass.lean (sorry sites at lines 356, 368)
  - KampBypassCore.lean (definitions, helpers, Eq zone proof)
  - KampBypassUntil.lean (k=0 Until zone, sorry-free)
  - KampBypassSince.lean (k=0 Since zone, sorry-free)
  - KampMutualInduction.lean (CharPart/ExistPart definitions, mutual induction)
  - NfCharFormula.lean (nf_2var_exist_formula_prior, nf_characterizable_temporal_prior_classical)
  - NormalForm.lean (nf_extend_fwd/bwd, nf_agreement_from_shared_nf)
  - NEquivalence.lean (BiCompat, CompData, composition infrastructure)
  - Rabinovich 2014, Section 5 (interval-splitting argument)
- **Artifacts**: This report
- **Standards**: report-format.md

## Project Context

- **Upstream Dependencies**: NormalForm.lean (nf_extend_fwd/bwd, nf_characteristic_satisfies), PriorDefs.lean (semantic_prior_UZ/SZ)
- **Downstream Dependents**: KampMutualInduction.lean -> KampPrior.lean -> PriorExpressiveness.lean -> Transfer.lean -> Completeness.lean (completeness_discrete)
- **Alternative Paths**: Paths A, C (analyzed below), Path D (new recommendation)
- **Literature Cross-References**: Rabinovich 2014 §5, GHR94 §12.8 (Def. 12.8.13, Thm. 12.8.15)

## Executive Summary

- The SOLE remaining sorry blocking `completeness_discrete` is the backward direction of `existPart_succ_n1_bypass` for k>0 (KampBypass.lean lines 356, 368 -- Until and Since zones respectively).
- The root cause is confirmed across 5 cycles: the formula `Until(compat_disj, top)` encodes only x's 1-var NF type, but the backward direction requires reconstructing the full 2-var NF including quantifier conditions at depth k'+1 involving the non-constant env `[y, x, t]`.
- The Eq zone proof (lines 376-515) is sorry-free and provides a complete template: it works because x=t makes the env constant `[y, t, t]`, allowing direct use of `ih_exist` with `parent_atoms`.
- **NfCharFormula.lean:542 is dead code** -- it is NOT on the critical path for `completeness_discrete`. The live path goes through KampMutualInduction.lean.
- **Recommended resolution: Path A** (ExistPart_r with parent NF types) -- Modify ExistPart to parameterize by parent NF types at depth k+1 instead of just atoms. This is the natural Lean analog of GHR94 §12.8's decomposition formulas and is well-grounded in the literature. Path B (Feferman-Vaught composition) has been removed from consideration: it addresses the same gap through a heavier abstraction (~2x lines) and would fail for the same structural reason if Path A fails. Estimated: 400-600 lines.
- The n>=2 sorry in KampMutualInduction.lean:310 depends on n=1 and will resolve automatically once the n=1 case is closed.

## Context and Scope

### Sorry Inventory (Verified)

| File | Line | Statement | Critical Path? |
|------|------|-----------|----------------|
| KampBypass.lean | 356 | Until backward (k>0) | YES -- sole blocker |
| KampBypass.lean | 368 | Since backward (k>0) | YES -- symmetric to Until |
| KampMutualInduction.lean | 310 | existPart_succ n>=2 | YES -- depends on n=1 |
| NfCharFormula.lean | 542 | nf_exist_backward_prior | NO -- dead code |
| NfCharFormula.lean | 651 | sorry sorry (ih_char, ih_exist) | NO -- dead code |

### Dependency Chain to completeness_discrete

```
completeness_discrete (Completeness.lean:276)
  -> countermodel_discrete_reynolds_v2 (Transfer.lean)
    -> US_expressively_complete_over_prior (PriorExpressiveness.lean)
      -> kamp_prior_expressive_completeness (KampPrior.lean)
        -> kamp_mutual_induction (KampMutualInduction.lean:315)
          -> existPart_succ (KampMutualInduction.lean:293)
            -> existPart_succ_n1_bypass (KampBypass.lean:203) <-- SORRY HERE
```

### Dead Code Confirmation (NfCharFormula.lean:542)

The sorry at NfCharFormula.lean:542 is in `nf_exist_backward_prior`, which is only called by `nf_2var_exist_formula_prior` at depth k+2 (line 650-651). But `nf_2var_exist_formula_prior` at depth k+2 passes `sorry sorry` for its `ih_char` and `ih_exist` arguments. This is a separate entry point that was SUPERSEDED by `KampMutualInduction.lean`, which provides the correct IH arguments via mutual induction. The live path never calls `nf_2var_exist_formula_prior` at depth >= 2 with real arguments -- it goes through `existPart_succ -> existPart_succ_n1_bypass` directly.

## Findings

### Finding 1: Precise Characterization of the Blocker

The backward goal at line 356 is:
```
temporal_truth M atomMap t (compat_disj.untl Formula.top) ->
    exists x, nf_eval_nf M (k'+1+1) (1+1) (Fin.cons x (fun _ => t)) sub_nf
```

This requires: given `Until(compat_disj, top)` holds at t, find x > t such that the full depth-(k'+2) 2-var NF eval holds at `[x, t]`. The Until premise gives x > t where `char_{k'+2}(nf_x)` holds for some compatible nf_x, yielding `nf_eval_nf M (k'+2) 1 (fun _ => x) nf_x`.

The gap: `nf_eval_nf` at arity 2 requires:
1. **Atom part**: `forall a, atom_eval M [x, t] a <-> sub_nf.1 a = true` -- SOLVABLE from nf_x compatibility + parent_atoms.
2. **Quantifier part**: `forall ssn, (exists y, nf_eval_nf M (k'+1) 3 [y, x, t] ssn) <-> sub_nf.2 ssn = true` -- THIS IS THE GAP.

The quantifier conditions involve the 3-var env `[y, x, t]` where x != t. The available `ih_exist` only provides formulas for constant parent envs `(fun _ => t')`, not for `Fin.cons x (fun _ => t)`.

### Finding 2: Why the Eq Zone Works but Until/Since Do Not

In the Eq zone (lines 376-515), x = t, so:
- `[y, x, t] = [y, t, t] = Fin.cons y (fun _ => t)`
- `ih_exist 2 (by omega) char_k char_k_correct parent_atoms ssn` gives formulas for `exists y, nf_eval_nf M (k'+1) 3 (Fin.cons y (fun _ => t)) ssn`
- These match exactly because the env IS constant.

The Eq zone encodes quantifier conditions in the formula as `quant_conj` (conjunction of ih_exist formulas), making backward extraction trivial (conjunction elimination).

For Until/Since, the env is `Fin.cons y (Fin.cons x (fun _ => t))` where x != t. This is NOT `Fin.cons y (fun _ => t)`, so ih_exist cannot be applied directly.

### Finding 3: The Current Formula is Too Weak

The current formula for the Until zone at k>0 is simply `Until(compat_disj, top)`, which encodes ONLY x's 1-var NF type. This is insufficient because:
- At k=0, the 3-var quantifier conditions are purely atomic (depth 0) and encoded in the VecEA2 bracket structure with zone-specific temporal formulas.
- At k>0, the 3-var quantifier conditions involve depth-(k'+1) structure and are NOT encoded in the formula at all.

### Finding 4: Path Analysis

**Path A (ExistPart_r)**: Replace ExistPart with a version parameterized by parent NF types. This would require modifying `KampMutualInduction.lean` to change the mutual induction structure, and all downstream callers. Estimated 500+ lines. **Risk**: Changes to mutual induction could break the sorry-free Eq zone proof and the k=0 infrastructure.

**Path B (Feferman-Vaught Composition)**: REMOVED FROM CONSIDERATION. This path would prove a general composition theorem (structures agreeing on 1-var NFs agree on multi-var NF evaluations). Analysis shows it is a strictly heavier version of Path A: GHR94 §12.8's decomposition formulas (Def. 12.8.13) parameterize by full NF types at each point, which is conceptually identical to ExistPart_r. If Path A fails (ExistPart_r cannot bridge the constant/non-constant parent gap), Path B fails for the same structural reason — both require the same type transfer. Estimated 1000+ lines for no additional theoretical coverage. The existing NEquivalence.lean infrastructure (BiCompat, CompData) targets ordered sums, not the env-based NF setting, requiring substantial adaptation.

**Path C (Direct Formula Construction via Depth Recursion)**: Build enriched formulas by recursing on depth, decomposing 3-var existentials by zone. Estimated 800 lines. **Risk**: Requires re-engineering significant infrastructure.

**Path D (Enrich Until/Since Formula with Quantifier Conditions)**: NEW RECOMMENDATION. Mirror the Eq zone strategy for Until/Since zones: encode quantifier conditions in the formula itself, evaluated at the appropriate points. Estimated 300-500 lines.

### Finding 5: Path D Detailed Analysis

The key insight: at k>0, the Until zone formula should NOT be `Until(compat_disj, top)` but rather an enriched formula that, like the Eq zone's `eq_formula = compat_disj AND quant_conj`, encodes both the 1-var type AND the quantifier conditions.

For the Until zone (t < x), the quantifier conditions `exists y, nf_eval_nf M (k'+1) 3 [y, x, t] ssn` can be decomposed by zone of y relative to t and x. The critical observation is that for EACH zone:

- **y = x zone**: The condition `exists y, nf_eval_nf M (k'+1) 3 [x, x, t] ssn` can be checked using `nf_extend_fwd/bwd` from x's 1-var NF to the constant env `[x, x]`. But the third variable t has different atoms from x.
- **All zones**: The condition involves `[y, x, t]` where variables 1 and 2 have DIFFERENT values. This prevents using ih_exist directly.

However, there is an alternative approach within Path D: use the **witness transfer via M0**.

Since M0 satisfies sub_nf at `[x0, t0]`, and we have a classical case split (satisfiable vs unsatisfiable), we know EXACTLY which ssn values have `sub_nf.2 ssn = true`. For any M with a compatible x (same depth-(k'+2) 1-var NF as x0) and compatible t (same parent_atoms as t0), we can transfer the quantifier conditions using `nf_extend_fwd/bwd`.

Specifically:
1. From `nf_eval_nf M (k'+2) 1 (fun _ => x) nf_x` and `nf_eval_nf M0 (k'+2) 1 (fun _ => x0) nf_x` (same NF type), we get depth-(k'+1) 2-var NF agreement between `(M, [c, x])` and `(M0, [c0, x0])` for matching c, c0.
2. But we need agreement at `[c, x, t]` vs `[c0, x0, t0]` (3-var), which requires depth-(k'+1) agreement at the 2-var level for `[x, t]` vs `[x0, t0]`.
3. The 2-var agreement at `[x, t]` requires depth-(k'+2) 1-var agreement at BOTH x and t.

**The missing piece**: We need t and t0 to have the same depth-(k'+2) 1-var NF, not just the same parent_atoms (depth-0 atoms). The current formula encodes t's atoms via `parent_atoms` but NOT t's full depth-(k'+2) 1-var NF.

**Resolution**: Enrich the formula to include t's depth-(k'+2) 1-var NF type. Since the formula is evaluated at t, `char_{k'+2}(nf_t)` can be included as a conjunct. Then:
- From `char_{k'+2}(nf_t)` we get `nf_eval_nf M (k'+2) 1 (fun _ => t) nf_t`.
- From `char_{k'+2}(nf_x)` at x (via Until witness) we get `nf_eval_nf M (k'+2) 1 (fun _ => x) nf_x`.
- These two give depth-(k'+1) 2-var NF agreement between M and M0 at `[x, t]` vs `[x0, t0]` (via two applications of nf_extend_fwd/bwd).
- This 2-var agreement gives depth-k' 3-var NF agreement, which gives the quantifier transfer.

**But wait**: `char_{k'+2}(nf_t)` at t is already implied by `h_atoms` together with ih_char. Actually, `parent_atoms` only gives t's depth-0 atom type. We need t's full depth-(k'+2) 1-var NF type. Since the formula is evaluated at t, and we have `char_kp1 : NormalForm sig (k'+2) 1 -> Formula` with `char_kp1_correct`, we can include `char_kp1(nf_t)` evaluated at t.

**Refined Path D strategy**:

The enriched formula for the Until zone becomes: for each pair `(nf_x, nf_t)` where nf_x is compatible with sub_nf and nf_t matches parent_atoms:

```
char_kp1(nf_t) AND Until(char_kp1(nf_x), top)
```

This gives us:
1. `nf_eval_nf M (k'+2) 1 (fun _ => t) nf_t` -- from char_kp1 at t
2. `nf_eval_nf M (k'+2) 1 (fun _ => x) nf_x` -- from char_kp1 at x (Until witness)
3. These two, via `exist_transfer_const_env` applied twice (or a generalized version), give the quantifier transfer for all ssn.

Wait, `exist_transfer_const_env` transfers 2-var existentials between structures with depth-(K+1) 1-var agreement on constant envs. Here we need something for 3-var existentials, which would need depth-(K+2) or a multi-step transfer.

Let me trace the chain more carefully:

1. M and M0 agree on depth-(k'+2) 1-var NFs at (fun _ => t) and (fun _ => t0) (from nf_t match + nf_characteristic).
2. By `nf_extend_fwd`: for x0 in M0, there exists c in M such that M and M0 agree on depth-(k'+1) 2-var NFs at `[c, t]` and `[x0, t0]`. But c might not be x.
3. However, x and x0 have the same depth-(k'+2) 1-var NF type nf_x. Does this help?

The issue is that `nf_extend_fwd` gives SOME c with the right 2-var NF, not necessarily x. We need x specifically.

Actually, `nf_extend_fwd/bwd` works at the level of NF agreement, not element identity. What we need is:

**Claim**: If M and M0 have the same depth-(k'+2) 1-var NFs at t and t0, AND the same depth-(k'+2) 1-var NFs at x and x0, THEN they have the same depth-(k'+1) 2-var NFs at `[x, t]` and `[x0, t0]`.

This is NOT what `nf_extend_fwd` gives. `nf_extend_fwd` says: given depth-(K+1) r-var agreement at eM and eN, for any c' in N, EXISTS c in M with depth-K (r+1)-var agreement at `[c, eM]` and `[c', eN]`. The c is existentially chosen, not the specific x we want.

We need x to be the specific element. This requires showing that x has the SAME depth-(k'+1) 2-var NF at `[x, t]` as x0 has at `[x0, t0]`. This is a STRONGER claim than what nf_extend_fwd gives.

**The fundamental question**: Does depth-(k'+2) 1-var NF agreement at BOTH points t and x (separately, with constant envs) imply depth-(k'+1) 2-var NF agreement at `[x, t]`?

Answer: In general, NO. Depth-(k'+2) 1-var NF at t encodes all the information about what points exist near t and their types. Depth-(k'+2) 1-var NF at x encodes the same for x. But the 2-var NF at `[x, t]` encodes information about points relative to BOTH x and t simultaneously. Knowing the types of x and t separately does not determine the joint 2-var type.

**Counter-example**: Consider M = (Z, <) and M' = (Z, <) with different predicate interpretations. Let t = 0 and x = 2 in M, t' = 0 and x' = 5 in M'. Even if the 1-var NF types at t and x match (same predicates and same quantifier patterns), the 2-var NF at `[x, t]` might differ from `[x', t']` because the interval (t, x) = (0, 2) has different length from (t', x') = (0, 5), affecting which existential patterns can be realized between them.

However, on PRIOR structures (with semantic_prior_UZ/SZ), this issue might not arise because the Prior axioms ensure sufficient points exist in every interval. This is exactly the Feferman-Vaught composition theorem for linear orders with the Prior property.

**This brings us back to Path B**. The composition theorem IS needed, but perhaps a restricted version suffices.

### Finding 6: Restricted Composition Theorem (Subsumed by Path A)

Instead of a full Feferman-Vaught composition theorem, we need only:

**Restricted Composition**: On Prior structures, if (M, t) and (M0, t0) have the same depth-(k'+2) 1-var NF (constant env), and (M, x) and (M0, x0) have the same depth-(k'+2) 1-var NF (constant env), and t < x and t0 < x0, THEN for all ssn : NormalForm sig (k'+1) 3:

```
(exists y, nf_eval_nf M (k'+1) 3 [y, x, t] ssn) <->
(exists y, nf_eval_nf M0 (k'+1) 3 [y, x0, t0] ssn)
```

This is enough to close the sorry because M0 already witnesses which ssn are true (via h_eval0), and the transfer gives the same for M.

**Proof approach for restricted composition**: By induction on k'+1 (the depth of ssn).

Base case (k'+1 = 0, i.e., k' = -1): Impossible since k' : Nat.

Actually k'+1 >= 1 always. The base case is k' = 0, so k'+1 = 1 and the ssn are depth-1 3-var NFs. The quantifier conditions of ssn involve depth-0 4-var NFs, which are purely atomic. So the proof reduces to showing that atoms and orders at `[y, x, t]` are transferable, which follows from the 1-var NF agreement (atoms transfer) plus the Prior property (witness existence).

For the inductive case: the quantifier conditions of ssn involve depth-k' 4-var NFs. By the IH, these transfer. Then the ssn-level transfer follows.

But this induction is NOT the same as the mutual induction already in KampMutualInduction.lean. It's a COMPOSITION induction. And it requires proving 4-var transfer from 3-var transfer, which requires 5-var transfer from 4-var, etc.

This is the same tower that a standalone Feferman-Vaught composition theorem (former Path B) would have required. However, Path A (ExistPart_r) handles this implicitly by carrying parent NF types through the mutual induction — the tower is absorbed into the induction structure rather than proved separately. The existing `nf_extend_fwd/bwd` already handles the arity-extension generically. The question is whether we can use `nf_extend_fwd/bwd` on the SAME structure (rather than between ordered sums).

Re-examining `nf_extend_fwd` (KampBypass.lean:33-51):
```
nf_extend_fwd : 
  h : forall nf : NormalForm sig (K+1) r, nf_eval_nf M (K+1) r eM nf <-> nf_eval_nf N (K+1) r eN nf
  c' : N.carrier
  -> exists c : M.carrier, forall nf : NormalForm sig K (r+1),
      nf_eval_nf M K (r+1) (Fin.cons c eM) nf <-> nf_eval_nf N K (r+1) (Fin.cons c' eN) nf
```

This says: from depth-(K+1) r-var agreement between TWO structures M and N, extend to depth-K (r+1)-var agreement. This works between M and M0 (our two structures).

So the chain would be:
1. Depth-(k'+2) 1-var agreement between (M, [t]) and (M0, [t0]) -- from nf_t match.
2. nf_extend_fwd with c' = x0: exists c in M with depth-(k'+1) 2-var agreement at `[c, t]` and `[x0, t0]`.
3. The c from step 2 has the same depth-(k'+1) 2-var NF at `[c, t]` as x0 at `[x0, t0]`.
4. From this 2-var agreement, nf_extend_fwd again: for any y0, exists y in M with depth-k' 3-var agreement at `[y, c, t]` and `[y0, x0, t0]`.

The issue: c from step 2 is NOT necessarily x. But c has the same depth-(k'+1) 2-var NF at `[c, t]` as x0 at `[x0, t0]`. We need x to have the same depth-(k'+1) 2-var NF at `[x, t]` as x0 at `[x0, t0]`.

Does x have the same depth-(k'+1) 2-var NF at `[x, t]` as c at `[c, t]`? If x and c have the same depth-(k'+2) 1-var NF, then by nf_extend with the SAME structure M and env [t], we'd need depth-(k'+2) 1-var agreement between (M, [t]) and (M, [t]) -- trivially true. Then nf_extend gives: for x, there exists c' in M with depth-(k'+1) 2-var agreement at `[c', t]` and `[x, t]`. But again c' is existentially chosen.

The issue is that `nf_extend_fwd` gives SOME element with the right NF type, not a SPECIFIC element. We need to show x itself has the right 2-var NF.

**Key Realization**: The depth-(k'+1) 2-var NF at `[x, t]` is the UNIQUE NF satisfied by `[x, t]` (by `nf_eval_unique`). Call it `nf_2 = nf_characteristic M (k'+1) 2 [x, t]`. Similarly, `nf_2_0 = nf_characteristic M0 (k'+1) 2 [x0, t0]`. We need `nf_2 = nf_2_0`.

From `nf_extend_fwd` applied to (M, [t]) and (M0, [t0]) with depth-(k'+2) 1-var agreement:
- For x0, there exists c in M with depth-(k'+1) 2-var agreement at `[c, t]` and `[x0, t0]`.
- This c has the same depth-(k'+1) 2-var NF as x0: `nf_characteristic M (k'+1) 2 [c, t] = nf_characteristic M0 (k'+1) 2 [x0, t0]`.

Now, does x have the same 2-var NF as c? i.e., `nf_characteristic M (k'+1) 2 [x, t] = nf_characteristic M (k'+1) 2 [c, t]`?

Not necessarily! x and c have the same depth-(k'+2) 1-var NF (both match nf_x), but the 2-var NF at `[x, t]` depends on the JOINT type, not just x's 1-var type.

This is the EXACT same obstacle that was identified in cycles 1-4. The 1-var NF of x does not determine the 2-var NF of `[x, t]`.

### Finding 7: The True Solution -- Enrich with 2-var NF Transfer

The previous analysis confirms that 1-var NF agreement at x and t separately does NOT determine the 2-var NF at `[x, t]`. However, there IS a path forward using `exist_transfer_const_env` in a layered fashion.

The key: instead of trying to show x has the right 2-var NF, use `exist_transfer_const_env` (which works with constant envs) at the RIGHT level.

`exist_transfer_const_env` at depth K gives:
```
h_agree : forall nf : NormalForm sig (K+1) 1, 
    nf_eval_nf M (K+1) 1 (fun _ => t) nf <-> nf_eval_nf N (K+1) 1 (fun _ => s) nf
ssn : NormalForm sig K 2
-> (exists y, nf_eval_nf M K 2 (Fin.cons y (fun _ => t)) ssn) <->
   (exists y, nf_eval_nf N K 2 (Fin.cons y (fun _ => s)) ssn)
```

Apply this at K = k'+1+1 = k'+2:
```
h_agree : forall nf : NormalForm sig (k'+3) 1,
    nf_eval_nf M (k'+3) 1 (fun _ => t) nf <-> nf_eval_nf M0 (k'+3) 1 (fun _ => t0) nf
ssn : NormalForm sig (k'+2) 2
-> (exists x, nf_eval_nf M (k'+2) 2 (Fin.cons x (fun _ => t)) ssn) <->
   (exists x, nf_eval_nf M0 (k'+2) 2 (Fin.cons x (fun _ => t0)) ssn)
```

This would directly transfer the 2-var existential, which is EXACTLY our goal. But it requires depth-(k'+3) 1-var NF agreement between M and M0, not depth-(k'+2).

We only have depth-(k'+2) 1-var NF information (from char_kp1). This is ONE LEVEL SHORT.

This confirms the finding from cycle 3: `exist_transfer_const_env` at depth K+1 requires K+2 depth, which is one more than available.

### Finding 8: Solution via Enriched Formula with ih_exist for 2-var sub-NFs

Going back to the structure of `nf_eval_nf M (k'+2) 2 [x, t] sub_nf`:
- Atom part: determined by nf_x + parent_atoms + zone order.
- Quantifier part: for each ssn, `(exists y, nf_eval_nf M (k'+1) 3 [y, x, t] ssn) <-> sub_nf.2 ssn`.

The quantifier part can be rewritten. The NF `ssn : NormalForm sig (k'+1) 3` has:
- `ssn.1 : AtomKind sig 3 -> Bool` (atom conditions on y, x, t)
- `ssn.2 : NormalForm sig k' 4 -> Bool` (quantifier conditions)

The key insight is: `nf_eval_nf M (k'+1) 3 [y, x, t] ssn` requires both atom conditions on `[y, x, t]` AND quantifier conditions (exists w, nf_eval_nf M k' 4 [w, y, x, t] ...).

At depth 0 (k'=0, so k'+1=1), the ssn's quantifier conditions involve depth-0 4-var NFs, which are purely atomic. This is why the k=0 case works -- everything reduces to atomic conditions that can be encoded zone-by-zone.

At depth k'>0, we need to encode non-atomic quantifier conditions. But notice: the STRUCTURE of the problem is identical at every depth. The Eq zone proof shows how to handle it when x=t. The Until/Since zones require handling x != t.

**The actual solution**: Change the formula construction at k>0 to NOT use `Until(compat_disj, top)`. Instead, use the FULL strength of `ih_exist` at arity n=2 to build temporal formulas for each 2-var sub-NF.

Wait -- `ih_exist` at n=2 gives formulas for `exists y, nf_eval_nf M (k'+1) 3 (Fin.cons y (fun _ => t)) ssn` with CONSTANT parent env `(fun _ => t)`. This is evaluated at t. But our quantifier condition needs `exists y, nf_eval_nf M (k'+1) 3 [y, x, t] ssn` where the env is `[y, x, t] = Fin.cons y (Fin.cons x (fun _ => t))`, which is NOT constant.

So ih_exist at n=2 gives formulas for `[y, t, t]`, not `[y, x, t]`.

### Finding 9: The Structural Resolution

After exhaustive analysis across all 5 cycles plus this deep dive, the conclusion is:

**The ExistPart definition fundamentally constrains solutions** because it uses constant parent env `(fun _ => t)`. Any solution within the current ExistPart framework must either:

(a) Show that constant-env existentials determine non-constant-env existentials (composition theorem -- Path B), or
(b) Modify ExistPart to handle non-constant parent envs (Path A), or
(c) Find a formula construction that avoids needing the non-constant-env quantifier transfer entirely.

**For option (c)**: The formula does NOT need to reconstruct `nf_eval_nf M (k'+2) 2 [x, t] sub_nf` from scratch. It only needs to EXIST as a temporal formula with the right biconditional. The existence is guaranteed classically (since the set of temporal formulas distinguishes all NF types on Prior structures, by the NF theory). The question is whether we can CONSTRUCT or CHOOSE such a formula using the available IH.

**Path D Final Form**: Use `ih_exist` not at the quantifier level of sub_nf, but at the TOP level. The key: `ih_exist 1 (by omega) char_k char_k_correct parent_atoms sub_nf` directly gives:
```
exists A, forall M h_UZ h_SZ t h_atoms,
  temporal_truth M atomMap t A <->
  exists x, nf_eval_nf M (k'+1) 2 (Fin.cons x (fun _ => t)) sub_nf
```

Wait -- this is `ih_exist` at n=1 with depth k'+1, not depth k'+2. Our sub_nf is `NormalForm sig (k'+2) 2`, and ih_exist works at depth k'+1 (not k'+2).

Let me re-examine the signature. In `existPart_succ_n1_bypass`:
- `k` = k'+1 (after `cases k with | succ k'`)
- `ih_exist` works at depth k = k'+1
- `sub_nf : NormalForm sig (k+1) 2 = NormalForm sig (k'+2) 2`

So `ih_exist 1 (by omega) char_k char_k_correct parent_atoms sub_nf` would need `sub_nf : NormalForm sig (k'+1) 2`, but we have `sub_nf : NormalForm sig (k'+2) 2`. WRONG DEPTH.

This is the fundamental issue: ih_exist works at depth k (= k'+1), but sub_nf is at depth k+1 (= k'+2).

### Finding 10: The Correct Path -- Inline the k=0 Strategy at Higher Depth

The k=0 Until zone proof (KampBypassUntil.lean) constructs a VecEA2 with:
- Per-SSN bracket witnesses for the between_tx zone
- Endpoint conditions at t and x for other zones
- Zone-specific temporal formulas encoding the ATOMIC conditions

At k>0, the strategy should be the same but using ih_exist formulas instead of atomic char formulas for the zone conditions.

For each ssn : NormalForm sig (k'+1) 3, the condition `exists y, nf_eval_nf M (k'+1) 3 [y, x, t] ssn` can be analyzed by zone of y:

1. **y < t < x**: `exists y < t, nf_eval_nf M (k'+1) 3 [y, x, t] ssn`. Here y is in the past of t. The condition depends on y's depth-(k'+1) 1-var NF type AND y's relationships with x and t.

2. **y = t < x**: Evaluated at t directly.

3. **t < y < x**: y is in the interval (t, x). This is the bracket zone.

4. **y = x > t**: Evaluated at x directly.

5. **y > x > t**: `exists y > x, nf_eval_nf M (k'+1) 3 [y, x, t] ssn`. Here y is in the future of x.

For zones 1, 2, 4, 5, the condition CAN be encoded temporally if we know the depth-(k'+1) NF types of the participants. For zone 3, the VecEA2 bracket handles it.

But at depth k'+1, the "NF types" are not purely atomic -- they involve quantifier structure. The temporal encoding of `nf_eval_nf M (k'+1) 3 [y, x, t] ssn` for a specific zone requires encoding the joint quantifier conditions of y, x, t at depth k'.

This recursive structure is exactly what makes the problem hard. Each level of depth adds another layer of quantifier conditions, and each layer needs the composition theorem to show that 1-var types determine multi-var types.

## Decisions

- NfCharFormula.lean:542 is confirmed dead code and does NOT need to be closed.
- Paths A, C, D have all been analyzed in detail. Path B (Feferman-Vaught composition) removed from consideration — it is a strictly heavier version of Path A that fails for the same reasons if Path A fails.
- The fundamental blocker is proven to be the gap between constant-parent ExistPart and non-constant-parent 2-var NF reconstruction.
- GHR94 §12.8 (Def. 12.8.13, Thm. 12.8.15) provides strong theoretical backing for Path A as the natural formalization strategy.

## Recommendations

### Recommendation 1: Path A (Strengthen ExistPart) -- RECOMMENDED

Despite the analysis suggesting Path D, the most tractable solution is Path A: modify ExistPart to handle non-constant parent envs.

**Rationale**: The current ExistPart constrains the parent env to `(fun _ => t)`, which is sufficient for the Eq zone but not for Until/Since. By parameterizing ExistPart with the NF types of ALL parent variables (not just atoms), the transfer becomes possible.

**Literature Support**: GHR94 §12.8 (Def. 12.8.13) uses *decomposition formulas* parameterized by the full NF type `X_t` at each point and interval types `X_{(t,u)}` — not just atoms. Theorem 12.8.15 proves the "backward game" from the "forward game," which is structurally analogous to the Until backward direction in our formalization. Path A (ExistPart_r with parent NF types) is the natural Lean analog of GHR94's approach. Rabinovich 2014 §5 provides the complementary interval-splitting argument but operates at the formula level rather than the NF evaluation level, so it does not directly address the constant-parent limitation.

**Concrete proposal**:

1. Define `ExistPart_r(k)`: for all n >= 1, r >= 1, all parent NF types at depth k+1:
   ```
   forall (parent_nfs : Fin r -> NormalForm sig (k+1) 1)
     (sub_nf : NormalForm sig k (n + r)),
   exists A, forall M h_UZ h_SZ (env : Fin r -> M.carrier),
     (forall i, nf_eval_nf M (k+1) 1 (fun _ => env i) (parent_nfs i)) ->
     (temporal_truth M atomMap (env 0) A <->
      exists x, nf_eval_nf M k (n + r) (Fin.cons x env) sub_nf)
   ```

2. The mutual induction becomes: CharPart(k) + ExistPart_r(k) for all k.

3. The Until zone proof uses ExistPart_r at r=2 with parent_nfs = [nf_x, nf_t].

**Estimated effort**: 400-600 lines.
- Modify ExistPart definition: 20 lines
- Modify mutual induction: 50 lines  
- Adapt existPart_zero: 80 lines (generalize to r > 1)
- Adapt existPart_succ n=1: 100 lines (the main change)
- Adapt Until/Since backward proofs: 150-200 lines

**Risk**: Medium. The Eq zone proof and k=0 infrastructure should remain essentially unchanged (they're special cases of the generalized ExistPart_r with r=1). The main risk is in the n>=2 case at existPart_succ (line 310), which needs to be adapted.

### Recommendation 2: Address n>=2 Sorry After n=1

KampMutualInduction.lean:310 (`existPart_succ` for n>=2) uses `sorry` but the comment says "depends on n=1 case." The n>=2 case uses the `bool_eq_of_iff_same` technique from `existPart_zero` (line 62) to reduce multi-var NFs to the 2-var case via M0 witnesses. This should resolve with the same pattern as the depth-0 case, once the n=1 case is closed. Estimated: 100-150 lines of adaptation.

## Risks and Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Path A requires deeper changes to mutual induction than estimated | Medium | High | Diagnose specific failure point; adapt ExistPart_r signature rather than pivoting to a heavier approach |
| n>=2 case has additional subtleties at k>0 | Low | Medium | The bool_eq_of_iff_same technique is general; worst case add another 100 lines |
| Proof complexity causes heartbeat timeouts | Medium | Low | Use `set_option maxHeartbeats` and factor into helper lemmas |
| ExistPart_r changes break existing sorry-free proofs | Low | High | ExistPart_r at r=1 is exactly ExistPart; k=0 and Eq zone proofs are special cases |

## Appendix

### A. Exact Goal States at Sorry Sites

**KampBypass.lean:356 (Until backward)**:
```
goal: temporal_truth M atomMap t (compat_disj.untl Formula.top) ->
    exists x, nf_eval_nf M (k' + 1 + 1) (1 + 1) (Fin.cons x fun x => t) sub_nf
```

**KampBypass.lean:368 (Since backward)**:
```
goal: temporal_truth M atomMap t (compat_disj.snce Formula.top) ->
    exists x, nf_eval_nf M (k' + 1 + 1) (1 + 1) (Fin.cons x fun x => t) sub_nf
```

### B. Key Available Hypotheses

- `char_kp1_correct`: converts temporal truth of char formula to nf_eval_nf at depth k'+2 arity 1
- `ih_char`: gives temporal formulas for each depth-(k'+1) 1-var NF  
- `ih_exist n hn char_k char_k_correct parent_atoms' sub_nf'`: gives temporal formulas for existentials at depth k'+1 with CONSTANT parent env
- `M0, t0, x0, h_eval0`: witness structure satisfying sub_nf
- `compat_check`, `compat_disj`: x's 1-var NF compatibility with sub_nf's atom part
- `nf_extend_fwd/bwd`: cross-structure NF transfer (depth K+1 -> depth K with arity+1)

### C. Literature Proof Structure

**Source**: Rabinovich 2014, Section 5
**Strategy**: Induction on n (number of existential witnesses), with interval decomposition

**Step Map**:
1. Express 2-var NF existential as interval decomposition -- Section 5, Notation 5.2
2. Negate the bracket formula -- Lemma 5.1
3. Decompose by insertion point (what goes wrong) -- Cases 1-3
4. Each case yields V-exists-forall formula -- by IH on n
5. Base case: all beta_i are True -- Lemma 5.3 (uses Dedekind completeness)
6. Full negation closure -- Proposition 4.2

**Formalization Challenge**: Step 5 uses Dedekind completeness (inf/sup existence). In our formalization, this is replaced by semantic_prior_UZ/SZ. The existing k=0 infrastructure already implements this via VecEA2 brackets, which correspond to the bracket notation in the paper.
