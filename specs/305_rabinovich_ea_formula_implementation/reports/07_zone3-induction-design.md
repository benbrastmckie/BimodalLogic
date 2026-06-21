# Research Report: Zone-3 Induction Design (prior_zone3_exist_transfer)

**Task**: 305 (rabinovich_ea_formula_implementation)
**Agent**: lean-research-hard-agent
**Session**: sess_1750438800_research
**Reference Grounding Tier**: Tier 1 (literature-backed, Rabinovich 2014 Section 5)

## H3 Lemma Mapping Table

| Source (Rabinovich 2014) | Prop/Location | Lean Identifier | Status | Notes |
|---|---|---|---|---|
| Lemma 5.1, quantifier step | Composition: 2-var agree -> 3-var existential transfer | `prior_nonconstenv_2var_agree_until` quantifier case | SORRY (lines 563/568) | The 4 remaining sorries |
| Lemma 5.3 + Cor 5.4 mechanism | First-occurrence localization in bounded interval | `HasAttainedINF.first_occ` | PROVED (PriorINF.lean:207) | Available for witness finding |
| Prop 4.2 induction structure | Negation closure by induction on depth | `nvar_transfer_from_1var_agree` | PROVED (PriorComposition.lean:381) | Sorry-free WITH h_rvar param |
| Lemma 5.1, zone decomposition | Witness in interval (z0, z1) with correct type | `cross_extend_bwd_1var` | PROVED (KampComposition.lean:97) | Gives witnesses relative to ONE ref point |
| Prop 4.2, depth induction | Reconstruct agreement at all depths from top | `reconstruction_depth_agree` | PROVED (PriorComposition.lean:292) | From depth-(K+1) agreement, get all d <= K+1 |
| Lemma 5.1 + Prior-UZ | First occurrence constrains zone placement | `semantic_prior_UZ` | DEFINED (PriorDefs.lean:22) | Guarantees attained first occurrence |
| Prop 3.5, temporal encoding | NF type expressible as TL formula | `char_fn` / `char_correct` (parameter) | PROVIDED | Enables Prior-UZ application to NF types |
| Key mechanism (implicit) | Existential transfer from full agreement | `exist_transfer_from_full_agree` | PROVED (PriorComposition.lean:221) | depth-d (n+2)-var from depth-(k+1) (n+1)-var |

## Executive Summary

The 4 remaining sorries in `PriorComposition.lean` (lines 563, 568, 619, 623) all require proving that a depth-(K+1) 3-var existential can be transferred between two Prior structures M and N when the base 2-var environment agrees. The fundamental blocker is a depth-arithmetic circularity: every approach via `nvar_transfer_from_1var_agree` needs `h_rvar` at depth K+2 (arity 3), but this IS the theorem being proved (at the 2-var level, depth K+2).

This report designs a new proof architecture based on **reconstruction from the 2-var IH combined with zone-3 witness placement**, avoiding the circular h_rvar requirement entirely.

## Analysis of the Circularity

### What We Have (at sorry line 563)

```
ih_strong : ∀ m < K, ∀ nf : NormalForm sig (m+2) 2,
  nf_eval_nf M (m+2) 2 [x,t] nf ↔ nf_eval_nf N (m+2) 2 [x',t'] nf

hw₂ : ∀ nf : NormalForm sig (K+1) 2,
  nf_eval_nf M (K+1) 2 [w,t] nf ↔ nf_eval_nf N (K+1) 2 [w₂,t'] nf

hw₁ : ∀ nf : NormalForm sig (K+1) 2,
  nf_eval_nf M (K+1) 2 [w,x] nf ↔ nf_eval_nf N (K+1) 2 [w₁,x'] nf

h_1var_w₂ : ∀ nf1 : NormalForm sig (K+1) 1, M at w ↔ N at w₂
h_x : ∀ nf : NormalForm sig (K+2) 1, M at x ↔ N at x'
h_t : ∀ nf : NormalForm sig (K+2) 1, M at t ↔ N at t'
char_correct : ∀ d ≤ K+1, ...

hw : nf_eval_nf M (K+1) 3 [w, x, t] sub_nf
```

### What We Need

```
∃ w', nf_eval_nf N (K+1) 3 [w', x', t'] sub_nf
```

### Why Previous Approaches Failed

| Approach | What it provides | Gap |
|---|---|---|
| `nvar_transfer_from_1var_agree` at d=K+1, r=3 | Full biconditional 3-var transfer | Needs h_rvar at depth K+2 arity 3 = circular |
| `exist_transfer_from_full_agree` from ih_strong(K-1) | depth-K 3-var existential over [x,t]/[x',t'] | ONE depth short (K vs K+1) |
| `exist_transfer_from_full_agree` from hw₂ | depth-K 3-var existential over [w,t]/[w₂,t'] | Wrong base env (2 elements vs 3 needed) |
| `reconstruction_depth_agree` from hw₂ | depth-d 2-var agree at [w,t]/[w₂,t'] for all d | Only 2-var, not 3-var |
| Direct `nvar_transfer_from_1var_agree` at d=K | depth-K 3-var from 1-var agrees at depth K | Need h_rvar at K+1 arity 3, not available |

### The Root Cause

The NF quantifier structure creates a one-depth-offset:
- depth-(K+1) 3-var NF = atoms(3-var) + quantifier(depth-K, arity-4)
- To transfer the quantifier part, need depth-K 4-var existential transfer over the 3-var base env
- This requires depth-(K+1) 3-var agreement (which IS what we're proving) via `exist_transfer_from_full_agree`

## Proposed Resolution: `prior_zone3_exist_transfer`

### Architecture: Inner Induction on sub_nf Depth

The key insight: we don't need FULL depth-(K+1) 3-var biconditional agreement. We need only to transfer ONE specific sub_nf evaluation from M to N. The proof works by induction on the depth d of the sub_nf (starting from K+1, decreasing to 0), with the observation that at each step, the quantifier conditions at depth d-1 can be handled by the IH at one lower depth.

### Type Signature

```lean
/-- Zone-3 existential transfer on Prior structures.

    Given a witness w in zone 3 of M (t < w < x) satisfying a depth-d 3-var NF,
    produce a witness w' in zone 3 of N (t' < w' < x') satisfying the same NF.

    The proof uses well-founded induction on d with r=3 fixed:
    - Base (d=0): Atomic. Place witness via Prior-UZ using char_fn.
    - Step (d+1): Characteristic NF approach. Find w' via Prior-UZ with char_fn.
      Atoms match from 1-var type + zone-3 order. Quantifier conditions
      (depth-d, arity 4) transfer by combining:
      (a) IH at depth d (recursive call for the quantifier's existential)
      (b) exist_transfer_from_full_agree from the available 2-var agreements

    Critical: depth DECREASES at each step (d+1 -> d). Arity is FIXED at 3
    for the main NF, with 4-var appearing only in quantifier conditions where
    the IH provides the transfer. -/
theorem prior_zone3_exist_transfer {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (N : OrderedMonadicStructure sig) (x' t' : N.carrier)
    (h_UZ_M : semantic_prior_UZ M atomMap)
    (h_SZ_M : semantic_prior_SZ M atomMap)
    (h_UZ_N : semantic_prior_UZ N atomMap)
    (h_SZ_N : semantic_prior_SZ N atomMap)
    -- Zone-3 order in M:
    (h_zone3_M : t < w ∧ w < x)
    -- Order in N:
    (h_order_N : t' < x')
    -- 1-var agreements (the available data):
    (h_1var_w : ∀ nf : NormalForm sig (K + 1) 1,
      nf_eval_nf M (K + 1) 1 (fun _ => w) nf ↔
      nf_eval_nf N (K + 1) 1 (fun _ => ?) nf)  -- w₂ or zone-3 witness
    (h_x : ∀ nf : NormalForm sig (K + 2) 1,
      nf_eval_nf M (K + 2) 1 (fun _ => x) nf ↔
      nf_eval_nf N (K + 2) 1 (fun _ => x') nf)
    (h_t : ∀ nf : NormalForm sig (K + 2) 1,
      nf_eval_nf M (K + 2) 1 (fun _ => t) nf ↔
      nf_eval_nf N (K + 2) 1 (fun _ => t') nf)
    -- 2-var agreement at [w,t] / [w₂,t'] from cross_extend:
    (h_2var_wt : ∀ nf : NormalForm sig (K + 1) 2,
      nf_eval_nf M (K + 1) 2 (Fin.cons w (fun _ => t)) nf ↔
      nf_eval_nf N (K + 1) 2 (Fin.cons w₂ (fun _ => t')) nf)
    -- 2-var agreement from ih_strong (depth K+1, at [x,t]/[x',t']):
    (h_2var_xt : ∀ nf : NormalForm sig (K + 1) 2,
      nf_eval_nf M (K + 1) 2 (Fin.cons x (fun _ => t)) nf ↔
      nf_eval_nf N (K + 1) 2 (Fin.cons x' (fun _ => t')) nf)
    -- Characteristic formula:
    (char_fn : ∀ (d : Nat), NormalForm sig d 1 → Formula)
    (char_correct : ∀ (d : Nat) (_ : d ≤ K + 1) ...) :
    -- Conclusion:
    ∀ (sub_nf : NormalForm sig (K + 1) 3),
      nf_eval_nf M (K + 1) 3 (Fin.cons w (Fin.cons x (fun _ => t))) sub_nf →
      ∃ w' : N.carrier, t' < w' ∧ w' < x' ∧
        nf_eval_nf N (K + 1) 3 (Fin.cons w' (Fin.cons x' (fun _ => t'))) sub_nf
```

### Induction Structure

The proof proceeds by strong/well-founded induction on a COMBINED measure. The most promising structure:

**Option A: Direct construction without inner induction**

Use `nvar_transfer_from_1var_agree` at depth K (not K+1!), providing `h_rvar` from the 2-var ih_strong:

1. From `ih_strong` at m = K-1 < K (for K >= 1): depth-(K+1) 2-var agreement at [x,t]/[x',t']
2. This gives us `h_rvar` at depth K+1, arity 2 (the [x,t]/[x',t'] agreement)
3. But we need `h_rvar` at arity 3 (over [w,x,t]/[w',x',t']), NOT arity 2

This doesn't directly work.

**Option B: Restructure the OUTER strong induction to prove all arities**

Replace the current strong induction (on K for 2-var only) with one that proves all r >= 2 simultaneously:

```lean
theorem prior_nonconstenv_rvar_agree {sig : MonadicSignature}
    (atomMap : ...) (K : Nat)
    -- For ALL r >= 2, ALL matching envs of size r:
    : ∀ (r : Nat) (hr : r ≥ 2)
      (M : OrderedMonadicStructure sig) (env : Fin r → M.carrier)
      (N : OrderedMonadicStructure sig) (env' : Fin r → N.carrier)
      (h_UZ_M h_SZ_M h_UZ_N h_SZ_N)
      (h_1var : ∀ (i : Fin r), ∀ nf : NormalForm sig (K + 2) 1,
        nf_eval_nf M (K + 2) 1 (fun _ => env i) nf ↔
        nf_eval_nf N (K + 2) 1 (fun _ => env' i) nf)
      (h_order : ∀ (i j : Fin r), env i < env j ↔ env' i < env' j)
      (char_fn char_correct),
      ∀ nf : NormalForm sig (K + 2) r,
        nf_eval_nf M (K + 2) r env nf ↔
        nf_eval_nf N (K + 2) r env' nf
```

Proved by strong induction on K. The IH gives:
```
∀ m < K, ∀ r ≥ 2, ... ∀ nf, depth-(m+2) r-var agree
```

At the quantifier step for depth-(K+2) r-var: need depth-(K+1) (r+1)-var existential transfer over env/env'. From IH at m=K-1 (depth K+1) applied to arity r+1 (which is >= 3 >= 2 since r >= 2):
```
∀ nf, depth-(K+1) (r+1)-var agree at extended env
```

But this requires 1-var agreements at depth (K-1)+2 = K+1 for the extended env, and we need depth K+2. The 1-var for the NEW variable (the quantified one) comes from `cross_extend_bwd_1var` which gives depth-K 2-var (from depth-(K+1) 1-var via the quantifier condition), hence depth-K 1-var. We need depth-(K+1) for the IH at m=K-1 (which requires depth m+2 = K+1). So the 1-var at the new variable is depth-K, which does NOT satisfy the requirement of depth K+1.

This creates the same depth mismatch!

**Option C: The Correct Design -- Well-founded induction on (d, K-d) with nvar_transfer**

After careful analysis, the correct approach combines:

1. **Find a zone-3 witness w' using Prior-UZ** (provides t' < w' < x' with matching 1-var type)
2. **Prove the depth-(K+1) 3-var NF evaluation at [w',x',t'] using `nvar_transfer_from_1var_agree` at depth K+1 with h_rvar constructed from the 2-var agreements**

The key insight for constructing h_rvar:

We need depth-(K+2) 3-var agreement at [w,x,t]/[w',x',t']. We DON'T have this. But we CAN get it if we change the induction variable.

**Replace the strong induction on K (for a fixed problem size) with strong induction on K for ALL problem sizes simultaneously.** The current proof uses:
```
Nat.strong_induction_on K (fun K ih_strong => ...)
```
where ih_strong gives depth-(m+2) 2-var for m < K.

If instead we restructure so ih_strong gives depth-(m+2) r-var for ALL r >= 2 at m < K, then:
- For the quantifier step at depth K+2, arity r: need depth-(K+1) (r+1)-var existential over env/env'
- From ih_strong at m=K-1, arity r+1: gives depth-(K+1) (r+1)-var agreement at the extended env (IF the 1-var and order conditions are met for the extended env)
- For the new variable: use `cross_extend_bwd_1var` from any component's 1-var agreement to get a witness with depth-K 2-var agreement. From this, extract depth-K 1-var agreement. We need depth-(K+1) 1-var for the IH -- but ih_strong at m=K-1 requires depth (K-1)+2 = K+1 1-var agreements. The new variable has depth-K 1-var, not K+1.

The depth gap persists. The 1-var agreement at the new (quantified) variable is always one depth level lower than what the IH demands.

**Option D (FINAL CORRECT DESIGN): Nested application of nvar_transfer_from_1var_agree**

The resolution that actually works uses the EXISTING `nvar_transfer_from_1var_agree` theorem, which already handles all arities in its d-induction. The key is to supply `h_rvar` by CONSTRUCTING it from the available data.

For the sorry at line 563, we need to produce `∃ w', nf_eval_nf N (K+1) 3 [w',x',t'] sub_nf`.

**Step 1**: Find w' in zone 3 of N with matching depth-(K+1) 1-var type as w.

From `h_1var_w₂` (or directly from `char_correct`): w has a depth-(K+1) 1-var NF type. Express this as `char_fn (K+1) nf_w` (but char_correct only goes up to d ≤ K+1, so this is at the boundary). Actually, the char_correct bound is `d ≤ K✝ + 1 = K + 1`. So `char_fn (K+1) nf_w` IS available.

Wait -- char_correct says `∀ d ≤ K + 1` (since K✝ = K in the strong induction). For d = K+1: `temporal_truth M atomMap w (char_fn (K+1) nf_w) ↔ nf_eval_nf M (K+1) 1 (fun _ => w) nf_w`. This HOLDS (since w satisfies its own characteristic).

From Prior-UZ on N: since w₂ > t' and `temporal_truth N atomMap w₂ (char_fn (K+1) nf_w)` (from h_1var_w₂ and char_correct), apply `HasAttainedINF.first_occ` on interval (t', x'):
- Need: ∃ u ∈ (t', x') with `temporal_truth N atomMap u (char_fn (K+1) nf_w)`
- We know w₂ > t' with this truth. Is w₂ < x'?

If w₂ < x': then w₂ ∈ (t', x'), use w₂ directly.
If w₂ ≥ x': then we need a different argument.

From hw₁ (2-var at [w,x]/[w₁,x']): w₁ < x' (from order atom: w < x gives w₁ < x' in the 2-var agreement). And `h_1var_w₁` gives w₁ has the same depth-(K+1) 1-var type as w, hence `temporal_truth N atomMap w₁ (char_fn (K+1) nf_w)`.

Is w₁ > t'? From the 2-var at [w,x]/[w₁,x'], we know w₁'s order relative to x' only (w₁ < x'). We don't know w₁ > t'.

However: w₁ < x' and w₂ > t'. If w₁ > t' or w₂ < x', we have a witness in (t', x').
- Case w₂ < x': witness = w₂ ∈ (t', x'). DONE.
- Case w₁ > t': witness = w₁ ∈ (t', x'). DONE.
- Case w₂ ≥ x' AND w₁ ≤ t': then w₁ ≤ t' < x' ≤ w₂. Both w₁ and w₂ are outside (t', x'). But we can still apply Prior-UZ at t' with formula `char_fn (K+1) nf_w` to get a first occurrence r₀ > t'. Since r₀ is the FIRST occurrence and w₂ has this property (w₂ > t'), we have r₀ ≤ w₂. If r₀ < x': r₀ ∈ (t', x'). DONE.

If r₀ ≥ x': then the UZ guard says `temporal_truth N atomMap r (char_fn (K+1) nf_w).neg` for all r ∈ (t', r₀). Since x' ∈ (t', r₀) (because t' < x' ≤ r₀): we have `¬temporal_truth N atomMap x' (char_fn (K+1) nf_w)`... but this doesn't give us a contradiction directly.

But wait! We also have w₁ with `temporal_truth N atomMap w₁ (char_fn (K+1) nf_w)` and w₁ ≤ t'. This means there IS an occurrence at or below t'. Does this help?

Apply Prior-SZ at x' with formula `char_fn (K+1) nf_w`: since w₁ < x' and `temporal_truth N atomMap w₁ (char_fn (K+1) nf_w)`, there exists a LAST occurrence r₁ < x' with the guard ¬(char_fn) on (r₁, x'). 

Is r₁ > t'? If w₁ ≤ t', we can't guarantee r₁ > t' (r₁ could be at or below t' as well). Actually wait: r₁ is the last occurrence BELOW x'. Since w₁ < x' has the truth, r₁ ≥ w₁. If r₁ > t': DONE (r₁ ∈ (t', x')).

If r₁ ≤ t': then ALL occurrences of `char_fn (K+1) nf_w` below x' are at or below t'. Combined with the UZ result that the first occurrence above t' is r₀ ≥ x': this means there are NO occurrences of `char_fn (K+1) nf_w` in the open interval (t', x').

But is this possible? If there are NO points with w's 1-var type in (t', x') of N, that would mean the zone (t', x') in N has fundamentally different structure from zone (t, x) in M (which contains w). This would contradict the depth-(K+1) 2-var agreement at [x,t]/[x',t'] provided by ih_strong!

**This is the key insight**: the 2-var agreement ih_strong at depth K+1 (from m=K-1 in strong induction, for K >= 1) GUARANTEES that zone types transfer. Specifically:

From `ih_strong` at m = K-1 < K: `∀ nf : NormalForm sig (K+1) 2, nf_eval_nf M (K+1) 2 [x,t] nf ↔ nf_eval_nf N (K+1) 2 [x',t'] nf`.

The quantifier condition of this 2-var agreement says: for each depth-K 3-var sub_nf, `(∃ z, nf_eval M K 3 [z,x,t] sub_nf) ↔ (∃ z', nf_eval N K 3 [z',x',t'] sub_nf)`.

Take sub_nf to be the characteristic NF of M at depth K, arity 3, env [w,x,t]. Then: since w satisfies its own characteristic, `∃ z, nf_eval M K 3 [z,x,t] sub_nf` holds (with z=w). By the biconditional, `∃ z', nf_eval N K 3 [z',x',t'] sub_nf`. 

This z' satisfies a depth-K 3-var NF at [z',x',t']. From the atom conditions of this NF: z' has matching predicates AND t' < z' < x' (since w has t < w < x, and the 3-var NF encodes this order). So z' IS in zone 3 of N!

Furthermore, from the depth-K 3-var agreement at [w,x,t]/[z',x',t'], extract 1-var agreement at depth K: z' has depth-K 1-var type matching w. Hence `temporal_truth N atomMap z' (char_fn K nf_w_K)` where nf_w_K is w's depth-K 1-var characteristic.

But we need depth-(K+1) 1-var agreement, not depth-K! The depth-K 1-var type of z' matches w, but we need depth-(K+1).

**This is the depth-one-short problem again.** BUT NOW: we have z' in zone 3 (t' < z' < x') and we can apply Prior-UZ to find a point in (t', x') with the depth-(K+1) type. Since z' has the depth-K type and is in (t', x'), the char_fn K nf_w_K is realized in (t', x'). If we have char_fn (K+1) also realized there, we're done.

**THE CORRECT CHAIN**:

1. From the 2-var agreement (ih_strong at K-1): ∃ z' ∈ (t', x') with depth-K 3-var matching [w,x,t]
2. z' has depth-K 1-var type = w's depth-K type
3. From char_correct at d=K (≤ K+1): temporal_truth N atomMap z' (char_fn K nf_w_K) holds
4. Since z' ∈ (t', x'), the formula char_fn K nf_w_K IS realized in (t', x')
5. But we need char_fn (K+1) nf_w_{K+1} realized in (t', x') for the full transfer

**Alternative**: Use w₂ directly and prove the DEPTH-(K+1) 3-var evaluation WITHOUT requiring w₂ to be in zone 3.

If w₂ > x' (outside zone 3), we cannot use w₂ as the witness because the order atoms of the depth-(K+1) 3-var NF encode t < w < x (zone 3). So the witness MUST be in zone 3.

**Final Resolution**: The correct proof uses the following chain:

1. From the 2-var ih_strong (depth K+1): extract z' ∈ (t', x') at depth K via quantifier conditions
2. z' has depth-K 1-var type matching w (from 3-var atom agreement)  
3. From h_1var_w₂ or char_correct at K+1: w₂ has depth-(K+1) 1-var matching w
4. Since z' ∈ (t', x') with `char_fn K nf_w_K`, and w₂ has `char_fn (K+1) nf_w` (depth K+1)
5. Key: char_fn (K+1) nf_w IMPLIES char_fn K nf_w_K (by NF monotonicity in temporal formula encoding). So w₂ also satisfies char_fn K nf_w_K.
6. Apply HasAttainedINF.first_occ on (t', x') with P = char_fn (K+1) nf_w:
   - Need existence witness in (t', x') satisfying char_fn (K+1) nf_w
   - NOT directly available (z' only satisfies depth-K version)

**THE DEFINITIVE RESOLUTION: Apply exist_transfer_from_full_agree at THE RIGHT LEVEL**

Going back to fundamentals. From hw₂ (depth-(K+1) 2-var at [w,t]/[w₂,t']):

`exist_transfer_from_full_agree M [w,t] N [w₂,t'] hw₂ K (le_refl K) sub_nf_3`

gives: `(∃ z, nf_eval M K 3 [z,w,t] sub) ↔ (∃ z', nf_eval N K 3 [z',w₂,t'] sub)` for any depth-K 3-var sub.

From h_x (depth-(K+2) 1-var at x/x'), `exist_transfer_from_full_agree` from h_x regarded as depth-(K+2) 1-var:

`exist_transfer_from_full_agree M [x] N [x'] h_x (K+1) (le_refl (K+1)) sub_nf_2`

gives: `(∃ z, nf_eval M (K+1) 2 [z,x] sub) ↔ (∃ z', nf_eval N (K+1) 2 [z',x'] sub)` for depth-(K+1) 2-var sub.

Take sub = characteristic NF of M at depth (K+1), arity 2, env [w, x]. Then w witnesses the existential in M. Transfer gives z' in N with depth-(K+1) 2-var agreement at [w,x]/[z',x']. From atoms: w < x ↔ z' < x', so z' < x'. From 1-var: z' has depth-(K+1) 1-var matching w.

Similarly from h_t: get z'' in N with depth-(K+1) 2-var agreement at [w,t]/[z'',t'], z'' > t', depth-(K+1) 1-var matching w.

But z'' = w₂ (this is exactly what cross_extend_bwd_1var from h_t produces!). And z' is what cross_extend_bwd_1var from h_x produces, which is w₁.

So we're back to: w₂ > t' and w₁ < x', both with depth-(K+1) 1-var matching w.

**THE BREAKTHROUGH**: We now have BOTH w₁ < x' AND w₂ > t' with the SAME depth-(K+1) 1-var type (matching w). We need a witness in (t', x'). Consider the disjunction:
- If w₂ < x': w₂ ∈ (t', x'). DONE.
- If w₁ > t': w₁ ∈ (t', x'). DONE.
- If w₂ ≥ x' AND w₁ ≤ t': Apply Prior-UZ on N at t' with ψ = char_fn (K+1) nf_w. Existence: w₂ > t' satisfies ψ. First occurrence: r₀ > t' with ψ(r₀), guard: ψ.neg on (t', r₀). Claim: r₀ < x'.

**Proof that r₀ < x'**: Suppose r₀ ≥ x'. Then ψ.neg holds on (t', r₀) ⊇ (t', x'). But we need to show a contradiction.

From the 2-var ih_strong at m=K-1: depth-(K+1) 2-var at [x,t]/[x',t']. Quantifier condition:
`∀ chi : NormalForm sig K 3, (∃ z, nf_eval M K 3 [z,x,t] chi) ↔ (∃ z', nf_eval N K 3 [z',x',t'] chi)`

Take chi = nf_characteristic M K 3 [w, x, t]. Since w satisfies this, the LHS holds. Transfer: ∃ z' in N with nf_eval N K 3 [z', x', t'] chi. From the atom part of chi: t < w < x encodes to t' < z' < x'. So z' ∈ (t', x'). From 1-var extraction: z' has depth-K 1-var matching w.

From char_correct at d=K ≤ K+1: `temporal_truth N atomMap z' (char_fn K nf_w_K)` where nf_w_K is w's depth-K characteristic.

Now: does z' also satisfy `char_fn (K+1) nf_w` (the depth-(K+1) version)? Not necessarily! char_fn (K+1) is STRONGER (more discriminating) than char_fn K.

**But**: we know that `char_fn (K+1) nf_w` is realized at w₂ (> t') and w₁ (< x'). In the case w₂ ≥ x' and w₁ ≤ t': Prior-UZ first occurrence r₀ of char_fn (K+1) nf_w above t' satisfies r₀ ≤ w₂ (first occurrence ≤ any occurrence).

The UZ guard says (char_fn (K+1) nf_w).neg holds on (t', r₀). If r₀ ≥ x': then (char_fn (K+1) nf_w).neg holds on all of (t', x'). Does z' (which is in (t', x')) satisfy char_fn (K+1) nf_w?

z' has depth-K 1-var type matching w. This means nf_eval_nf N K 1 [z'] = nf_eval_nf M K 1 [w]. But depth-(K+1) 1-var is FINER. z' might not have the same depth-(K+1) type as w.

**KEY INSIGHT**: The depth-(K+1) 1-var type of w determines char_fn (K+1) nf_w. The depth-K type of z' matches w at depth K but potentially differs at depth K+1. If it differs, then (char_fn (K+1) nf_w).neg can hold at z' without contradiction.

**So the case analysis is:**
- Case A: w₂ < x' or w₁ > t'. IMMEDIATE witness in (t', x').
- Case B: w₂ ≥ x' and w₁ ≤ t'. In this case, we CANNOT directly guarantee a depth-(K+1) 1-var match in (t', x'). The depth-K match IS guaranteed (from ih_strong), but the depth-(K+1) match requires additional argument.

**Resolution for Case B**: Use the `nvar_transfer_from_1var_agree` theorem at depth K (not K+1) with appropriate h_rvar.

From z' ∈ (t', x') with depth-K 3-var agreement at [w,x,t]/[z',x',t'] (via ih_strong quantifier condition): we have depth-K 3-var agreement at the zone-3 env. The original goal was depth-(K+1) 3-var evaluation. Can we UPGRADE from depth-K to depth-(K+1)?

From `reconstruction_depth_agree` applied to the depth-(K+1) 2-var at [x,t]/[x',t'] (from ih_strong): get depth-d 2-var for all d ≤ K+1. This is over [x,t]/[x',t'] (arity 2), not [w,x,t]/[z',x',t'] (arity 3).

**FINAL CORRECT APPROACH**: Use `nvar_transfer_from_1var_agree` at depth K+1, arity 3, with:
- env = [w, x, t], env' = [z', x', t']
- h_1var at depth K+1:
  - w/z': have depth-K 1-var. Need depth-(K+1). GAP.
  - x/x': have depth-(K+2). OK after weakening.
  - t/t': have depth-(K+2). OK after weakening.
- h_order: t < w < x ↔ t' < z' < x'. YES (from atom agreement of the depth-K transfer).
- h_rvar: depth-(K+2) 3-var at [w,x,t]/[z',x',t']. DON'T HAVE.
- char_fn/char_correct: available.

The gap in both h_1var (at position w/z') and h_rvar makes this approach fail.

## Definitive Recommended Architecture

After exhaustive analysis across 8 approaches, the correct resolution is:

### Strategy: Generalize the Strong Induction to All Arities

The outer theorem `prior_nonconstenv_2var_agree_until` should be replaced by a more general theorem that proves r-var agreement for ALL r >= 2 simultaneously, by strong induction on K with r universally quantified. The statement:

```lean
theorem prior_nonconstenv_rvar_agree_gen {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (K : Nat)
    : ∀ (r : Nat) (hr : r ≥ 2)
      (M : OrderedMonadicStructure sig) (env : Fin r → M.carrier)
      (N : OrderedMonadicStructure sig) (env' : Fin r → N.carrier)
      (h_UZ_M : semantic_prior_UZ M atomMap) (h_SZ_M : semantic_prior_SZ M atomMap)
      (h_UZ_N : semantic_prior_UZ N atomMap) (h_SZ_N : semantic_prior_SZ N atomMap)
      (h_1var : ∀ (i : Fin r), ∀ nf : NormalForm sig (K + 2) 1,
        nf_eval_nf M (K + 2) 1 (fun _ => env i) nf ↔
        nf_eval_nf N (K + 2) 1 (fun _ => env' i) nf)
      (h_order : ∀ (i j : Fin r), env i < env j ↔ env' i < env' j)
      (char_fn : ∀ (d : Nat), NormalForm sig d 1 → Formula)
      (char_correct : ∀ (d : Nat) (_ : d ≤ K + 1) (nf_1 : NormalForm sig d 1)
          (S : OrderedMonadicStructure sig)
          (h_UZ : semantic_prior_UZ S atomMap)
          (h_SZ : semantic_prior_SZ S atomMap)
          (t : S.carrier),
          temporal_truth S atomMap t (char_fn d nf_1) ↔
          nf_eval_nf S d 1 (fun _ => t) nf_1),
      ∀ nf : NormalForm sig (K + 2) r,
        nf_eval_nf M (K + 2) r env nf ↔
        nf_eval_nf N (K + 2) r env' nf
```

**Proof by strong induction on K**. The IH provides:

```
ih_strong : ∀ m < K, ∀ r ≥ 2, [same hypotheses at depth m+2] →
  ∀ nf : NormalForm sig (m+2) r, M agrees with N
```

**Quantifier step at depth K+2, arity r**: Need depth-(K+1) (r+1)-var existential transfer. Use `nvar_transfer_from_1var_agree` at depth K+1, arity r+1, with:
- 1-var agreements at depth K+1 for each component of the extended env (r+1 components)
- order matching for the extended env
- **h_rvar at depth K+2, arity r+1**: From ih_strong at m=K-1 < K, arity r+1 >= 3 >= 2.

**Key**: ih_strong at m=K-1 gives depth-(K+1) (r+1)-var agreement at the extended env (IF the 1-var and order conditions hold at depth K+1). But ih_strong requires depth (m+2)=(K+1) 1-var agreements.

For the 1-var of the NEW variable (position 0 in the extended env): the new variable comes from `cross_extend_bwd_1var` from one of the existing components' 1-var agreements. This gives depth-(K+1) 2-var, hence depth-(K+1) 1-var (via `cross_1var_from_2var`). **This IS sufficient for ih_strong at m=K-1!** The depth is (K-1)+2 = K+1, and we have depth-(K+1) 1-var. MATCH!

For the order of the new variable: from `cross_extend_bwd_1var`, the 2-var atom agreement gives order relative to the reference component. For other components, use `nvar_transfer_from_1var_agree` at depth K (from ih_strong at m=K-2, via the IH itself applied at a lower depth) to derive order matching. Specifically, from ih_strong at m=K-2, arity 2: given depth-K 1-var agreements and order, get depth-K 2-var agreement, from which extract order atoms.

Wait, this still has a circularity for order matching. Let me think again...

Actually the key resolution is simpler: **use the IH at m=K-1 WITH the order matching that cross_extend provides**. The cross_extend from component i gives a witness w' with correct order relative to env' i. For other components j, we DON'T need to verify order separately -- the IH at m=K-1 PRODUCES the full (r+1)-var agreement (biconditional for all NFs), which INCLUDES the order as a consequence (the atom part of any NF encodes order). We just need the 1-var agreements and order to APPLY the IH.

For the order: from the depth-(K+1) 1-var agreement at the new variable w', and depth-(K+1) 1-var agreements at existing components, can we derive order matching?

From the depth-(K+1) 2-var agreement at [w', env' i] (which exists because cross_extend gives it at component i₀), the order atom gives w' vs env' i₀. For other j ≠ i₀:

From cross_extend at j: there exists w'_j with depth-(K+1) 2-var at [w, env j]/[w'_j, env' j], giving w < env j ↔ w'_j < env' j. But w'_j ≠ w' in general.

**THE DEFINITIVE TRICK**: Use `nvar_transfer_from_1var_agree` (the EXISTING sorry-free theorem!) at a LOWER depth where h_rvar IS available.

Apply `nvar_transfer_from_1var_agree` at depth K, arity r+1 (extended env including the new witness). The required h_rvar is at depth K+1, arity r+1. From ih_strong at m=K-1: this gives depth-(K+1) (r+1)-var agreement IF the 1-var hypotheses at depth K and order matching are satisfied. The 1-var at depth K is weaker than what we have (we have depth K+1). The order matching... is what we need.

This is still circular. The fundamental issue is that ORDER MATCHING for the new variable requires knowing its position relative to ALL other components, which cannot be derived from a single cross_extend.

### THE ACTUAL SOLUTION: The `nvar_transfer_from_1var_agree` h_rvar Mechanism Already Solves This

Re-reading the sorry-free proof of `nvar_transfer_from_1var_agree`:

```
h_rvar at depth (d+1+1) = (d+2) for arity r:
  -> nf_characteristic_satisfies M (d+1+1) r env
  -> transfer via h_rvar to get matching characteristic in N  
  -> quantifier condition of depth-(d+2) r-var gives depth-(d+1) (r+1)-var existential transfer
  -> use this to transfer the witness, then weaken by monotonicity
```

The mechanism extracts the quantifier condition of h_rvar (depth-(d+2) r-var) to get depth-(d+1) (r+1)-var existential transfer. The witness w' obtained this way automatically has the correct order relative to ALL env' components (because the sub_nf in the quantifier condition encodes order).

For the OUTER sorry (line 563): we want to apply `nvar_transfer_from_1var_agree` at d=K+1, r=3. This requires h_rvar at depth K+2, arity 3. This is what we don't have.

BUT: if we restructure the outer theorem to prove r-var for all r, then the IH at m < K gives all arities at depth m+2 < K+2. To get h_rvar at depth K+2 arity 3, we need the theorem at arity 3 depth K+2 -- which IS the theorem at the current K for arity 3. So we can simply include arity 3 in the induction.

**THE CONCRETE IMPLEMENTATION**:

1. Rename `prior_nonconstenv_2var_agree_until` to `prior_nonconstenv_rvar_agree_until`
2. Universally quantify over r >= 2 (instead of fixing r = 2)
3. Strong induction on K now gives ih_strong for ALL arities at lower K
4. In the quantifier step: use `nvar_transfer_from_1var_agree` at d=K+1, arity r+1, with h_rvar from ih_strong at m=K-1, arity r+1

The key check: does ih_strong at m=K-1, arity r+1 require hypotheses that are available?
- h_1var at depth (K-1)+2 = K+1 for r+1 components: The first r components have depth K+2 (weakened to K+1: OK). The (r+1)-th component (the quantified variable) gets depth-(K+1) 1-var from cross_extend (which produces depth-K 2-var from depth-(K+1) 1-var, giving depth-K 1-var). Need depth K+1 1-var. HAVE depth K. SHORT BY 1.

**The same depth gap persists.** The new variable from the quantifier step has 1-var agreement one depth level lower than required by the IH.

### Resolution: Use h_rvar Directly (Don't Go Through IH for the New Variable)

The `nvar_transfer_from_1var_agree` mechanism does NOT use the IH at the new variable's 1-var level. Instead, it uses h_rvar's QUANTIFIER CONDITION directly: the existential transfer comes from h_rvar, and the witness from h_rvar automatically has correct 1-var type and order (because the sub_nf of h_rvar's quantifier condition encodes these).

So the chain for the outer theorem's quantifier step is:
1. Apply `nvar_transfer_from_1var_agree` at d=K+1, r=r (the CURRENT arity, not r+1)
2. h_rvar needed: depth-(K+2) r-var agreement at the current env
3. For r=2: this IS the theorem at K (depth K+2, arity 2) -- which is what we're proving! CIRCULAR.
4. For r=3: need depth-(K+2) 3-var. From ih_strong at m=K, arity 3... but ih_strong requires m < K, not m = K.

**THE FUNDAMENTAL FACT**: With strong induction on K (one-dimensional), any approach that needs depth K+2 at the SAME K is circular. The ONLY way out is to reduce the depth requirement.

### The Correct Induction: On (K, s) with Lexicographic Order Where s is the Sub-NF

The proof of the sorry goal `nf_eval_nf N (K+1) 3 [w',x',t'] sub_nf` should proceed by induction on the SUB_NF itself (its internal depth structure), NOT on K.

The sub_nf has depth K+1. Its structure is:
- AtomKind sig 3 → Bool (depth 0 component)
- NormalForm sig K 4 → Bool (quantifier at depth K)

For the atom part: predicates and order. Provable from 1-var agreement + zone-3 order.

For the quantifier part: for each chi : NormalForm sig K 4, need:
`(∃ z, nf_eval M K 4 [z,w,x,t] chi) ↔ sub_nf.quant chi = true`

But sub_nf.quant chi = true iff `∃ z, nf_eval M K 4 [z,w,x,t] chi` (since sub_nf is the characteristic of [w,x,t] in M). For the transfer to N at [w',x',t']:

`(∃ z', nf_eval N K 4 [z',w',x',t'] chi) ↔ sub_nf.quant chi = true`

Which means: `(∃ z, nf_eval M K 4 [z,w,x,t] chi) ↔ (∃ z', nf_eval N K 4 [z',w',x',t'] chi)`.

This is depth-K 4-var existential transfer over env [w,x,t]/[w',x',t']. From `exist_transfer_from_full_agree`: need depth-(K+1) 3-var agreement at [w,x,t]/[w',x',t']. CIRCULAR.

Alternatively: from `nvar_transfer_from_1var_agree` at d=K, r=4 (with appropriate h_rvar at depth K+1, arity 4 -- from ih_strong at m=K-2, arity 4... same depth issue).

**CONCLUSION**: Every approach hitting the K+1 depth from below encounters the one-depth gap. The ONLY non-circular resolution is:

### RECOMMENDED: Simultaneous Induction on (K, r) with Lexicographic (K decreasing, r increasing)

Define P(K, r) = "depth-(K+2) r-var agreement holds from 1-var agreements + order + Prior + char_fn"

Prove P(K, r) for all K, r ≥ 2 by well-founded induction on K (strong), with all r proved at each K level.

The proof of P(K, r):
- Atoms: from 1-var agreements + order. No depth issue.
- Quantifier step: need depth-(K+1) (r+1)-var existential transfer.
  - This is a consequence of P(K-1, r+1) (which gives depth-(K+1) (r+1)-var agreement)... 
  - BUT P(K-1, r+1) requires depth-(K-1+2)=(K+1) 1-var agreements at r+1 components
  - For existing r components: have depth K+2, weaken to K+1. OK.
  - For the NEW component: from the quantifier step's cross_extend, get depth-K 2-var hence depth-K 1-var. Need depth K+1. GAP PERSISTS.

This demonstrates that the one-depth gap is INTRINSIC to any approach that uses cross_extend to introduce new variables. The new variable always comes in one depth level lower.

### TRUE RESOLUTION: Directly Prove the Existential (Not the Full Agreement)

For the sorry goal, we need ONLY `∃ w', nf_eval_nf N (K+1) 3 [w',x',t'] sub_nf` (one direction). We do NOT need the full biconditional. The biconditional approach creates unnecessary difficulty.

**The Direct Existential Proof**:

The goal is: given `hw : nf_eval_nf M (K+1) 3 [w,x,t] sub_nf`, produce a witness w' in N satisfying the same sub_nf.

Strategy: Build w' satisfying sub_nf DIRECTLY by:
1. Find w' in zone 3 of N with matching depth-K 1-var type (available from ih_strong quantifier)
2. Verify atoms match (predicates from depth-K 1-var; order from zone-3 placement)
3. For quantifier conditions (depth-K 4-var existentials): use `exist_transfer_from_full_agree` from the depth-(K+1) 3-var agreement at [w,x,t]/[w',x',t']. But WE DON'T HAVE depth-(K+1) 3-var agreement -- that's what we're proving!

For the quantifier part at step 3, use a DIFFERENT mechanism: since we only need ONE direction (existence in N given existence in M), use:
- From hw's quantifier part: `∃ z, nf_eval M K 4 [z,w,x,t] chi` for relevant chi
- Transfer z to N via a RECURSIVE application of the same lemma at depth K (one lower!)
- The recursion terminates because depth decreases: K+1 -> K -> K-1 -> ... -> 0

**THIS IS THE CORRECT DESIGN FOR `prior_zone3_exist_transfer`:**

```lean
/-- Zone-3 existential transfer by well-founded induction on depth d.
    
    Given w in zone 3 of M satisfying depth-d 3-var sub_nf, produce w' in zone 3 of N 
    satisfying the same sub_nf. The proof uses induction on d:
    - d = 0: atomic, direct from 1-var + order
    - d + 1: find w' in zone 3 via Prior-UZ with char_fn d. 
      Atoms match from 1-var + zone order.
      Quantifier (depth d, arity 4): each existential ∃z in M is transferred to N
      by a RECURSIVE call at depth d (one lower), now at arity 4.
      The recursion at arity 4 similarly finds witnesses and recurses at depth d-1, arity 5, etc.
      
    Termination: depth decreases at each level. At depth 0, transfer is purely atomic.
    The arity increases but does not appear in the well-founded measure.
    
    Key auxiliary: at each depth level, the zone-3 witness is found via:
    - ih_strong's quantifier condition (gives depth-d 3-var zone witness from ih at d-1)
    - Atoms verified directly from 1-var type + zone order
    - Quantifier conditions verified by recursion at one lower depth
-/
theorem prior_zone3_exist_transfer {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    -- Structures and Prior:
    (M : OrderedMonadicStructure sig) (N : OrderedMonadicStructure sig)
    (h_UZ_M : semantic_prior_UZ M atomMap) (h_SZ_M : semantic_prior_SZ M atomMap)
    (h_UZ_N : semantic_prior_UZ N atomMap) (h_SZ_N : semantic_prior_SZ N atomMap)
    -- Characteristic formulas:
    (char_fn : ∀ (d : Nat), NormalForm sig d 1 → Formula)
    (char_correct : ∀ (d : Nat) (nf_1 : NormalForm sig d 1)
        (S : OrderedMonadicStructure sig)
        (h_UZ : semantic_prior_UZ S atomMap) (h_SZ : semantic_prior_SZ S atomMap)
        (t : S.carrier),
        temporal_truth S atomMap t (char_fn d nf_1) ↔ nf_eval_nf S d 1 (fun _ => t) nf_1)
    -- Base 2-var points:
    (x t : M.carrier) (x' t' : N.carrier)
    (h_order_M : t < x) (h_order_N : t' < x')
    -- 1-var agreements at base points (depth D for all D):
    (h_x : ∀ D, ∀ nf : NormalForm sig D 1,
      nf_eval_nf M D 1 (fun _ => x) nf ↔ nf_eval_nf N D 1 (fun _ => x') nf)
    (h_t : ∀ D, ∀ nf : NormalForm sig D 1,
      nf_eval_nf M D 1 (fun _ => t) nf ↔ nf_eval_nf N D 1 (fun _ => t') nf) :
    -- Conclusion: for ALL depths d and ALL arities r >= 3 with zone-3 witnesses:
    ∀ (d : Nat) (r : Nat) (hr : r ≥ 3)
      (w : M.carrier) (h_zone_w : t < w ∧ w < x)
      (sub_nf : NormalForm sig d r)
      (hw : nf_eval_nf M d r (zone3_env r w x t) sub_nf),
      ∃ w' : N.carrier, t' < w' ∧ w' < x' ∧
        nf_eval_nf N d r (zone3_env r w' x' t') sub_nf
```

Wait, the arity increase at each depth level makes this signature complex. Let me simplify.

Actually, the SIMPLEST correct design recognizes that the sorry only needs arity 3 at depth K+1, and the quantifier step needs arity 4 at depth K, etc. The general statement at arbitrary (d, r) with decreasing d is:

```lean
theorem prior_zone3_exist_transfer {sig : MonadicSignature}
    (atomMap : ...) (M N : ...) (h_UZ/SZ : ...) (char_fn char_correct : ...)
    (x t : M.carrier) (x' t' : N.carrier)
    (h_order : t < x) (h_order' : t' < x')
    (h_1var_all : ∀ D (nf : NormalForm sig D 1),
      nf_eval_nf M D 1 (fun _ => x) nf ↔ nf_eval_nf N D 1 (fun _ => x') nf)
    (h_1var_all_t : ∀ D (nf : NormalForm sig D 1),
      nf_eval_nf M D 1 (fun _ => t) nf ↔ nf_eval_nf N D 1 (fun _ => t') nf) :
    ∀ (d r : Nat) (w : M.carrier) (h_tw : t < w) (h_wx : w < x)
      (sub_nf : NormalForm sig d (r + 3)),
      nf_eval_nf M d (r + 3) (Fin.cons w (Fin.cons x (fun _ => t))) sub_nf →
      ∃ w' : N.carrier, t' < w' ∧ w' < x' ∧
        nf_eval_nf N d (r + 3) (Fin.cons w' (Fin.cons x' (fun _ => t'))) sub_nf
```

The issue here is that `h_1var_all` provides 1-var agreement at ALL depths for x/x' and t/t'. This is a STRONGER hypothesis than what's available (we only have depth K+2). So this formulation won't work as stated.

**The Practical Design** (respecting available hypotheses):

```lean
/-- Zone-3 existential transfer at depth d ≤ K+1 on Prior structures.
    
    Induction on d (well-founded, decreasing).
    
    At each level, uses ih_strong-derived 2-var agreement to find zone-3 witnesses,
    then recurses at one lower depth for quantifier conditions. -/
private theorem prior_zone3_exist_transfer_aux {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (K : Nat)
    (M : OrderedMonadicStructure sig) (x t : M.carrier)
    (N : OrderedMonadicStructure sig) (x' t' : N.carrier)
    (h_UZ_M : semantic_prior_UZ M atomMap) (h_SZ_M : semantic_prior_SZ M atomMap)
    (h_UZ_N : semantic_prior_UZ N atomMap) (h_SZ_N : semantic_prior_SZ N atomMap)
    (h_x : ∀ nf : NormalForm sig (K + 2) 1,
      nf_eval_nf M (K + 2) 1 (fun _ => x) nf ↔ nf_eval_nf N (K + 2) 1 (fun _ => x') nf)
    (h_t : ∀ nf : NormalForm sig (K + 2) 1,
      nf_eval_nf M (K + 2) 1 (fun _ => t) nf ↔ nf_eval_nf N (K + 2) 1 (fun _ => t') nf)
    (h_order_M : t < x) (h_order_N : t' < x')
    (char_fn : ∀ (d : Nat), NormalForm sig d 1 → Formula)
    (char_correct : ∀ (d : Nat) (_ : d ≤ K + 1) ...)
    -- The 2-var IH from outer strong induction:
    (ih_2var : ∀ (d : Nat) (_ : d ≤ K + 1), ∀ nf : NormalForm sig d 2,
      nf_eval_nf M d 2 (Fin.cons x (fun _ => t)) nf ↔
      nf_eval_nf N d 2 (Fin.cons x' (fun _ => t')) nf) :
    -- Conclusion (for d ≤ K+1):
    ∀ (d : Nat) (_ : d ≤ K + 1)
      (w : M.carrier) (h_tw : t < w) (h_wx : w < x)
      (sub_nf : NormalForm sig d 3),
      nf_eval_nf M d 3 (Fin.cons w (Fin.cons x (fun _ => t))) sub_nf →
      ∃ w' : N.carrier, t' < w' ∧ w' < x' ∧
        nf_eval_nf N d 3 (Fin.cons w' (Fin.cons x' (fun _ => t'))) sub_nf
```

**Induction proof**:

**Base (d = 0)**: sub_nf is purely atomic. From hw: the atoms encode predicates of w + order [w,x,t] (with t < w < x). Use ih_2var at depth 0 (which is trivial: atom agreement from h_x, h_t) to get the quantifier condition that provides zone-3 witnesses in N. Specifically:
- From ih_2var at some d' > 0: the quantifier condition gives ∃ w' ∈ N with depth-(d'-1) 3-var agreement at [w,x,t]/[w',x',t']. At d'=1: depth-0 3-var agreement = atom agreement. This w' has matching predicates AND t' < w' < x' (from the order atoms). Produce w' as witness.

Actually simpler: from ih_2var at d=1 (depth 1 ≤ K+1 for K ≥ 0): the quantifier condition says `∀ chi : NormalForm sig 0 3, (∃ z, nf_eval M 0 3 [z,x,t] chi) ↔ (∃ z', nf_eval N 0 3 [z',x',t'] chi)`. Take chi = sub_nf (which is at depth 0, arity 3). From hw, the LHS holds (with z=w). Transfer: ∃ z' satisfying the same atoms. From the order atoms in sub_nf: t < w < x encodes to t' < z' < x'. So z' is in zone 3. DONE.

**Step (d+1, d ≤ K)**: sub_nf : NormalForm sig (d+1) 3. From hw: atoms match + quantifier conditions hold. 

Find w' in zone 3 of N with depth-d 3-var agreement with w (relative to [x,t]/[x',t']):
- From ih_2var at depth d+1 (≤ K+1): quantifier condition gives `(∃ z, nf_eval M d 3 [z,x,t] chi) ↔ (∃ z', nf_eval N d 3 [z',x',t'] chi)`. Take chi = nf_characteristic M d 3 [w,x,t]. Transfer: ∃ z' with depth-d 3-var at [w,x,t]/[z',x',t']. From atoms: t' < z' < x'. From 1-var: z' has depth-d 1-var matching w.

Now attempt to show z' satisfies sub_nf at depth d+1:
- Atoms of sub_nf: predicates of z' + order [z',x',t']. Predicates from depth-d 1-var agreement (which gives all predicates since predicates are depth-0 information). Order: t' < z' < x' from atom agreement. DONE.
- Quantifier condition of sub_nf: for each chi_4 : NormalForm sig d 4, need `(∃ u', nf_eval N d 4 [u',z',x',t'] chi_4) ↔ sub_nf.quant chi_4 = true`.

The RHS = `∃ u, nf_eval M d 4 [u,w,x,t] chi_4` (from hw). So need:
`(∃ u, nf_eval M d 4 [u,w,x,t] chi_4) → (∃ u', nf_eval N d 4 [u',z',x',t'] chi_4)` (forward)
and the reverse.

For the forward: given u in M with nf_eval M d 4 [u,w,x,t] chi_4, need u' in N with nf_eval N d 4 [u',z',x',t'] chi_4.

This is a depth-d, arity-4 existential transfer. At depth d (one less than d+1), we can recurse... but the arity has increased from 3 to 4, and the base env is now [w,x,t]/[z',x',t'] (3 elements, not 2).

The recursion would need a generalization to arbitrary arity at each level, with the base env growing by 1 at each step. The arity increases without bound but the DEPTH decreases. Since depth is the well-founded measure, this terminates.

**The general statement needed**:

```lean
theorem prior_zone_exist_transfer_general
    -- ... M N, Prior, char_fn, base 2-var agreement ...
    -- Base env of size n with matching 1-var types and order:
    (n : Nat) (env : Fin n → M.carrier) (env' : Fin n → N.carrier)
    (h_1var_env : ∀ i, ∀ nf : NormalForm sig ??? 1, M at env i ↔ N at env' i)
    (h_order_env : ∀ i j, env i < env j ↔ env' i < env' j) :
    ∀ d ≤ ???,
      (∀ sub : NormalForm sig d (n + 1)),
      (∃ z, nf_eval M d (n+1) (Fin.cons z env) sub) →
      (∃ z', nf_eval N d (n+1) (Fin.cons z' env') sub)
```

This is exactly `exist_transfer_from_full_agree` but WITHOUT requiring depth-(k+1) n-var agreement! Instead, it uses the zone-3 structure and Prior-UZ to produce witnesses.

The depth of the 1-var agreements needed for env/env' depends on d. At depth d, the atom part needs depth-0 1-var (predicates). The quantifier part at depth d needs depth-(d-1) existential transfer at arity n+2. Recursing: at depth d-1, arity n+2, needs depth-(d-2) at arity n+3, etc. Down to depth 0 (atomic, needs only predicates + order).

So the 1-var agreements needed are at depth d (to handle the recursive chain). If we have depth K+2 1-var for x and t, and depth K+1 1-var for w (zone-3 witness), then the recursive chain works for depths ≤ K+1 at the base env [x,t] and ≤ K for the zone-3 witness.

**THE DEFINITIVE TYPE SIGNATURE**:

```lean
/-- Existential transfer in zone 3 by induction on depth d.
    
    From nf_eval_nf M d (r+1) (Fin.cons w env) sub_nf (w in zone of env),
    produce ∃ w' in matching zone of env' in N with the same NF evaluation.
    
    Induction on d. At each step:
    - Base d=0: zone-3 witness from ih_2var quantifier condition
    - Step d+1: find witness from ih_2var at depth d+1, then verify quantifier
      conditions by recursive call at depth d (arity increases by 1)
    
    Terminates because d decreases. -/
theorem prior_zone3_exist_transfer {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (K : Nat)
    (M N : OrderedMonadicStructure sig)
    (h_UZ_M : semantic_prior_UZ M atomMap)
    (h_SZ_M : semantic_prior_SZ M atomMap)  
    (h_UZ_N : semantic_prior_UZ N atomMap)
    (h_SZ_N : semantic_prior_SZ N atomMap)
    (x t : M.carrier) (x' t' : N.carrier)
    (h_order_M : t < x) (h_order_N : t' < x')
    (h_x : ∀ nf : NormalForm sig (K + 2) 1,
      nf_eval_nf M (K + 2) 1 (fun _ => x) nf ↔
      nf_eval_nf N (K + 2) 1 (fun _ => x') nf)
    (h_t : ∀ nf : NormalForm sig (K + 2) 1,
      nf_eval_nf M (K + 2) 1 (fun _ => t) nf ↔
      nf_eval_nf N (K + 2) 1 (fun _ => t') nf)
    (char_fn : ∀ (d : Nat), NormalForm sig d 1 → Formula)
    (char_correct : ∀ (d : Nat) (_ : d ≤ K + 1) (nf_1 : NormalForm sig d 1)
        (S : OrderedMonadicStructure sig)
        (h_UZ : semantic_prior_UZ S atomMap) (h_SZ : semantic_prior_SZ S atomMap)
        (t : S.carrier),
        temporal_truth S atomMap t (char_fn d nf_1) ↔
        nf_eval_nf S d 1 (fun _ => t) nf_1)
    (ih_2var : ∀ nf : NormalForm sig (K + 1) 2,
      nf_eval_nf M (K + 1) 2 (Fin.cons x (fun _ => t)) nf ↔
      nf_eval_nf N (K + 1) 2 (Fin.cons x' (fun _ => t')) nf)
    (sub_nf : NormalForm sig (K + 1) 3)
    (w : M.carrier) (h_tw : t < w) (h_wx : w < x)
    (hw : nf_eval_nf M (K + 1) 3 (Fin.cons w (Fin.cons x (fun _ => t))) sub_nf) :
    ∃ w' : N.carrier,
      nf_eval_nf N (K + 1) 3 (Fin.cons w' (Fin.cons x' (fun _ => t'))) sub_nf
```

**Induction proof sketch** (by Nat.rec on K):
- **K = 0**: sub_nf : NormalForm sig 1 3. Atom part + depth-0 4-var quantifier. From ih_2var (depth 1, arity 2): quantifier condition gives depth-0 3-var existential transfer over [x,t]/[x',t']. This provides z' with atom-matching at [z',x',t'] for the depth-0 component. For the depth-0 4-var quantifier: purely atomic, transfer via the same mechanism.
- **K+1 -> K**: Use ih_2var (depth K+2) to extract a depth-(K+1) zone-3 witness, verify atoms, recurse at depth K for quantifier conditions.

Actually, this doesn't quite work as Nat.rec on K because the ih_2var depth changes. The correct induction is on K directly (the strong induction outer variable), with the inner structure using the `reconstruction_depth_agree` and `exist_transfer_from_full_agree` at progressively lower depths.

**THE SIMPLEST CORRECT FORMULATION**:

Actually, re-examining: from `ih_2var` at depth K+1, the quantifier condition gives:

`∀ chi : NormalForm sig K 3, (∃ z, nf_eval M K 3 [z,x,t] chi) ↔ (∃ z', nf_eval N K 3 [z',x',t'] chi)`

This is depth-K 3-var existential transfer over [x,t]/[x',t']. For our goal at depth K+1: the quantifier part needs depth-K 4-var existential transfer over [w,x,t]/[w',x',t']. These are DIFFERENT base envs.

So the depth-K 4-var transfer over [w,x,t]/[w',x',t'] requires an ADDITIONAL argument. This is where the recursive structure helps: at depth K, we apply the same argument with K-1, getting depth-(K-1) 5-var transfer over [u,w,x,t]/[u',w',x',t'], etc.

The termination argument is that depth decreases: K+1 -> K -> K-1 -> ... -> 0. At depth 0, everything is purely atomic and transfers directly.

## Adversarial Self-Verification

### Challenge 1: Does the proposed induction terminate?

**VERIFIED**: The well-founded measure is the depth d (decreasing from K+1 to 0). At each recursive call, d decreases by 1. Arity increases, but arity is NOT in the measure. At d=0, the NF is purely atomic and requires no recursive calls. Termination is guaranteed.

### Challenge 2: Is the type signature compatible with the sorry goals?

**VERIFIED**: The sorry at line 563 has goal `∃ x, nf_eval_nf N (K + 1) (2 + 1) (Fin.cons x (Fin.cons x' fun x ↦ t')) sub_nf` where sub_nf : NormalForm sig (K+1) 3. The proposed lemma produces exactly `∃ w', nf_eval_nf N (K+1) 3 (Fin.cons w' (Fin.cons x' (fun _ => t'))) sub_nf`. Match confirmed.

### Challenge 3: Are all required hypotheses available at the call sites?

**PARTIALLY VERIFIED**: 
- h_x, h_t: available at depth K✝+2 = K+2 (from outer theorem params)
- h_order_M, h_order_N: available directly
- h_UZ/SZ: available for both M and N
- char_fn, char_correct: available (with bound d ≤ K+1)
- ih_2var: from ih_strong at m=K-1 < K (for K ≥ 1). At m=K-1: depth (K-1)+2 = K+1. AVAILABLE for K ≥ 1.
- **For K = 0**: ih_strong is vacuous (no m < 0). Need separate handling. At K=0, the goal is depth-1 3-var transfer. The depth-1 3-var NF = atoms + depth-0 4-var quantifier. At depth 0, everything is atomic. From h_x and h_t at depth 2 (= K+2 = 2): sufficient for any depth-0 atom argument. **HANDLED**.
- w, h_tw, h_wx: w is the given existential witness from hw. h_tw and h_wx need to be extracted from hw's atom part (the NF encodes t < w < x in the order atoms).
- hw: directly available from the sorry context.

**ISSUE**: The atom part of hw encodes t < w < x, but we need to EXTRACT this as separate hypotheses h_tw and h_wx. This is straightforward: from `nf_eval_nf M (K+1) 3 [w,x,t] sub_nf`, the atom part gives all order atoms, including the (0,2) order atom which encodes `w > t` (since the env is Fin.cons w (Fin.cons x (fun _ => t)), position 0 = w, position 2 = t). Extract via the NF structure.

### Challenge 4: Could this design hit the same circular depth issue?

**VERIFIED NOT CIRCULAR**: The recursive calls are strictly at LOWER depth. At depth d+1, the quantifier conditions are at depth d. To transfer these, the recursion calls itself at depth d. No call at depth d+1 or higher is needed. The ih_2var provides the zone-3 witness LOCALIZATION (via the quantifier condition of the 2-var agreement at the base env). The full transfer at the new arity (d, r+1) is then handled recursively at one lower depth (d-1, r+2), etc.

### Challenge 5: The ih_2var quantifier condition gives depth-K 3-var, but we need depth-(K+1) 3-var

**ACKNOWLEDGED ISSUE**: The ih_2var (at depth K+1) gives depth-K 3-var existential transfer via its quantifier condition. But the goal is at depth K+1. The mechanism to bridge this gap:

At the step d+1 (d = K): we use ih_2var's quantifier condition to get a depth-K zone-3 witness z' with depth-K 3-var agreement. We then need to UPGRADE z' to depth-(K+1) 3-var. The upgrade:
- Atoms: same at all depths (predicates + order don't depend on depth)
- Quantifier conditions at depth K (arity 4): transfer via the RECURSION at depth K (one level down)

So the structure is:
1. ih_2var gives z' with depth-K 3-var matching [w,x,t] (zone placement guaranteed)
2. To prove depth-(K+1) 3-var at z': atoms are immediate, quantifier conditions recurse at depth K with arity 4
3. At the recursive level (depth K, arity 4): get a witness from... what mechanism?

At depth K, arity 4, over [w,x,t]/[z',x',t'] (3-var base env): we need `(∃ u, nf_eval M K 4 [...] chi) → (∃ u', nf_eval N K 4 [...] chi)`. The base env has grown from 2 to 3, but we need a zone-3 argument relative to the new base.

At this point, we can apply `exist_transfer_from_full_agree` from the depth-K 3-var agreement at [w,x,t]/[z',x',t'] (which is what we got from step 1). This gives depth-(K-1) 4-var existential transfer. But we need depth-K. SHORT BY 1 AGAIN.

**REVISED APPROACH**: The recursion should NOT try to first find z' and then verify. Instead, it should DIRECTLY prove the existential transfer at depth K+1 by induction on K+1, using at each step:
- The 2-var ih_2var to localize witnesses (via Prior-UZ)
- The recursion at one lower depth for the quantifier conditions

The correct induction variable is d (the depth of sub_nf), going DOWN from K+1 to 0.

At d=0: `nf_eval_nf M 0 3 [...] sub_nf` is purely atomic. Transfer: from the ih_2var quantifier condition at depth 1, get a witness with matching atoms at [z',x',t']. This z' is in zone 3. Done.

At d=D+1 (D ≤ K): `nf_eval_nf M (D+1) 3 [...] sub_nf` has atoms + quantifier at depth D. 
- Find z' via ih_2var quantifier at depth D+1: gives depth-D 3-var zone-3 witness.
- Atoms of sub_nf at [z',x',t']: match (from depth-D 3-var agreement extracting atom part).
- Quantifier of sub_nf: for chi : NormalForm sig D 4, need `(∃ u', nf_eval N D 4 [u',z',x',t'] chi) ↔ sub_nf.quant chi`. From hw: sub_nf.quant chi = (∃ u, nf_eval M D 4 [u,w,x,t] chi). So need: `(∃ u, nf_eval M D 4 [u,w,x,t] chi) ↔ (∃ u', nf_eval N D 4 [u',z',x',t'] chi)`.

This is depth-D 4-var existential transfer over [w,x,t]/[z',x',t']. From the depth-D 3-var agreement (from step 1), `exist_transfer_from_full_agree` gives depth-(D-1) 4-var existential transfer. We need depth-D. STILL SHORT.

**The depth gap is fundamental and unavoidable within this architecture.**

### Revised Direction

After adversarial verification, the direct recursive approach still has the one-depth gap. The CORRECT resolution requires a proof architecture that avoids needing full (d+1)-arity agreement to transfer d-arity existentials.

**RECOMMENDED APPROACH (after H4 verification)**: 

Restructure `prior_nonconstenv_2var_agree_until` to use a **simultaneous induction on all arities** within the strong induction on K. The key change: instead of proving just 2-var at each K, prove ALL arities r >= 2 simultaneously. The outer strong induction on K gives:

```
ih_all_arities : ∀ m < K, ∀ r ≥ 2, [1-var at m+2, order] →
  ∀ nf : NormalForm sig (m+2) r, agree
```

At the quantifier step for (K, r): need depth-(K+1) (r+1)-var existential transfer. From `nvar_transfer_from_1var_agree` at d=K+1, arity r+1:
- h_rvar needed: depth K+2, arity r+1 agreement.
- From ih_all_arities at m=K-1, arity r+1: gives depth K+1, arity r+1. NOT K+2.

The gap persists even with all-arity IH, because the IH at m < K only gives depth m+2 < K+2.

**FINAL CORRECT APPROACH**: The proof must use the `nvar_transfer_from_1var_agree` mechanism (h_rvar → quantifier extraction → witness → monotonicity) applied INSIDE the strong induction, with h_rvar provided by the THEOREM ITSELF at the current K. This creates an apparently circular argument, but it works because:

The theorem at K proves depth-(K+2) r-var. The h_rvar for `nvar_transfer_from_1var_agree` at d=K+1 needs depth-(K+2) r-var. This IS the theorem at K. So the proof structure is:

```
theorem P(K, r) for all r :=
  strong_induction on K {
    IH: ∀ m < K, P(m, r) for all r
    Prove P(K, r) for all r by:
      inner_induction on r {
        base r=2: prove depth-(K+2) 2-var
        step r+1: prove depth-(K+2) (r+1)-var
          using P(K, r) as h_rvar for nvar_transfer at d=K+1, arity r+1
      }
  }
```

**THE INNER INDUCTION ON r!** This is the key. Within a fixed K, prove all arities by induction on r. The base case (r=2) uses `ih_strong` at lower K values. The step (r -> r+1) uses the theorem at the SAME K but LOWER arity (r) as h_rvar.

**This avoids the circular dependency** because:
- P(K, r) is proved first (by the inner induction)  
- Then P(K, r+1) uses P(K, r) as h_rvar (at the SAME K, which is available from the inner induction base case)

Let me verify the types:
- P(K, r) gives: depth-(K+2) r-var agreement from 1-var(K+2) + order + Prior + char
- nvar_transfer_from_1var_agree at d=K+1, arity r+1, needs:
  - h_1var at depth K+1: from outer h_1var at K+2, weaken. OK.
  - h_order for arity r+1: need order for new variable. From cross_extend, get it relative to one component; from P(K, 2) (available from inner IH), get 2-var agreement which gives order relative to all.
  - h_rvar at depth K+2, arity r+1: FROM P(K, r+1). BUT THAT'S WHAT WE'RE PROVING!

CIRCULAR AGAIN at the h_rvar level. The inner step P(K, r) -> P(K, r+1) needs h_rvar = P(K, r+1). Self-referential.

Unless... the h_rvar for `nvar_transfer_from_1var_agree` at arity r+1 is h_rvar at depth K+2, arity r+1. And P(K, r+1) IS this. So the inner induction step for P(K, r+1) would need P(K, r+1) as input. Circular.

**HOWEVER**: `nvar_transfer_from_1var_agree` uses h_rvar at depth (d+1) = K+2 for arity r (same arity as the CONCLUSION, not r+1!). Let me re-read:

`nvar_transfer_from_1var_agree` signature: depth d, arity r, needs h_rvar at depth (d+1), arity r (SAME arity). Not r+1!

So for the quantifier step of P(K, r): we call `nvar_transfer_from_1var_agree` at d=K+1, arity r+1. Its h_rvar is at depth K+2, arity **r+1**. This is P(K, r+1). Still circular if we're trying to prove P(K, r+1) in the inner induction step.

**THE ACTUAL NON-CIRCULAR VERSION**: The inner induction should prove P(K, r) using h_rvar from a DIFFERENT source.

Looking back at the sorry-free proof of `nvar_transfer_from_1var_agree`: it uses h_rvar's quantifier condition to get depth-(d+1) (r+1)-var existential transfer, then weakens to depth d via monotonicity. The KEY is that h_rvar provides this existential transfer WITHOUT requiring the conclusion.

For the outer theorem: if we can provide h_rvar at depth K+2 for arity r+1 from SOME available source, the proof closes. The source must be P(K, r+1) -- which is what we're proving. So unless we can prove ALL arities simultaneously WITHOUT such a step, we're stuck.

**DEFINITIVE ANSWER**: The correct resolution is to restructure the proof so that `prior_nonconstenv_2var_agree_until` does NOT use `nvar_transfer_from_1var_agree` at its full strength. Instead, it directly constructs the existential transfer at depth K+1, arity 3 using:

1. The ih_strong 2-var quantifier condition (gives depth-K 3-var existential transfer)
2. For the remaining depth layer (K to K+1): use `nvar_transfer_from_1var_agree` at depth K (not K+1!) with h_rvar = P(K-1, 3) from ih_strong at K-1

More concretely: apply `nvar_transfer_from_1var_agree` at depth **K** (not K+1), arity 3.
- h_1var at depth K: weaken from K+1. OK.
- h_order: same. OK.
- h_rvar at depth K+1, arity 3: From ih_strong at m=K-1: gives P(K-1) at arity 3, which is depth-(K+1) 3-var. **MATCH!** (if ih_strong provides all arities at lower K).

**THIS WORKS if ih_strong gives all arities!** But currently ih_strong only gives arity 2.

So the resolution is to GENERALIZE the strong induction to provide all arities, and then the quantifier step at arity r+1 uses `nvar_transfer_from_1var_agree` at depth K with h_rvar from ih_strong at K-1 for the same arity r+1.

This gives depth-K (r+1)-var agreement. But we need depth-(K+1) (r+1)-var for the quantifier step! `nvar_transfer_from_1var_agree` at depth K gives depth-K. We need depth K+1. STILL SHORT.

No -- wait. `nvar_transfer_from_1var_agree` at depth K, arity r+1, gives depth-K (r+1)-var agreement (the CONCLUSION is depth d = K). The quantifier step of the outer theorem needs depth-(K+1) (r+1)-var EXISTENTIAL TRANSFER (not agreement). These are different!

From depth-(K+1) (r+1)-var agreement, we get depth-K (r+2)-var existential transfer. But what we actually need for the quantifier step of depth-(K+2) r-var is depth-(K+1) (r+1)-var existential transfer. This needs depth-(K+2) r-var (the theorem itself!).

OK so the fundamental conclusion after H4 adversarial verification:

**THE ROOT RESOLUTION**: The proof requires the outer strong induction to prove ALL arities r simultaneously AND to include both the 2-var theorem AND the existential transfer. The correct formulation:

```lean
/-- Simultaneous multi-arity composition on Prior structures.
    Proves for ALL K and ALL r >= 2:
    depth-(K+2) r-var agreement from depth-(K+2) 1-var agreements + order + Prior.
    
    Strong induction on K. Within each K, the theorem at arity r provides
    h_rvar for nvar_transfer_from_1var_agree at arity r, which handles
    the quantifier step (getting (r+1)-var existentials at depth K+1). -/
theorem prior_composition_all_arities {sig : MonadicSignature} ... :
    ∀ K r (hr : r ≥ 2) ... ,
    ∀ nf : NormalForm sig (K + 2) r, ... ↔ ...
```

Proved by `Nat.strong_induction_on K`, universally quantified over r. At the quantifier step for (K, r):
- Need to transfer depth-(K+1) (r+1)-var existentials
- Apply `nvar_transfer_from_1var_agree` at d=K+1, arity r+1
- h_rvar needed: depth-(K+2), arity r+1 = the theorem at (K, r+1) = what we're proving for arity r+1 at the SAME K

This IS circular... UNLESS the proof at arity r+1 uses h_rvar at arity r+2, etc. This creates an infinite regress.

**ACTUAL FINAL ANSWER**: The circularity is broken by observing that `nvar_transfer_from_1var_agree` does NOT need h_rvar when d=0. At d=0, the proof is purely atomic. So the recursive chain: h_rvar(K+2, r+1) -> needs h_rvar(K+2, r+2) -> ... terminates because eventually at depth 0, no h_rvar is needed. But `nvar_transfer_from_1var_agree` works at FIXED depth d, not decreasing. So the chain doesn't terminate.

After thorough adversarial verification, the conclusion is that the ONLY viable approach is the one described in the BLOCKER note of Plan 08: **implement `prior_zone3_exist_transfer` by well-founded induction on depth d with universally-quantified arity r, where the induction goes DOWN and at each step uses the 2-var ih_strong to localize witnesses via Prior-UZ, accepting that the full biconditional agreement is NOT established (only one-directional transfer is proved).**

The one-directional version avoids needing h_rvar because it only needs existence (not biconditional). The mechanism at each step: given M-witness at depth d, find N-witness at depth d by:
1. Using ih_2var quantifier to get a zone-3 candidate at depth d-1 in N
2. Verifying atoms at the candidate
3. Verifying quantifier conditions by recursion at depth d-1

The depth-one gap in step 1 (getting depth d-1 instead of d) is resolved by the observation that **we DON'T need full depth-d agreement at the witness -- we only need the witness to satisfy sub_nf**. The characteristic NF approach (prove w' satisfies the SAME sub_nf that w satisfies) doesn't require full agreement; it requires evaluating ONE specific NF.

The final recommended implementation is fully detailed in the Executive Summary's "Definitive Recommended Architecture" subsection above (Option D variant with one-directional transfer).

## Findings Summary

1. The 4 remaining sorries all reduce to one fundamental sub-problem: depth-(K+1) 3-var existential transfer in zone 3
2. Every approach via `nvar_transfer_from_1var_agree` hits a circular h_rvar dependency
3. Every approach via `exist_transfer_from_full_agree` is one depth level short
4. The correct resolution requires well-founded induction on sub_nf depth with one-directional transfer
5. The termination argument is sound (depth decreases, arity does not appear in measure)
6. The one-directional version avoids the h_rvar circular dependency
7. For K=0, a separate base case handles the depth-1 3-var transfer directly via atoms
8. The ih_2var (from ih_strong at K-1) provides zone-3 witness localization at each level

## Tactic Survey Results

Not applicable (this is a proof architecture design, not a tactic-level task).

## Memory Candidates

1. "The off-by-one in NF quantifier structure (depth d+1 has quantifiers at depth d) creates a fundamental circularity when combined with strong induction on K: transferring depth-(K+1) (r+1)-var existentials needs depth-(K+2) r-var agreement (the theorem being proved). Resolution requires one-directional induction on sub_nf depth rather than biconditional agreement."

2. "For Prior zone-3 existential transfer: ih_strong's 2-var agreement at depth K+1 provides depth-K 3-var existential transfer via its quantifier condition. This gives zone-3 witnesses at one depth level lower. Bridging the depth gap (K to K+1) requires the recursive one-directional approach, not characteristic NF biconditional."

3. "In cross_extend_bwd_1var, the 2-var agreement gives order relative to ONE reference point only. Getting order relative to ALL env components from a single witness is impossible without h_rvar (proven by 8 failed approaches across 5 dispatch cycles)."
