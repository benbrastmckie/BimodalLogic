# Research Report: Strong D-Induction for Zone 3 Between-Zone Transfer

- **Task**: 303 - k_gt_0_depth_induction
- **Focus**: Feasibility of strong D-induction to close 4 sorry in PriorComposition.lean
- **Date**: 2026-06-18
- **Status**: Research complete -- approach feasible with caveats

## Summary

Strong D-induction (via `Nat.strong_induction_on`) is necessary and structurally correct for eliminating the circularity in `prior_nonconstenv_2var_agree_until/since`. However, the zone-3 argument requires more than just the strong IH -- it needs a carefully staged proof that combines Prior-UZ/SZ witness placement, the strong IH for 2-var agreement at intermediate pairs, and `nf_extend_bwd` for arity lifting. The depth-0 base case additionally requires a direct Prior-UZ/SZ argument for purely-atomic 4-var existentials.

## 1. Exact Proof Obligations at Each Sorry

### Line 264 (K=0, Until zone, `prior_nonconstenv_2var_agree_until`)

**Goal**:
```lean
⊢ (∃ x_1, nf_eval_nf M 1 (2 + 1) (Fin.cons x_1 (Fin.cons x fun x ↦ t)) sub_nf) ↔
    ∃ x, nf_eval_nf N 1 (2 + 1) (Fin.cons x (Fin.cons x' fun x ↦ t')) sub_nf
```

**Meaning**: Transfer depth-1 3-var existentials between M and N at environments [w,x,t]/[w',x',t'], given depth-2 1-var agreement at x/x' and t/t', with t < x and t' < x', and Prior-UZ/SZ on both structures. char_correct available at d <= 1.

**Context depth**: D = K+2 = 2. Quantifier depth = D-1 = 1. Sub-NF arity = 3.

### Line 285 (K=succ K', Until zone)

**Goal**:
```lean
⊢ (∃ x_1, nf_eval_nf M (K' + 2) (2 + 1) (Fin.cons x_1 (Fin.cons x fun x ↦ t)) sub_nf) ↔
    ∃ x, nf_eval_nf N (K' + 2) (2 + 1) (Fin.cons x (Fin.cons x' fun x ↦ t')) sub_nf
```

**Meaning**: Same as above but at depth K'+2 (= D-1 where D = K'+3). IH available from `induction K` at K'.

### Line 336 (K=0, Since zone, `prior_nonconstenv_2var_agree_since`)

Mirror of line 264 with reversed order: x < t, x' < t'.

### Line 354 (K=succ K', Since zone)

Mirror of line 285 with reversed order.

## 2. Circularity Analysis

### Why Simple K-Induction Fails

The current `induction K` structure provides the IH at K' when proving at K = K'+1:
- **IH gives**: depth-(K'+2) 2-var agreement (the full theorem at K')
- **Goal needs**: depth-(K'+2) 3-var existential transfer

To get depth-(K'+2) 3-var existential transfer from depth-(K'+2) 2-var agreement, one would need `nf_extend_bwd` -- but that requires depth-(K'+3) 2-var agreement (one higher), which is the CURRENT theorem being proved. Circular.

### The Intermediate Pair Problem

Even with strong D-induction, the zone-3 argument encounters a fundamental structural issue:

1. The theorem at depth D proves: depth-D 2-var at [x,t]/[x',t']
2. Its quantifier part needs: `(∃ w, nf_eval M (D-1) 3 [w,x,t] sub_nf) ↔ (∃ w', nf_eval N (D-1) 3 [w',x',t'] sub_nf)`
3. For zone 3 (t < w < x): we find w' via Prior-UZ/SZ with the same depth-(D-1) 1-var NF as w
4. We need: `nf_eval M (D-1) 3 [w,x,t] sub_nf → nf_eval N (D-1) 3 [w',x',t'] sub_nf`
5. This depth-(D-1) 3-var agreement requires:
   - Atom part: from 1-var agreements + known orders (provable)
   - Quantifier part: depth-(D-2) 4-var existential transfer at [y,w,x,t]/[y',w',x',t']

Step 5's quantifier part would follow from depth-(D-1) 3-var agreement at [w,x,t] (via nf_extend_bwd) -- but that's what we're proving. OR it would follow from depth-D 2-var at [x,t] (via nf_extend_bwd from depth-D 2-var → depth-(D-1) 3-var) -- but THAT is what the outer theorem is proving!

### Resolution: nf_extend_bwd from the Strong IH

The strong IH at D-1 gives: depth-(D-1) 2-var agreement at [w,x]/[w',x'] and [w,t]/[w',t']. Applying `nf_extend_bwd` to either of these:
- From depth-(D-1) 2-var at [w,x]/[w',x'] → for any y in M, ∃ y' in N with depth-(D-2) 3-var at [y,w,x]/[y',w',x']

But we need depth-(D-2) 4-var at [y,w,x,t]/[y',w',x',t']. This is ONE MORE variable.

The resolution requires observing that `nf_extend_bwd` is applied to the 3-var agreement at [w,x,t] -- but getting that 3-var agreement IS the problem.

**ACTUAL resolution**: The 3-var existential transfer does NOT require full 3-var NF agreement at a specific env. It requires the EXISTENTIAL to transfer. The existential `∃ w, nf_eval M (D-1) 3 [w,x,t] sub_nf` can be characterized ZONE BY ZONE on w:

- **Zone 1** (w < t): constant-env relative to t. `cross_extend_bwd_1var` from h_t gives w' with depth-(D-2) 2-var at [w,t]/[w',t']. Combined with the fact that the 3-var env [w,x,t] with w < t < x has w below both others, `constenv_2var_determines` lifts to 3-var because the (n+1)-var NF on const envs is determined by 2-var.

  Wait -- [w,x,t] is NOT a constant env. But w < t < x means w is below both t and x. For the quantifier part of the 3-var NF at [w,x,t], the existential `∃ y, nf_eval (D-2) 4 [y,w,x,t] ssn4` can be handled by nested zone decomposition on y.

  Actually, for zone 1, the correct tool is simply `nf_extend_bwd` from h_t (depth-D 1-var at t/t'):
  - h_t gives depth-D 1-var agreement at t/t'
  - `nf_extend_bwd` applied to h_t at arity 1: from depth-D 1-var, for any w with specific depth-(D-1) 2-var relationship to t, find w' with depth-(D-1) 2-var at [w,t]/[w',t']
  
  But we need depth-(D-1) 3-var at [w,x,t], not depth-(D-1) 2-var at [w,t].

- **Zone 3** (t < w < x): The hard case. Requires Prior-UZ/SZ + char_fn.

## 3. Correct Proof Architecture (Revised Understanding)

After extensive analysis, the correct architecture for the zone-3 case combines two ingredients:

### Ingredient 1: Prior-UZ/SZ Witness Placement

Given w in (t, x) with depth-(D-1) 1-var type nf_w:
1. `char_fn (D-1) nf_w` characterizes this type as a temporal formula (from char_correct at d = D-2 <= D-1? Actually char_correct gives d <= K+1 = D-1. YES.)
2. Wait -- char_correct in the current signature is `∀ d ≤ K+1`. With D = K+2, that's d ≤ D-1. So char_fn characterizes types at depth up to D-1. But we need to characterize nf_w which is at depth D-1. 

   **Issue**: char_correct covers `d ≤ K+1 = D-1`, and nf_w is at depth D-1. So char_correct DOES cover it (with d = D-1 and the bound d ≤ D-1 being d ≤ D-1, satisfied with equality).

   Wait, re-reading the char_correct signature:
   ```lean
   char_correct : ∀ (d : Nat) (_ : d ≤ K + 1) (nf_1 : NormalForm sig d 1) ...
   ```
   K+1 = D-1 (since D = K+2). So for d = D-1 = K+1, the bound d ≤ K+1 holds. YES.

3. In M: temporal_truth M atomMap w (char_fn (D-1) nf_w) holds (by char_correct, since nf_eval_nf M (D-1) 1 [w] nf_w holds)
4. Since t < w, the formula `(char_fn (D-1) nf_w) U top` holds at t in M
5. Need: does temporal truth of `(char_fn (D-1) nf_w) U top` at t transfer to t' via h_t?

   The formula `(char_fn (D-1) nf_w) U top` has temporal depth at most (D-1) + 1 = D (since char_fn produces a formula whose temporal truth corresponds to a depth-(D-1) NF evaluation). Actually, we need to be careful about formula depth vs NF depth.

   The key insight: depth-D 1-var NF agreement at t/t' implies agreement on ALL temporal formulas of "appropriate complexity." Specifically, the depth-D 1-var NF determines `∃ y, nf_eval M (D-1) 2 [y,t] ssn2` for all depth-(D-1) 2-var NF types ssn2. If we can show that the formula `(char_fn (D-1) nf_w) U top` at t is equivalent to such an existential, then the transfer follows.

   Indeed: `temporal_truth M atomMap t ((char_fn (D-1) nf_w) U top)` means ∃ s > t s.t. temporal_truth M s (char_fn (D-1) nf_w) and top holds in between. The "top holds in between" is vacuous. So it's just ∃ s > t, nf_eval M (D-1) 1 [s] nf_w.

   This is equivalent to ∃ s, nf_eval M (D-1) 2 [s, t] ssn_above_with_nf_w, where ssn_above_with_nf_w is the depth-(D-1) 2-var NF type that has:
   - 1-var type of s = nf_w
   - Order: s > t (i.e., index 0 > index 1)
   - The full 2-var NF at [s, t] is determined by s's position relative to t and both their 1-var types

   Hmm, actually this is NOT a single 2-var NF type -- different s values above t can have different 2-var NFs even with the same 1-var NF, because the quantifier conditions of the 2-var NF depend on what other points exist between t and s.

### Ingredient 2: Strong D-Induction for the Recursive Case

Once w' is found in (t', x') with depth-(D-1) 1-var agreement with w, the strong IH at D-1 gives:
- depth-(D-1) 2-var at [w,t]/[w',t'] (since t < w, t' < w', and 1-var agreement at both pairs)
- depth-(D-1) 2-var at [w,x]/[w',x'] (since w < x, w' < x', and 1-var agreement at both pairs)

For the Since case of the IH at D-1 applied to (w, t): We need depth-(D-1) 1-var agreement at w/w' and t/t'. We have:
- w/w': from nf_agreement_from_shared_nf (both satisfy nf_w)
- t/t': from h_t weakened via nf_agreement_monotone (depth-D → depth-(D-1))

**Issue with char_correct for recursive call**: The IH at D-1 requires char_correct at d ≤ (D-1)-1 = D-2 = K. The outer char_correct covers d ≤ K+1. Restricting to d ≤ K is fine (omega).

### The Remaining Gap

Having depth-(D-1) 2-var at [w,x] and [w,t] does NOT directly give depth-(D-1) 3-var at [w,x,t]. However:

**Key observation**: We don't need FULL depth-(D-1) 3-var agreement at [w,x,t]. We only need that the SPECIFIC sub_nf is satisfied by BOTH M at [w,x,t] AND N at [w',x',t']. If we can show:
1. M satisfies sub_nf at [w,x,t] (given -- that's w being a witness)
2. N satisfies sub_nf at [w',x',t'] (need to prove)

For (2), sub_nf's components are:
- **Atom part**: predicates at positions 0,1,2 and order atoms between them. Position 0 = w/w', position 1 = x/x', position 2 = t/t'. Predicates transfer from 1-var agreements. Orders transfer from the zone structure.
- **Quantifier part**: for each ssn4 : NF (D-2) 4, sub_nf.2 ssn4 = true iff ∃ y, nf_eval M (D-2) 4 [y,w,x,t] ssn4.

For the quantifier part: from M satisfying sub_nf, we know which ssn4 are true/false. We need the SAME existential conditions to hold in N. This means: `(∃ y, nf_eval M (D-2) 4 [y,w,x,t] ssn4) ↔ (∃ y', nf_eval N (D-2) 4 [y',w',x',t'] ssn4)`.

This is a depth-(D-2) 4-var existential transfer at [w,x,t]/[w',x',t']. 

From depth-(D-1) 2-var at [w,x]/[w',x']:
- `nf_extend_bwd` gives: for any y in M, ∃ y' with depth-(D-2) 3-var at [y,w,x]/[y',w',x']
- But we need depth-(D-2) 4-var at [y,w,x,t]/[y',w',x',t']

From depth-(D-1) 2-var at [w,t]/[w',t']:
- `nf_extend_bwd` gives: for any y in M, ∃ y'' with depth-(D-2) 3-var at [y,w,t]/[y'',w',t']
- Different from above (y' vs y'')

**Alternative: use nf_extend_bwd from depth-(D-1) 2-var at [x,t]/[x',t']**:
We DON'T have depth-(D-1) 2-var at [x,t]/[x',t'] from the IH -- the IH at D-1 gives depth-(D-1) 2-var at [w,x] and [w,t], but not at [x,t] (because that requires the theorem at D-1 for the pair (x,t), which in turn requires depth-(D-1) 1-var agreement at x and t).

Wait -- we DO have depth-(D-1) 1-var agreement at x/x' (from h_x weakened) and t/t' (from h_t weakened). So we CAN apply the IH at D-1 to (x, t) to get depth-(D-1) 2-var at [x,t]/[x',t']!

From depth-(D-1) 2-var at [x,t]/[x',t'], apply `nf_extend_bwd`:
- For any w in M, ∃ w* in N with depth-(D-2) 3-var at [w,x,t]/[w*,x',t']

And ALSO from depth-(D-1) 2-var at [w,x]/[w',x'], apply `nf_extend_bwd`:
- For any t_pt in M, ∃ t* in N with depth-(D-2) 3-var at [t_pt,w,x]/[t*,w',x']

Hmm, the envs don't quite match what we need. We need depth-(D-2) 4-var at [y,w,x,t].

**KEY INSIGHT**: From depth-(D-1) 3-var agreement at [w,x,t]/[w',x',t'] (which is what we're trying to establish for the zone-3 witness), `nf_extend` would give the 4-var transfer. But we need to establish the 3-var agreement FIRST.

However, from depth-(D-1) 2-var at [x,t]/[x',t'] (which we GET from the IH at D-1), `nf_extend_bwd` gives:
```
For any w in M, ∃ w* in N with depth-(D-2) 3-var at [w,x,t]/[w*,x',t']
```

This w* has the right depth-(D-2) 3-var NF at [w*,x',t']. If w* = w' (our zone-3 witness), then we'd have depth-(D-2) 3-var at [w,x,t]/[w',x',t']. But w* is found by nf_extend_bwd and might NOT be w'!

However, depth-(D-2) 3-var agreement at [w,x,t]/[w*,x',t'] means w* has the same depth-(D-2) NF profile as w relative to x,t. Since w' has the same depth-(D-1) 1-var NF as w (from Prior-UZ/SZ placement), and w* has the same depth-(D-2) 3-var NF as w at [w,x,t], these are DIFFERENT w's with different guarantees.

**THE ACTUAL CORRECT APPROACH**: Use the w* from `nf_extend_bwd` applied to depth-(D-1) 2-var at [x,t]/[x',t']. This gives depth-(D-2) 3-var at [w,x,t]/[w*,x',t']. Then:
- At depth D-2, the 3-var NF has its own quantifier part (depth D-3, 4-var)
- This recursion terminates at depth 0 where everything is purely atomic

But we need depth-(D-1) 3-var at [w,x,t] (from the goal), not depth-(D-2). There's a one-level gap between what nf_extend_bwd gives (D-2) and what we need (D-1).

## 4. Proposed Solution: Restructured Strong Induction with nf_extend Chain

### Observation

The gap between depth-(D-1) needed and depth-(D-2) available from nf_extend is bridged by observing that:

**From depth-D 2-var at [x,t]/[x',t'] (the CONCLUSION of the outer theorem)**, `nf_extend_bwd` gives depth-(D-1) 3-var at [w,x,t]. But we're proving the depth-D 2-var, so this is circular for a direct proof.

**BUT from depth-(D-1) 2-var at [x,t]/[x',t'] (from IH at D-1)**, `nf_extend_bwd` gives depth-(D-2) 3-var at [w,x,t]. This is ONE LESS than needed.

**The resolution**: Restructure the theorem to prove it by showing that M and N share the same NF DIRECTLY, using `nf_agreement_from_shared_nf`. The approach:

1. From depth-(D-1) 2-var at [x,t]/[x',t'] (IH at D-1), use nf_extend_bwd to get w* in N with depth-(D-2) 3-var at [w,x,t]/[w*,x',t'].
2. Also from h_x (depth-D 1-var at x/x'), use `cross_extend_bwd_1var` to get w** with depth-(D-1) 2-var at [w,x]/[w**,x']. 
3. Key: w** has the same depth-(D-1) 2-var NF as w at [w,x]/[w**,x']. This determines w**'s depth-(D-1) 1-var NF (via projection). 
4. If w** is also in (t', x'), it's a valid zone-3 witness.

Actually, I realize the cleanest approach is:

### Proposed Clean Architecture

**Theorem (strong form)**: For all D >= 2, on Prior structures:
```
strong_prior_nonconstenv_2var (D : Nat) (hD : D >= 2) :
  [depth-D 1-var agreement at x/x' and t/t'] →
  [orders t < x, t' < x'] →
  [char_correct at d <= D-1] →
  depth-D 2-var agreement at [x,t]/[x',t']
```

Proved by `Nat.strong_induction_on D`. At depth D:

**Atom part**: `nonconstenv_atom_agree_until` (already sorry-free).

**Quantifier part**: For each sub_nf : NF (D-1) 3, prove the existential transfer.

For the existential transfer `∃ w ... ↔ ∃ w' ...`:
- Apply IH at D-1 to get depth-(D-1) 2-var at [x,t]/[x',t'] (from weakened h_x, h_t)
- From depth-(D-1) 2-var at [x,t]/[x',t'], `nf_extend_bwd` gives: for the given w in M, ∃ w' in N with depth-(D-2) 3-var at [w,x,t]/[w',x',t']
- From depth-(D-2) 3-var at [w,x,t]/[w',x',t'] via `nf_agreement_from_shared_nf`: M and N agree on all depth-(D-2) 3-var NFs at these envs
- But we need agreement on the specific sub_nf at depth D-1, not D-2!

**THE FUNDAMENTAL GAP**: nf_extend_bwd from depth-(D-1) 2-var gives depth-(D-2) 3-var. We need depth-(D-1) 3-var. This is an irreducible one-level depth gap that strong D-induction alone cannot bridge.

## 5. Resolution of the Depth Gap

After extensive analysis, the depth gap can be bridged by ONE of these approaches:

### Approach A: Prove P(D, r) for all r simultaneously

Define P(D) := "For all r >= 2 and all r-var non-constant envs with depth-D 1-var agreement at each component, depth-D r-var agreement holds."

Then P(D)'s proof at r uses nf_extend_bwd from P(D) at r-1 (same depth, lower arity). Since nf_extend_bwd starts from depth-D (r-1)-var and gives depth-(D-1) r-var, this doesn't work either unless we can get depth-D (r-1)-var from the proof itself.

### Approach B: Use the full characteristic NF structure

The depth-D 2-var agreement is proved by showing M satisfies N's characteristic NF (target). The quantifier part of target asks about depth-(D-1) 3-var existentials. Instead of trying to transfer these BETWEEN structures, prove them DIRECTLY in M by constructing witnesses.

Specifically: target.2 sub_nf = `decide (∃ w', nf_eval N (D-1) 3 [w',x',t'] sub_nf)`. If this is true, N has a witness w'. We need to find w in M. Use `nf_extend_fwd` from depth-(D-1) 2-var at [x,t]/[x',t'] (from IH at D-1):
- For w' in N, ∃ w in M with depth-(D-2) 3-var at [w,x,t]/[w',x',t']
- w has depth-(D-2) 3-var agreement with w'. Does w satisfy sub_nf at depth D-1?

NOT necessarily -- we only get depth-(D-2), not depth-(D-1). Same gap.

### Approach C: Reformulate as joint 2-var + existential-transfer theorem (RECOMMENDED)

Prove a STRONGER theorem by joint induction:

```
strong_transfer (D : Nat) :
  ∀ (r >= 1), 
  [depth-D r-var agreement at envM/envN on Prior structures] →
  [depth-(D-1) (r+1)-var existential transfer]
```

This follows from `nf_extend_bwd/fwd` DIRECTLY. It's already proved as a consequence of r-var agreement! The chain is:
- depth-D r-var agreement is the hypothesis
- nf_extend_bwd gives the (r+1)-var existential transfer at depth D-1

So the existential transfer is NOT the problem. The problem is establishing the r-var AGREEMENT. Specifically, depth-D 2-var agreement requires depth-(D-1) 3-var existential transfer (from nf_extend from something we DON'T have yet).

### Approach D: Use nf_extend on h_x and h_t DIRECTLY (CORRECT APPROACH)

From h_x (depth-D 1-var at x/x'):
- This is depth-D, arity-1 agreement at x/x'
- `nf_extend_bwd` (from depth-D arity-1): for any w in M, ∃ w' in N with depth-(D-1) 2-var at [w, x]/[w', x']
  Wait -- nf_extend_bwd requires depth-(K+1) r-var, so depth-D 1-var gives depth-(D-1) 2-var? Let me check.

  `nf_extend_bwd {K r} (h : depth-(K+1) r-var) (c) : ∃ c', depth-K (r+1)-var at [c,envM]/[c',envN]`
  
  With K+1 = D and r = 1: from depth-D 1-var at x/x', for any w, ∃ w' with depth-(D-1) 2-var at [w, x]/[w', x']. **YES!**

Similarly from h_t (depth-D 1-var at t/t'):
- For any w, ∃ w'' with depth-(D-1) 2-var at [w, t]/[w'', t']

Now from depth-(D-1) 2-var at [w, x]/[w', x'], apply nf_extend_bwd again:
- This is depth-(D-1) arity-2, so: for any t_pt in M, ∃ t_pt' with depth-(D-2) 3-var at [t_pt, w, x]/[t_pt', w', x']
- Setting t_pt = t: ∃ some_t' with depth-(D-2) 3-var at [t, w, x]/[some_t', w', x']

But some_t' might not be t'! And the env order is [t, w, x], not [w, x, t].

However, the env is just a function Fin 3 -> carrier. The order of variables doesn't matter semantically -- we can always reindex. The key is that we get depth-(D-2) 3-var at SOME 3-element env that includes w, x, t in M and w', x', t' in N (possibly with different points for the third).

**THIS IS THE KEY**: From h_x (depth-D 1-var), nf_extend_bwd gives depth-(D-1) 2-var at [w, x]/[w', x']. Then from THAT, nf_extend_bwd gives depth-(D-2) 3-var at [t, w, x]/[t*, w', x'] for SOME t*.

If t* = t', we're done (modulo reindexing). But t* is whatever point in N the nf_extend_bwd chooses -- not necessarily t'.

**HOWEVER**: from h_t SEPARATELY, we know the 1-var type of t'. And from the depth-(D-2) 3-var at [t, w, x]/[t*, w', x'], t* has specific properties. If we can show t* has the same 1-var type as t', then t* and t' are the same (up to NF equivalence, which by nf_agreement_from_shared_nf gives full agreement).

This is getting complex but potentially viable. The question is whether the argument can be formalized concisely.

### Approach E: The ACTUAL approach from Rabinovich (SIMPLEST)

Re-reading the proof architecture more carefully: `prior_nonconstenv_2var_agree` is called by `prior_2var_transfer_until` which is called by `existPart_succ_n1_bypass`. The existPart bypass ALREADY handles witness placement. It finds a witness x in M with the right 1-var NF type matching M₀'s witness x₀, and then calls `prior_2var_transfer_until` to transfer the full 2-var NF.

The 2-var NF transfer (prior_nonconstenv_2var_agree) needs to show the 3-var existential conditions match. For this, the argument is:

**For zones 1, 2, 4, 5**: The 3-var existential `∃ w, nf_eval M (D-1) 3 [w,x,t] sub_nf` where w is NOT in zone 3 can be handled by `cross_extend_bwd_1var`:
- Zone 1 (sub_nf says w < t): from h_t, cross_extend gives w' < t' with the right 2-var NF at [w,t]. The 3-var NF at [w,x,t] with w < t is determined by the 2-var NFs [w,t] and [w,x] -- but we only get [w,t] from one cross_extend.
  
  ACTUALLY: For zone 1, the env [w,x,t] with w < t < x means from h_t (depth-D 1-var), cross_extend gives w' with depth-(D-1) 2-var at [w,t]/[w',t']. The 3-var NF at [w,x,t] is NOT determined by just [w,t]. It also depends on x's relationship to w.

  HOWEVER: The 3-var existential transfer `∃ w, ... ↔ ∃ w', ...` only needs ONE w' that satisfies sub_nf. For zones 1 and 5, we can use `nf_extend_bwd` applied to h_x or h_t at the right arity:
  
  From h_x (depth-D 1-var at x/x'): nf_extend_bwd gives for any w in M, ∃ w' with depth-(D-1) 2-var at [w,x]/[w',x']. If sub_nf is at depth D-1 and arity 3, having depth-(D-1) 2-var at [w,x]/[w',x'] gives us PARTIAL information about [w,x,t]/[w',x',t'].
  
  From h_t (depth-D 1-var at t/t'): similarly, ∃ w'' with depth-(D-1) 2-var at [w,t]/[w'',t'].

This doesn't cleanly separate zones from the 3-var problem. 

## 6. ACTUAL Feasible Approach (After Full Analysis)

After this extensive analysis, I believe the correct approach is:

### Step 1: Strong D-Induction (Restructure)

Replace `induction K` with `Nat.strong_induction_on (K+2)` (or equivalently, define D=K+2 and induct on D).

### Step 2: Apply IH at D-1 to Get 2-var at [x,t]/[x',t']

The strong IH gives: the full theorem at depth D-1. Apply it to x/x' and t/t' (weakening h_x, h_t from depth D to depth D-1 via `nf_agreement_monotone`). This gives depth-(D-1) 2-var agreement at [x,t]/[x',t'].

### Step 3: Use nf_extend_bwd from Depth-(D-1) 2-var

From depth-(D-1) 2-var at [x,t]/[x',t'], `nf_extend_bwd` gives: for any w in M, ∃ w' in N with depth-(D-2) 3-var at [w,x,t]/[w',x',t'].

### Step 4: Bootstrap from Depth-(D-2) to Depth-(D-1)

The depth-(D-2) 3-var agreement at [w,x,t]/[w',x',t'] gives us most of what we need. The gap from D-2 to D-1 is exactly ONE level. At depth D-1, the 3-var NF has:
- Atoms: same as depth-0 (transfers from component agreements)
- Quantifier part: depth-(D-2) 4-var existentials (which follow from the depth-(D-2) 3-var via nf_extend_bwd)

**WAIT**: nf_extend_bwd from depth-(D-2) 3-var at [w,x,t]/[w',x',t'] gives: for any y, ∃ y' with depth-(D-3) 4-var at [y,w,x,t]/[y',w',x',t']. But the quantifier part of the depth-(D-1) 3-var NF asks about depth-(D-2) 4-var, not depth-(D-3).

So the bootstrapping doesn't work directly. The gap persists at every level.

### Step 5: The Correct Resolution (FINAL)

The gap is resolved by observing that we DON'T need to prove depth-(D-1) 3-var AGREEMENT at [w,x,t]/[w',x',t']. We only need to prove the EXISTENTIAL TRANSFER:

```
(∃ w, nf_eval M (D-1) 3 [w,x,t] sub_nf) ↔ (∃ w', nf_eval N (D-1) 3 [w',x',t'] sub_nf)
```

For the forward direction: given w with nf_eval M (D-1) 3 [w,x,t] sub_nf, we need to find w' in N satisfying sub_nf.

**Use nf_extend_bwd from depth-D 2-var... but we're proving that!**

Wait -- let me re-read `nf_extend_bwd`:
```
nf_extend_bwd (h : depth-(K+1) r-var agreement at envM/envN) (c : M.carrier) :
  ∃ c', depth-K (r+1)-var agreement at [c, envM]/[c', envN]
```

If we had depth-D 2-var at [x,t]/[x',t'] (which is the CONCLUSION), setting K+1=D and r=2:
- For any w, ∃ w' with depth-(D-1) 3-var at [w,x,t]/[w',x',t']

This DIRECTLY gives the existential transfer! w' satisfies any depth-(D-1) 3-var NF that w satisfies.

**So the proof structure should be**: Prove depth-D 2-var at [x,t]/[x',t'] by showing both sides of the biconditional via a WELL-FOUNDED argument. Specifically:

The theorem IS self-referential (its conclusion enables its own quantifier part), so it must be proved by well-founded induction on SOMETHING that decreases. That something is the DEPTH.

In `nf_characteristic_satisfies M D 2 [x,t]`, the quantifier part asks about depth-(D-1) 3-var existentials. These existentials can be transferred by nf_extend_bwd IF we have depth-D 2-var agreement. But we're PROVING depth-D 2-var agreement.

The resolution is that nf_characteristic_satisfies provides the UNIQUE NF. We don't need to transfer each sub_nf independently -- we need to show M's characteristic equals N's characteristic. The characteristics are DETERMINED by the NF evaluation structure, which ultimately bottoms out at depth 0 (atoms).

**FINAL ANSWER**: The proof should use `Nat.strong_induction_on D` where at each D, the quantifier part uses the SAME theorem at depth D-1 (from the IH). The point is: from IH at D-1, we get depth-(D-1) 2-var at [x,t]/[x',t']. Then nf_extend_bwd from that gives depth-(D-2) 3-var. The quantifier conditions of the depth-D 2-var NF ask about depth-(D-1) existentials. The gap is:

- We have depth-(D-2) 3-var (from nf_extend on IH at D-1)
- We need depth-(D-1) 3-var existential transfer

This gap means **the approach of using nf_extend_bwd from the IH at D-1 is INSUFFICIENT by itself**. We need an additional mechanism.

## 7. The Missing Mechanism: Prior-UZ/SZ Squeeze for Higher-Depth Transfer

The mechanism that bridges the depth gap is the **Prior-UZ/SZ squeeze combined with char_fn**. Here's how it works:

At depth D, for zone 3 (t < w < x), the existential transfer is:
```
∃ w, [t < w < x ∧ nf_eval M (D-1) 3 [w,x,t] sub_nf] → ∃ w', [t' < w' < x' ∧ nf_eval N (D-1) 3 [w',x',t'] sub_nf]
```

The argument:
1. w's depth-(D-1) 1-var NF is nf_w. Let phi_w = char_fn (D-1) nf_w.
2. temporal_truth M w phi_w holds (char_correct).
3. Since t < w, "∃ s > t, temporal_truth M s phi_w" holds.
4. By depth-D 1-var NF agreement at t/t': the quantifier condition of t's NF that encodes "existence above t of type nf_w" transfers. Specifically, the 2-var NF ssn at [w,t] is such that the existential `∃ y, nf_eval M (D-1) 2 [y,t] ssn` holds (since w is such a y). By h_t (depth-D agreement), `∃ y', nf_eval N (D-1) 2 [y',t'] ssn` holds too. Let w₁' be such a y'. Then w₁' > t' and has depth-(D-1) 2-var agreement with w at [w,t]/[w₁',t'].
5. Similarly from h_x: since w < x, the existential below x of w's type transfers. Get w₂' < x' with depth-(D-1) 2-var agreement at [w,x]/[w₂',x'].

Now w₁' > t' and w₂' < x'. If w₁' = w₂', we have a single witness in (t', x'). But they might differ!

6. **Key**: w₁' has depth-(D-1) 2-var NF at [w₁', t'] matching [w, t]. Since w < x and the 2-var NF at [w,t] encodes information about w's position, w₁' has depth-(D-2) 1-var NF matching w's (from projection). Similarly w₂' has depth-(D-2) 1-var NF matching w's.

7. **Prior-UZ/SZ to get a witness in the interval**: Since some point above t' has phi_w-type (w₁'), and some point below x' has phi_w-type (w₂'), by the Prior-UZ axiom applied at t' with formula phi_w, there's a FIRST occurrence above t'. Call it w_first. Since w₂' < x' also satisfies phi_w, w_first ≤ w₂' < x'. So w_first ∈ (t', x').

8. w_first has depth-(D-1) 1-var agreement with w (both satisfy nf_w, use nf_agreement_from_shared_nf).

9. Apply strong IH at D-1 to (w, w_first) and (x, x') and (t, t') to get depth-(D-1) 2-var at [w_first, x']/[w, x] and [w_first, t']/[w, t].

10. From these two depth-(D-1) 2-var agreements at [w_first, x'] and [w_first, t'], PLUS the atom agreement, PLUS the depth-(D-2) 3-var from step 3 above... we STILL need to prove depth-(D-1) 3-var.

**THE GAP PERSISTS**. After all this analysis, I conclude:

## 8. Feasibility Assessment

### Strong D-Induction: NECESSARY but NOT SUFFICIENT alone

Strong D-induction eliminates the K-induction circularity and provides access to the theorem at all lower depths. However, the zone-3 argument requires an additional structural insight:

**The existential transfer at depth D-1 and arity 3 cannot be reduced to the 2-var theorem alone.** It requires either:
1. A mutual induction that proves r-var transfer for all r simultaneously (arity-climbing)
2. A direct argument that zone-3 witnesses can be found using Prior-UZ/SZ at the specific arity needed

### Recommended Path Forward

**Option 1 (Cleanest, ~300-500 lines)**: Reformulate `prior_nonconstenv_2var_agree` to use `nf_extend_bwd` from the CONCLUSION (depth-D 2-var) as a well-founded recursion. The well-foundedness comes from the fact that the total (depth, arity) decreases lexicographically in the recursion:
- Proving depth-D arity-2 uses depth-(D-1) arity-3 existential transfer
- Which IS depth-D arity-2 applied via nf_extend_bwd (same depth, but nf_extend_bwd is a CONSEQUENCE of the agreement, not a precondition)

Wait -- nf_extend_bwd IS a consequence of the agreement! Its proof uses the quantifier conditions of the agreement to find witnesses. So depth-D 2-var agreement IMPLIES depth-(D-1) 3-var existential transfer. They're EQUIVALENT in some sense.

**This means the proof can't use nf_extend_bwd as a tool** -- it needs to prove the quantifier conditions DIRECTLY without assuming the conclusion.

**Option 2 (Correct, ~400-600 lines)**: Prove the 3-var existential transfer DIRECTLY for each zone, using:
- Zone 1,5: `cross_extend_bwd_1var` + `constenv_2var_determines` (or adapted versions)
- Zone 2,4: trivial (use x' or t' directly)  
- Zone 3: Prior-UZ/SZ to find w' in (t', x') with the right 1-var NF, then REBUILD the full 3-var NF satisfaction at [w',x',t'] piece by piece:
  - Atom part: from 1-var agreements + known orders
  - Quantifier part: recursive call to the SAME existential-transfer argument at depth D-2 (strong induction provides this)

**This is the viable approach!** The key observation: for the quantifier part of depth-(D-1) 3-var at zone-3 witness w', we need depth-(D-2) 4-var existential transfer. This is handled by applying the SAME zone-decomposition argument recursively on the 4-var existential. The recursion terminates because depth decreases at each level.

Concretely, define:
```
strong_exist_transfer (D : Nat) (r : Nat) :
  [Prior + h_x + h_t + orders + char_correct] →
  ∀ sub_nf : NF (D-1) (r+1),
  (∃ w, nf_eval M (D-1) (r+1) [w, env_M] sub_nf) ↔ 
  (∃ w', nf_eval N (D-1) (r+1) [w', env_N] sub_nf)
```

Proved by induction on D (strong). At each D, zone decompose, use Prior-UZ/SZ for zone 3, and for the quantifier conditions of zone 3's witness, recurse at D-1.

The arity does NOT increase in the recursion because: at each level, we're proving an existential transfer (arity r+1). The quantifier conditions inside ask about arity r+2, but those are at depth D-2. At depth 0, the quantifier conditions vanish (depth-0 NFs are purely atomic). So the recursion is on depth alone, with arity being a parameter.

### Estimated Lines

- Restructure `prior_nonconstenv_2var_agree_until/since` with strong D-induction: ~100 lines
- Zone decomposition for the 3-var existential transfer: ~150 lines per zone
- Prior-UZ/SZ squeeze argument for zone 3: ~200 lines
- Helper lemmas (atom transfer for 3-var, order extraction, monotonicity coercions): ~150 lines
- Mirror for Since: ~200 lines (much shared)
- Total: **600-900 lines** of new code (replacing the 4 sorry lines)

### Key Available Infrastructure

| Name | Location | Purpose |
|------|----------|---------|
| `Nat.strong_induction_on` | Mathlib.Data.Nat.Init | Strong induction on Nat |
| `nf_agreement_monotone` | NormalForm.lean:339 | Depth weakening |
| `nf_agreement_from_shared_nf` | NormalForm.lean:291 | Unique NF → agreement |
| `nf_characteristic_satisfies` | NormalForm.lean:224 | M satisfies its own characteristic |
| `cross_extend_bwd_1var` | KampComposition.lean:97 | 1-var to 2-var lift |
| `nf_extend_bwd` | KampBypass.lean:57 | General arity extension |
| `exist_transfer_nvar_constenv` | KampComposition.lean:122 | Constant-env existential transfer |
| `constenv_2var_determines` | KampComposition.lean (approx) | 2-var determines n-var on const envs |
| `semantic_prior_UZ` | PriorDefs.lean:22 | First occurrence above |
| `semantic_prior_SZ` | PriorDefs.lean:33 | Last occurrence below |

### Risks

1. **Heartbeat limits**: The strong induction + zone decomposition may exceed heartbeat limits. Mitigate with `set_option maxHeartbeats` and factoring into helper lemmas.
2. **Termination**: Lean needs to verify the strong induction is well-founded. Using `Nat.strong_induction_on` handles this automatically.
3. **Zone 3 complexity**: The Prior-UZ/SZ squeeze argument + recursive quantifier conditions may be longer than estimated.
4. **Env reindexing**: The 3-var env [w,x,t] needs careful handling of Fin indices.

## 9. Adversarial Self-Verification

### Challenged Claims

| Claim | Verified? | Notes |
|-------|-----------|-------|
| nf_agreement_monotone exists with right type | YES | Confirmed at NormalForm.lean:339 |
| Nat.strong_induction_on available | YES | Confirmed via lean_leansearch, used at KampMutualInduction.lean:397 |
| char_correct covers depth D-1 | YES | Bound is d <= K+1 = D-1 |
| Prior-UZ/SZ can squeeze w' into (t', x') | PLAUSIBLE | Requires careful argument about first occurrences |
| nf_extend_bwd gives depth-(D-2) from depth-(D-1) | YES | By definition of nf_extend_bwd |
| Depth gap (D-2 vs D-1) can be bridged by recursion on D | PLAUSIBLE | Needs proof that zone-3 quantifier conditions at depth D-2 are handled by strong IH at D-2 |
| NfCharFormula.lean:651 sorry is NOT blocking | PARTIALLY | It's on the path from charPart_succ but the main pipeline uses kamp_mutual_induction which bypasses it |

### Uncertain Claims (Confidence < 80%)

1. **Zone-3 quantifier recursion terminates correctly** (70%): The argument that depth decreases at each recursive call needs formal verification. At depth D, zone 3 needs D-1 existential, whose quantifier needs D-2, etc. At D=0, atoms only. But arity grows! At each level, the existential is over one more variable. Does this matter? No -- because the arity is bounded by the fixed sub_nf that we're working with. Each level's existential is for a SPECIFIC NF, not all NFs.

2. **Prior-UZ/SZ squeeze gives w' in (t', x')** (75%): The argument relies on: (a) existence of a point above t' with phi_w (from h_t transfer), (b) existence of a point below x' with phi_w (from h_x transfer), (c) Prior-UZ gives first occurrence above t', which must be ≤ the point below x'. Step (c) needs: the FIRST point above t' satisfying phi_w is less than x'. This requires: if the first point above t' with phi_w were ≥ x', then there would be NO point in (t', x') with phi_w -- but from h_x transfer, there IS such a point (below x'). Contradiction. YES -- this works.

3. **No dependency on NfCharFormula.lean sorry** (85%): The main pipeline through kamp_mutual_induction → existPart_succ → existPart_succ_n1_bypass provides the proper IH arguments, bypassing the NfCharFormula sorry at line 651. But charPart_succ uses nf_characterizable_temporal_prior_classical which calls nf_2var_exist_formula_prior at k+2 with sorry args. This creates a dependency in the CharPart chain. Need to verify this doesn't affect the ExistPart chain.

## 10. NfCharFormula.lean Sorry Analysis

### Dependency Trace

The 3 sorry at NfCharFormula.lean:651 pass `sorry` as `ih_char`, `ih_exist`, and `ih_all_char` arguments to `existPart_succ_n1_bypass`. The call chain is:

```
kamp_mutual_induction (k >= 3) → charPart_succ (k-1 >= 2)
  → nf_characterizable_temporal_prior_classical (k-1)
    → nf_2var_exist_formula_prior (k-1 >= 2, hits | k+2 => branch)
      → existPart_succ_n1_bypass ... sorry sorry sorry ...
```

Since `existPart_succ_n1_bypass` (KampBypass.lean) has 0 sorry IN ITS SOURCE but calls `prior_2var_transfer_until/since` from PriorComposition.lean (which has sorry), the sorry propagates through imports. The 3 explicit sorry at line 651 are ADDITIONAL sorry on top of the transitively-imported ones.

### Impact Assessment

**Once PriorComposition.lean's 4 sorry are fixed**:
- `prior_2var_transfer_until/since` become sorry-free
- `existPart_succ_n1_bypass` becomes transitively sorry-free (no imported sorry)
- BUT NfCharFormula:651 STILL has 3 explicit sorry as arguments

**The circular dependency**: `charPart_succ` → `nf_characterizable_temporal_prior_classical` → `nf_2var_exist_formula_prior` → needs CharPart(k+1) and ExistPart(k+1) as arguments → which come from `kamp_mutual_induction` → which uses `charPart_succ`. Circular!

**Resolution**: The circularity is broken by `nf_2var_exist_formula_prior_filled` (KampMutualInduction.lean:425), which extracts ExistPart from `kamp_mutual_induction` directly. The fix for NfCharFormula:651 is to restructure `nf_characterizable_temporal_prior_classical` to use `nf_2var_exist_formula_prior_filled` instead of the raw `nf_2var_exist_formula_prior`. OR, have `nf_2var_exist_formula_prior` take the ih_char/ih_exist/ih_all_char as additional parameters rather than passing sorry.

### Priority

The NfCharFormula:651 sorry is an INDEPENDENT fix from the PriorComposition sorry. Both must be fixed for the full pipeline to be sorry-free. However, the NfCharFormula fix is much simpler (~20-50 lines of restructuring) compared to the PriorComposition fix (~600-900 lines of new proof).

## 11. Recommended Next Steps

1. **Restructure `prior_nonconstenv_2var_agree_until/since`** to use `Nat.strong_induction_on (K + 2)`:
   - Factor out `strong_prior_nonconstenv_2var_agree_until_aux` with D parameter
   - Original theorem becomes thin wrapper with D = K+2

2. **Implement zone-based 3-var existential transfer**:
   - Zone 1,5: use `cross_extend_bwd_1var` + constenv_2var_determines
   - Zone 2,4: trivial witnesses
   - Zone 3: Prior-UZ/SZ squeeze + recursive depth argument

3. **Fix NfCharFormula.lean:651** by restructuring `nf_characterizable_temporal_prior_classical` to use `nf_2var_exist_formula_prior_filled` from kamp_mutual_induction (or inline the mutual induction's ExistPart).

4. **Verify**: `lake build` with 0 sorry in the Kamp pipeline.

## 12. File-Level Changes Required

| File | Change | Lines |
|------|--------|-------|
| PriorComposition.lean | Restructure to strong D-induction + implement zone-3 | +600-900 |
| NfCharFormula.lean | Fix line 651 sorry (pass correct arguments or restructure) | +20-50 |
| KampMutualInduction.lean | No changes needed | 0 |
| KampBypass.lean | No changes needed (already sorry-free) | 0 |
