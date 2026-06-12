# Phase 5 Handoff: Composition Quantifier Step Analysis

**Date**: 2026-06-12
**Session**: sess_1781193902_83bc5c
**Phase**: 5d (Composition Lemma)
**Status**: IN PROGRESS

## What Was Done

### NfComposition.lean (committed 5e4ffcad0)

Created composition lemma file with:
1. `pred_agree_of_1var_nf_eq` -- sorry-free: same (k+1)-1-var NF implies same predicates
2. `classical_decide_eq_of_iff` -- sorry-free: helper for Bool funext
3. `nf_3var_from_1var_nfs` -- PARTIAL:
   - Depth 0 (base case): sorry-free (atoms only, all arities)
   - Depth k+1 atom part: sorry-free
   - Depth k+1 quantifier part: **SORRY** (the core difficulty)

### Filter Fix (committed 68c80dd5f)

Strengthened interval ssn filter. Verified forward proofs. Build passes.

## The Quantifier Step Goal

At the sorry in `nf_3var_from_1var_nfs`, the goal (after simplification) is:

```
⊢ (∃ z, nf_eval_nf M (k+1) 4 (Fin.cons z (Fin.cons y1 (Fin.cons x1 (fun _ => t1)))) sub4) ↔
  (∃ z, nf_eval_nf M (k+1) 4 (Fin.cons z (Fin.cons y2 (Fin.cons x2 (fun _ => t2)))) sub4)
```

With hypotheses:
- `h_y`: y1 and y2 have same depth-(k+2) 1-var NF
- `h_x`: x1 and x2 have same depth-(k+2) 1-var NF
- `h_t`: t1 and t2 have same depth-(k+2) 1-var NF
- `h_ord`: all pairwise orders match
- `ih`: the theorem statement itself at depth k (for arity-4 inner call)

## Why It's Hard

The → direction needs: given z witnessing sub4 at (z,y1,x1,t1), find z' witnessing sub4 at (z',y2,x2,t2).

**Key difficulty**: z' must simultaneously have:
1. Same depth-(k+2) 1-var NF as z (for predicates and quantifier structure)
2. Same order relative to y2,x2,t2 as z has relative to y1,x1,t1

Condition (1) is achievable: just pick z' = z (same model). But condition (2) fails because env and env' are different points.

Condition (2) requires finding z' in the right "order region". z falls in one of 8 order regions relative to y1,x1,t1 (assuming they're all distinct and in some order). The same region exists relative to y2,x2,t2 (by h_ord). But we need a z' in that region with the right 1-var NF.

## The Transfer Argument

From h_y (depth-(k+2) 1-var NFs agree): nf_y1.2 = nf_y2.2 at the depth-(k+1) 2-var level. This means:
- (∃ z, nf_eval_nf M (k+1) 2 (z,y1) sub2) ↔ (∃ z, nf_eval_nf M (k+1) 2 (z,y2) sub2)

The depth-(k+1) 2-var NF at (z,y1) encodes:
- Predicates at z and y1
- Order between z and y1
- Which depth-k 3-var NFs are realized at (w,z,y1) for various w

So from z with a specific 2-var NF at (z,y1), we get z' with the SAME 2-var NF at (z',y2). In particular, z' has:
- Same predicates as z (from the 2-var NF)
- Same order relative to y2 as z has to y1 (from the 2-var NF's order atom)

Similarly from h_x: z'' with same 2-var NF at (z'',x2) as z at (z,x1).
From h_t: z''' with same 2-var NF at (z''',t2) as z at (z,t1).

BUT: z', z'', z''' are DIFFERENT points. We need a SINGLE z' that works for all three.

## Proposed Resolution

### Option A: Generalize the theorem to use 2-var NF hypotheses

Instead of requiring matching (k+1)-level 1-var NFs, require matching depth-k 2-var NFs at all pairs:

```lean
theorem nf_composition_from_2var (k n : Nat) ...
    (h_2var : ∀ i j : Fin n,
      nf_characteristic M k 2 (pair_env (env i) (env j)) =
      nf_characteristic M k 2 (pair_env (env' i) (env' j)))
    : nf_characteristic M k n env = nf_characteristic M k n env'
```

The quantifier step then adds z to both envs. For pairs involving z: z is the SAME in both contexts. For pair (z, env i) vs (z, env' i): we need these to have the same depth-k 2-var NF. But z is the same, and env i/env' i have the same depth-k 2-var NF with z iff they have the same depth-(k+1) 1-var NF... no, that's circular.

Actually: for this option, the hypothesis is about depth-k 2-var NFs (same depth as the theorem). The extended pair (z, env i) and (z, env' i) need the same depth-k 2-var NF. z is the same in both, but env i ≠ env' i. The depth-k 2-var NF at (z, env i) depends on z AND env i.

This doesn't immediately help either.

### Option B: Use the model structure directly

On a linear order, z's position relative to y1,x1,t1 determines a "quantifier type". Two z values in the same order region with the same predicates have the same depth-0 n-var NF with any set of fixed points. At higher depths, the quantifier type also includes information about the neighborhoods of z.

The argument works by showing: if z is in region R relative to (y1,x1,t1), and R exists relative to (y2,x2,t2) (by h_ord), and z has a certain "complete type" that's realizable in R (by the 1-var NF agreement), then z' exists in R with the same complete type.

This is essentially the full Doets Lemma 1.4 proof.

### Option C: Reformulate for the backward proof

The backward proof doesn't actually need the full composition theorem between two different environments. It needs to show that ssn (from sub_nf.2) is the ACTUAL characteristic NF at (y,x,t). This could potentially be done by induction on k within the backward proof itself, without the general composition theorem.

## Recommendation

**Option C** is most promising for the backward proof: prove h_quant by induction on k within the backward proof, using the formula's information. At depth 0, atoms suffice. At depth k >= 1, the quantifier part can use p2_k and the formula's char_kp1 encoding to characterize the 3-var NF.

The general composition theorem (Options A/B) is a major independent result (400+ lines) that may not be needed if the backward proof can be structured to avoid it.

## Files

- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfComposition.lean` (new, 1 sorry)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NegationClosure.lean` (1 sorry at :1371)
