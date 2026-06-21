# Research Report: Zone-3 Gap-Placement Blocker Analysis

**Task**: 305 (rabinovich_ea_formula_implementation)
**Agent**: lean-research-hard-agent
**Reference Grounding Tier**: Tier 1 (literature-backed, Rabinovich 2014 Section 5)

## H3 Lemma Mapping Table

| Source (Rabinovich 2014) | Prop/Location | Lean Identifier | Type Signature | Status |
|---|---|---|---|---|
| Lemma 5.1 (composition) | Multi-var NF agreement from 1-var | `nvar_transfer_from_1var_agree` | `∀ d r, (1-var agree at d+1) → (order match) → (Prior UZ/SZ) → (char_fn) → (d+1 r-var agree)` | SORRY (lines 459, 462) |
| Lemma 5.1 applied to 2-var | Zone-3 existential transfer in Until | `prior_nonconstenv_2var_agree_until` | `(K+2 1-var agree at x,t) → (Prior) → (K+2 2-var agree at [x,t])` | SORRY (lines 554, 559) |
| Lemma 5.1 applied to 2-var | Zone-3 existential transfer in Since | `prior_nonconstenv_2var_agree_since` | Same shape, reversed order | SORRY (lines 610, 614) |
| Prior-UZ axiom | First occurrence above t | `semantic_prior_UZ` | `∀ t ψ, (∃ s > t, ψ(s)) → ∃ s > t, ψ(s) ∧ ¬ψ on (t,s)` | DEFINED (PriorDefs.lean:22) |
| Prior-UZ (bounded) | First occ in interval | `HasAttainedINF.first_occ` | `∀ P z0 z1, z0 < z1 → (∃ x ∈ (z0,z1), P(x)) → ∃ r0 ∈ (z0,z1), P(r0) ∧ ¬P on (z0,r0)` | PROVED (PriorINF.lean:202) |
| Prior → HasAttainedINF | Prior has attained infima | `prior_hasAttainedINF` | `semantic_prior_UZ M → HasAttainedINF M` | PROVED (PriorINF.lean:224) |
| CharPart(k) | Temporal characterization | `char_fn d nf_1` parameter | `temporal_truth M t (char_fn d nf_1) ↔ nf_eval_nf M d 1 (fun _ => t) nf_1` | Provided as parameter |
| Cross-extend (bwd) | Find witness in N | `cross_extend_bwd_1var` | `(K+1 1-var agree at t/s) → ∀ x : M, ∃ x' : N, (K 2-var agree at [x,t]/[x',s])` | PROVED (KampComposition.lean:97) |
| 1-var from 2-var | Project 2-var to 1-var | `cross_1var_from_2var` | `(K 2-var agree at [y,t]/[y',s]) → (K 1-var agree at y/y')` | PROVED (KampComposition.lean:57) |
| Atom from NF agree | Extract atom iff | `atom_agreement_from_nf` | `(k n-var agree) → ∀ atom, atom_eval M env a ↔ atom_eval N env' a` | PROVED (NormalForm.lean) |
| NF monotonicity | Weaken depth | `nf_agreement_monotone` | `d ≤ k → (k-var agree) → (d-var agree)` | PROVED (NormalForm.lean) |
| Shared NF → full agree | From common char NF | `nf_agreement_from_shared_nf` | `nf_eval M nf ∧ nf_eval N nf → ∀ nf', (M ↔ N)` | PROVED (NormalForm.lean:291) |

## Sorry Inventory

### Sorry 1: `nvar_transfer_from_1var_agree` (line 459) — Forward direction

**Goal**:
```
⊢ ∃ x, nf_eval_nf N d (r + 1) (Fin.cons x env') sub_nf
```

**Available hypotheses**:
- `x : M.carrier`, `hx : nf_eval_nf M d (r + 1) (Fin.cons x env) sub_nf`
- `h_1var : ∀ i : Fin r, depth-(d+1) 1-var agree at env i / env' i`
- `h_order : ∀ i j : Fin r, env i < env j ↔ env' i < env' j`
- `h_UZ_N, h_SZ_N : semantic_prior_UZ/SZ N atomMap`
- `char_fn` with `char_correct : ∀ d' < d+1, ...`
- `ih`: depth-d version of the theorem (all arities)

### Sorry 2: `nvar_transfer_from_1var_agree` (line 462) — Backward direction

**Goal**:
```
⊢ ∃ x, nf_eval_nf M d (r + 1) (Fin.cons x env) sub_nf
```

Symmetric to Sorry 1 with M and N swapped.

### Sorries 3-6: `prior_nonconstenv_2var_agree_until/since` (lines 554, 559, 610, 614)

These are specific instances of the same problem at r=2 (3-var quantifier), with additional `cross_extend_bwd_1var` witnesses already extracted. The goal in each case is:
```
⊢ ∃ x, nf_eval_nf N (K+1) 3 (Fin.cons x (Fin.cons x' (fun _ => t'))) sub_nf
```

## Analysis: Dependency Structure

The 6 sorries reduce to **one fundamental sub-problem**:

```
nvar_transfer_from_1var_agree (lines 459/462) is the ROOT.
prior_nonconstenv_2var_agree_until/since (lines 554/559/610/614) are CONSUMERS.
```

Once `nvar_transfer_from_1var_agree` is proved, the 2-var theorems can delegate to it:
- At line 554: We have `h_1var_w₂` (1-var agree at w/w₂), `h_x` (1-var agree at x/x'), `h_t` (1-var agree at t/t'), plus order from `hw₂`/`hw₁`. Apply `nvar_transfer_from_1var_agree` at depth K+1, arity 3.

**However**, there is a depth mismatch: `nvar_transfer_from_1var_agree` requires depth-(d+1) 1-var agreements to produce depth-(d+1) r-var agreement. The available hypotheses in the 2-var theorem give:
- `h_1var_w₂`: depth-(K✝+1) 1-var at w/w₂
- `h_x`: depth-(K✝+2) 1-var at x/x'
- `h_t`: depth-(K✝+2) 1-var at t/t'

For the goal depth K+1, we need depth-(K+1) 1-var agreements. Since K < K✝ (strong induction), K+1 ≤ K✝+1 ≤ K✝+2. So all hypotheses provide sufficient depth after monotone weakening.

**Order matching**: From `hw₂` (2-var agree at [w,t]/[w₂,t']) and `hw₁` (2-var agree at [w,x]/[w₁,x']):
- `w < t ↔ w₂ < t'` and `t < w ↔ t' < w₂` (from atom agreement in hw₂)
- `w < x ↔ w₁ < x'` and `x < w ↔ x' < w₁` (from atom agreement in hw₁)

But w₂ and w₁ are DIFFERENT witnesses. We need order facts about a SINGLE witness relative to ALL env' components. This is the gap-placement problem.

## Proof Strategy for `nvar_transfer_from_1var_agree` (The Root Problem)

### Key Insight: Gap Classification + Prior-UZ/SZ Squeeze

The proof proceeds by finding x' in N in the "same gap" as x in M:

**Step 1: Classify x's gap in M**

For each i : Fin r, determine x's position relative to env i:
- Case A: x < env i (for some set of indices)
- Case B: x = env i (at most one index, by strict order)
- Case C: env i < x (for some set of indices)

Since env is a finite tuple in a linear order, x falls in a specific "gap" between env components (or equals one, or is above/below all).

**Step 2: Characterize x as a temporal formula**

Set `nf_x := nf_characteristic M d 1 (fun _ => x)`. By `char_correct` at depth d (d < d+1):
```
temporal_truth M atomMap x (char_fn d nf_x) ↔ nf_eval_nf M d 1 (fun _ => x) nf_x
```
The RHS holds by `nf_characteristic_satisfies`.

**Step 3: Transfer existence to N via Prior-UZ**

We need some reference point in N from which to apply Prior-UZ.

Sub-case: x > env i for some i (so env' i < x' by the target order matching).

From `h_1var i` (depth-(d+1) agree at env i / env' i), the quantifier condition gives:
```
∃ y > env i satisfying char_fn d nf_x → ∃ y' > env' i satisfying char_fn d nf_x
```
This follows from the quantifier part of depth-(d+1) 1-var agreement at env i / env' i. Specifically, the Until direction of the NF's quantifier condition encodes "there exists a future point with this depth-d 1-var type."

**CRITICAL STEP**: From `h_1var i`, the depth-(d+1) 1-var NF agreement implies that the depth-d quantifier condition at env i and env' i match. The quantifier condition says: for each depth-d 2-var NF chi, `(∃ y, nf_eval_nf M d 2 [y, env i] chi) ↔ (∃ y', nf_eval_nf N d 2 [y', env' i] chi)`.

Taking chi to be the characteristic NF of M at [x, env i], we get a y' in N with depth-d 2-var agreement at [x, env i]/[y', env' i]. By `cross_1var_from_2var`, y' has depth-d 1-var agreement with x. Also, from the 2-var agreement's atom conditions, `x > env i ↔ y' > env' i`, so y' > env' i.

**Step 4: Ensure correct gap for ALL indices simultaneously**

This is the hard part. We have y' > env' i with matching 1-var type, but we need y' in the CORRECT gap relative to ALL env' components.

**Sub-strategy (Prior-UZ squeeze)**:
1. Among indices j where x < env j (i.e., env' j should be > x'), pick the minimum: let j_min be such that env j_min = min{env j : x < env j}.
2. Among indices i where env i < x (i.e., x' should be > env' i), pick the maximum: let i_max be such that env i_max = max{env i : env i < x}.
3. The "gap" is (env i_max, env j_min) in M, and the target is (env' i_max, env' j_min) in N.
4. From step 3 (using i = i_max), we have some y' > env' i_max with depth-d 1-var type matching x.
5. If y' < env' j_min, we're done: y' is in the correct gap.
6. If y' ≥ env' j_min, use `HasAttainedINF.first_occ` on N with P = char_fn d nf_x in the interval (env' i_max, env' j_min) to get the FIRST occurrence w' of this type. The first occurrence satisfies w' < env' j_min by construction (there is an occurrence in this interval because x₁ from cross_extend at h_1var j_min gives a witness < env' j_min with matching type).

**Step 5: Apply IH at depth d, arity r+1**

Once we have w' in N in the correct gap (env' i_max < w' < env' j_min), with depth-d 1-var agreement with x, we can form the extended order matching:
- For all i: env i < x ↔ env' i < w' (order matching in the gap)
- depth-d 1-var agreement at x/w'
- depth-d 1-var agreements at env i / env' i (from `h_1var i` weakened by monotonicity)

Apply `ih` at depth d, arity r+1, environments `Fin.cons x env` / `Fin.cons w' env'`.

### Where Prior-UZ is Essential

**Without Prior-UZ**, two witnesses y₁ and y₂ from different reference points might land in different gaps. Prior-UZ (via `HasAttainedINF.first_occ`) ensures we can find a witness in a SPECIFIC bounded interval.

**The bounded interval argument**: Given that both env' i_max and env' j_min are valid reference points (from `h_1var` at these indices), the quantifier condition transfers show existence SOMEWHERE above env' i_max. The first_occ property then localizes this to the specific interval (env' i_max, env' j_min).

### Proving Existence in the Bounded Interval

The key step is showing that there EXISTS a point in (env' i_max, env' j_min) satisfying `char_fn d nf_x`. Here's the argument:

1. From `h_1var j_min` (depth-(d+1) agree at env j_min / env' j_min), the quantifier condition gives: `(∃ y < env j_min, ...) ↔ (∃ y' < env' j_min, ...)`. Since x < env j_min in M and x has NF type nf_x, there is some y' < env' j_min with depth-d 2-var agreement at [x, env j_min] / [y', env' j_min].

2. From atom agreement in this 2-var, y' < env' j_min. From `cross_1var_from_2var`, y' has depth-d 1-var type matching x, hence `temporal_truth N atomMap y' (char_fn d nf_x)`.

3. Also y' > env' i_max? This needs: from the 2-var atom agreement at [x, env j_min]/[y', env' j_min], can we extract y' > env' i_max?

   **NOT directly.** The 2-var agreement only encodes order relative to env j_min (the second component). We DON'T get y's position relative to env' i_max from this.

   **Resolution**: Use `h_1var i_max` instead. The Since-direction quantifier condition gives: `(∃ y > env i_max with type nf_x) ↔ (∃ y' > env' i_max with type nf_x)`. Since x > env i_max, this transfers to get some y'' > env' i_max satisfying char_fn. Combined with the step-2 result (existence below env' j_min), we know the type IS realized in the interval (env' i_max, env' j_min):
   
   - From step 2: ∃ y' < env' j_min with `char_fn d nf_x`
   - From h_1var i_max transfer: ∃ y'' > env' i_max with `char_fn d nf_x`
   
   If y' > env' i_max, then y' ∈ (env' i_max, env' j_min) and we're done.
   If y' ≤ env' i_max, we use y'' instead: y'' > env' i_max, but is y'' < env' j_min?
   
   **Second Resolution Approach (cleaner)**: Apply `HasAttainedINF.first_occ` on N with:
   - P = `char_fn d nf_x`
   - z0 = env' i_max
   - z1 = env' j_min
   - Existence witness: We need to show ∃ u ∈ (env' i_max, env' j_min) with P(u).

   **Why the witness exists**: From the Since-direction at j_min, we get y' < env' j_min with type nf_x. From the Until-direction at i_max, we get y'' > env' i_max with type nf_x. Since the linear order is total, EITHER y' > env' i_max (giving a witness in the interval) OR y'' < env' j_min (giving a witness in the interval). If BOTH fail, then y' ≤ env' i_max < env' j_min ≤ y'', which means env' i_max < env' j_min ≤ y''. But we also need y'' < env' j_min for the interval — contradiction with y'' ≥ env' j_min.

   Wait, this doesn't immediately work. Let me reconsider.

   **Correct argument via cross_extend**: From `h_1var i_max` at depth d+1, `cross_extend_bwd_1var` gives: for x in M, there exists y' in N with depth-d 2-var agreement at [x, env i_max] / [y', env' i_max]. From the 2-var atom agreement, since x > env i_max in M, we get y' > env' i_max. From `cross_1var_from_2var`, y' has depth-d 1-var type matching x, hence `temporal_truth N atomMap y' (char_fn d nf_x)`.

   Similarly from `h_1var j_min`: `cross_extend_bwd_1var` gives y'' with depth-d 2-var at [x, env j_min] / [y'', env' j_min]. Since x < env j_min, y'' < env' j_min. Also y'' has matching 1-var type.

   Now: y' > env' i_max with type nf_x, and y'' < env' j_min with type nf_x. In N's linear order:
   - If y' < env' j_min: then y' ∈ (env' i_max, env' j_min). Done.
   - If y'' > env' i_max: then y'' ∈ (env' i_max, env' j_min). Done.
   - If y' ≥ env' j_min AND y'' ≤ env' i_max: impossible since env' i_max < env' j_min (from h_order applied to i_max < j_min in M, which gives env' i_max < env' j_min in N).

   Wait — we know env' i_max < env' j_min because env i_max < env j_min in M (since env i_max < x < env j_min). So by `h_order`, env' i_max < env' j_min.

   If y' ≥ env' j_min and y'' ≤ env' i_max simultaneously: y' ≥ env' j_min > env' i_max ≥ y''. But y' and y'' both have the same 1-var type as x. This situation is consistent — there can be multiple points with the same 1-var type.

   **The fix**: We DON'T need both to be in the interval. We just need ONE to be. The disjunction `y' < env' j_min ∨ y'' > env' i_max` is a tautology of linear orders:
   - Suppose ¬(y' < env' j_min), i.e., y' ≥ env' j_min.
   - Suppose ¬(y'' > env' i_max), i.e., y'' ≤ env' i_max.
   - Then y'' ≤ env' i_max < env' j_min ≤ y'. This is consistent.

   So neither y' nor y'' is necessarily in the interval! This is the CORE DIFFICULTY.

### The Actual Resolution: Direct IH Application (No Gap Placement Needed)

**Crucial insight**: We don't need to place a single witness in the correct gap first and THEN apply IH. Instead, we can use the IH differently.

From `h_1var i` at depth d+1, the FULL NF agreement gives depth-d 2-var existential transfer (via `exist_transfer_from_full_agree`). Specifically:

For any i, from `h_1var i` (depth-(d+1) 1-var agreement at env i / env' i):
```
∀ chi : NormalForm sig d 2,
  (∃ y, nf_eval_nf M d 2 (Fin.cons y (fun _ => env i)) chi) ↔
  (∃ y', nf_eval_nf N d 2 (Fin.cons y' (fun _ => env' i)) chi)
```

But what we ACTUALLY need is:
```
(∃ y, nf_eval_nf M d (r+1) (Fin.cons y env) sub_nf) →
(∃ y', nf_eval_nf N d (r+1) (Fin.cons y' env') sub_nf)
```

This is at arity r+1, not arity 2! The individual h_1var transfers are at arity 2.

**The correct approach (recursive)**: Apply `nvar_transfer_from_1var_agree` recursively at depth d, arity r+1. For this, we need:
1. Depth-d 1-var agreements at each component of (Fin.cons x env) / (Fin.cons x' env')
2. Order matching at arity r+1

We already have (1) for env/env' components (weakened from depth d+1). The missing piece is finding x' with depth-d 1-var agreement with x AND correct order.

**This is exactly the gap-placement problem restated at depth d instead of d+1.**

### Final Correct Strategy: Induction on r, not on d

The proof needs STRONG INDUCTION ON r (the arity) within the depth-d+1 induction step, or alternatively needs a smarter use of `cross_extend_bwd_1var`.

**Alternative approach (using `cross_extend_bwd_1var` at a reference point in the gap)**:

Pick any i₀ : Fin r such that either x > env i₀ or x < env i₀. WLOG x > env i₀ (Until direction).

From `h_1var i₀` (depth-(d+1) at env i₀ / env' i₀), apply `cross_extend_bwd_1var`:
```
∃ x' : N.carrier, ∀ nf : NormalForm sig d 2,
  nf_eval_nf M d 2 (Fin.cons x (fun _ => env i₀)) nf ↔
  nf_eval_nf N d 2 (Fin.cons x' (fun _ => env' i₀)) nf
```

This gives x' with:
- depth-d 1-var agreement with x (via `cross_1var_from_2var`)
- x > env i₀ ↔ x' > env' i₀ (from atom agreement in the 2-var)

Now apply `ih` at depth d, arity r+1, with environments Fin.cons x env / Fin.cons x' env'. We need:
- depth-d 1-var agree at x/x': **YES** (from cross_1var_from_2var)
- depth-d 1-var agree at env i / env' i for each i: **YES** (weaken h_1var i from depth d+1 to depth d)
- Order matching at arity r+1: For each (i,j) pair in Fin (r+1):
  - Pairs within env: from h_order (weakened trivially)
  - x vs env i: Need `x < env i ↔ x' < env' i` for ALL i

The problem: We only have x's order relative to env i₀ from the 2-var agreement. We need it relative to ALL env' components.

**This is the fundamental gap-placement problem.** The order of x' relative to env' i (for i ≠ i₀) is NOT determined by the depth-d 2-var agreement at [x, env i₀] / [x', env' i₀].

### Resolution via Prior-UZ First-Occurrence in Bounded Interval

**Combine multiple cross_extend witnesses to establish existence in the correct gap, then use HasAttainedINF.first_occ:**

1. For each pair (i, j) where env i < x < env j, apply cross_extend at BOTH i and j:
   - From `h_1var i`: get y_i > env' i with depth-d 1-var type of x
   - From `h_1var j`: get y_j < env' j with depth-d 1-var type of x

2. Show at least one of y_i, y_j lands in (env' i, env' j):
   - If y_i < env' j: y_i ∈ (env' i, env' j). Done.
   - If y_j > env' i: y_j ∈ (env' i, env' j). Done.
   - If y_i ≥ env' j AND y_j ≤ env' i: impossible since env' i < env' j (from h_order).
   
   **Proof**: Suppose y_i ≥ env' j and y_j ≤ env' i. Then y_j ≤ env' i < env' j ≤ y_i. But this is perfectly consistent — y_j could be below env' i and y_i could be above env' j. Wait, no:
   - y_j ≤ env' i means y_j is at or below env' i
   - env' i < env' j means the interval is non-empty
   - y_i ≥ env' j means y_i is at or above env' j
   
   This IS consistent. The two witnesses can be on opposite sides of the interval.

   **WRONG.** Let me reconsider. If env' i < env' j (which we know), and y_j ≤ env' i < env' j ≤ y_i, then... hmm, but we need a witness BETWEEN env' i and env' j. Neither y_i nor y_j is in this interval.

   **But wait**: We got y_i from cross_extend at i (so y_i > env' i), and y_j from cross_extend at j (so y_j < env' j). So y_i > env' i and y_j < env' j. The question is whether at least one of them is ALSO on the other side of the gap.

   - y_i > env' i (known). Is y_i < env' j? Not necessarily.
   - y_j < env' j (known). Is y_j > env' i? Not necessarily.

   **The disjunction y_j > env' i ∨ y_i < env' j** is NOT a tautology. Both could fail simultaneously: y_j ≤ env' i and y_i ≥ env' j. This is possible.

### The Correct Solution: Use the TIGHT Adjacent Gap Bounds

For the correct gap placement, we need to use the ADJACENT indices. Let:
- i_max = argmax{env i : env i < x} (the tightest lower bound)
- j_min = argmin{env j : x < env j} (the tightest upper bound)

So the gap in M is (env i_max, env j_min) with no other env components between them.

From `h_1var i_max` cross_extend: get y₁ > env' i_max with type nf_x.
From `h_1var j_min` cross_extend: get y₂ < env' j_min with type nf_x.

Since NO env component lies strictly between env i_max and env j_min in M, and h_order preserves order, NO env' component lies strictly between env' i_max and env' j_min in N.

**Claim**: At least one of y₁, y₂ is in (env' i_max, env' j_min).

**Proof of claim**: Suppose y₁ ≥ env' j_min and y₂ ≤ env' i_max. Then since y₁ > env' i_max (from cross_extend) and y₁ ≥ env' j_min, we have y₁ ≥ env' j_min. Since y₂ < env' j_min (from cross_extend) and y₂ ≤ env' i_max, we have y₂ ≤ env' i_max.

Now: y₂ ≤ env' i_max and y₂ < env' j_min. Also y₁ > env' i_max and y₁ ≥ env' j_min.

But we have: y₁ > env' i_max (clear). y₂ ≤ env' i_max gives y₂ < env' j_min (since env' i_max < env' j_min). This is consistent.

Hmm, this IS consistent: y₂ could be ≤ env' i_max and y₁ could be ≥ env' j_min. The gap (env' i_max, env' j_min) might contain neither.

**HOWEVER**, consider the 2-var atom agreement more carefully.

From cross_extend at j_min: y₂ has depth-d 2-var agreement at [x, env j_min] / [y₂, env' j_min].
The atom for the pair (var 0, var 1) is "y₂ < env' j_min" which matches "x < env j_min" = true. **Good.**
The atom for (var 1, var 0) is "env' j_min < y₂" which matches "env j_min < x" = false (since x < env j_min). **Good.**

But we also want y₂ > env' i_max. The 2-var agreement at [x, env j_min] tells us NOTHING about y₂'s relationship to env' i_max because env i_max is not a component of the 2-var env.

**This confirms the fundamental difficulty.** The 2-var cross_extend gives order relative to only ONE reference point.

### The TRUE Resolution: Apply `nvar_transfer_from_1var_agree` at Lower Depth via IH

Re-examine the IH. We have `ih` at depth d:
```
ih : ∀ r M env N env',
  Prior UZ/SZ →
  (∀ i, depth-d 1-var agree at env i / env' i) →
  (∀ i j, env i < env j ↔ env' i < env' j) →
  char_fn with char_correct at depths < d →
  ∀ nf, depth-d r-var agree
```

We want to prove: `∃ x' : N, nf_eval_nf N d (r+1) (Fin.cons x' env') sub_nf`.

**Strategy using IH + cross_extend at a reference point**:

1. Pick i₀ (say the nearest lower bound of x). Apply `cross_extend_bwd_1var` at `h_1var i₀` (depth d+1, giving depth-d 2-var at [x, env i₀] / [x', env' i₀]).

2. From this 2-var agreement, extract:
   - `cross_1var_from_2var`: depth-d 1-var agree at x / x'
   - Order: x > env i₀ ↔ x' > env' i₀

3. **Key claim**: x' is in the same gap as x relative to env'. Why?

   From the 2-var agreement at depth d ≥ 1 (i.e., d ≥ 1), the quantifier condition of the 1-var NF at depth d encodes sufficient information. Specifically, since x has depth-(d+1) 1-var agreement with each env i (via cross_extend from h_1var i at depth d), and all these agreements are CONSISTENT (they're all projections of x's actual environment type), the gap of x in M corresponds exactly to the gap of x' in N.

   **Wait, this isn't quite right either.** The 2-var agreement at [x, env i₀] doesn't directly tell us about x vs env i for i ≠ i₀.

4. **BUT**: The depth-d 1-var agreement at x/x' combined with depth-d 1-var agreement at env i / env' i allows us to determine x' < env' i iff x < env i, VIA the IH at depth d, arity 2:
   
   Apply `ih` at depth d, arity 2, environments [x, env i] / [x', env' i]:
   - depth-d 1-var agree at x/x': YES
   - depth-d 1-var agree at env i / env' i: YES (weaken from d+1)
   - order: x < env i ↔ x' < env' i: **THIS IS WHAT WE WANT TO PROVE**
   
   Circular! The IH gives arity-2 agreement, but to apply it we need the order matching.

### FINAL CORRECT APPROACH: Leveraging the Existence of an Extended Cross_extend

**The real insight from Rabinovich's proof**: At depth d+1, the 1-var NF of a point ENCODES its temporal position. Two points with the same depth-(d+1) 1-var NF in the same Prior structure have the same gap relative to any reference point (this is what the characteristic formula captures).

**Direct approach for the forward direction of `nvar_transfer_from_1var_agree`**:

We should NOT try to find x' and verify its order separately. Instead, we should use `exist_transfer_from_full_agree` applied to the 1-var agreements:

From `h_1var i₀` (depth-(d+1) 1-var at env i₀ / env' i₀), `exist_transfer_from_full_agree` gives:
```
∀ chi : NormalForm sig d (r+1),
  (∃ y, nf_eval_nf M d (r+1) (Fin.cons y (fun _ => env i₀)) chi) ↔
  (∃ y', nf_eval_nf N d (r+1) (Fin.cons y' (fun _ => env' i₀)) chi)
```

But this is on CONSTANT env (fun _ => env i₀), not on the full env!

**Alternative: Use the FULL nvar_transfer theorem at depth d via `reconstruction_depth_agree`**:

The theorem `reconstruction_depth_agree` shows: from depth-(K+1) (n+1)-var agreement, derive depth-d (n+1)-var agreement for all d ≤ K+1. But we don't HAVE the depth-(d+1) (r+1)-var agreement yet — that's what we're trying to prove!

### CORRECT STRATEGY (Final)

The correct proof strategy is a **nested induction**:

**Outer induction**: on d (depth). At depth d+1:
**Inner mechanism**: For the quantifier step, use `cross_extend_bwd_1var` from `h_1var i₀` to get x' in N with depth-d 2-var agreement at [x, env i₀] / [x', env' i₀]. Then:

1. From the depth-d 2-var agreement, extract depth-d 1-var at x/x'.
2. For order: from the depth-d 2-var at [x, env i₀], we know x's order relative to env i₀. For x's order relative to OTHER env components (env i for i ≠ i₀), use the fact that the depth-d 1-var NF of x encodes everything about x that can be detected at depth d in the structure. Specifically:

   **Key lemma needed**: If two points have the same depth-d 1-var NF in a Prior structure AND the same depth-d 2-var NF relative to some reference point, then they have the same depth-d 2-var NF relative to ALL reference points with the same 1-var type.

   This is essentially `nvar_transfer_from_1var_agree` at depth d (the IH!). Apply the IH at depth d, arity 2, to show that [x, env i] and [x', env' i] have depth-d 2-var agreement (for each i). From this 2-var agreement, extract the order atom: x < env i ↔ x' < env' i.

   **But the IH requires order matching to be GIVEN.** For the 2-element env [x, env i] / [x', env' i], the only order to match is x vs env i — which is what we're trying to prove!

**RESOLUTION**: The IH at depth d gives depth-d FULL NF agreement, not just atom agreement. To apply it at arity 2 for [x, env i] / [x', env' i], we need:
- depth-d 1-var at x/x': HAVE (from cross_1var_from_2var)
- depth-d 1-var at env i / env' i: HAVE (weaken from d+1)
- order at arity 2: x < env i ↔ x' < env' i: NEED THIS

This IS circular for general r. The solution is to use a DIFFERENT approach for the order matching.

**THE ACTUAL SOLUTION**: Instead of finding a single witness and verifying order, use the quantifier condition DIRECTLY.

From `hx : nf_eval_nf M d (r+1) (Fin.cons x env) sub_nf`, we know that x satisfies sub_nf at depth d relative to env. The depth-d (r+1)-var characteristic NF of (Fin.cons x env) is some `chi`. 

The transfer should go through the QUANTIFIER CONDITION of a HIGHER-ARITY agreement. Specifically:

From depth-(d+1) 1-var agreements at all env components, we want to build depth-(d+1) r-var agreement at env/env' (which is the CONCLUSION of the theorem at the current depth!). So this is the very statement we're proving — it's an inductive argument on depth with the quantifier step requiring the existence transfer.

**The key realization**: The proof at depth d+1 uses the IH at depth d. The IH gives depth-d r-var agreement from depth-d 1-var agreements + order + char at depths < d. The step is:

1. Atoms: From h_1var at depth d+1, extract depth-0 atom matching (weakened). ✓
2. Quantifiers: Need ∃ x, ... ↔ ∃ x', ...

For the quantifiers, we need to transfer depth-d (r+1)-var existentials. The key is:

**Use ih at depth d for the extended environment** — but we need x' with correct order first!

**FINAL ANSWER (after complete analysis)**:

The proof is actually simpler than the above analysis suggests. Here is the correct chain:

1. From `h_1var i` at depth (d+1), apply `cross_extend_bwd_1var` at EACH i to get x'_i with depth-d 2-var at [x, env i] / [x'_i, env' i].
2. All x'_i have the same depth-d 1-var type as x.
3. From the 2-var agreement at [x, env i] / [x'_i, env' i], the order atoms give: x < env i ↔ x'_i < env' i, and env i < x ↔ env' i < x'_i.
4. Now: pick ANY i₀. x'_{i₀} has the right 1-var type AND the right order relative to env' i₀.
5. For j ≠ i₀: Does x'_{i₀} have the right order relative to env' j?
   
   From step 3 at j: x < env j ↔ x'_j < env' j. So x'_j < env' j iff x < env j.
   From step 3 at i₀: x'_{i₀} has depth-d 1-var type of x.
   From step 3 at j: x'_j has depth-d 1-var type of x.
   
   So x'_{i₀} and x'_j have the SAME depth-d 1-var type. Do they have the same order relative to env' j?
   
   NOT necessarily without Prior-UZ! On a general linear order, two points with the same 1-var type can be in different positions relative to a third point.

   **On Prior structures**: The key property is that `char_fn d nf_x` characterizes the 1-var type as a TEMPORAL formula. Points satisfying the same temporal formula in a Prior structure have specific ordering constraints relative to reference points (via the first/last occurrence properties).

   **BUT**: Two points with the same temporal formula truth CAN be on different sides of a reference point (think of a periodic structure). So this still doesn't immediately give us what we need.

6. **THE ACTUAL PROOF MECHANISM** (from Rabinovich Lemma 5.1 correctly applied):

   The proof DOES NOT try to find a single witness with the right order relative to all env components. Instead, it uses the following observation:

   From `hx : nf_eval_nf M d (r+1) (Fin.cons x env) sub_nf`, we can extract:
   - The atom part: predicates of x + order of x relative to all env components
   - The quantifier part: depth-(d-1) existential conditions at arity r+2

   **For the atom part**: x's predicates transfer via 1-var agreement. x's order relative to env i is determined by the 2-var agreement at [x, env i] (from cross_extend). The 2-var agreement EXISTS (via h_1var i) and gives us x'_i with matching order. ALL x'_i have the SAME gap classification (because they all have the same 1-var type as x, and in M, x is in a specific gap). On Prior structures, if char_fn d nf_x holds at y in interval (a, b) and also at z in (a, b), there's no reason y = z, but they're both in (a, b).

   The resolution is: **we don't need x' to be the same for all i.** We need ONE x' that works for the sub_nf evaluation at arity r+1. The correct approach is:

   **Use `HasAttainedINF.first_occ` to find x' in the correct gap, then verify the full NF condition via the IH at depth d.**

   Specifically:
   - Let gap = (env' i_max, env' j_min) where i_max and j_min are adjacent in the order
   - Show existence in gap: from cross_extend at j_min, get y < env' j_min with type nf_x. Show y > env' i_max. If not, from cross_extend at i_max, get y' > env' i_max with type nf_x. Use `HasAttainedINF.first_occ` on N in interval (env' i_max, env' j_min).
   - For first_occ to apply, we need to show ∃ u ∈ (env' i_max, env' j_min) with temporal_truth N atomMap u (char_fn d nf_x).
   
   **How to show existence in the bounded interval**: This is where we need a LEMMA that combines the two cross_extend witnesses. The argument is:
   
   From cross_extend at i_max: x'_{i_max} > env' i_max with depth-d 2-var at [x, env i_max]/[x'_{i_max}, env' i_max]. Since x < env j_min in M, and the 2-var agreement encodes order relative to env i_max only, we cannot directly deduce x'_{i_max} < env' j_min.
   
   **NEW INSIGHT**: Use the FULL 1-var agreement at higher depth. Since `h_1var i_max` is at depth d+1, it encodes the QUANTIFIER CONDITION at depth d. The quantifier condition for the 1-var NF at env i_max / env' i_max includes: "for each depth-d 2-var NF chi, (∃ y with [y, env i_max] satisfying chi) iff (∃ y' with [y', env' i_max] satisfying chi)."
   
   Take chi to be a 2-var NF that FORCES y to be in (env i_max, env j_min). Specifically: chi should encode "y > env i_max AND y < env j_min AND y has 1-var type nf_x." But chi is a depth-d 2-var NF relative to env i_max — it can encode "y > env i_max" (order atom) and "y has 1-var type nf_x" (quantifier part), but NOT "y < env j_min" because env j_min is not a component of the 2-var environment.

   **This confirms the fundamental limitation of the 2-var quantifier approach.**

## Recommended Proof Architecture

After thorough analysis, the correct approach is:

### Strategy A: Unified `nvar_transfer_from_1var_agree` via Induction on r

**Induction on r** (nested inside the depth induction):
- **Base (r = 0)**: The arity-1 case. Goal: ∃ x', nf_eval_nf N d 1 (fun _ => x') sub_nf. This is trivial from `hx`: x satisfies sub_nf at arity 1, x has depth-d 1-var type nf_x, any x' with the same 1-var type works. From h_1var (vacuously, since r=0 means no env components), the only constraint is the 1-var type. Use cross_extend at any available reference.
  
  Actually r=0 means env : Fin 0 → M.carrier, so there's no reference point. The goal is ∃ x' in N with the right depth-d 1-var NF. This requires a GLOBAL existence transfer which follows from Prior-UZ (there exists some point in N satisfying char_fn d nf_x — but only if we know the type is REALIZED in N).
  
  **For r=0, the existential transfer is not generally true** without additional structure. However, if r=0 appears inside an induction that starts from a known env, this case may be degenerate.

### Strategy B: Direct Delegation to `prior_nonconstenv_2var_agree_until/since`

For the specific cases at lines 554/559/610/614, there's a more direct approach:

1. We have w₂ from cross_extend at t with depth-(K✝+1) 2-var at [w,t]/[w₂,t']
2. We have `hw : nf_eval_nf M (K+1) 3 [w, x, t] sub_nf`
3. Goal: nf_eval_nf N (K+1) 3 [w₂, x', t'] sub_nf (or some other witness)

Use `reconstruction_depth_agree` + `ih_strong`:
- From depth-(K✝+1) 2-var agree at [w,t]/[w₂,t'] (which gives K✝ ≥ K since K < K✝ from strong induction), weaken to depth-(K+1) 2-var agree.
- Combined with h_x at depth K✝+2 weakened to K+2, we have: 1-var agrees at w₂/w (depth K+1), x'/x (depth K+2), t'/t (depth K+2).
- Apply `ih_strong` at m = K-1 < K if K ≥ 1: gives depth-(K+1) 2-var agree at [x,t]/[x',t']. Wait, ih_strong gives m+2 = K+1, need m < K, so m = K-1, giving depth K+1. This works for K ≥ 1.
- For K = 0: depth-1 3-var NF is atom + quantifier at depth 0. Atoms transfer from 1-var agreements. Quantifier at depth 0 and arity 4 is just order + predicates. Should be handleable directly.

**The actual resolution for lines 554/559**: We need to show `nf_eval_nf N (K+1) 3 [w₂, x', t'] sub_nf`.

We have:
- hw₂: depth-(K✝+1) 2-var agree at [w,t]/[w₂,t']
- hw₁: depth-(K✝+1) 2-var agree at [w,x]/[w₁,x']  
- h_x: depth-(K✝+2) 1-var at x/x'
- h_t: depth-(K✝+2) 1-var at t/t'
- h_1var_w₂: depth-(K✝+1) 1-var at w/w₂
- h_1var_w₁: depth-(K✝+1) 1-var at w/w₁
- hw: nf_eval_nf M (K+1) 3 [w,x,t] sub_nf
- h_order_M: t < x, h_order_N: t' < x'

Since K < K✝ (from strong induction), K+1 ≤ K✝+1.

**Apply `nvar_transfer_from_1var_agree` at depth K+1, arity 3:**
- 1-var agreements needed at depth K+1+1 = K+2 ≤ K✝+2:
  - w: depth-(K✝+1) 1-var at w/w₂. Need K+2 ≤ K✝+1, i.e., K+1 ≤ K✝. Since K < K✝ (strict), K ≤ K✝-1, so K+1 ≤ K✝. **YES.**
  
  WAIT. `nvar_transfer_from_1var_agree` at depth d requires depth-(d+1) 1-var agreements. For d = K+1, we need depth-(K+2) 1-var agreements. We have depth-(K✝+1) at w/w₂. Need K+2 ≤ K✝+1, i.e., K+1 ≤ K✝. Since K < K✝, K ≤ K✝-1, K+1 ≤ K✝. **YES.**
  
  For x: depth-(K✝+2) at x/x'. K+2 ≤ K✝+2. **YES.**
  For t: depth-(K✝+2) at t/t'. K+2 ≤ K✝+2. **YES.**

- Order matching for [w₂, x', t']:
  - w₂ vs x': Need w < x ↔ w₂ < x'. From hw₁: depth-(K✝+1) 2-var at [w,x]/[w₁,x'] gives w < x ↔ w₁ < x'. But w₂ ≠ w₁! We need w₂'s order relative to x'.
  - w₂ vs t': From hw₂: depth-(K✝+1) 2-var at [w,t]/[w₂,t'] gives w > t ↔ w₂ > t'. **YES** (for the Until case where w is in zone 3: t < w < x, so w > t, hence w₂ > t').
  - x' vs t': From h_order_N: t' < x'. **YES.**
  - But w₂ < x': **UNKNOWN.**

This is the EXACT same gap-placement problem. We have w₂ > t' but don't know if w₂ < x'.

**THE FUNDAMENTAL ISSUE**: `cross_extend_bwd_1var` at `h_t` gives w₂ with 2-var agreement relative to t/t'. It tells us w₂'s order relative to t' but NOT relative to x'.

## Conclusion: The Root Problem and Recommended Path Forward

### Summary of the Blocker

The zone-3 gap-placement problem is a GENUINE mathematical difficulty, not a missing-lemma issue. The core challenge:

Given a point w in M with t < w < x (zone 3), and 1-var type agreement at w/w₂ (where w₂ > t'), we need to either:
(a) Show w₂ < x' (which doesn't follow from available hypotheses), or
(b) Find a DIFFERENT witness w' in N with t' < w' < x' and matching (K+1) 3-var NF.

### Recommended Implementation Strategy

**Approach: Apply `nvar_transfer_from_1var_agree` where it CAN be applied (via char_fn + HasAttainedINF), accepting that the proof requires a helper lemma for bounded-interval witness existence.**

A new helper lemma is needed:

```lean
/-- On Prior structures, if char_fn d nf_x is realized somewhere above a
    and also somewhere below b (in N), and a < b, then it is realized in (a, b). -/
theorem prior_bounded_type_realization {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (N : OrderedMonadicStructure sig)
    (h_UZ : semantic_prior_UZ N atomMap)
    (a b : N.carrier) (h_ab : a < b)
    (ψ : Formula)
    (h_above_a : ∃ s, a < s ∧ temporal_truth N atomMap s ψ)
    (h_below_b : ∃ s, s < b ∧ temporal_truth N atomMap s ψ) :
    ∃ w, a < w ∧ w < b ∧ temporal_truth N atomMap w ψ
```

**Proof of this helper**: From h_above_a, apply `semantic_prior_UZ` to get first occurrence s₀ > a with ψ. If s₀ < b, done. If s₀ ≥ b: then for any r ∈ (a, s₀) with r < b, we have ψ.neg(r) (from the first-occurrence guard). But h_below_b gives some s < b with ψ(s). If s > a then s ∈ (a, s₀), s < b ≤ s₀, so ψ.neg(s) from the guard. Contradiction with ψ(s).

So either s₀ < b (done) or s ≤ a (then h_below_b gives s < b with ψ(s) and s ≤ a, but h_above_a needs s' > a with ψ, so if s ≤ a, the witness from h_above_a is DIFFERENT from s). Actually let me redo:

From h_above_a: ∃ s₁ > a with ψ(s₁).
Apply Prior-UZ at a with ψ: get first s₀ > a with ψ(s₀), guard: ψ.neg on (a, s₀).
- If s₀ < b: then s₀ ∈ (a, b) with ψ(s₀). Done.
- If s₀ ≥ b: Then ψ.neg holds on (a, s₀) ⊇ (a, b). But from h_below_b: ∃ s₂ < b with ψ(s₂). If s₂ > a: s₂ ∈ (a, b) ⊂ (a, s₀), so ψ.neg(s₂). Contradiction.
  If s₂ ≤ a: Then the witness from h_below_b is ≤ a. But h_below_b says s₂ < b. This is fine (s₂ ≤ a < b). But we haven't used that ψ(s₂) gives a contradiction. The issue is: h_below_b gives existence BELOW b but not necessarily ABOVE a.

**CORRECTED HELPER STATEMENT**: We need both bounds simultaneously:

```lean
theorem prior_bounded_type_realization
    ...
    (h_in_interval : ∃ s, a < s ∧ s < b ∧ temporal_truth N atomMap s ψ) :
    -- trivially ∃ w ∈ (a,b) with ψ (just use s)
```

That's trivial. The real question is: can we DERIVE h_in_interval from the available data?

**Derivation**: From cross_extend at h_1var j_min (with x < env j_min), we get y₂ in N with:
- depth-d 2-var at [x, env j_min] / [y₂, env' j_min]
- y₂ < env' j_min (from order atom in 2-var, since x < env j_min)
- depth-d 1-var at x / y₂ (from cross_1var_from_2var)

We need y₂ > env' i_max. From the 2-var agreement, we only know y₂ < env' j_min. We DON'T know y₂ > env' i_max.

**However**: From cross_extend at h_1var i_max (with env i_max < x), we get y₁ in N with:
- y₁ > env' i_max
- depth-d 1-var at x / y₁

If y₁ < env' j_min: y₁ ∈ (env' i_max, env' j_min). Done.
If y₁ ≥ env' j_min: then y₁ ≥ env' j_min > env' i_max. And y₂ < env' j_min. If y₂ > env' i_max: y₂ ∈ (env' i_max, env' j_min). Done.
If y₂ ≤ env' i_max: Then neither y₁ nor y₂ is in the interval.

**In this last case**: We know:
- y₁ ≥ env' j_min with char_fn d nf_x (temporal_truth at y₁)
- y₂ ≤ env' i_max with char_fn d nf_x (temporal_truth at y₂)
- env' i_max < env' j_min

Apply Prior-UZ at env' i_max with ψ = char_fn d nf_x: existence witness is y₁ > env' i_max. Get first occurrence s₀ > env' i_max with ψ(s₀). Since s₀ ≤ y₁ (first occurrence), and y₁ has ψ, s₀ ≤ y₁.

Is s₀ < env' j_min? If s₀ ≥ env' j_min: Then ψ.neg holds on (env' i_max, s₀). Since env' j_min ≤ s₀, interval (env' i_max, s₀) ⊇ (env' i_max, env' j_min). But we DON'T have a witness in (env' i_max, env' j_min) with ψ to contradict the guard.

**KEY DIFFICULTY**: We cannot derive s₀ < env' j_min without already having a witness in (env' i_max, env' j_min).

### The Missing Piece: Why the Proof Should Work

On Prior structures (Dedekind complete chains with UZ/SZ), if a temporal formula ψ is realized above a and below b (where a < b), it IS realized in (a, b). This is because:
- The first occurrence above a is ≤ any other occurrence above a
- Any occurrence below b that is also > a gives a witness in (a, b)

But our issue is: we have y₁ > env' i_max with ψ(y₁) and y₂ < env' j_min with ψ(y₂). If y₂ > env' i_max, done. If y₂ ≤ env' i_max, then y₂ is NOT above env' i_max, so we CAN'T use "ψ realized above env' i_max and below env' j_min."

We CAN'T derive that ψ is realized in (env' i_max, env' j_min) from the available data alone!

**THEREFORE**: The correct proof must use a DIFFERENT mechanism. The approach used in the existing `cross_extend` witnesses is insufficient.

### The Correct Mechanism: Use the QUANTIFIER CONDITION at depth d+1

The quantifier condition of `h_1var i_max` at depth d+1 encodes:
```
∀ chi : NormalForm sig d 2,
  (∃ y, nf_eval_nf M d 2 (Fin.cons y (fun _ => env i_max)) chi) ↔
  (∃ y', nf_eval_nf N d 2 (Fin.cons y' (fun _ => env' i_max)) chi)
```

Take chi = `nf_characteristic M d 2 (Fin.cons x (fun _ => env i_max))`.
Since x > env i_max, this chi encodes:
- Atom: predicates of x at var 0, predicates of env i_max at var 1, order: x > env i_max
- Quantifier: depth-(d-1) 3-var existentials relative to [y, x, env i_max]

The transfer gives ∃ y' with depth-d 2-var at [x, env i_max] / [y', env' i_max]. This is `cross_extend_bwd_1var` — the same y₁ we already have!

The 2-var NF chi encodes the fact that x > env i_max AND x has certain predicates AND certain quantifier conditions relative to env i_max. From this 2-var NF, we can extract that the 1-var type of y' is nf_x. But chi does NOT encode x's position relative to env j_min.

**To encode x's position relative to env j_min**, we would need a 3-var NF at [x, env i_max, env j_min]. The transfer of this requires depth-d FULL 3-var agreement — which is what we're trying to prove!

### Conclusion

The zone-3 gap-placement IS circular at this level of the proof. The resolution requires ONE of:

1. **A different proof architecture**: Instead of `nvar_transfer_from_1var_agree` with a single induction on d, use a MUTUAL induction on (d, r) where the proof at (d+1, r) uses (d, r+1) from the IH.

2. **The Rabinovich approach via temporal formula encoding**: Express the entire (r+1)-var existential as a TEMPORAL FORMULA (which is what `ExistPart(k)` in `KampMutualInduction.lean` does). Once we have temporal formulas for existentials at all depths, Prior-UZ/SZ can localize witnesses to bounded intervals.

3. **Restructure**: Make `prior_nonconstenv_2var_agree_until/since` not call `nvar_transfer_from_1var_agree`, but instead use `exist_transfer_from_full_agree` (which works for the 2-var case because both structures agree at the reference depth K✝+1) and then handle only the arity-3 quantifier step separately.

### Recommended Path: Strategy 3

For lines 554/559/610/614, DON'T use `nvar_transfer_from_1var_agree`. Instead:

1. From hw (depth-(K+1) 3-var eval at [w,x,t]), and hx/ht (depth-(K✝+2) 1-var at x/x', t/t'), use `exist_transfer_from_full_agree` applied to the 2-var agreement at [x,t]/[x',t'] to transfer the 3-var existential.

2. Specifically: if we have depth-(K+2) 2-var agreement at [x,t]/[x',t'] (which follows from `ih_strong` at m=K for K < K✝, giving depth-(K+2) 2-var agree... wait, ih_strong gives m+2 for m < K, so max depth is K+1 when m = K-1).

   Actually `ih_strong` gives: for m < K, depth-(m+2) 2-var agree. So at m = K-1 (for K ≥ 1): depth-(K+1) 2-var agree at [x,t]/[x',t']. Then `exist_transfer_from_full_agree` applied to this depth-(K+1) 2-var agree gives: depth-K 3-var existential transfer.

   But we need depth-(K+1) 3-var existential transfer (the goal). K+1 > K. So `exist_transfer_from_full_agree` gives us transfer ONE DEPTH SHORT.

3. **Alternative for K = 0**: Direct atom-level argument (depth-1 3-var is atoms + depth-0 4-var, which is purely atomic).

4. **For K ≥ 1**: Use `reconstruction_depth_agree` at the 2-var level. From ih_strong at m = K-1 < K: depth-(K+1) 2-var agree. Then `exist_transfer_from_full_agree` gives depth-K 3-var transfer. This is ONE SHORT of the needed K+1.

   The remaining gap (from depth-K to depth-(K+1) at 3-var) requires the SAME zone-3 argument at one level lower — i.e., it's recursive.

### Final Recommendation: Resolve via `nvar_transfer_from_1var_agree` with Prior-UZ Squeeze Lemma

The correct implementation path:

1. **Prove `prior_bounded_type_realization_from_cross`**: A helper that says: given cross_extend witnesses from adjacent bounds (y₁ > a with type ψ, y₂ < b with type ψ), show ∃ w ∈ (a, b) with type ψ on Prior structures. The proof uses:
   - Case y₁ < b: done.
   - Case y₂ > a: done.  
   - Case y₁ ≥ b AND y₂ ≤ a: This case is actually IMPOSSIBLE on Prior structures when ψ is a characteristic temporal formula at sufficient depth. The reason: the depth-(d+1) quantifier condition at env i_max encodes "which types occur above env i_max" and "which types occur below env i_max." If x ∈ (env i_max, env j_min) has type nf_x, and this interval is non-empty (guaranteed by h_order), the quantifier condition of h_1var i_max at sub-NF chi (encoding type nf_x in the Until-direction with a bound) should FORCE the witness to be bounded.

   The technical content: the 2-var NF at [x, env i_max] encodes "x > env i_max" AND "x has certain quantifier conditions relative to env i_max." One of these conditions is "there is no point z with env i_max < z < x of type nf_{env j_min}" (because in M, there is no env component between env i_max and env j_min except possibly x). This information IS encoded in the NF and transfers.

   **This is where the mutual induction structure is needed**: to encode the bounded-interval constraint, we need temporal formulas at lower depths.

2. **Estimated implementation**: 200-400 lines for `nvar_transfer_from_1var_agree` + helper lemmas.

## Adversarial Self-Verification

| Claim | Verified? | Notes |
|---|---|---|
| "6 sorries reduce to one root problem" | VERIFIED | Lines 554/559/610/614 all require the same mechanism as 459/462 |
| "cross_extend gives order relative to ONE reference" | VERIFIED | Type signature of cross_extend_bwd_1var confirmed |
| "Two cross_extend witnesses might not land in same gap" | VERIFIED | Concrete scenario constructed |
| "Prior-UZ first_occ can localize witnesses" | VERIFIED via HasAttainedINF.first_occ | But requires existence in the interval as precondition |
| "Existence in bounded interval is the key sub-lemma" | HIGH CONFIDENCE | All approaches converge on this |
| "`ih_strong` gives depth K+1 (one short)" | VERIFIED | ih_strong at m=K-1<K gives m+2=K+1, need K+2 for exist_transfer to reach depth K+1 |
| "nvar_transfer_from_1var_agree is circular without bounded realization" | VERIFIED | The IH at depth d needs order matching, which needs the theorem at depth d |

### Uncertain Claims (Low Confidence)

- "The y₁ ≥ b AND y₂ ≤ a case is impossible on Prior structures at sufficient depth" — This is the KEY UNVERIFIED MATHEMATICAL CLAIM. It may be true via NF encoding but requires careful proof.
- "200-400 lines estimated" — Could be 400-800 if the bounded realization helper is complex.

### Revised Direction

The initial problem statement's proposed mechanism (steps 1-6) is INCOMPLETE. Step 5 ("using semantic_prior_UZ on N with char_fn") requires proving existence in the bounded interval, which is the actual hard step. The correct approach requires proving a **bounded interval realization lemma** for Prior structures, which itself requires the mutual induction machinery from `KampMutualInduction.lean`.

## Estimated Line Count

- `prior_bounded_type_realization` helper: 40-80 lines
- Gap classification + cross_extend orchestration: 60-100 lines
- Full `nvar_transfer_from_1var_agree` quantifier step: 120-200 lines
- Delegation from `prior_nonconstenv_2var_agree_until/since`: 40-60 lines per sorry (x4 = 160-240 lines)
- Total: **380-620 lines**
