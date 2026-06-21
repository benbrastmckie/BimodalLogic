# Phase 6d Handoff: Zone-3 Existential Transfer

## Immediate Next Action
Implement `exist_transfer_upgrade` in PriorComposition.lean with two cases:
1. Inductive step (k >= 1): sorry-free, proven by finding witness via depth-k existential transfer, verifying atoms via atom_agreement_from_nf, and handling quantifier via IH at (n+1) with the depth-k agreement at the extended env.
2. Base case (k = 0): requires Prior-specific argument (see analysis below).

## Current State
- Phase 6d: IN PROGRESS (4 sorries remain at lines 563, 568, 619, 623)
- Build: passes with sorries
- All other phases (6a-6c): COMPLETED and sorry-free

## Key Discovery: exist_transfer_upgrade Lemma

The resolution of all 4 sorries is a single new lemma `exist_transfer_upgrade`:

```lean
theorem exist_transfer_upgrade {sig : MonadicSignature} :
    forall (k n : Nat) (M : OMS sig) (envM : Fin (n+1) -> M.carrier)
    (N : OMS sig) (envN : Fin (n+1) -> N.carrier)
    (h_agree : forall nf : NF sig (k+1) (n+1), nf_eval_nf M (k+1) (n+1) envM nf <-> nf_eval_nf N (k+1) (n+1) envN nf)
    (sub : NF sig (k+1) (n+2)),
    (exists z, nf_eval_nf M (k+1) (n+2) (Fin.cons z envM) sub) <->
    (exists z', nf_eval_nf N (k+1) (n+2) (Fin.cons z' envN) sub)
```

This extends `exist_transfer_from_full_agree` by exactly one depth level: from d <= k to d = k+1.

### Inductive Step (PROVEN)
For `succ k ih`: depth-(k+2) agreement -> depth-(k+2) existential transfer.
1. Extract quantifier transfer `hex` from h_agree (depth-(k+1) existential transfer)
2. Forward: find z' via `hex` using `nf_characteristic M (k+1) (n+2) [z, envM]`
3. `nf_agreement_from_shared_nf` gives `h_full`: depth-(k+1) (n+2)-var agreement at [z,envM]/[z',envN]
4. Atoms: `atom_agreement_from_nf M _ N _ h_full a` transfers hz_atoms
5. Quant at depth k+1 arity n+3: apply `(ih (n+1) M (Fin.cons z envM) N (Fin.cons z' envN) h_full chi_sub).symm`

The IH at `n+1` provides depth-(k+1) (n+3)-var existential transfer from depth-(k+1) (n+2)-var agreement. This is exactly what the quantifier condition requires. The `.symm` handles the direction flip between the goal and the IH.

Backward direction is symmetric with `ih ... h_full chi_sub` (without .symm).

### Base Case (k=0) -- BLOCKED

The base case is FALSE for general structures. From depth-1 (n+1)-var agreement, depth-1 (n+2)-var existential transfer requires depth-0 (n+3)-var existential transfer at the extended env [z,envM]/[z',envN]. But depth-0 existential transfer at arity r+1 does NOT follow from depth-0 agreement at arity r, because depth-0 is purely atomic and introducing a new existential variable requires finding a point with specific predicates and order relative to ALL env elements -- which is a structural property of the model.

**On Prior structures**, this IS provable because:
- Prior-UZ/SZ guarantees any realized 1-var type in any interval has a matching point
- The zone decomposition (w < t, t < w < x, x < w) ensures the existential variable can be placed in the correct order zone

**Resolution options**:
1. Add Prior-specific hypotheses to exist_transfer_upgrade's base case (UZ, SZ, char_fn, char_correct)
2. Prove the base case as a separate lemma specific to Prior structures
3. Handle K=0 in the outer theorem separately (K=0 means sub_nf at depth 1, which might have a simpler direct argument)

### Application at Sorry Sites

At the sorry sites (lines 563, 568, 619, 623), apply `exist_transfer_upgrade` with:
- k = K (from the outer strong induction variable, K = K_tilde)
- n = 1 (arity n+1 = 2 for the 2-var agreement)
- h_agree = ih_strong at m=K-1 (gives depth-(K+1) 2-var agreement at [x,t]/[x',t'])

This requires K >= 1 for ih_strong to be non-vacuous. For K = 0, a separate argument is needed.

## Sorry Inventory

| # | File | Line | Statement | Why Deferred | Next Dispatch |
|---|------|------|-----------|-------------|--------------|
| 1 | PriorComposition.lean | 563 | nf_eval_nf N (K+1) 3 [w2,x',t'] sub_nf (until fwd) | Base case of exist_transfer_upgrade FALSE for general structures; needs Prior-specific argument | Implement Prior-specific base case or K=0 branch |
| 2 | PriorComposition.lean | 568 | nf_eval_nf M (K+1) 3 [w2,x,t] sub_nf (until bwd) | Same root cause | Same |
| 3 | PriorComposition.lean | 619 | nf_eval_nf N (K+1) 3 [w2,x',t'] sub_nf (since fwd) | Same root cause | Same |
| 4 | PriorComposition.lean | 623 | nf_eval_nf M (K+1) 3 [w2,x,t] sub_nf (since bwd) | Same root cause | Same |

## Key Decisions
1. The exist_transfer_upgrade approach with Nat induction on k, arity n universally quantified, is the correct mechanism
2. The inductive step proof uses the IH at (n+1) with h_full (depth-k agreement at extended env) -- verified sorry-free in Lean
3. The base case (k=0) requires Prior-specific structural arguments
4. The approach differs from the original plan's `prior_zone3_exist_transfer` by being a general algebraic lemma (for k >= 1) rather than a Prior-specific lemma

## References
- `exist_transfer_from_full_agree` (PriorComposition.lean:221) -- gives d <= k from k+1 agreement
- `nf_agreement_from_shared_nf` (NormalForm.lean) -- extracts agreement from shared characteristic
- `atom_agreement_from_nf` (NormalForm.lean) -- atoms from depth-k agreement
- `nf_characteristic_satisfies` (NormalForm.lean) -- characteristic NF satisfies nf_eval_nf
- `nf_eval_unique` (NormalForm.lean) -- uniqueness of characteristic
