# Teammate C Findings: Alternative Proof Strategies and Literature Analysis

**Task**: 154 - sum_preservation_ef_games
**Date**: 2026-05-15
**Focus**: Is there a fundamentally simpler approach that avoids the BiCompat abstraction?

## Executive Summary

After detailed study of Doets (1987/1989), `nf_agreement_monotone`, and the current code, I conclude: (1) the BiCompat abstraction is on the right track and closely mirrors the literature; (2) there IS a simpler approach -- replace `sum_nf_lift_gen` + BiCompat with a SINGLE induction on depth d that mirrors `nf_agreement_monotone`'s quantifier step directly, doing ordered-sum-level transfer rather than component transfer; (3) this eliminates BiCompat entirely by combining the lifting and sentence-level proofs. The key insight is that `nf_agreement_monotone` already provides the template for the quantifier step, and the only missing piece is establishing that component-level transfer produces ordered-sum-level witnesses with matching NFs.

## Literature Analysis

### Doets' Original Argument (Lemma 1.4 / Lemma 3.1.7)

Doets 1989 Lemma 1.4 states:
> "If for all i in I, m(i) =^n m'(i), then Sum_{i in I} m(i) =^n Sum_{i in I} m'(i)."

The proof is described as "straightforward" using the EF game technique. The duplicator's strategy is:

1. When Player I picks element (a, i) in Sum m(i), Player II responds with (b, i) in Sum m'(i), choosing b via the component-i n-game winning strategy.
2. The strategy is well-defined because the component-i strategy handles all rounds that involve elements from component i.
3. The partial isomorphism is maintained because cross-component order is determined by indices (which match), and same-component order/predicates are preserved by the component partial isomorphism.

### The Generalized Version (Doets 1989 Lemma 1.5)

Doets 1989 Lemma 1.5 generalizes to non-identical index sets:
> Sum_{i in I} m(i) =^n Sum_{j in J} m'(j) whenever (I, {i | m(i) |= sigma})_{sigma in Sigma} =^n (J, {j | m'(j) |= sigma})_{sigma in Sigma}

This requires that the INDEX structures agree on the distribution of n-characteristics. Lemma 1.4 is the special case where I = J and each m(i) =^n m'(i) (so the index structures are identical up to n-equivalence).

### Translation to NF Language

The EF game proof translates to the NF framework as follows:

- n-equivalence <=> same n-characteristics (Doets 1987 Theorem 1.6.3)
- The duplicator strategy becomes: given environments in two ordered sums, the NF characteristics agree if indices match and component elements have matching NFs.
- Each quantifier step (adding one element) reduces the remaining depth by 1 and increases the number of elements by 1, keeping total budget constant.

### Key Structural Insight from nf_agreement_monotone

`nf_agreement_monotone` (NormalForm.lean:339-421) proves: depth-k n-var NF agreement implies depth-m n-var NF agreement for m <= k. Its quantifier step works by:

1. From depth-k agreement, extract depth-k characteristic NFs for M and N.
2. Show they are the SAME characteristic (N satisfies M's characteristic).
3. Use the quantifier part: `hex_transfer_k` gives bi-directional transfer at depth k-1 with n+1 vars.
4. For a given element y in N at depth m, find y's depth-(k-1) NF, transfer to get x in M with the SAME depth-(k-1) NF.
5. `nf_agreement_from_shared_nf` gives FULL depth-(k-1) (n+1)-var agreement.
6. IH steps down from k-1 to m at (n+1) vars.

**Critical observation**: `nf_agreement_monotone` does NOT need to track per-element NF state. It works because `nf_agreement_from_shared_nf` automatically gives full NF agreement from shared characteristic NF, and the transfer finds witnesses with the SAME NF in both structures.

## Analysis of the Current Approach

### What BiCompat Does

`BiCompat sig d n I ms ms' env_M env_N` is a recursive predicate that pre-packages the witness oracles for all d quantifier levels. At depth d+1, it provides:
- Forward: for each j,c', find c with atom agreement + recursive BiCompat at depth d
- Backward: for each j,c, find c' with atom agreement + recursive BiCompat at depth d

`sum_nf_lift_gen` then uses these pre-packaged witnesses to prove NF agreement by induction on d.

### Why BiCompat Is Hard to Construct

The 4 sorry sites in `sum_nf_agree_sentence` are all at the point where BiCompat must be constructed. The difficulty is that BiCompat requires atom agreement for the EXTENDED ordered-sum environments, which includes same-component order atoms -- and these order atoms require multi-var component NF agreement that must be built up iteratively through a chain of component transfers.

The chain of component transfers is the structural complexity that has proven intractable across 2 implementation rounds.

### Is BiCompat Overcomplicated?

**Yes.** BiCompat separates the witness finding (building the oracle) from the witness using (the induction in `sum_nf_lift_gen`). This separation is the source of complexity: the oracle must be constructed BEFORE the induction, but the information needed to construct it is naturally available DURING the induction.

## Proposed Alternative: Direct Induction Without BiCompat

### The Core Idea

Replace `sum_nf_lift_gen` + BiCompat construction with a SINGLE definition `sum_nf_lift_direct` that proves ordered-sum NF agreement by induction on d, finding witnesses ON THE FLY during the induction -- exactly as `nf_agreement_monotone` does.

The key principle: **do not separate witness construction from the induction**. Instead, at each quantifier step within the induction, find witnesses using ordered-sum-level transfer (derived from component transfer), then use `nf_agreement_from_shared_nf` on the ordered sum to get full NF agreement for the extended environments.

### Detailed Architecture

```lean
private theorem sum_nf_lift_direct (sig : MonadicSignature) :
    ∀ (d : Nat) (n : Nat) (I : Type) [LinearOrder I]
    (ms ms' : I → OrderedMonadicStructure sig)
    (h_comp : ∀ (m : Nat), m ≤ d + n → ∀ i, ∀ nf : NormalForm sig m 0,
      nf_eval_nf (ms i) m 0 Fin.elim0 nf ↔ nf_eval_nf (ms' i) m 0 Fin.elim0 nf)
    (env_M : Fin n → (orderedSum sig I ms).carrier)
    (env_N : Fin n → (orderedSum sig I ms').carrier)
    (h_agree_higher : ∀ nf : NormalForm sig (d + n) n,
      nf_eval_nf (orderedSum sig I ms) (d + n) n env_M nf ↔
      nf_eval_nf (orderedSum sig I ms') (d + n) n env_N nf)
    (nf : NormalForm sig d n),
    nf_eval_nf (orderedSum sig I ms) d n env_M nf ↔
    nf_eval_nf (orderedSum sig I ms') d n env_N nf
```

This is structurally identical to `nf_agreement_monotone` with `k := d + n` and `m := d`. The hypothesis `h_agree_higher` gives depth-(d+n) n-var ordered-sum NF agreement, and we prove depth-d n-var agreement.

**Why this works**: `nf_agreement_monotone` already handles this! The ordered sums are just two structures M and N. If we have depth-(d+n) agreement at n vars, `nf_agreement_monotone` immediately gives depth-d agreement at n vars.

Wait -- this IS just `nf_agreement_monotone` applied to the ordered sums. So the question becomes: can we establish depth-(d+n) n-var ordered-sum NF agreement from component equivalence?

### The Real Question: Establishing the Higher-Depth Agreement

For `sum_nf_agree_sentence` at depth k+1, we need ordered-sum depth-(k+1) 0-var agreement. If we could establish depth-(k+1) 0-var agreement, then `nf_agreement_monotone` gives everything else.

The sentence-level case (n=0) IS what `sum_nf_agree_sentence` proves. The current proof structure (induction on k) is correct for this.

So the actual question is: at the inductive step of `sum_nf_agree_sentence(k+1)`, can we close the quantifier sub-step WITHOUT BiCompat?

### The Direct Quantifier Step

At `sum_nf_agree_sentence(k+1)`, the quantifier step requires: for `sub_nf : NormalForm sig k 1`, show

```
(exists x : (orderedSum ms).carrier, nf_eval_nf (orderedSum ms) k 1 (![x]) sub_nf) <->
(exists y : (orderedSum ms').carrier, nf_eval_nf (orderedSum ms') k 1 (![y]) sub_nf)
```

Given `⟨i, b⟩` with `nf_eval_nf (orderedSum ms') k 1 (![⟨i,b⟩]) sub_nf`:

1. Get b's depth-k 1-var NF in ms' i: `char_b := nf_characteristic (ms' i) k 1 (![b])`
2. Transfer to find a in ms i with same depth-k 1-var NF (from component (k+1)-equiv extracting quantifier part)
3. **Key claim**: `nf_eval_nf (orderedSum ms') k 1 (![⟨i,b⟩]) sub_nf` implies `nf_eval_nf (orderedSum ms) k 1 (![⟨i,a⟩]) sub_nf`

Step 3 is the gap. We know a and b have the same depth-k 1-var COMPONENT NF in ms i / ms' i. We need the same depth-k 1-var ORDERED-SUM NF for `⟨i,a⟩` vs `⟨i,b⟩`.

**At n=1, `AtomKind sig 1` has ONLY pred atoms** (proved by `atomKind_one_pred_only`). So the depth-k 1-var ordered-sum NF differs from the component NF ONLY in the quantifier part, where quantification ranges over the full ordered sum rather than just the component.

This is exactly the point where the proof needs the lifting lemma: component depth-k 1-var agreement does NOT imply ordered-sum depth-k 1-var agreement because the quantifier domains differ.

### A Simpler Lifting Approach: Mutual Induction on (k, d)

Instead of BiCompat, use a MUTUAL induction that simultaneously proves:

- **Claim A(k)**: `sum_nf_agree_sentence` at depth k (ordered-sum depth-k 0-var agreement)
- **Claim B(k, d)**: For d <= k and environments `![⟨i,a⟩]`, `![⟨i,b⟩]` with matching component depth-d 1-var NFs AND the property that `Claim A(m)` holds for all m < k, then depth-d 1-var ordered-sum NF agreement holds.

The mutual induction:

**Base A(0)**: Vacuous (AtomKind sig 0 empty).

**Base B(k, 0)**: Atoms only. At n=1, only pred atoms. Component NF matching gives pred agreement. Ordered-sum pred atoms = component pred atoms at n=1 (since interp is per-component). So atom agreement follows directly.

**Step B(k, d+1)**: Given component depth-(d+1) 1-var NF matching for a, b:
- Atom part: pred atoms from component NF matching (same as base).
- Quantifier part at depth d, n=2: given `⟨j,c⟩` in orderedSum ms. Two cases:
  - **j = i (same component)**: Use component depth-d 2-var transfer (from component depth-(d+1) 1-var, extract quantifier to get depth-d 2-var transfer). Find c' with same depth-d 2-var component NF for (c, a) vs (c', b). Component NF matching at 2 vars gives both pred and ORDER agreement within the component. For ordered-sum order:
    - Cross-component order (between ⟨j,c⟩ and existing env elements in different components): automatic from index matching.
    - Same-component order (between ⟨i,c⟩ and ⟨i,a⟩): from component 2-var NF matching.
  - **j != i (different component)**: Find c' via component j transfer from Claim A(m) for appropriate m (available by IH). Cross-component order is automatic. No same-component order issue.

  Now need depth-d 2-var ordered-sum NF agreement. This requires a FURTHER generalization of Claim B to arbitrary n, not just n=1.

**This is the fundamental issue**: Claim B at depth d+1 with n=1 requires Claim B at depth d with n=2. And Claim B at depth d with n=2 requires Claim B at depth d-1 with n=3. And so on until depth 0.

### The ACTUAL Simplification: One Induction, Arbitrary n

The simplest correct proof is:

```lean
theorem sum_nf_agree_full (sig : MonadicSignature) :
    ∀ (d : Nat) (n : Nat) (I : Type) [LinearOrder I]
    (ms ms' : I → OrderedMonadicStructure sig)
    -- Component sentence-level equivalence at depth d+n
    (h_comp : ∀ (m : Nat), m ≤ d + n → ∀ i, ∀ nf : NormalForm sig m 0,
      nf_eval_nf (ms i) m 0 Fin.elim0 nf ↔ nf_eval_nf (ms' i) m 0 Fin.elim0 nf)
    -- Environments with index matching
    (env_M : Fin n → (orderedSum sig I ms).carrier)
    (env_N : Fin n → (orderedSum sig I ms').carrier)
    (h_idx : ∀ p : Fin n, (env_M p).1 = (env_N p).1)
    -- Per-component multi-var NF agreement for env elements
    -- (key hypothesis: for each component j, the elements from j agree at depth d)
    (h_comp_env : ∀ (j : I),
      let proj_M := fun (p : { q : Fin n // (env_M q).1 = j }) => (env_M p.1).2
      let proj_N := fun (p : { q : Fin n // (env_N q).1 = j }) =>
        (h_idx p.1 ▸ show (ms' (env_N p.1).1).carrier from (env_N p.1).2 : (ms' j).carrier)
      ∀ nf : NormalForm sig d (Fintype.card { q : Fin n // (env_M q).1 = j }),
        nf_eval_nf (ms j) d _ proj_M nf ↔ nf_eval_nf (ms' j) d _ proj_N nf)
    (nf : NormalForm sig d n),
    nf_eval_nf (orderedSum sig I ms) d n env_M nf ↔
    nf_eval_nf (orderedSum sig I ms') d n env_N nf
```

But as noted in report 04, the `h_comp_env` with variable-size projections is EXTREMELY hard to formalize. The dependent subtype `{ q : Fin n // (env_M q).1 = j }` has variable cardinality, making the environment type depend on runtime data.

### The Pragmatic Solution: Keep BiCompat but Simplify Construction

Given the formalization difficulty of the "correct" approach, the pragmatic solution is to keep the BiCompat architecture (which is already proved in `sum_nf_lift_gen`) and find a simpler way to CONSTRUCT the BiCompat instance.

**Key insight for simplification**: Instead of constructing BiCompat for arbitrary environments from scratch, construct it by induction on d using the following:

At depth d+1, BiCompat requires forward and backward witness oracles. For each (j, c') in ms':

1. **Component j has no existing elements from env**: Use component (d+n)-equiv to find c. Atom agreement for cross-component elements comes from index matching. Recursive BiCompat at depth d comes from IH (with one more element in component j).

2. **Component j has existing elements from env**: Use `component_extend_fwd` (already proved sorry-free) to find c with extended component NF agreement. Same-component atom agreement comes from `atom_agreement_from_nf` on the component. Cross-component atom agreement comes from index matching. Recursive BiCompat at depth d comes from IH.

The construction IS a recursive function `build_bicompat : d -> ... -> BiCompat sig d n ...` by induction on d, where at each level we call `component_extend_fwd/bwd` to get the witnesses and derive atom agreement from the component NF agreement.

**What has been missing**: A clear way to TRACK the per-component NF state through the recursion. The prior attempts tried to track this explicitly (CompNFState), which was too complex.

**Simpler tracking**: Instead of explicit per-component state, use the ORDERED-SUM NF agreement itself as the state. At each level, from ordered-sum depth-(d+n) n-var agreement (available from `sum_nf_agree_sentence` IH + `nf_agreement_monotone`), extract the quantifier transfer to find witnesses. Then `nf_agreement_from_shared_nf` on the ordered sum gives depth-(d+n-1) (n+1)-var agreement for extended environments.

**Wait -- this is `nf_agreement_monotone` applied to the ordered sums.** The circular dependency is: we need ordered-sum depth-(d+n) n-var agreement, but that is what we are trying to prove.

### Breaking the Circle: The Budget Shift

The key realization from the budget analysis in report 04:

- `sum_nf_agree_sentence(k+1)` has `h_comp` at depths m <= k+1.
- The quantifier step goes from depth k+1 n=0 to depth k n=1. Budget: d+n = k+1.
- Component transfer uses component depth-(k+1) 0-var equiv (h_comp at m=k+1).
- Extracting quantifier gives depth-k 1-var component transfer.
- `component_extend_fwd` gives depth-k 1-var component NF agreement.
- Need ordered-sum depth-k 1-var NF agreement -- THIS is the lifting.

For the lifting at depth k n=1:
- Quantifier step goes to depth k-1 n=2. Budget: d+n = k+1.
- Component transfer uses component depth-k 1-var equiv (from component k+1 equiv, peeled once).
- But we need to KNOW the ordered-sum depth-k 1-var NF agreement for the CURRENT environments to apply `nf_agreement_monotone` and extract quantifier transfer at the ordered-sum level.

**THIS is where the circularity lives**: ordered-sum depth-k 1-var agreement IS the lifting lemma, and its quantifier step needs itself at lower depth.

### The ACTUAL Working Solution: Induction on d (the lifting depth)

The correct induction is on d within the lifting lemma, NOT on k:

```
sum_nf_lift(d) : For all n, if component (d+n)-equiv and env compatibility,
  then ordered-sum depth-d n-var NF agreement.

Base (d=0): Atoms only. Verify from component NF matching + index matching.

Step (d+1): Atoms from component NF matching. Quantifier step:
  Given ⟨j,c⟩ in orderedSum ms satisfying sub_nf at depth d, (n+1) vars:
  1. Find c' in ms' j via component transfer from component (d+n+1)-equiv.
     Specifically: component depth-(d+n+1) 0-var equiv -> extract quantifier ->
     depth-(d+n) 1-var transfer. Get c' with same depth-(d+n) 1-var component NF.
  2. From depth-(d+n) 1-var component NF matching, by nf_agreement_monotone on
     the COMPONENT, get depth-d 1-var component NF matching. This gives pred
     agreement and (when combined with existing elements) order agreement within
     the component.
  3. For the extended environments at depth d, (n+1) vars:
     - h_idx still holds (new indices match).
     - Component NF matching: c and c' have depth-d 1-var matching in component j.
       Combined with existing same-component elements' matching (from hypothesis),
       by component_extend we get depth-d (r+1)-var matching where r = current
       same-component element count.
  4. Apply IH at depth d with (n+1) vars. Budget: d + (n+1) = (d+1) + n. Component
     (d+n+1)-equiv >= d + n + 1 = (d + (n+1)) + 0. CHECK: we need component
     equiv at depth d + (n+1) = d + n + 1. We have component equiv at depths
     m <= d + n + 1 (from original h_comp at m <= (d+1) + n). OK!

Key: the IH at depth d needs h_comp at m <= d + (n+1) = d + n + 1. The original
h_comp gives m <= (d+1) + n = d + n + 1. So the budget is EXACTLY met.
```

**This works AND avoids BiCompat.** The atom agreement for same-component order comes from `component_extend_fwd/bwd` (which uses component multi-var NF agreement to guarantee order preservation). The IH at depth d handles the rest.

But the hypothesis `h_comp_env` (per-component multi-var NF agreement) is still needed and still involves variable-size projections.

### Alternative: Use h_atoms + h_comp without explicit component projections

Here is the simplest formulation I can find that avoids both BiCompat AND component projections:

```lean
theorem sum_nf_lift_simple (sig : MonadicSignature) :
    ∀ (d : Nat) (n : Nat) (I : Type) [LinearOrder I]
    (ms ms' : I → OrderedMonadicStructure sig)
    (h_comp : ∀ (m : Nat), m ≤ d + n → ∀ i, ∀ nf : NormalForm sig m 0,
      nf_eval_nf (ms i) m 0 Fin.elim0 nf ↔ nf_eval_nf (ms' i) m 0 Fin.elim0 nf)
    (env_M : Fin n → (orderedSum sig I ms).carrier)
    (env_N : Fin n → (orderedSum sig I ms').carrier)
    -- Atom agreement at n vars
    (h_atoms : ∀ a : AtomKind sig n,
      atom_eval (orderedSum sig I ms) env_M a ↔
      atom_eval (orderedSum sig I ms') env_N a)
    -- Index matching
    (h_idx : ∀ p : Fin n, (env_M p).1 = (env_N p).1)
    -- For each quantifier step, we can find a matching witness
    -- This is provided by the following recursive witness property:
    -- (implicitly: component multi-var NF agreement allows finding witnesses)
    (nf : NormalForm sig d n),
    nf_eval_nf (orderedSum sig I ms) d n env_M nf ↔
    nf_eval_nf (orderedSum sig I ms') d n env_N nf
```

The question is: can we close the quantifier step using ONLY h_atoms + h_idx + h_comp? Without a witness oracle (BiCompat) or explicit component projections?

**Answer: No.** At the quantifier step, we need to FIND a matching witness ⟨j,c'⟩ given ⟨j,c⟩. The witness must have atom agreement with the EXTENDED environment (including same-component order). h_atoms gives agreement for the CURRENT environment but tells us nothing about the new element. h_comp gives component sentence-level agreement but not how to match the new element to existing same-component elements.

**This is why BiCompat (or an equivalent witness oracle) is necessary.** The EF game argument finds witnesses dynamically, using the component strategy. In the NF framework, this dynamic witness finding must be encoded somehow. BiCompat is one encoding; component projection + multi-var NF agreement is another.

## Concrete Recommendation

### Approach 1: Keep BiCompat, Simplify Construction via extend_atoms

The current `sum_nf_lift_gen` + BiCompat architecture is correct and already proved. The task reduces to constructing BiCompat instances at the 4 sorry sites. The `extend_atoms` helper (already proved) and `component_extend_fwd/bwd` (already proved) provide the building blocks.

**Construction recipe for BiCompat sig k 1 I ms ms' (![⟨i,a⟩]) (![⟨i,b⟩])**:

By induction on k (decreasing).

Base (k=0): `BiCompat sig 0 ... = True`. Trivial.

Step (k+1): Need forward and backward oracles. For a given (j, c') in ms' j:

**Case j != i (cross-component)**:
- Find c via component (k+1)-equiv at j: from h_comp at m = k+1, get component j's depth-(k+1) 0-var agreement. Extract quantifier to get depth-k 1-var transfer. Find c with same depth-k 1-var component NF as c'.
- Atom agreement: pred atoms from component NF via `atom_agreement_from_nf`. Order atoms between ⟨j,c⟩ and ⟨i,a⟩: this is cross-component (j != i), so `⟨j,c⟩ < ⟨i,a⟩ ↔ j < i`, which equals `⟨j,c'⟩ < ⟨i,b⟩ ↔ j < i`. Automatic from index matching.
- Apply `extend_atoms` to get full atom agreement at n+1=2 vars.
- Recursive BiCompat at depth k, n+1=2: apply IH at k with updated parameters.

**Case j = i (same-component)**:
- Find c via `component_extend_fwd` from the 1-var component NF agreement of a,b at depth k+1. This gives c with depth-k 2-var component NF agreement for (c,a) vs (c',b).
- Atom agreement: pred atoms from component NF. Same-component order atoms `⟨i,c⟩ < ⟨i,a⟩ ↔ ⟨i,c'⟩ < ⟨i,b⟩`: this reduces to `c < a ↔ c' < b` within component i, which is guaranteed by the 2-var component NF agreement (the order atom `.order 0 1` in the component NF).
- Apply `extend_atoms`.
- Recursive BiCompat at depth k, n+1=2: apply IH at k with updated parameters.

The IH at depth k needs component multi-var NF agreement for the EXTENDED environment. For the same-component case, we have depth-k 2-var agreement from `component_extend_fwd`. For the cross-component case, we have depth-k 1-var agreement in each component separately. The IH must handle both cases.

**The key challenge remains**: the IH for constructing BiCompat at depth k with n=2 vars needs to handle environments where MULTIPLE elements might be in the same component, requiring progressively deeper component multi-var NF agreement. This is the variable-size projection problem.

### Approach 2: Eliminate BiCompat, Use Well-Founded Recursion on (d, delta)

Define the proof by well-founded recursion on `(d, delta)` where `delta` is the gap between the component equivalence depth and the target NF depth. This avoids the separate BiCompat construction.

```lean
-- Prove: ordered-sum depth-d n-var NF agreement
-- by well-founded recursion on d
-- At each quantifier step:
--   1. Find witness via component transfer (uses component equiv, not ordered-sum equiv)
--   2. Derive atom agreement for extended env (uses component multi-var NF)
--   3. Recurse at depth d-1, n+1 (d decreases, well-founded)
```

This is structurally identical to BiCompat but inlined into the main proof. The advantage: no separate BiCompat predicate to define and construct. The disadvantage: the proof term may be large and hard to maintain.

### Approach 3 (RECOMMENDED): Factor into build_bicompat helper

Keep the BiCompat + sum_nf_lift_gen split (already proved), but define a NEW helper:

```lean
private theorem build_bicompat (sig : MonadicSignature) :
    ∀ (d : Nat) (n : Nat) (I : Type) [LinearOrder I]
    (ms ms' : I → OrderedMonadicStructure sig)
    (h_comp : ∀ (m : Nat), m ≤ d + n → ∀ i, ∀ nf : NormalForm sig m 0,
      nf_eval_nf (ms i) m 0 Fin.elim0 nf ↔ nf_eval_nf (ms' i) m 0 Fin.elim0 nf)
    (env_M : Fin n → (orderedSum sig I ms).carrier)
    (env_N : Fin n → (orderedSum sig I ms').carrier)
    (h_idx : ∀ p : Fin n, (env_M p).1 = (env_N p).1)
    (h_atoms : ∀ a : AtomKind sig n,
      atom_eval (orderedSum sig I ms) env_M a ↔
      atom_eval (orderedSum sig I ms') env_N a),
    BiCompat sig d n I ms ms' env_M env_N
```

Prove by induction on d. At d+1:
- Forward oracle: given (j, c'), use component transfer to find c. Use `extend_atoms` (already proved) for atom agreement. Recurse at depth d.
- Backward oracle: symmetric.

**The same-component order problem** must be solved within this helper. The solution: when finding c via `component_extend_fwd`, the depth-d (r+1)-var component NF agreement includes order atoms. Specifically, `.order 0 k` in the component evaluates to `c <_j (env_M k).2` (if `(env_M k).1 = j`). Component NF matching guarantees this equals `c' <_j (env_N k).2`. Converting to ordered-sum order: `⟨j,c⟩ < ⟨j,(env_M k).2⟩` iff `c <_j (env_M k).2` (by Sigma.Lex with same index). So `h_ord_fwd k` and `h_ord_bwd k` (needed by `extend_atoms`) follow from component NF order atoms.

**For cross-component elements** (`(env_M k).1 != j`): `⟨j,c⟩ < ⟨(env_M k).1, (env_M k).2⟩` iff `j < (env_M k).1`, which is independent of c. Since `h_idx` gives `(env_M k).1 = (env_N k).1`, we have `j < (env_M k).1 ↔ j < (env_N k).1`. So order agreement is automatic.

**The recursive call** at depth d needs `component_extend` to have produced a FULL component multi-var NF agreement that includes all same-component elements. This is where `component_extend_fwd` is used: it finds c such that the extended environment `Fin.cons c proj_M_j` has depth-d agreement with `Fin.cons c' proj_N_j` in the component. But `component_extend_fwd` takes a SIMPLE environment `eM : Fin r -> (ms j).carrier` and produces extended agreement at `Fin (r+1)`.

**The difficulty**: extracting `eM` (the projection of env_M to component j) from the full environment. This requires the variable-size projection.

### Simplification for the n=1 Initial Case

At the 4 sorry sites, n=1 and the environment is `![⟨i,a⟩]`, `![⟨i,b⟩]`. We have component depth-k 1-var NF agreement for a, b.

For `build_bicompat` at n=1:
- Component i projection: exactly 1 element (a or b). `eM = ![a]`, `eN = ![b]`.
- Other components: 0 elements.

At depth d+1, n=1, the oracle for (j, c'):
- **j = i**: Use `component_extend_fwd` with `eM = ![a]`, `eN = ![b]`, depth k. Get c with depth-(k-1) 2-var component NF agreement for `(c,a)` vs `(c',b)`. This gives all atoms including order. Recursive BiCompat at depth d, n=2: need to track that component i now has 2 elements (c,a) and (c',b) with depth-(k-1) 2-var agreement. Component i's projection becomes `![c, a]` and `![c', b]`.
- **j != i**: Use component j transfer from h_comp. Get c with depth-k 1-var component NF matching for c, c'. Recursive BiCompat at depth d, n=2: component i has 1 element, component j has 1 element.

The recursive call at depth d, n=2 may add elements to component i or j or a third component k. Each same-component addition peels one layer of component NF agreement. The budget is: component i started with depth-k 1-var agreement, and each same-component addition reduces depth by 1. After q same-component additions, we have depth-(k-q) (1+q)-var agreement. This terminates when depth reaches 0 (after k additions), where BiCompat = True.

**The tracking problem**: the recursive call needs to know the current component NF agreement state for each component. This state differs between components (component i started with 1-var agreement, other components started with 0-var agreement).

### Final Assessment

**The fundamental difficulty is a FORMALIZATION problem, not a mathematical problem.** The math is clear (Doets' proof works, the budget accounting is correct). The formalization difficulty is tracking variable-size per-component NF state through a recursion.

**Three viable paths forward**:

1. **Accept the complexity**: Implement the full `build_bicompat` with per-component state tracking, using dependent types or Finset projections. Estimated 6-8 hours of careful Lean engineering.

2. **Specialize to budget d+n <= K**: Define `build_bicompat` with an explicit budget parameter K and prove that at each step, the budget is sufficient. The per-component state can be encoded as "number of same-component elements" (a Nat), and the depth agreement is K minus that count. This avoids variable-size projections.

3. **Use a different NF decomposition**: Prove that the ordered-sum depth-d n-var NF decomposes as a function of (indices, component NFs). This is the cleanest mathematical approach but requires significant new infrastructure.

I recommend **path 2** as the most practical. The budget parameter K provides a clean termination measure, and the per-component state (element count) is a simple Nat that avoids dependent-type projections.

## Concrete Implementation Sketch for Path 2

```lean
-- Helper: component NF agreement at depth (K - r) for r elements
private def CompNFCompat (sig : MonadicSignature)
    (K r : Nat) (ms ms' : I → OrderedMonadicStructure sig)
    (j : I) (eM : Fin r → (ms j).carrier) (eN : Fin r → (ms' j).carrier) : Prop :=
  ∀ nf : NormalForm sig (K - r) r,
    nf_eval_nf (ms j) (K - r) r eM nf ↔ nf_eval_nf (ms' j) (K - r) r eN nf

-- build_bicompat by induction on d, using CompNFCompat to track state
-- At each oracle call: distinguish same-component vs cross-component
-- Same-component: use component_extend, depth decreases from (K-r) to (K-r-1)
-- Cross-component: use fresh h_comp transfer at depth K
-- Budget: d + n = K, so depth-0 is reached after K steps
```

This avoids variable-size projections by fixing the Fin r type at each component and using `component_extend_fwd/bwd` to increment r.

## Summary of Key Findings

1. **BiCompat is not fundamentally wrong** -- it correctly captures the witness oracle structure of the EF game.

2. **BiCompat construction is the blocker**, not the BiCompat design or `sum_nf_lift_gen` itself.

3. **A simpler approach that avoids BiCompat entirely does NOT exist** in the current NF framework, because the quantifier step inherently requires finding matching witnesses with atom agreement.

4. **The construction can be simplified** by using a budget parameter and tracking per-component element counts rather than full variable-size projections.

5. **The mathematical proof is correct** with the current hypothesis (`h_comp at m <= k+1`). The budget accounting works: d+n = k+1, and component (k+1)-equiv provides exactly enough peeling levels.

6. **nf_agreement_monotone IS the structural template**, but it applies to a SINGLE pair of structures. For ordered sums, the "single pair" approach fails because the quantifier domains differ between components and the full sum.

7. **The recommended path**: implement `build_bicompat` with a budget parameter K and per-component element count tracking, using `component_extend_fwd/bwd` (already proved) and `extend_atoms` (already proved) as building blocks.
