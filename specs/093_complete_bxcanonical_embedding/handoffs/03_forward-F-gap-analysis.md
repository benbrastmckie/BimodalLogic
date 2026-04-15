# Forward-F Gap Analysis

## Status: Phase 1 [PARTIAL] -- Mathematical gap identified

## The Problem

`rr_fwd_chain_forward_F` (RootScopedChain.lean line 1272):
```
F(psi) in chain(n) -> exists s > n, psi in chain(s)
```

## Analysis Summary

After exhaustive analysis, this sorry is **unprovable with the current chain definition**. The gap is NOT in the proof strategy -- it is in the chain construction itself.

## Root Cause

`enriched_fwd_step` (line 561) uses `resolving_enriched_fwd_exists.choose` in the resolving branch. This existential guarantees:

1. `target in M' OR F(target) in M'` (DISJUNCTIVE -- not target in M')
2. F-preservation for all formulas in sigma_list
3. Some witness w in M' (might be != target)

The disjunction in (1) is **genuine** -- the BX11 fold (enriched_fwd_fold_with_witness) processes formulas via temp_linearity, which has three cases. Case 3 ("F(F(beta) and chi) in M") pushes the target under F, giving only F(target) in M'.

Since `.choose` picks an arbitrary MCS satisfying the existential, there is no guarantee that `.choose` will ever select an M' with `target in M'`. The proof cannot force the Left case of the disjunction.

## Approaches Analyzed and Rejected

### 1. Proof by contradiction (19+ prior attempts)
Assume psi never appears in chain(s) for s > n. Then F(psi) persists in chain(m) for all m (by F-obligation constancy). At each visit step for psi, the fold resolves some OTHER formula w != psi. No structural contradiction can be derived:
- The defect set fluctuates (resolved formulas can reappear as defects)
- The BX11 ordering changes at each step (no monotone decrease)
- No well-founded measure works

### 2. Change step to use `fwd_succ` (resolve target directly)
`fwd_succ`'s resolving branch uses seed `{target} union g_content(M)`, giving `target in M'`. BUT this loses F-preservation:
- F-formulas of OTHER formulas are NOT preserved
- Worse: Lindenbaum can add `G(neg chi)` to M', permanently killing F(chi)
- F(psi) can be lost at resolving steps for other targets
- Cannot propagate F(psi) to psi's visit step

### 3. F-preserving seed (`{target} union g_content(M) union f_carry(M)`)
Proved WRONG by Task #69. The seed is inconsistent because G-lifting F-formulas is not derivable in BX. The consistency proof requires the G-lift argument, which only works for G-formulas (in g_content), not for F-formulas.

### 4. Combined seed (`{target, beta'} union g_content(M)`)
Where beta' is the fold compound. Consistency requires `F(target and beta') in M`, but temp_linearity Case 3 (`F(F(target) and beta') in M`) prevents this in the general case.

### 5. Reorder fold to put target last
Processing target last gives target in M' in Cases 1 and 3, but Case 2 (`F(beta and F(target)) in M`) still gives only F(target). And we cannot rule out Case 2.

### 6. Reorder fold to put target first, use F_mono
When beta already has target as leftmost conjunct, `F(beta and target)` follows from `F(beta)` by `F_mono` (since `beta -> beta and target` when target is a conjunct). This forces Case 1. BUT: a subsequent Case 3 (for a later formula) can DOWNGRADE target's extraction from Or.inl to Or.inr.

### 7. Two-phase step (enriched fold then fwd_succ)
Use enriched fold for F-preservation (get M1), then fwd_succ from M1 for target resolution (get M2). But M2 does not preserve F-formulas from M1. The g_content(M1) subset M2 does not include F-formulas.

## The Mathematical Gap

The BX11 axiom (temporal linearity) gives three cases for any pair F(A), F(B) in an MCS:
- F(A and B) in M (both resolved together)
- F(A and F(B)) in M (A resolved first)
- F(F(A) and B) in M (B resolved first)

The fold compounds these pairwise choices into a single compound formula. The "earliest" formula (in BX11 ordering) gets direct membership in M'; all others get at best F-protection.

The target might NEVER be "earliest" at any visit step. The BX11 ordering depends on the current MCS, which changes at each step. There is no monotonicity or convergence guarantee.

## Recommended Fix

The chain definition needs to change so that `enriched_fwd_step` guarantees `target in M'` (not disjunctive). Two viable approaches:

### Approach A: Target-prioritized fold
Modify the fold to MAINTAIN target as a direct conjunct throughout, even when Case 3 fires for other formulas. This requires a new fold variant that:
- Keeps target separate from the fold compound
- When Case 3 fires for chi: compound becomes `F(old_compound) and chi`, but target stays as a SEPARATE conjunct
- Final seed: `{target and compound} union g_content(M)` where compound protects F-formulas

Consistency proof: need `F(target and compound) in M`. From F(target) in M and F(compound) in M, temp_linearity gives F(target and compound) in M in Case 1. Cases 2 and 3 give different compounds but might still give consistency via a different argument.

### Approach B: Iterative refinement
Instead of a single fold, use an iterative process:
1. Start with seed `{target} union g_content(M)`
2. Lindenbaum gives M' with target in M'
3. For each chi with F(chi) in M: if F(chi) not in M', there is nothing to do (chi is not a defect in M'). If F(chi) in M': already preserved.
4. Issue: we cannot verify F(chi) in M' or not, since Lindenbaum is non-constructive.

### Approach C: Different chain architecture
Instead of a round-robin chain with one step per formula, use a chain where each "step" resolves the target directly (using `discharge_single_step`) and accepts that other F-formulas may be lost. Then prove forward_F by showing that at psi's visit step (where target = psi and F(psi) in chain(s)), psi in chain(s+1). The F-propagation gap is bridged by showing F(psi) cannot be permanently lost once it enters the chain.

The key observation for Approach C: if G(neg psi) enters chain(k), it stays forever (by g_content + temp_4). But G(neg psi) entering chain(k) means F(psi) not in chain(k), contradicting F(psi) in chain(n) and the `no_new_f_defects` argument... wait, `no_new_f_defects` says: G(neg psi) in chain(n) implies F(psi) not in chain(n+1). The CONTRAPOSITIVE is: F(psi) in chain(n+1) implies G(neg psi) not in chain(n).

But with `fwd_succ`, F(psi) might not be in chain(n+1) even when F(psi) in chain(n). So G(neg psi) COULD enter chain(n+1).

Once G(neg psi) enters, it stays forever, making forward_F impossible. The question is: can G(neg psi) enter the chain between step n (where F(psi) in chain(n)) and psi's visit step?

If yes: forward_F fails.
If no: forward_F works.

To prevent G(neg psi) from entering: need to show {target_k} union g_content(chain(k)) is inconsistent with G(neg psi) at each intermediate step k. This requires G(neg psi) to be derivable from {target_k} union g_content(chain(k)), which means... this is the consistency question again.

## Files Modified
None (analysis only).

## Effort Spent
~5 hours of mathematical analysis.
