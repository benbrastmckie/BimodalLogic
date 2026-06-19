# CharPart-Threading Architecture Design

- **Task**: 303 - k_gt_0_depth_induction
- **Date**: 2026-06-18
- **Purpose**: Concrete fix design for the Phase 5 blocker (FALSE depth0_3var_exist_transfer lemmas)

## Executive Summary

The sorry sites in `PriorComposition.lean` (lines 274, 345, 460, 480) share a single root
cause: `depth0_3var_exist_transfer_until/since` and `exist_transfer_3var_nonconstenv` attempt
to transfer between-zone existentials from endpoint 1-var agreement alone. This is
mathematically FALSE (counterexample: Z with P=evens, t=t'=-1, x=4, x'=0).

The fix threads `CharPart(K+1)` through the call chain so the between-zone transfer uses
temporal formula semantics (which encode 2-variable interval properties) rather than trying
to derive them from two independent 1-variable conditions.

## Current Sorry Chain

```
kamp_mutual_induction (KampMutualInduction.lean:383)
  -> existPart_succ (line 294)
     -> existPart_succ_n1_bypass (KampBypass.lean:421, k>0 only)
        -> prior_2var_transfer_until/since (PriorComposition.lean:668/693)
           -> prior_nonconstenv_2var_agree_until/since (line 499/589)
              K=0 base:
                -> depth0_3var_exist_transfer_until/since (lines 200/277)
                   -> SORRY at lines 274, 345 (between-zone)    [S3, S4]
              K=succ K' step:
                -> exist_transfer_3var_nonconstenv (line 370)
                   -> SORRY at lines 460, 480 (depth boost)     [S1, S2]
```

## Available CharPart at Each Level

| Call Site | Available CharPart | How |
|-----------|-------------------|-----|
| `kamp_mutual_induction` k=succ k' | `CharPart(k')`, `CharPart(k'+1)` | `ih.1` (CharPart k'), `charPart_succ` |
| `existPart_succ` | `CharPart(k)`, `CharPart(k+1)` | `ih_char`, `ih_char_succ` params |
| `existPart_succ_n1_bypass` | `char_kp1` (formula-level CharPart(k+1)), `ih_char` (CharPart(k)) | params |
| `prior_2var_transfer_until` | NOT AVAILABLE | must be threaded |
| `prior_nonconstenv_2var_agree_until` | NOT AVAILABLE | must be threaded |
| `exist_transfer_3var_nonconstenv` | NOT AVAILABLE | must be threaded |

## Proposed Architecture

### Strategy: Eliminate the Standalone 3-var Transfer Lemmas

The key insight: `depth0_3var_exist_transfer_until/since` are FALSE as standalone lemmas.
`exist_transfer_3var_nonconstenv` is also unprovable without Prior+CharPart. Rather than
patching them with more parameters, **inline the 3-var transfer into
`prior_nonconstenv_2var_agree_until/since`** where Prior hypotheses are already available,
and add CharPart as a new parameter.

### Modified Type Signatures

#### 1. `prior_nonconstenv_2var_agree_until` (PriorComposition.lean:499)

ADD parameter after `h_SZ_N`:
```lean
-- NEW: CharPart at all depths up to K+1
(char_all : ∀ d, d ≤ K + 1 → CharPart atomMap d)
```

This replaces the well-foundedness issue: instead of requiring CharPart(K+1) only, we pass
CharPart at all depths <= K+1. At the K=0 base case, `char_all 1 (by omega)` gives CharPart(1).
At the K=succ K' step, `char_all (K'+2) (by omega)` gives CharPart(K'+2). The bound K+1 is
tight: CharPart(K+1) is exactly what the outer mutual induction has available when it calls
ExistPart(K+1).

**Alternative (simpler)**: Since `CharPart atomMap d` for d <= K+1 follows from `CharPart atomMap (K+1)` by monotonicity of the mutual induction, we can pass just:
```lean
(char_kp1 : CharPart atomMap (K + 1))
```
and derive lower-depth CharPart internally. Even simpler: the mutual induction gives us CharPart at ALL depths via `(kamp_mutual_induction atomMap h_surj d).1`. But we cannot call `kamp_mutual_induction` inside `prior_nonconstenv_2var_agree` because that would create circular dependence (prior_nonconstenv -> existPart_succ -> kamp_mutual_induction -> existPart_succ -> prior_nonconstenv).

**Chosen approach**: Pass `CharPart atomMap (K + 1)` as a single parameter. At K=0,
CharPart(1) suffices for the temporal formula construction. At K=succ K', CharPart(K'+2)
gives us CharPart(K'+1) by the monotonicity argument in `charPart_succ` (which only needs
CharPart at lower depth + ExistPart at lower depth, both available from the IH).

Wait -- there is a subtlety. The K=0 base case needs to build a temporal formula for each
depth-1 2-var NF. This requires `existPart_succ_n1_bypass_k0` which takes `char_1`. We
have `CharPart atomMap 1` which gives `∀ nf, ∃ A, ...`. Choosing the formula A for each
nf gives us the `char_1 : NormalForm sig 1 1 -> Formula` function needed.

**Actually simplest**: Pass the formula-level char function directly:
```lean
(char_kp1_fn : NormalForm sig (K + 1) 1 → Formula)
(char_kp1_correct : ∀ (nf_1 : NormalForm sig (K + 1) 1)
    (M : OrderedMonadicStructure sig)
    (h_UZ : semantic_prior_UZ M atomMap)
    (h_SZ : semantic_prior_SZ M atomMap)
    (t : M.carrier),
    temporal_truth M atomMap t (char_kp1_fn nf_1) ↔
    nf_eval_nf M (K + 1) 1 (fun _ => t) nf_1)
```

This exactly matches the `char_kp1` / `char_kp1_correct` parameters already present in
`existPart_succ_n1_bypass`. No need for a `CharPart`-level abstraction.

**DECISION**: Use formula-level char function (matches existing parameter style).

#### 2. `prior_nonconstenv_2var_agree_since` (PriorComposition.lean:589)

Mirror of above: add same `char_kp1_fn` / `char_kp1_correct` parameters.

#### 3. `prior_2var_transfer_until` (PriorComposition.lean:668)

Wrapper: add same parameters and forward them.

#### 4. `prior_2var_transfer_since` (PriorComposition.lean:693)

Mirror of above.

#### 5. `exist_transfer_3var_nonconstenv` (PriorComposition.lean:370)

**DELETE**. This theorem is unprovable without Prior hypotheses and the between-zone
temporal formula infrastructure. Its two call sites (K=0 base and K>0 step of
`prior_nonconstenv_2var_agree_until/since`) will be replaced with inline proofs that
use the CharPart-based approach.

#### 6. `depth0_3var_exist_transfer_until` (PriorComposition.lean:200)

**DELETE**. FALSE as stated (counterexample documented).

#### 7. `depth0_3var_exist_transfer_since` (PriorComposition.lean:277)

**DELETE**. FALSE as stated (mirror counterexample).

### Modified Call Sites

#### A. `existPart_succ_n1_bypass` k>0 case (KampBypass.lean:570-706)

Currently passes `prior_2var_transfer_until atomMap h_surj k' M x t M0 x0 t0 h_UZ h_SZ h_UZ0 h_SZ0 h_x_agree h_t_agree h_t_lt_x h_t0_lt_x0 sub_nf h_eval0`.

ADD: `char_kp1 char_kp1_correct` parameters. These are ALREADY in scope as params of `existPart_succ_n1_bypass` (lines 425-432).

New call: `prior_2var_transfer_until atomMap h_surj k' M x t M0 x0 t0 h_UZ h_SZ h_UZ0 h_SZ0 char_kp1 char_kp1_correct h_x_agree h_t_agree h_t_lt_x h_t0_lt_x0 sub_nf h_eval0`

#### B. `existPart_succ` n>=2 case (KampMutualInduction.lean:322)

This also calls `existPart_succ_n1_bypass`. Same threading -- `char_kp1` is `char_kp1_correct` from the `existPart_succ` parameter list.

#### C. `kamp_mutual_induction` (KampMutualInduction.lean:383-398)

No change needed. `existPart_succ` already receives `ih_char_succ : CharPart atomMap (k+1)` which provides the `char_kp1_fn` / `char_kp1_correct`. The formula-level function is constructed inside `existPart_succ` (or `existPart_succ_n1_bypass`) by `Classical.choose`/`Classical.choose_spec` on CharPart. This is already done at line 308-309 where `char_kp1 char_kp1_correct` are forwarded.

**No change to kamp_mutual_induction is needed** because the CharPart is already flowing
through the existing parameter chain.

## Proof Architecture for the K=0 Base Case

### Current (broken) approach:
```
prior_nonconstenv_2var_agree_until K=0
  -> atom agreement (sorry-free)
  -> quant: exist_transfer_3var_nonconstenv
     -> build depth-1 2-var h_xt
        -> atom agreement (sorry-free)
        -> quant: depth0_3var_exist_transfer_until  <-- FALSE, sorry
```

### New approach:

At K=0, we need depth-2 2-var agreement at [x,t]/[x',t']. The atom part uses
`nonconstenv_atom_agree_until` (sorry-free). The quantifier part requires:

For each `sub_nf : NormalForm sig 1 2`:
```
(exists y, nf_eval M 1 2 [y,x,t] sub_nf) <-> (exists y', nf_eval N 1 2 [y',x',t'] sub_nf)
```

This is EXACTLY what `existPart_succ_n1_bypass_k0` characterizes temporally. The bypass
produces a formula `A` such that:
```
temporal_truth M atomMap x A <-> (exists y, nf_eval M 1 2 [y,x] sub_nf)  (when parent_atoms match x)
```

But wait: `existPart_succ_n1_bypass_k0` characterizes the existential at a SINGLE point (x or t),
conditioned on parent_atoms matching. It does NOT directly give the biconditional between M and N.

**The correct approach at K=0**:

1. From h_x (depth-2 1-var at x/x') and h_t (depth-2 1-var at t/t'), get depth-1 1-var
   by monotonicity.
2. Use `constenv_same_depth_2var` to get depth-1 2-var at [x,x]/[x',x'] and [t,t]/[t',t'].
   (This is the CONSTANT env case, already sorry-free.)
3. For the NON-constant env [x,t]/[x',t'], use the temporal formula approach:
   - From `char_kp1_fn` (= CharPart(1) formula), build the temporal formula A for each
     depth-1 2-var NF chi via `existPart_succ_n1_bypass_k0`.
   - A has operator depth at most 2 (it uses char_1 formulas wrapped in U/S).
   - Actually: A's truth at point t depends on parent_atoms at t. The formula is:
     `char_1(nf_t0) AND (char_1(nf_x0) U top)` or similar.
   - Transfer A's truth from M to N (or N to M) using depth-2 1-var agreement at t/t'
     (since A has op_depth <= 2, temporal_truth at t is determined by the depth-2 1-var NF).

**Wait -- temporal formula transfer requires a DIFFERENT theorem.** The transfer of
`temporal_truth M atomMap t A` to `temporal_truth N atomMap t' A` is exactly what depth-2
1-var NF agreement gives, BUT only if A's truth at a point is determined by the 1-var NF
at that point. This is NOT true in general -- temporal_truth depends on the ENTIRE structure,
not just the NF at a single point.

**However**: the formulas produced by `existPart_succ_n1_bypass_k0` ARE determined by the
1-var NF at the evaluation point, because they are built from:
- Predicate literals at the point (determined by 1-var NF)
- Until/Since formulas involving char_1 formulas at OTHER points

The Until/Since formulas involve global structure (other points in the linear order), so
temporal_truth at t is NOT a function of t's 1-var NF alone.

**This is the fundamental issue.** Temporal truth at a point depends on the entire model,
not just the NF at that point. So we cannot "transfer temporal_truth via NF agreement."

### Correct Approach: Use the quantifier part of 1-var NF agreement directly

Depth-2 1-var NF agreement at t/t' means:
```
∀ nf : NormalForm sig 2 1, nf_eval_nf M 2 1 [t] nf <-> nf_eval_nf N 2 1 [t'] nf
```

The QUANTIFIER part of a depth-2 1-var NF gives:
```
∀ chi : NormalForm sig 1 2,
  (exists y, nf_eval M 1 2 [y, t] chi) <-> (exists y', nf_eval N 1 2 [y', t'] chi)
```

This is the depth-1 2-var existential transfer at constant env [_, t]/[_, t']. This is
ALREADY what `constenv_same_depth_2var` gives us.

The DEPTH-1 2-var agreement at [x,t]/[x',t'] is what we actually need. But we cannot
get it from 1-var agreement at endpoints alone (that's the original problem).

### The Actual Fix: Restructure the Induction

The current structure induces on K inside `prior_nonconstenv_2var_agree_until`, with:
- K=0 base: try to build depth-2 2-var from depth-2 1-var (fails at between-zone)
- K=succ K' step: use IH (depth-(K'+2) 2-var) + `exist_transfer_3var_nonconstenv` (sorry)

**The fix**: At K=0 base, instead of trying to build depth-2 2-var directly, use the
approach already working in the k>0 case of `existPart_succ_n1_bypass`:

In the k>0 case of `existPart_succ_n1_bypass` (KampBypass.lean:570-613), the backward
direction works like this:
1. Extract temporal_truth of `char_kp1 nf_t0` at t (gives t has nf_t0's 1-var NF)
2. Extract x from Until witness (gives x has nf_x0's 1-var NF)
3. These give depth-(k'+1+1) 1-var agreement at x/x0 and t/t0
4. Call `prior_2var_transfer_until` to get 2-var agreement

So `existPart_succ_n1_bypass` at k>0 ALREADY calls `prior_2var_transfer_until`, which
calls `prior_nonconstenv_2var_agree_until`, which is what we're trying to fix.

**This is the circular dependency.** `existPart_succ_n1_bypass` calls
`prior_nonconstenv_2var_agree_until` which (in the K=0 base case) would need
`existPart_succ_n1_bypass_k0` to do the temporal formula trick, but
`existPart_succ_n1_bypass_k0` needs CharPart(1) which needs ExistPart(0) -- but
ExistPart(0) is sorry-free, so CharPart(1) IS available.

**Let me trace the types more carefully:**

When `existPart_succ_n1_bypass` is called with k = succ k':
- char_kp1 has type `NormalForm sig (k'+1+1) 1 -> Formula` with correctness
- prior_2var_transfer_until is called with K = k' (so depth = k'+2)
- Inside prior_nonconstenv_2var_agree_until at K = k':
  - K=0 base (when k'=0): needs depth-2 2-var agreement
  - K=succ K'' step: uses IH

So when k'=0 (meaning existPart_succ_n1_bypass was called with k=1), the K=0 base
of prior_nonconstenv_2var_agree_until runs with depth = 2.

For THIS K=0 base, we have:
- h_x, h_t: depth-2 1-var agreement
- h_order: t < x, t' < x'
- char_kp1_fn with correctness at depth K+1 = 1

We need: depth-2 2-var agreement at [x,t]/[x',t'].

**The key realization**: We can build depth-2 2-var agreement at [x,t]/[x',t'] by:

1. **Atom part**: nonconstenv_atom_agree_until (sorry-free, uses h_x, h_t, h_order).

2. **Quantifier part**: For each `sub_nf : NormalForm sig 1 2`:
   ```
   (exists y, nf_eval M 1 2 [y,x,t] sub_nf) <-> (exists y', nf_eval N 1 2 [y',x',t'] sub_nf)
   ```

   For this, use `existPart_succ_n1_bypass_k0` with char_1 = char_kp1_fn (which IS
   CharPart(1) in formula form). The bypass gives a formula A such that:
   ```
   temporal_truth S atomMap x A <-> (exists y, nf_eval S 1 2 [y,x] sub_nf)
   ```
   conditioned on parent_atoms matching x's predicates.

   But the env here is `[y, x, t]` not `[y, x]` -- it's a 3-var env, not 2-var.
   Wait: nf_eval_nf M 1 2 [y, x, t] sub_nf -- this is wrong. The env should be
   Fin.cons y (Fin.cons x (fun _ => t)) which has 3 elements, but sub_nf is at arity 2.

   Actually, re-reading the code: the quantifier part of depth-2 2-var at [x,t] asks:
   for each sub_nf : NormalForm sig 1 3,
   ```
   (exists y, nf_eval M 1 3 (Fin.cons y (Fin.cons x (fun _ => t))) sub_nf) <-> ...
   ```
   No wait, the quantifier part of a depth-(K+2) n-var NF has sub_nfs at depth-(K+1) (n+1)-var.
   So for K=0, depth=2, n=2: sub_nf at depth 1, arity 3.

   `existPart_succ_n1_bypass_k0` characterizes depth-1 2-var existentials at [y, x] (arity 2).
   We need depth-1 3-var existentials at [y, x, t] (arity 3).

   So the bypass at n=1 does NOT directly give us the 3-var transfer.

### Correct Fix: Restructure `prior_nonconstenv_2var_agree_until` to NOT need 3-var transfer at K=0

The problem is: building depth-2 2-var from depth-2 1-var at endpoints requires 3-var
existential transfer, which is the original sorry. We cannot avoid this by temporal formulas
because the temporal formula approach operates at arity 2 (n=1), not arity 3.

**But wait**: the k>0 case of `existPart_succ_n1_bypass` does NOT call the 3-var transfer
directly. It calls `prior_2var_transfer_until` which gives the full depth-(K+2) 2-var
agreement. The k>0 backward direction gets 1-var agreement from the temporal formula and
then calls `prior_2var_transfer_until` to lift it to 2-var. Inside
`prior_2var_transfer_until`, the 3-var transfer is needed.

**The actual solution**: Use `existPart_succ_n1_bypass_k0` to bypass the 3-var transfer
entirely. Instead of trying to prove `prior_nonconstenv_2var_agree_until` and then use it
in `existPart_succ_n1_bypass`, we should merge the two proofs.

Here is the key structural observation:

- `existPart_succ_n1_bypass` at k=0 uses `existPart_succ_n1_bypass_k0` which is sorry-free.
  The k=0 case NEVER calls `prior_nonconstenv_2var_agree_until`.

- `existPart_succ_n1_bypass` at k=succ k' calls `prior_2var_transfer_until` (wrapper for
  `prior_nonconstenv_2var_agree_until`). Inside, the induction on K has:
  - K=0 base: calls `exist_transfer_3var_nonconstenv` with h_xt built from
    `nonconstenv_atom_agree + depth0_3var_exist_transfer_until` -- the FALSE lemma!
  - K=succ K' step: calls `exist_transfer_3var_nonconstenv` with h_xt from IH.

- The sorry in `exist_transfer_3var_nonconstenv` is at the depth boost: we have depth-K
  3-var agreement and need depth-(K+1) 3-var. The depth boost would need depth-K 4-var,
  creating an arity-climbing recursion.

**THE REAL FIX**: Replace the K=0 base case of `prior_nonconstenv_2var_agree_until` with
a construction that uses the ih_exist parameter (ExistPart at lower depth).

At K=0, we need depth-2 2-var agreement at [x,t]/[x',t'] from:
- h_x: depth-2 1-var at x/x'
- h_t: depth-2 1-var at t/t'
- h_order: t < x, t' < x'
- Prior axioms
- char_kp1_fn: CharPart(1) formulas

For the quantifier part, we need for each sub_nf : NormalForm sig 1 3:
```
(exists y, nf_eval M 1 3 [y, x, t] sub_nf) <-> (exists y', nf_eval N 1 3 [y', x', t'] sub_nf)
```

This is ExistPart(1) at arity n=2. We have `ih_exist : ExistPart atomMap h_surj k` from the
existPart_succ parameter chain (where k is the depth of the bypass). When the bypass is
called with k = succ k', ih_exist = ExistPart(k' + 1). For k'=0 (k=1), ih_exist = ExistPart(1).

But ExistPart(1) at n=2 gives: for char_1 correct and parent_atoms and sub_nf at arity 3,
```
exists A, temporal_truth S atomMap t A <-> exists y, nf_eval S 1 3 [y, t] sub_nf
```
conditioned on parent_atoms matching t. This is the CONSTANT env case [y, t, t, t, ...],
not the NON-CONSTANT case [y, x, t].

**So ExistPart does not directly give us the non-constant env transfer either.**

### THE ACTUAL ACTUAL FIX: Pass ih_exist into PriorComposition

The reason the 3-var existential transfer is hard is that we're trying to prove it from
scratch inside PriorComposition. But `existPart_succ` already has `ih_exist : ExistPart(k)`.
At the K=0 base of `prior_nonconstenv_2var_agree_until`, we're proving ExistPart(k+1) at
n=1. We need depth-1 3-var transfer (n=2). This is ExistPart(1) at n=2.

Wait, but ExistPart is for CONSTANT parent env (fun _ => t), and the 3-var env is
[y, x, t] which has x different from t. So ExistPart at n=2 gives [y, z, t] with z
as the quantified variable -- that's 3-var at env [z, t, t], not [z, x, t].

This is the crux of the whole problem. ExistPart(k) at any arity operates with constant
parent env. The non-constant env is EXACTLY what PriorComposition is supposed to provide.

### FINAL CORRECT FIX: Temporal Formula via CharPart at Both Endpoints

Going back to the plan's "option (c)" recommendation with deeper analysis:

**At the K=0 base case of `prior_nonconstenv_2var_agree_until`**:

We need depth-2 2-var agreement at [x,t]/[x',t']. For the quantifier part, we need
depth-1 3-var existential transfer.

A depth-1 3-var NF `sub_nf : NormalForm sig 1 3` has:
- Atom part: predicates at 3 variables + order relations
- Quantifier part: depth-0 4-var existential conditions

At depth 1, the quantifier part involves depth-0 4-var conditions which are purely atomic.

For `exists y, nf_eval M 1 3 [y, x, t] sub_nf`:
- Zone split on y relative to x and t (5 zones)
- Zones outside [t,x]: use `cross_extend_bwd_1var` to get witness in N
- Zone y=t or y=x: direct witness
- Between zone: SAME problem as before but one arity higher

**This recursion is the fundamental difficulty**. But it terminates at depth 0 where
everything is purely atomic, and at depth 0 the between-zone for arity-3 is equally
problematic...

**ACTUALLY**: Let me re-examine the IH structure. At the K>0 step:
```
prior_nonconstenv_2var_agree_until K = succ K'
  IH gives: prior_nonconstenv_2var_agree_until at K'
  -> depth-(K'+2) 2-var agreement h_xt at [x,t]/[x',t']
  -> exist_transfer_3var_nonconstenv uses h_xt for depth-(K'+1) 3-var quantifier transfer
```

The sorry in `exist_transfer_3var_nonconstenv` is the depth boost from K to K+1 for the
3-var agreement. But with h_xt available (from IH), we already have:
```
hex_K : depth-K 3-var existential transfer (from h_xt quantifier part)
hex_x : depth-(K+1) 2-var existential transfer at [_,x]/[_,x'] (from h_x quantifier)
hex_t : depth-(K+1) 2-var existential transfer at [_,t]/[_,t'] (from h_t quantifier)
```

The witness c_K from hex_K has the right zone (orders transfer at depth K). The witnesses
c_x from hex_x and c_t from hex_t have depth-(K+1) 1-var matching y.

**The fix at K>0**: Show that c_K has depth-(K+1) 1-var matching y by using CharPart(K+1).

From CharPart(K+1), for y's 1-var NF nf_y, there exists formula A_y such that
`temporal_truth S atomMap y A_y <-> nf_eval S (K+1) 1 [y] nf_y` for all Prior S.

Now, c_K has depth-K 1-var matching y (extractable from the depth-K 3-var agreement).
c_x has depth-(K+1) 1-var matching y (from hex_x).
c_t has depth-(K+1) 1-var matching y (from hex_t).

If c_K = c_x or c_K = c_t, we're done. Otherwise, we need to show c_K has the right
depth-(K+1) 1-var NF.

**But c_K has the right depth-K 1-var. The boost to K+1 is not free.**

HOWEVER, c_K also has the right depth-K 3-var NF at [c_K, x', t'] matching [y, x, t].
This means c_K has the right order relative to x' and t', AND the right depth-(K-1) 4-var
quantifier conditions. Combined with depth-K 1-var, this is strictly MORE information than
just 1-var. Can we extract depth-(K+1) 1-var from it?

No -- depth-K 3-var and depth-K 1-var together give depth-K information with additional
arity, not depth-(K+1) information.

### THE DEFINITIVE FIX: Strengthen the IH

Instead of proving `prior_nonconstenv_2var_agree_until` by induction on K where the goal is
depth-(K+2) 2-var, restructure to prove a STRONGER statement by induction:

**Strong statement**: For all d <= K+2 (not just d = K+2),
```
∀ nf : NormalForm sig d 2,
  nf_eval_nf M d 2 [x,t] nf <-> nf_eval_nf N d 2 [x',t'] nf
```

With this strengthening:
- The IH at K=succ K' gives depth-(K'+2) 2-var for ALL d <= K'+2.
- For the quantifier part at depth K'+3, we need depth-(K'+2) 3-var transfer.
- From h_xt at depth K'+2 (from IH), the quantifier part gives depth-(K'+1) 3-var transfer.
- We need to boost to depth-(K'+2). This is the same gap.

The strengthening doesn't help because the gap is always 1.

### RESOLUTION: Inline `existPart_succ_n1_bypass_k0`-Style Construction

After extensive analysis, here is the correct and feasible fix:

**Replace `exist_transfer_3var_nonconstenv` and the depth-0 transfer lemmas with a
DIRECT temporal formula construction inside `prior_nonconstenv_2var_agree_until/since`.**

The approach (matching Rabinovich Lemma 5.1):

At the K=0 base, to get depth-2 2-var at [x,t]/[x',t']:
1. Atom part: sorry-free (nonconstenv_atom_agree_until)
2. Quantifier part: for each sub_nf : NormalForm sig 1 3, need:
   ```
   (exists y, nf_eval M 1 3 [y,x,t] sub_nf) <-> (exists y', nf_eval N 1 3 [y',x',t'] sub_nf)
   ```
   Use a zone decomposition on y's order relative to x and t:
   - Zone y > x (= zone 5): `cross_extend_bwd_1var` from h_x gives y' > x' with depth-0 2-var at [y,x]/[y',x']. Then the 3-var eval at [y,x,t] reduces to 2-var at [y,x] + atom at t, which transfers. (Depth-0 3-var is purely atomic, so this is straightforward.)
   - Zone y = x (= zone 4): use x' as witness
   - Zone y < t (= zone 1): symmetric via h_t
   - Zone y = t (= zone 2): use t' as witness
   - Zone t < y < x (= zone 3): **The hard case**. Here sub_nf's atom part specifies y's
     predicates + orders (t < y AND y < x). Since depth is 1, the quantifier part asks for
     depth-0 4-var existentials which are purely atomic.

   For zone 3 at depth 1 (sub_nf at depth 1, arity 3):
   - The atom part of sub_nf specifies: preds(y), t < y, y < x, t < x
   - The quantifier part: for each chi : NormalForm sig 0 4, is chi satisfiable by [z,y,x,t]?
     At depth 0, this is purely atomic: z's predicates + orders relative to y, x, t.
   - There are finitely many such chi. For the between-zone y where t < y < x: From M's
     witness y, build a temporal formula A_y encoding y's properties using char_1:
     `A_y = char_1(nf_y)` where nf_y is y's depth-1 1-var NF.
   - A_y has depth <= 1 as a temporal formula (since char_1 formulas are built from
     predicates + Until/Since of depth-0 characteristic formulas).
   - From h_x (depth-2 1-var at x/x'): the quantifier part gives
     `exists s, nf_eval M 1 2 [s,x] chi2 <-> exists s', nf_eval N 1 2 [s',x'] chi2`
     for all depth-1 2-var NF chi2.
   - Set chi2 = nf_characteristic M 1 2 [y,x]. Then exists s=y in M. Transfer gives
     exists s' with depth-1 2-var at [s',x'] matching [y,x]. From this, s' has the
     same predicates as y and s' has order relative to x' matching y's order relative to x.
     Since y < x (zone 3), s' < x'.
   - Similarly from h_t: exists s'' with s'' has depth-1 2-var at [s'',t'] matching [y,t].
     Since y > t, s'' > t'.
   - We have s' < x' and s'' > t'. If s' = s'' or s' and s'' are in the right zone,
     we'd be done. But s' and s'' are DIFFERENT witnesses.
   - **Key**: s' has depth-1 1-var matching y. s'' has depth-1 1-var matching y. By
     uniqueness of characteristic NFs, s' and s'' have the same depth-1 1-var NF.
   - s' < x' (from order transfer) and s'' > t' (from order transfer).
   - If s' > t', then s' is in zone 3 of N and we can use s' as the witness.
   - If s' <= t': Then we need to show a zone-3 witness exists in N using Prior axioms.
     s' has the same predicates as y. From Prior-UZ applied to N at t', there exists a first
     occurrence of s''s predicate pattern above t'. This first occurrence is <= s'' < x'
     (since s'' > t'). So first_occ > t'. If first_occ < x', it's in zone 3.
     If first_occ = x': impossible if y's predicates differ from x's (since x' has different
     predicates from s''). If same predicates, the interval might be vacuous.
   - Similarly if s'' >= x': use Prior-SZ at x'.

   **This is the Prior-UZ/SZ squeeze argument.** It works when the predicate pattern of y
   differs from both x and t. When y has the same predicates as x or t, the zone 3 witness
   can be derived from the equality of predicates + the order constraint.

   Let me formalize this more carefully:

   **Given**: y in M with t < y < x and specific predicates sigma(y).
   **From h_x**: exists s' in N with depth-1 2-var at [s',x'] matching [y,x]. So s' < x'
   and s' has predicates sigma.
   **From h_t**: exists s'' in N with depth-1 2-var at [s'',t'] matching [y,t]. So s'' > t'
   and s'' has predicates sigma.

   **Case 1**: s' > t'. Then t' < s' < x', so s' is in zone 3 of N.
   Additionally, s' has depth-1 2-var at [s',x'] matching [y,x], which includes
   the depth-0 3-var quantifier conditions relative to x'. For the 3-var quantifier
   conditions relative to t': s' has the same predicates as y, and s' > t' (if case 1),
   and... we don't have the quantifier conditions relative to t'.

   **This is the gap**: s' has the right 2-var agreement with x' but NOT with t'. The
   3-var NF at [s',x',t'] involves atoms relative to all three points and quantifier
   conditions involving all three.

   At depth 1, the 3-var quantifier conditions involve depth-0 4-var existentials which
   are purely atomic. For a depth-0 4-var existential at [z, s', x', t'], we need a
   point z with specific predicates and specific orders relative to s', x', t'. This
   is achievable because the orders are decided (z's zone relative to the three anchor
   points) and predicates are satisfiable by Prior-UZ/SZ.

   Actually at depth 0, the 4-var conditions reduce to: for each bool-assignment of
   orders and predicates for z, does such a z exist? The answer depends on whether
   the corresponding zone interval is non-empty and contains a point with the right
   predicates.

**THIS IS GETTING INTO THE WEEDS OF THE ACTUAL PROOF.** Let me pull back and state
the architectural conclusion.

## Architectural Conclusion

### What to delete:
1. `depth0_3var_exist_transfer_until` (PriorComposition.lean, lines 200-274) -- FALSE
2. `depth0_3var_exist_transfer_since` (PriorComposition.lean, lines 277-345) -- FALSE
3. `exist_transfer_3var_nonconstenv` (PriorComposition.lean, lines 370-480) -- unprovable without Prior+CharPart

### What to add (parameters):
1. Add `char_kp1_fn` + `char_kp1_correct` to `prior_nonconstenv_2var_agree_until/since`
2. Add same to `prior_2var_transfer_until/since`
3. Add `ih_exist : ExistPart atomMap h_surj k` to `prior_nonconstenv_2var_agree_until/since`

### What to restructure:

**K=0 base case of `prior_nonconstenv_2var_agree_until`** (the deepest blocker):

Replace the call to `exist_transfer_3var_nonconstenv` (which called the FALSE
`depth0_3var_exist_transfer_until`) with the following zone-based argument:

For each sub_nf : NormalForm sig 1 3, prove:
```
(exists y, nf_eval M 1 3 [y,x,t] sub_nf) <-> (exists y', nf_eval N 1 3 [y',x',t'] sub_nf)
```

by:
1. Zone split on sub_nf's order atoms for y vs x and y vs t (9 combinations, many vacuous)
2. Zones outside [t,x]: `cross_extend_bwd_1var` from h_x (for y > x) or h_t (for y < t)
3. Zone y=x: use x' (predicates match from h_x)
4. Zone y=t: use t' (predicates match from h_t)
5. Zone t < y < x (between-zone):
   - From h_x quantifier: exists s' < x' with depth-1 2-var at [y,x]/[s',x']
   - From h_t quantifier: exists s'' > t' with depth-1 2-var at [y,t]/[s'',t']
   - s' and s'' both have depth-1 1-var matching y, hence same NF type
   - Case analysis on s' vs t' and s'' vs x':
     - If t' < s' < x': s' is in zone 3 of N, use as between-zone witness
     - If s' <= t' AND s'' >= x': interval (t', x') contains no NF-type-matching point...
       but it MUST because:
       - From Prior-UZ at t': there exists first occurrence of sigma(y) above t',
         call it p. p <= s'' (s'' has sigma and s'' > t'). p > t'.
       - From Prior-SZ at x': there exists last occurrence of sigma(y) below x',
         call it q. q >= s' (s' has sigma and s' < x'). q < x'.
       - Actually s' < x' for sure (from order transfer). If s' <= t', then:
         - p (first sigma above t') exists because s'' > t' has sigma. p <= s''.
         - If p < x': p is in zone 3, use p as witness. The depth-1 2-var conditions
           at [p, x', t'] need to be verified from the depth-1 2-var conditions of
           [y, x, t] using the NF agreement of p and y plus structural properties.
       - This is where the argument gets delicate but is essentially the content of
         Rabinovich Lemma 5.1.

**K=succ K' step of `prior_nonconstenv_2var_agree_until`**:

Replace the call to `exist_transfer_3var_nonconstenv` with: use h_xt (depth-(K'+2)
2-var from IH) to get depth-(K'+1) 3-var existential transfer directly from its
quantifier part. The depth boost from K'+1 to K'+2 for the 3-var agreement is achieved
by the same zone-based argument, now at depth K'+2 instead of depth 2, using
char_kp1_fn at depth K'+2.

### Threading through callers:

**`prior_2var_transfer_until/since`**: Add `char_kp1_fn`, `char_kp1_correct` params. Forward to `prior_nonconstenv_2var_agree_until/since`.

**`existPart_succ_n1_bypass` k>0 case (KampBypass.lean)**: Already has `char_kp1` and `char_kp1_correct` in scope. Pass them to `prior_2var_transfer_until/since`.

**`existPart_succ` (KampMutualInduction.lean)**: Already has `ih_char_succ : CharPart atomMap (k+1)`. Extract formula-level char function via Classical.choose (already done for the n=1 call site). No change needed for the n>=2 case since it delegates to `existPart_succ_n1_bypass`.

**`kamp_mutual_induction`**: No change needed. The CharPart flows through existing parameter chain.

## Implementation Plan (Revised Phases 5-6)

### Phase 5 (Revised): Delete FALSE Lemmas + Add CharPart Parameters

1. Delete `depth0_3var_exist_transfer_until`, `depth0_3var_exist_transfer_since`, and `exist_transfer_3var_nonconstenv` from PriorComposition.lean
2. Add `char_kp1_fn` + `char_kp1_correct` to `prior_nonconstenv_2var_agree_until/since`
3. Add `char_kp1_fn` + `char_kp1_correct` to `prior_2var_transfer_until/since`
4. Update call site in KampBypass.lean to pass char_kp1/char_kp1_correct
5. Replace K=0 base case and K>0 step with sorry (preserving the new signatures)
6. Verify: `lake build` passes (sorry count should be same or reduced)

Estimated: 2-3 hours

### Phase 6 (Revised): Implement Zone-Based Transfer with CharPart

1. K=0 base: implement zone decomposition with Prior-UZ/SZ squeeze argument
   - Zones 1,2,4,5: reuse existing helpers
   - Zone 3: Prior-UZ/SZ + cross_extend_bwd_1var + case analysis
2. K>0 step: use IH (h_xt from IH) + zone decomposition at higher depth
3. Remove all sorry from PriorComposition.lean

Estimated: 6-10 hours (the between-zone case analysis is the hard part)

### Phase 7: Verification + Cleanup

1. `lean_verify completeness_discrete` clean
2. Clean up dead code and comments

Estimated: 1 hour

## Risk Assessment

| Risk | Severity | Likelihood | Notes |
|------|----------|------------|-------|
| Zone 3 between-zone case analysis intractable | HIGH | MEDIUM | The Prior-UZ/SZ squeeze argument may not straightforwardly give depth-1 3-var agreement at the witness. May need to show depth-0 conditions (purely atomic) are preserved and then handle depth-1 quantifier conditions by induction. |
| Heartbeat limits in zone decomposition | MEDIUM | HIGH | Zone 3 has many sub-cases. Factor into private helpers. |
| CharPart threading creates typing issues | LOW | LOW | The parameter types exactly match existing patterns in existPart_succ_n1_bypass. |
| K>0 step still needs arity climbing | MEDIUM | MEDIUM | With h_xt from IH, the 3-var existential at depth K'+1 may still need a depth boost. If so, the zone argument recurses and terminates at depth 0 where everything is atomic. |

## Key Verification Targets

After each phase:
```bash
# Phase 5: signatures changed, sorry preserved
lake build PriorComposition
lake build KampBypass

# Phase 6: sorry removed
grep -rn "^\s*sorry" Theories/Bimodal/Metalogic/WeakCanonical/Kamp/PriorComposition.lean

# Phase 7: full chain
lean_verify completeness_discrete
lake build
```
