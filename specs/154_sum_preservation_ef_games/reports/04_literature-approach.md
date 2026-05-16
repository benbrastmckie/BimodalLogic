# Research Report 04: Literature-Grounded Approach to Sum Preservation

**Task**: 154 - sum_preservation_ef_games
**Session**: sess_1778896377_48cac6
**Date**: 2026-05-15
**Focus**: Review literature for mathematically correct approach to the lifting lemma blocker

## Literature Proof Structure

**Source**: Doets (1987) Lemma 3.1.7 / Doets (1989) Lemma 1.4
**Strategy**: EF game duplicator strategy on ordered sums

### The One-Sentence Proof

Doets 1989, p. 227:
> "It is straightforward to describe a winning strategy for the second player in the Ehrenfeucht n-game between these sums under the condition given."

Doets 1987, p. 42 (Lemma 3.1.7):
> "If for all i in I, m(i) =^n m'(i), then Sum_{i in I} m(i) =^n Sum_{i in I} m'(i)."

### Step Map (EF Game Translation)

The EF game proof works as follows. Player I and Player II play a k-round game on orderedSum ms vs orderedSum ms'. The duplicator (Player II) maintains the invariant:

1. **Index preservation**: After each round r, each pair of chosen elements (x_r, y_r) satisfies x_r.1 = y_r.1 (same component index).

2. **Component strategy delegation**: When Player I picks element (a, i) in Sum m(i), Player II uses the component-i winning strategy (from m(i) =^k m'(i)) to find b in m'(i), and responds with (b, i).

3. **Partial isomorphism maintenance**: The resulting correspondence is a partial isomorphism because:
   - **Predicates**: Preserved by component strategy (same component, same NF).
   - **Cross-component order**: (a, i) < (b, j) iff i < j in I. Since indices match, this is automatic.
   - **Same-component order**: (a, i) < (b, i) iff a <_{m(i)} b. Preserved by component partial isomorphism.

4. **Budget accounting**: Component-i starts with a k-round winning strategy. After using r_i rounds in component i (where sum of all r_i = total rounds used), there are k - r_i rounds left for component i. Since the total game length is k and each round is spent in exactly one component, each component's strategy never exceeds its budget.

### Dependencies

- Step 3 depends on Step 1 and Step 2.
- Step 4 is implicit: the component equivalence at depth k provides enough "budget" for all rounds because the EF game has exactly k rounds total, and the component's strategy at depth k can handle k rounds.

### Translation to Normal Form Language

The NF translation of the EF game uses the correspondence (Doets 1987 Theorem 1.6.3 / 1989 Lemma 1.1):

- n-equivalence (EF game) <=> same n-characteristics (NFs) <=> same truth values for all formulas of quantifier depth <= n.

The duplicator strategy translates to: **the ordered-sum depth-k n-var NF characteristic of an environment is determined by the indices plus the component-level NF characteristics of the elements within each component.**

## Diagnosis: Why the Order Atom Blocker Recurs

### Root Cause

Three approaches (original sum_nf_agree, joint NF v3, bootstrap v4) all hit the same wall because they all attempt a **1-variable-at-a-time lifting strategy** that is fundamentally mismatched with the EF game argument:

1. **1-var component transfer finds b**: Given a in ms(i), find b in ms'(i) with the same component depth-k 1-var NF.

2. **1-var NF does not encode order relative to other elements**: The depth-k 1-var NF of element a in ms(i) records predicates on a and existential realization at depth k-1 with 2 vars. But it does NOT record the order of a relative to specific other elements in the structure.

3. **The quantifier step at depth k, n=1 requires depth-(k-1) at n=2**: This introduces order atoms between the NEW element and the EXISTING element. The 1-var matching of the new element does not determine these order atoms.

### Why This Is Fundamental

The gap is NOT a Lean formalization artifact -- it reflects a genuine mathematical issue:

- In the EF game, the duplicator chooses witnesses WITHIN the game context, maintaining partial isomorphism at each step. The order information is part of the partial isomorphism invariant.

- In the NF framework, the "1-var component NF" is an ABSOLUTE property of an element, independent of other elements. It cannot encode relative order relationships.

- The correct NF translation of the duplicator strategy requires MULTI-var component NF matching (tracking all elements chosen so far in each component), not 1-var matching followed by a separate lifting argument.

### Why Sentence-Level Bootstrap Cannot Work

The bootstrap approach (v4) tries to avoid the issue by working at n=0 (no atoms) and delegating to the lifting lemma. But the lifting lemma at depth k, n=1 needs depth-(k-1) at n=2, which has order atoms. The approach pushes the problem down one level but does not eliminate it.

Key calculation: `ih_k` gives ordered-sum depth-k agreement at n=0. By quantifier extraction, this gives depth-(k-1) transfer at n=1 (one level short). We need depth-k at n=1 to close the sorry, but we only get depth-(k-1).

**The depth budget is always short by exactly 1 when using sentence-level agreement to derive 1-var agreement.**

## Correct Mathematical Approach

### The Right Induction: Depth as the Induction Variable, All Variable Counts Simultaneously

The correct proof is by induction on **depth d** (decreasing), proving NF agreement for ALL variable counts n simultaneously. The key insight from `nf_agreement_monotone` (NormalForm.lean:339-421) is:

- Each quantifier step reduces depth by 1 and increases n by 1.
- The total "budget" (depth + #rounds used) stays constant.
- Component (k+1)-equivalence provides k+1 units of budget, enough for all k+1 quantifier layers.

### Detailed Architecture

```
sum_nf_agree_general (d : Nat) :
  For all n, environments env_M, env_N with:
    (1) Index matching: (env_M j).1 = (env_N j).1
    (2) Component elements matching: within each component, the elements
        have matching component NFs at appropriate depths
  Then:
    ∀ nf : NormalForm sig d n,
    nf_eval_nf (orderedSum ms) d n env_M nf ↔
    nf_eval_nf (orderedSum ms') d n env_N nf

Induction on d:

d=0 (base): 
  Only atoms. Three cases:
  - pred p j: evaluates to (ms (env_M j).1).interp p (env_M j).2
    Agreement from component-level atom matching.
  - order j1 j2 with (env_M j1).1 != (env_M j2).1 (cross-component):
    Evaluates to (env_M j1).1 < (env_M j2).1, which equals
    (env_N j1).1 < (env_N j2).1 by index matching. Automatic.
  - order j1 j2 with (env_M j1).1 = (env_M j2).1 = i (same component):
    Evaluates to (env_M j1).2 <_{ms i} (env_M j2).2, which matches
    (env_N j1).2 <_{ms' i} (env_N j2).2 by component NF matching.

d+1 (step):
  Atom part: same as d=0.
  Quantifier part: for sub_nf at depth d, n+1 vars.
    Given witness x = ⟨j, c⟩ in orderedSum ms:
      1. Use component-j equivalence to find c' in ms'(j) with matching
         component NF at depth d (derived from component k-equiv via
         nf_agreement_monotone on the component).
      2. Set witness y = ⟨j, c'⟩.
      3. Extended environments: Fin.cons ⟨j,c⟩ env_M and Fin.cons ⟨j,c'⟩ env_N.
      4. These satisfy the hypothesis at depth d, n+1 vars because:
         - Index matching: j = j (new element) + inherited.
         - Component matching: c and c' have matching component NFs
           (from step 1), and existing elements are unchanged.
      5. Apply IH at depth d, n+1 vars.
      6. Get sub_nf agreement -> conclude c' satisfies sub_nf.
```

### The Component Matching Hypothesis

The compatibility condition on environments is the main formalization challenge. There are two viable approaches:

**Approach A: Full Component Projection (Complex but General)**

Define: for env_M : Fin n -> (orderedSum ms).carrier, the "component-i projection" is the sub-environment restricted to elements in component i. The hypothesis states that for each component i, the component-i projections of env_M and env_N have the same depth-(d + n_i) 0-var NF in ms(i) / ms'(i), where n_i = |{j | (env_M j).1 = i}|.

This is mathematically correct but hard to formalize: variable-length projections, dependent types for the restricted environments.

**Approach B: Pairwise Atom Matching (Simpler, Sufficient)**

Define compatibility as: the environments agree on ALL atoms at n variables:
```
h_atoms : ∀ a : AtomKind sig n,
  atom_eval (orderedSum ms) env_M a ↔ atom_eval (orderedSum ms') env_N a
```

Plus: for each element j, the component-level depth-d NFs match:
```
h_elem : ∀ j : Fin n,
  nf_characteristic (ms (env_M j).1) d 1 (![(env_M j).2]) =
  nf_characteristic (ms' (env_N j).1) d 1 (![(env_N j).2])
```

This suffices for d=0 (atom verification). For d+1, the quantifier step finds witnesses via component transfer (using `h_elem` to extract the right component NF, then peeling to get multi-var transfer). The key question is whether `h_elem` (1-var NF per element) suffices for the same-component order atoms between multiple elements in the same component.

**The answer is: h_elem alone does NOT suffice for same-component multi-element order.** Two elements with identical 1-var NFs can be in either relative order. This is exactly the blocker we've been hitting.

**Approach C: Component-Aware Transfer Chain (Recommended)**

Instead of formulating the compatibility condition as a static hypothesis, CONSTRUCT the matching environments dynamically by chaining component transfers. The proof uses a single induction on d + n (the "total budget"):

```
sum_nf_agree_budget (K : Nat) :
  ∀ (d n : Nat) (hdn : d + n ≤ K)
  (h_comp : ∀ i, k_equiv sig K (ms i) (ms' i))
  (env_M : Fin n → (orderedSum ms).carrier)
  (env_N : Fin n → (orderedSum ms').carrier)
  (h_idx : ∀ j, (env_M j).1 = (env_N j).1)
  -- Key: environments were constructed by a chain of component transfers
  -- such that within each component, elements share matching NFs
  -- Formally: there exists a depth-(K-n) n-var NF agreement in each component
  (h_comp_env : ∀ j : Fin n,
    -- For each index j, the elements (env_M j).2 and (env_N j).2 in
    -- component (env_M j).1 have matching component NFs at depth (K-n)
    -- with respect to all previously-chosen same-component elements
    [appropriate condition])
  (nf : NormalForm sig d n),
  nf_eval_nf (orderedSum ms) d n env_M nf ↔
  nf_eval_nf (orderedSum ms') d n env_N nf
```

The "appropriate condition" is the hard part. The cleanest formulation I can find is:

**Condition**: The depth-(d+n) n-var NF characteristics of env_M and env_N in the ordered sums are EQUAL:

```
nf_characteristic (orderedSum ms) (d+n) n env_M = nf_characteristic (orderedSum ms') (d+n) n env_N
```

Wait -- but this is STRONGER than what we're trying to prove (we're trying to prove depth-d agreement, and this asserts depth-(d+n) agreement). However, it IS maintainable: when extending environments by a new element found via ordered-sum transfer at depth (d+n-1), the new environments share a depth-(d+n-1) (n+1)-var NF. Since d decreases by 1 and n increases by 1, d+n stays at the same value K = d + n.

But to establish the initial condition, we need depth-K 0-var ordered-sum NF agreement, which is exactly what we're trying to prove!

**This is circular.**

### Breaking the Circularity: The Two-Level Proof

The circularity breaks if we separate two concerns:

1. **Level 1**: Prove depth-K 0-var ordered-sum NF agreement (sentence level).
2. **Level 2**: From Level 1, derive everything else via `nf_agreement_monotone` on the ordered sums.

Level 2 is trivial: `nf_agreement_monotone` gives depth-m n-var agreement for any m <= K, n <= K, as long as we can establish depth-K n-var agreement. But `nf_agreement_monotone` only steps DOWN in depth, not up in n. So we need Level 1 to provide depth-K at n=0, and then something else to extend to higher n.

**But `nf_agreement_monotone` DOES handle this!** Look at its proof again: from depth-K agreement at n vars, it derives depth-m agreement at n vars (m <= K). In the quantifier step, it finds matching witnesses via the depth-K NF's quantifier part (which gives transfer at depth K-1 with n+1 vars). The witness sharing gives depth-(K-1) agreement at n+1 vars (via `nf_agreement_from_shared_nf`). Then IH steps down from K-1 to m at n+1 vars.

This means: if we prove depth-K ordered-sum agreement at n=0, then `nf_agreement_monotone` AUTOMATICALLY gives us depth-m agreement at n=0 for m <= K. But we need depth-m at n=1 for the quantifier step of the OUTER proof.

`nf_agreement_monotone` gives depth-m at n=0, not at n=1. To get depth-m at n=1, we'd need depth-K at n=1, which `nf_agreement_monotone` can't provide from n=0.

**HOWEVER**, `nf_agreement_monotone` provides depth-m at n=0, and from depth-m at n=0 (for large enough m), we can extract quantifier transfer at depth m-1 with n=1. From the transfer, `nf_agreement_from_shared_nf` gives depth-(m-1) at n=1. This is ONE level down.

For the main proof at step k+1, we need depth-k at n=1. If we have depth-(k+1) at n=0, extracting gives depth-k at n=1. **And we're proving depth-(k+1) at n=0!** This is not circular -- at step k+1, the IH gives us depth-k at n=0, and extracting from that gives depth-(k-1) at n=1. We need depth-k at n=1. Off by 1.

### The Resolution: Combined Induction

**The only way to close the gap is to prove the sentence-level agreement AND the 1-var lifting lemma simultaneously, in a single induction on k.**

Prove by induction on k:

**Claim(k)**: Both of the following hold:
- (A) Sentence-level: ∀ nf : NormalForm sig k 0, ordered-sum NFs agree at depth k, n=0.
- (B) Lifting: For all i, a, b with matching component depth-k 1-var NFs: ∀ nf : NormalForm sig k 1, ordered-sum NFs agree at depth k, n=1 for ![⟨i,a⟩] and ![⟨i,b⟩].

**Base (k=0)**:
- (A): AtomKind sig 0 is empty, vacuously true.
- (B): AtomKind sig 1 has only pred atoms, agreement from component matching.

**Step (k -> k+1)**:
- (A) at k+1: Atoms vacuous. Quantifier step: given ⟨i,b⟩ in orderedSum ms', use component transfer to find a with same component depth-k 1-var NF. Apply (B) at k to get depth-k 1-var ordered-sum NF agreement. Then `nf_agreement_from_shared_nf` gives sub_nf satisfaction.

- (B) at k+1: Atoms are pred-only at n=1, OK. Quantifier step at depth k, n=2: given ⟨j,c⟩ in orderedSum ms. Find c' via component transfer. Need depth-k 2-var ordered-sum NF agreement for Fin.cons ⟨j,c⟩ ![⟨i,a⟩] and Fin.cons ⟨j,c'⟩ ![⟨i,b⟩].

  This requires a GENERALIZED lifting lemma at depth k with n=2. The combined induction only proves (A) and (B) at depth k (from IH), not a generalized n=2 version.

  **To handle this, we need (B) generalized to all n, making it essentially the full multi-var lifting lemma.** But then (B) at depth k+1 with n+1 vars needs (B) at depth k with n+2 vars... infinite regress.

**THE DEPTH ALWAYS DECREASES BY 1 PER VAR ADDED, SO THE REGRESS TERMINATES AT DEPTH 0 AFTER k+1 STEPS.**

This works! The combined induction should be:

**Claim(k)**: For all d <= k, for all n <= k - d, for all compatible environments of size n:
  ∀ nf : NormalForm sig d n, ordered-sum NFs agree.

This is equivalent to: for all d + n <= k, for all compatible environments of size n, depth-d n-var NFs agree.

Induction on k. At step k+1:
- Need to prove depth-d n-var agreement for d + n <= k + 1.
- If d + n <= k, use IH directly.
- If d + n = k + 1:
  - If n = 0: prove depth-(k+1) 0-var agreement (sentence level). Atoms vacuous. Quantifier step: need depth-k 1-var agreement. Since k + 1 = k + 1 and IH covers d + n <= k, we need d=k and n=1, so d + n = k + 1. This is NOT covered by IH. **Circular again.**

Hmm. The issue is that at d + n = k + 1, EVERY case of the quantifier step moves to d + n = k + 1 (d decreases by 1, n increases by 1). The total stays at k + 1, never decreasing.

**The combined induction on k (total budget) does NOT work because the budget doesn't decrease through quantifier steps.**

### The Actual Working Approach: Induction on d (depth), Not on k (budget)

Let me reconsider. In `nf_agreement_monotone`, the induction IS on m (the target depth), not on k (the starting depth). And k is a PARAMETER that stays fixed throughout.

For the ordered sum, the analogous structure is:

**Theorem (sum_nf_agree_multi)**: For all d, for all n, for all compatible environments:
  ∀ nf : NormalForm sig d n, ordered-sum NFs agree.

Induction on d:
- d=0: atoms only. Verify directly from compatibility.
- d+1: atoms + quantifiers.
  - Atoms: verify from compatibility.
  - Quantifier step: given witness ⟨j,c⟩, find ⟨j,c'⟩ via component transfer at depth d (available from component equivalence). The extended environments are compatible at depth d (one less than d+1). Apply IH at depth d.

The key: component transfer at depth d requires component depth-(d+1) equivalence at the right number of variables. From component K-equivalence (K large enough), by `nf_agreement_monotone` on the component, we get component depth-(d+1) r-var agreement for any r with d+1+r <= K.

At each step, d decreases by 1 and n increases by 1. After all quantifier peelings, we reach d=0 with n = (original d). The component transfer at step r from depth d needs component equivalence at depth d+1 with r+1 vars total in that component. Since d + (r+1) <= d + n + 1 = original_d + 1, and we need component equivalence >= this, we need K >= original_d + 1.

For the sentence-level case: original_d = k+1, so K >= k+2. But we only have K = k+1 (component k+1 equivalence from k-equivalence with k-equiv-monotone).

**Wait -- from the hypothesis `∀ i, k_equiv sig k (ms i) (ms' i)`, we get component k-equivalence. For the proof of ordered-sum k-equivalence, the sentence-level case has d = k, n = 0. Quantifier step goes to d = k-1, n = 1. Component transfer needs component depth-k equivalence at 1 var. From component k-equiv, by nf_agreement_monotone on the component, we get depth-k at 0 vars. To get depth-k at 1 var, we need depth-(k+1) at 0 vars... which we don't have. OFF BY 1 AGAIN.**

Hmm. But wait -- in the EF game, the components are k-equivalent, and the game has k rounds. The duplicator uses one round to respond to each element, so after using k rounds, there are k elements with depth-0 agreement. This works because depth-0 is atoms only.

In NF language: from component k-equivalence, we can peel k quantifiers: depth-k at 0 vars -> depth-(k-1) at 1 var -> depth-(k-2) at 2 vars -> ... -> depth-0 at k vars.

So with k-equivalent components, we can handle environments of up to k elements at depth 0. For depth d with n vars, we need d + n <= k.

For the sentence-level proof of depth-k at n=0: d=k, n=0, total=k. The quantifier step goes to d=k-1, n=1, total=k. Component transfer at this step uses component depth-k at 0 vars (extracting quantifier part gives depth-(k-1) at 1 var transfer). Next step: d=k-2, n=2, total=k. Component transfer uses component depth-(k-1) at 1 var (available from first peeling). Each step uses the component equivalence at one lower depth.

**THIS WORKS!** The total budget is k (from component k-equivalence). At each step, d decreases by 1 and n increases by 1, keeping d+n = k. The component transfer at step r uses component depth-(k-r) at r vars, available from k-equivalence by peeling r quantifiers.

But the hypothesis for `sum_nf_agree_sentence` is component (k+1)-equivalence (from `k_equiv sig (k+1) (ms i) (ms' i)`, obtained from `h_comp` which gives agreement at all depths m <= k+1). Wait, let me recheck the actual hypothesis in the code.

Looking at line 161-162 of NEquivalence.lean:
```
(h_comp : ∀ (m : Nat), m ≤ k → ∀ i, ∀ nf : NormalForm sig m 0,
  nf_eval_nf (ms i) m 0 Fin.elim0 nf ↔ nf_eval_nf (ms' i) m 0 Fin.elim0 nf)
```

This gives component agreement at all depths m <= k for n=0 (sentence level). This IS component k-equivalence (depth-k 0-var agreement).

But `sum_nf_agree_sentence` is called at depth k, and the hypothesis gives component agreement at depths <= k. For the proof at depth k (n=0), the quantifier step needs depth-(k-1) at n=1. Component transfer uses component depth-k at 0 vars (from h_comp at m=k). Quantifier extraction gives depth-(k-1) at 1 var transfer.

Now, from the depth-(k-1) 1-var transfer, we find witnesses with the same depth-(k-1) 1-var NF. Then `nf_agreement_from_shared_nf` gives depth-(k-1) 1-var agreement for the extended environments. But we need depth-(k-1) 1-var agreement **in the ordered sum**, not just in the component.

This is the lifting lemma. And for the lifting lemma at depth k-1 with n=1, the quantifier step needs depth-(k-2) at n=2. And so on. The total budget is k.

**The lifting lemma can be proved by induction on d, with the hypothesis that component agreement at depth d+1 (or higher) provides the necessary transfer.**

Here's the full proof architecture:

```
-- Helper: given component k-equiv, extract component depth-d (r+1)-var transfer
-- (by peeling from depth-(d+1) 0-var agreement to depth-d 1-var agreement)

-- Main: prove ordered-sum depth-d n-var NF agreement
-- by induction on d, for all n, with component K-equiv (K >= d + n)
sum_nf_agree_full (d : Nat) :
  ∀ (n : Nat)
  (h_comp : ∀ (m : Nat), m ≤ d + n → ∀ i, ∀ nf : NormalForm sig m 0,
    nf_eval_nf (ms i) m 0 Fin.elim0 nf ↔ nf_eval_nf (ms' i) m 0 Fin.elim0 nf)
  (env_M : Fin n → (orderedSum sig I ms).carrier)
  (env_N : Fin n → (orderedSum sig I ms').carrier)
  (h_idx : ∀ j, (env_M j).1 = (env_N j).1)
  (h_env_agree : [component-level multi-var agreement for env elements])
  (nf : NormalForm sig d n),
  nf_eval_nf (orderedSum ms) d n env_M nf ↔
  nf_eval_nf (orderedSum ms') d n env_N nf
```

The `h_env_agree` hypothesis states that the elements in env_M and env_N have matching component-level NFs. The precise formulation is:

For each j : Fin n, the component depth-d n-var NFs of env_M and env_N agree when restricted to component (env_M j).1. Equivalently:

```
h_env_agree : ∀ j : Fin n, ∀ nf_c : NormalForm sig d n_j,
  nf_eval_nf (ms (env_M j).1) d n_j (proj_M j) nf_c ↔
  nf_eval_nf (ms' (env_N j).1) d n_j (proj_N j) nf_c
```

where `n_j` is the number of elements from component (env_M j).1 and `proj_M j` / `proj_N j` are the projected sub-environments.

**This is extremely hard to formalize in Lean due to the variable-size projections and dependent types.**

### Recommended Simplification: Atom-Level Compatibility

Instead of the full component projection, use a WEAKER but SUFFICIENT condition:

```
h_atoms : ∀ a : AtomKind sig n,
  atom_eval (orderedSum ms) env_M a ↔ atom_eval (orderedSum ms') env_N a
```

This covers:
- All pred atoms (element-level predicate matching)
- All order atoms (both cross-component and same-component)

Combined with:
- h_idx (index matching)
- h_comp (component K-equivalence at sentence level)

This suffices because:
1. At d=0: h_atoms directly gives the result.
2. At d+1: h_atoms gives the atom part. For the quantifier part, given witness ⟨j,c⟩ in orderedSum ms:
   a. Get c's depth-d 1-var component NF: `char_c := nf_characteristic (ms j) d 1 (![c])`.
   b. Use component transfer at depth d, 1 var (from component (d+1)-equiv, extracting quantifier part): find c' in ms' j with the same depth-d 1-var component NF.
   c. Extended environment atoms agree:
      - pred p (0) [new element]: from component matching of c, c'.
      - pred p (j+1) [existing elements]: from h_atoms.
      - order 0 (j+1) with same component: c and (env_M j').2 have their order determined by component NF matching for (c, env_M j'.2) vs (c', env_N j'.2). But this requires 2-var component matching, not just 1-var.

**This fails for the same-component order atom.** We need 2-var component matching to verify the order between the new element c and existing same-component elements. 1-var matching doesn't provide this.

### ACTUAL Solution: Replace h_atoms with Stronger Hypothesis Using nf_agreement_from_shared_nf

The trick is to use `nf_agreement_from_shared_nf` at each step to get the FULL depth-d NF agreement, not just atom agreement. The proof structure is:

1. At the quantifier step: given ⟨j,c⟩ satisfying sub_nf at depth d with n+1 vars in orderedSum ms.
2. Get c's depth-(d+n) 1-var NF in ms j (using component depth-(d+n+1) equiv).
   Wait -- we only have component equiv at depth d+n (from h_comp at m = d+n <= K).
   From component depth-(d+n) 0-var equiv, extract quantifier part to get depth-(d+n-1) 1-var transfer. Find c' with same depth-(d+n-1) 1-var component NF.
3. By `nf_agreement_from_shared_nf` on the COMPONENT, c and c' agree on all depth-(d+n-1) 1-var NFs.
4. By `nf_agreement_monotone` on the component, stepping from depth-(d+n-1) to depth-d: c and c' agree on all depth-d 1-var component NFs (since d <= d+n-1 when n >= 1).
   Wait, we need d+n-1 >= d, i.e., n >= 1. Since we're in the quantifier step which adds one var (going from n to n+1), n could be 0 at the start.
   
   If n = 0 (sentence level), the quantifier step goes to n=1. Component transfer uses depth-(d+0) = depth-d equiv. From depth-d 0-var equiv, extract depth-(d-1) 1-var transfer. Find c' with same depth-(d-1) 1-var NF.
   
   Then we need depth-d 1-var agreement. We have depth-(d-1) 1-var agreement. Off by 1. AGAIN.

**Unless we use a STRONGER component transfer.**

From component depth-K equiv (K = d+n), we don't just get depth-(K-1) 1-var transfer. We actually have depth-K 0-var agreement, and from the depth-K characteristic at 0 vars, the quantifier part gives depth-(K-1) 1-var transfer. This means we find c' with the same depth-(K-1) 1-var NF. Then `nf_agreement_from_shared_nf` gives depth-(K-1) at 1 var.

Now, by `nf_agreement_monotone` on the component from depth-(K-1) to depth-d: need d <= K-1, i.e., d <= d+n-1, i.e., n >= 1. For n >= 1, this works. For n = 0, K = d and we get depth-(d-1) at 1 var. Off by 1.

**The n=0 case (sentence level) with d = k is where the gap lives.** Component k-equiv only gets us to depth-(k-1) at 1 var. We need depth-k at 1 var.

**THIS IS EXACTLY THE SAME GAP.** The gap of 1 depth level is intrinsic to the relationship between sentence-level equivalence and 1-var equivalence.

### Breaking the Impasse: The hypothesis should be (k+1)-equivalence, not k-equivalence

Looking at the code again, `sum_nf_agree_sentence` is parameterized by:
```
h_comp : ∀ (m : Nat), m ≤ k → ∀ i, ...
```

But `sum_preservation_proof` calls it with:
```
h_comp' : ∀ (m : Nat), m ≤ k → ...
```
derived from `h_comp : ∀ i, k_equiv sig k (ms i) (ms' i)`.

So the actual hypothesis is component k-equivalence, and we're trying to prove ordered-sum k-equivalence. This is correct per Doets' statement. The question is whether the PROOF can go through with this hypothesis.

In the EF game, k-equivalent components DO give k-equivalent sums. The k-round game on the sum uses one round per element, and each component's k-round strategy has enough budget.

The NF gap arises because the NF framework encodes the game differently: depth-k 0-var agreement does NOT directly give depth-k 1-var agreement. It only gives depth-(k-1) 1-var agreement.

**But in the EF game, choosing one element uses one round. After the first move, there are k-1 rounds left. And depth-(k-1) at 1 var IS what remains.**

This means the NF framework IS working correctly: after choosing one element from the sum (first quantifier layer), we have k-1 depth units left with 1 element. This gives depth-(k-1) 1-var agreement, which is exactly what `nf_agreement_monotone` can derive.

The issue is that we're asking for depth-k at 1 var, which corresponds to k rounds with 1 pre-placed element. But in the EF game, placing one element uses one round, leaving k-1 rounds. So depth-k at 1 var would require k+1 rounds total (1 for placing + k for playing), which exceeds our budget of k.

**This means we should NOT be proving depth-k at 1 var from k-equivalent components. We should be proving depth-(k-1) at 1 var.**

And indeed, the quantifier step of `sum_nf_agree_sentence` at depth k+1 needs depth-k at 1 var. This corresponds to k+1 total budget (1 quantifier used + k remaining), and the components are (k+1)-equivalent (from `h_comp` at depth k+1, via `sum_preservation_proof` which calls with `h_comp' : ∀ m ≤ k → ...` derived from component k-equivalence). Wait, let me re-read `sum_preservation_proof`:

```lean
sum_preservation_proof : ∀ (k : Nat) ... 
  (∀ i, k_equiv sig k (ms i) (ms' i)) →
  k_equiv sig k (orderedSum sig I ms) (orderedSum sig I ms')

h_comp' : ∀ (m : Nat), m ≤ k → ∀ i, ∀ nf' : NormalForm sig m 0,
    nf_eval_nf (ms i) m 0 Fin.elim0 nf' ↔ nf_eval_nf (ms' i) m 0 Fin.elim0 nf'
```

So `h_comp'` gives component agreement at ALL depths m <= k. And `sum_nf_agree_sentence` is called at depth k.

In `sum_nf_agree_sentence` at depth k+1 (the induction step), the hypothesis `h_comp` gives component agreement at m <= k+1. The quantifier step goes to depth k with 1 var.

From component agreement at m = k+1 (depth k+1, 0 vars), by extracting the quantifier part, we get depth-k 1-var transfer. This gives c' with same depth-k 1-var NF. But we need depth-k 1-var agreement IN THE ORDERED SUM (the lifting lemma). From depth-k 1-var component NF matching, we need to prove depth-k 1-var ordered-sum NF matching.

And for the lifting lemma, the QUANTIFIER step at depth k with 1 var needs depth-(k-1) with 2 vars. Component transfer for the new element uses component depth-k agreement at 1 var (from component depth-(k+1) 0-var equiv, peeled once). This gives depth-(k-1) 2-var component NF matching for the pair. Then the lifting lemma at depth k-1, 2 vars, needs depth-(k-2) at 3 vars. Continue peeling.

After r steps: depth-(k-r) at (r+1) vars. Component transfer uses component depth-(k-r+1) at r vars (from (k+1)-equiv peeled r times). Need (k+1) - r >= k - r + 1, i.e., k+1-r >= k-r+1, i.e., 0 >= 0. TRUE. The budget is always sufficient.

Bottoms out at r = k: depth-0 at (k+1) vars. Atom verification. Component budget used: k+1 levels peeled from (k+1)-equiv.

**SO THE PROOF WORKS WITH THE EXISTING HYPOTHESIS `h_comp : ∀ m ≤ k+1`** (which is what the code provides at the inductive step).

The complete proof requires a JOINT INDUCTION with a parameter tracking the remaining depth:

```
sum_nf_lift (d : Nat) : ∀ (n : Nat),
  -- Component agreement at depth d+n+1 (sentence level) provides enough budget
  (h_comp : ∀ (m : Nat), m ≤ d + n + 1 → ∀ i, ∀ nf : NormalForm sig m 0,
    nf_eval_nf (ms i) m 0 Fin.elim0 nf ↔ nf_eval_nf (ms' i) m 0 Fin.elim0 nf) →
  ∀ (env_M : Fin n → (orderedSum sig I ms).carrier)
    (env_N : Fin n → (orderedSum sig I ms').carrier),
  (h_idx : ∀ j, (env_M j).1 = (env_N j).1) →
  -- Component-level multi-var agreement for existing elements
  (h_env_comp : [see below]) →
  ∀ (nf : NormalForm sig d n),
  nf_eval_nf (orderedSum ms) d n env_M nf ↔
  nf_eval_nf (orderedSum ms') d n env_N nf
```

Induction on d. At the quantifier step (d+1 -> d), the component transfer finds a new witness, and the IH at depth d handles the extended environment. The component budget is d + n + 1, which decreases to d + (n+1) + 1 = d + n + 2... wait, that INCREASES. That's wrong.

Let me redo. The budget should be a FIXED parameter K = d + n + 1. When d decreases to d-1 and n increases to n+1, the budget becomes (d-1) + (n+1) + 1 = d + n + 1 = K. It stays the same!

So the hypothesis should use a FIXED K:

```
sum_nf_lift (K : Nat) (d n : Nat) (hdn : d + n + 1 ≤ K + 1) :
  ...
```

With K fixed, the induction on d works: d decreases while n increases, keeping d+n constant.

**The h_env_comp hypothesis**: This is the "component-level multi-var NF agreement" for the elements in the environment. The cleanest formulation I can see is:

For all j : Fin n, consider the sub-environment of elements from component (env_M j).1. Let this have size r_j. Then the component-level depth-d r_j-var NFs agree for these sub-environments.

But this is STILL hard to formalize due to variable-size projections.

### Practical Recommendation

**Given the formalization complexity, the recommended approach is:**

1. **Reformulate `sum_nf_agree_sentence` to use a well-founded recursion on d (depth), quantifying over all n simultaneously.**

2. **Use a simplified compatibility condition**: The ordered-sum environments agree on all atoms (which captures index matching, predicates, and order). This is:
   ```
   h_atoms_agree : ∀ a : AtomKind sig n,
     atom_eval (orderedSum ms) env_M a ↔ atom_eval (orderedSum ms') env_N a
   ```

3. **For the quantifier step**: Find witnesses via the ordered sum's OWN quantifier transfer from a higher-depth agreement, NOT via component transfer.
   
   Specifically: from component depth-(d+n+1) 0-var agreement (h_comp at m = d+n+1), prove ordered-sum depth-(d+n+1) 0-var agreement (by an INNER induction, or by an earlier call). From this, by `nf_agreement_monotone`, get ordered-sum depth-(d+1) 0-var agreement. From this, extract ordered-sum quantifier transfer at depth d, 1 var. Then use this to find witnesses. `nf_agreement_from_shared_nf` gives depth-d (n+1)-var agreement for the extended environments, which includes all atoms (order + preds). Apply IH at depth d.
   
   **Wait -- this requires ordered-sum depth-(d+1) 0-var agreement as a SUB-RESULT.** If d+1 < the outer level, this is available from the outer IH of `sum_nf_agree_sentence`. If d+1 = the outer level, it's what we're proving.

   In `sum_nf_agree_sentence` at step k+1, we need the lifting lemma at depth k. The lifting lemma at depth k with n=1 needs ordered-sum depth-(k+1) 0-var agreement... which is what we're proving. CIRCULAR.

   BUT: in the lifting lemma, d starts at k and decreases. At d=k, n=0 (this is the sentence-level case, not the lifting case). The lifting starts at d=k, n=1 (the first quantifier step of the sentence-level proof). For the quantifier sub-step, we need d=k-1, n=2. The ordered-sum depth-k 0-var agreement (from `ih_k`, the outer IH) suffices to extract depth-(k-1) 1-var transfer. This finds a witness with depth-(k-1) 1-var NF. Then `nf_agreement_from_shared_nf` gives depth-(k-1) (n+1=2)-var agreement. Apply IH at depth k-1.

   But we need depth-k at n=1, not depth-(k-1). The transfer from depth-k 0-var gives depth-(k-1) 1-var transfer. The witness has depth-(k-1) 1-var NF matching. This is ENOUGH for the lifting at depth k-1, n=1 (using the IH of the lifting lemma). But we need the lifting at depth k, n=1.

   **THE GAP IS FUNDAMENTAL AND CANNOT BE CLOSED BY ANY REARRANGEMENT OF THE EXISTING NF INFRASTRUCTURE.**

4. **The only solution is one of:**
   a. Add a new lemma to NormalForm.lean that directly proves depth-d n-var NF agreement from depth-d 0-var agreement + index matching + component equivalence (a "sum-specific monotonicity" lemma).
   b. Reformulate the proof to avoid the lifting lemma entirely, using a game-theoretic or back-and-forth approach that is native to the NF framework.
   c. Prove a general "sum NF composition" lemma that shows the ordered-sum NF decomposes into component NFs + index structure.

### Option (c): Sum NF Decomposition (Recommended)

Prove:
```
theorem sum_nf_decomposition :
  nf_characteristic (orderedSum ms) k n env_M =
  f(indices, component_chars)
```

where `f` computes the ordered-sum NF from the indices and per-component NFs. This would immediately give: if two environments have the same indices and same component NFs, they have the same ordered-sum NF.

This is the NF analogue of the EF game observation that the ordered-sum game decomposes into per-component games plus index comparisons.

**However, formalizing this decomposition for arbitrary k and n is extremely complex.**

## Final Recommendation

### The Mathematically Correct Approach

The proof requires a **generalized lifting lemma** proved by induction on depth d, for all n simultaneously, with a component-level compatibility hypothesis that tracks multi-var NF agreement per component. The induction terminates because d strictly decreases at each quantifier step (while n increases by 1).

The core difficulty is formalizing the component-level multi-var compatibility condition in Lean's type system. This requires:
1. A way to project an n-element environment to the elements from a single component
2. Agreement of component NFs at depth d with the projected variable count
3. Maintaining this invariant when extending the environment

### Proposed Implementation Strategy

**Phase 1: Define component projection infrastructure**
- Define `componentProj (env : Fin n -> (orderedSum ms).carrier) (i : I) : Finset (Fin n)` = indices of elements from component i.
- Define `componentEnv (env : Fin n -> (orderedSum ms).carrier) (i : I) : Fin |componentProj env i| -> (ms i).carrier` = projected sub-environment.
- Prove basic properties: disjoint components cover all indices, extensions by same-component elements grow the projection by 1, etc.

**Phase 2: Formulate and prove the generalized lifting lemma**
- State: for environments with matching indices and matching component NFs at each depth, the ordered-sum NFs agree.
- Prove by induction on d.
- At d=0: verify atoms from component NF matching + index matching.
- At d+1: find witnesses via component transfer, verify extended compatibility, apply IH.

**Phase 3: Apply to close the 4 sorries**
- Use the lifting lemma inside `sum_nf_agree_sentence` to handle the quantifier step.

### Alternative: Simpler but Sufficient for n=1

If the full component projection infrastructure is too complex, a simpler version that handles only n=1 environments (sufficient for the quantifier step of `sum_nf_agree_sentence`) may work:

For n=1 environments `![⟨i,a⟩]` and `![⟨i,b⟩]`:
- Only one component (i) has elements. Component projection is trivial.
- Component compatibility: `∀ nf, nf_eval_nf (ms i) d 1 (![a]) nf ↔ nf_eval_nf (ms' i) d 1 (![b]) nf`
- The quantifier step at d+1 creates n=2 environments. These can have:
  - Both elements in component i: component compatibility requires depth-d 2-var matching in ms i. Available from component (d+1)-equiv peeled once.
  - Elements in different components (i and j): cross-component order is automatic. Component compatibility for i: 1-var at depth d (from hypothesis). For j: 1-var at depth d (from component transfer). No multi-var same-component matching needed.

**This n=1 specialization avoids the full projection infrastructure.** The quantifier step produces n=2 environments, but for cross-component pairs, no multi-var same-component matching is needed. For same-component pairs (both in component i), 2-var matching comes from peeling the component (d+1) 1-var agreement.

**The recursion**: at depth d+1 with n=1, the quantifier step goes to depth d with n=2. Within this, the next quantifier step goes to depth d-1 with n=3. Etc. But at each step, the new element may or may not be in the same component as existing elements. The same-component case requires progressively deeper component matching, which is available from the initial component equivalence (budget = d + n + 1 from the original h_comp).

**The n=1 specialization STILL requires handling arbitrary n in the inner recursion.** The inner recursion handles n=2, n=3, etc. up to d+1.

### Revised Final Recommendation

Given the analysis:

1. **The bootstrap sentence-level approach (plan v4) is on the right track** but needs the lifting lemma, which requires handling arbitrary n, not just n=1.

2. **The lifting lemma requires a generalized multi-var formulation** with induction on d (depth decreasing, n increasing, total d+n staying constant).

3. **The component projection infrastructure** is the main engineering challenge. Define it as helper functions with properties proved in a dedicated section.

4. **Alternatively, consider a direct `sum_nf_characteristic` decomposition** that relates the ordered-sum NF to component NFs + index structure, if a cleaner mathematical formulation can be found.

5. **The plan v4 should be revised** to include the multi-var generalization of the lifting lemma. The current plan only addresses n=1, which is insufficient.

6. **Estimated additional effort**: 8-12 hours for the component projection infrastructure + generalized lifting lemma + integration with `sum_nf_agree_sentence`.

## Existing Infrastructure Inventory

### Available in NormalForm.lean
- `nf_characteristic_satisfies`: every (M, env) satisfies its characteristic NF
- `nf_eval_unique`: if two NFs are both satisfied, they are equal
- `nf_exists_unique`: each (M, env) satisfies exactly one NF
- `nf_agreement_from_shared_nf`: shared NF implies agreement on all NFs at that depth
- `nf_agreement_monotone`: depth-k agreement implies depth-m agreement (m <= k)
- `atom_agreement_from_nf`: NF agreement implies atom agreement
- `doets_lemma_1_1`: bridge theorem (NF agreement <=> formula agreement)

### Available in NEquivalence.lean
- `orderedSum`: ordered sum construction with `Sigma.Lex.linearOrder`
- `atomKind_zero_elim`: `AtomKind sig 0 → False`
- `sum_nf_agree_sentence`: partial proof with 4 sorries at the lifting step
- `sum_preservation_proof`: delegates to `sum_nf_agree_sentence`
- `KEquivalenceFramework` instance: delegates to `sum_preservation_proof`

### Key Properties to Verify/Use
- `AtomKind sig 1` has pred atoms ONLY (no order atoms) -- this makes the n=1 atom case trivial
- `AtomKind sig n` for n >= 2 has both pred and order atoms
- `orderedSum` carrier order is `Sigma.Lex.linearOrder` -- cross-component order is by index, same-component order is by component order
- Component (k+1)-equivalence gives depth-k 1-var transfer via quantifier extraction
