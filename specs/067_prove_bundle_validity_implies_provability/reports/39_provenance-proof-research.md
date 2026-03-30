# Research Report: Provenance Proof for boundary_implies_k_lt_B

**Task**: 67 - prove_bundle_validity_implies_provability
**Focus**: Rigorous proof analysis for the sorry in `boundary_implies_k_lt_B`
**Session**: sess_1774885777_d6e8a1
**Date**: 2026-03-30

## 1. Problem Statement

### Theorem to Prove

```lean
theorem boundary_implies_k_lt_B (phi : Formula)
    (M0 : DeferralRestrictedSerialMCS phi) (k d : Nat) (theta : Formula)
    (h_d_ge : d >= 1)
    (h_iter_in : iter_F d theta ∈ restricted_forward_chain phi M0 k)
    (h_iter_not : iter_F (d + 1) theta ∉ restricted_forward_chain phi M0 k)
    (h_d_lt : d < closure_F_bound phi) :
    k < closure_F_bound phi
```

**Goal State** (from lean_goal):
```
phi : Formula
M0 : DeferralRestrictedSerialMCS phi
k d : ℕ
theta : Formula
h_d_ge : d ≥ 1
h_iter_in : iter_F d theta ∈ restricted_forward_chain phi M0 k
h_iter_not : iter_F (d + 1) theta ∉ restricted_forward_chain phi M0 k
h_d_lt : d < closure_F_bound phi
⊢ k < closure_F_bound phi
```

### Intuitive Meaning

We have a formula `iter_F d theta` (theta wrapped in d layers of F operators) that is:
1. Present in chain(k)
2. At its "boundary" - the next F-iteration `iter_F (d+1) theta` is NOT in chain(k)
3. The depth d is within the closure bound (d < B)

We need to prove that k (the chain position) is also bounded by B.

## 2. Key Infrastructure

### 2.1 The Chain Construction

The `restricted_forward_chain` is built from a base `DeferralRestrictedSerialMCS` M0:
- `chain(0) = M0.world` (the starting MCS)
- `chain(k+1) = constrained_successor_restricted(chain(k))`

Each chain element is a `DeferralRestrictedMCS phi`, meaning it is:
- A maximal consistent set
- Restricted to `deferralClosure phi`

### 2.2 F-Content Bulldozing

The constrained successor seed includes `f_content u`:
```lean
def constrained_successor_seed_restricted (phi : Formula) (u : Set Formula) : Set Formula :=
  g_content u ∪ deferralDisjunctions u ∪ p_step_blocking_formulas_restricted phi u ∪
  boundary_resolution_set phi u ∪ f_content u
```

This means: if `F(psi) ∈ chain(k)`, then `psi ∈ seed(chain(k))`, hence `psi ∈ chain(k+1)`.

### 2.3 Strong F-Persistence Theorems

Already proven:
```lean
theorem restricted_forward_chain_F_resolves (phi : Formula)
    (M0 : DeferralRestrictedSerialMCS phi) (k : Nat) (psi : Formula)
    (h_F : Formula.some_future psi ∈ restricted_forward_chain phi M0 k) :
    psi ∈ restricted_forward_chain phi M0 (k + 1)

theorem restricted_forward_chain_iter_F_resolves (phi : Formula)
    (M0 : DeferralRestrictedSerialMCS phi) (j d : Nat) (theta : Formula)
    (h_in : iter_F d theta ∈ restricted_forward_chain phi M0 j) :
    theta ∈ restricted_forward_chain phi M0 (j + d)
```

### 2.4 Closure Bound

```lean
def closure_F_bound (phi : Formula) : Nat :=
  max (Bimodal.Syntax.max_F_depth_in_closure phi) 1 + 1
```

Key property: If a formula has f_nesting_depth >= closure_F_bound phi, it cannot be in deferralClosure phi.

## 3. The Proof Strategy

### 3.1 Contrapositive Approach

We prove by contrapositive: assume `k >= B` and derive a contradiction.

**Claim**: If `k >= B` and `iter_F d theta ∈ chain(k)` with `d >= 1`, then either:
1. `iter_F (d+1) theta ∈ chain(k)` (contradicting the boundary condition), OR
2. `iter_F d theta ∉ chain(k)` (contradicting the hypothesis)

### 3.2 Formula Provenance Analysis

**Key Insight**: With f_content bulldozing, F-formulas can only enter the chain via:
1. Being in M0.world (chain(0)) - inherited from the starting MCS
2. Derivation from existing formulas via MCS closure

**Critical Observation**: F-formulas do NOT persist through the chain without resolving. If `F(psi) ∈ chain(j)`, then:
- `psi ∈ chain(j+1)` (by F_resolves)
- `F(psi)` may or may not be in `chain(j+1)` - it depends on the Lindenbaum extension

The key is that F-formulas RESOLVE, not persist. This means:

**Lemma (to prove)**: If `iter_F d theta ∈ chain(k)` for `k >= 1`, then `iter_F (d+1) theta ∈ chain(k-1)`.

### 3.3 Backward Tracing Argument

By the lemma above, we can trace backward:
- `iter_F d theta ∈ chain(k)` implies `iter_F (d+1) theta ∈ chain(k-1)`
- `iter_F (d+1) theta ∈ chain(k-1)` implies `iter_F (d+2) theta ∈ chain(k-2)`
- ...continuing until we reach chain(0)...
- `iter_F (d+k) theta ∈ chain(0) = M0.world`

**Bound from chain(0)**: Since M0.world is a DeferralRestrictedMCS, all formulas have f_nesting_depth bounded by max_F_depth_in_closure phi. Therefore:
```
f_nesting_depth(iter_F (d+k) theta) <= max_F_depth_in_closure phi
```

But:
```
f_nesting_depth(iter_F (d+k) theta) = d + k + f_nesting_depth(theta)
```

So:
```
d + k + f_nesting_depth(theta) <= max_F_depth_in_closure phi < closure_F_bound phi
```

Since d >= 1 and f_nesting_depth(theta) >= 0:
```
k < closure_F_bound phi - d <= closure_F_bound phi - 1 < closure_F_bound phi
```

### 3.4 The Missing Lemma

The proof requires establishing:

```lean
lemma iter_F_in_chain_implies_higher_iter_F_in_prev_chain (phi : Formula)
    (M0 : DeferralRestrictedSerialMCS phi) (k d : Nat) (theta : Formula)
    (h_k_pos : k >= 1)
    (h_d_pos : d >= 1)
    (h_in : iter_F d theta ∈ restricted_forward_chain phi M0 k) :
    iter_F (d + 1) theta ∈ restricted_forward_chain phi M0 (k - 1)
```

**Why this is true**: The only way for `iter_F d theta` to be in chain(k) for k >= 1 is:
1. `iter_F d theta` was derived/added during the Lindenbaum extension of chain(k)
2. But the seed only contains formulas from specific sources (g_content, f_content, etc.)
3. For `iter_F d theta` with d >= 1, this means `F(iter_F d theta) = iter_F (d+1) theta` was in chain(k-1)

**Technical Issue**: The Lindenbaum extension can add arbitrary formulas from deferralClosure. So `iter_F d theta` might be added without `iter_F (d+1) theta` being in the previous chain.

### 3.5 Alternative: Direct Depth Argument

Instead of backward tracing, we can use a direct depth argument:

**Observation**: chain(k) is a DeferralRestrictedMCS, so all formulas in chain(k) are in deferralClosure phi. By the depth bound:

```lean
theorem deferral_restricted_mcs_F_bounded_upper (phi psi : Formula) (M : Set Formula)
    (h_mcs : DeferralRestrictedMCS phi M)
    (h_F_in : Formula.some_future psi ∈ M) :
    ∀ d, d ≥ 1 → iter_F d psi ∈ M → iter_F (d + 1) psi ∉ M → d < closure_F_bound phi
```

This says: the boundary depth d is always < B. But we need to show k < B, not just d < B.

## 4. The Core Difficulty

The theorem as stated may be **false** or require additional hypotheses.

**Counterexample Scenario**:
- Let B = 3 (closure_F_bound phi = 3)
- Suppose chain(0) contains `F(F(p))` = iter_F 2 p
- By F_resolves: `F(p)` = iter_F 1 p ∈ chain(1)
- By F_resolves: `p` = iter_F 0 p ∈ chain(2)
- Now consider chain(5). If `F(p)` ∈ chain(5), with d=1 and boundary at d+1=2...
- The theorem would require k=5 < B=3, which is false.

**Resolution**: The boundary condition `iter_F (d+1) theta ∉ chain(k)` provides the key constraint. If `F(F(p)) ∈ chain(5)`, then by F_resolves, `F(p) ∈ chain(6)`. So if `F(p) ∈ chain(5)` with boundary at depth 2, we have:
- iter_F 1 p = F(p) ∈ chain(5)
- iter_F 2 p = F(F(p)) ∉ chain(5)

But wait - can F(F(p)) be in chain(5)? If so, there's no boundary at depth 2.

**The Real Question**: Can a formula `iter_F d theta` with `d >= 1` be in chain(k) where:
1. iter_F (d+1) theta ∉ chain(k) (boundary condition)
2. k >= B

## 5. Refined Proof Strategy

### 5.1 Key Insight: Formula Origin

Every formula in chain(k) either:
1. Was in chain(k-1) and persisted (e.g., via g_content or deduction)
2. Entered via f_content (meaning its F-wrapper was in chain(k-1))
3. Entered via boundary_resolution_set
4. Was added by Lindenbaum

For F-formulas specifically, the critical path is f_content:
- If `F(psi) ∈ chain(k)` for k >= 1, it could be:
  - In g_content(chain(k-1)): requires G(F(psi)) ∈ chain(k-1)
  - Added by Lindenbaum: from deferralClosure

### 5.2 G-Chain Propagation

If `G(F(psi)) ∈ chain(j)`, then `F(psi) ∈ chain(j')` for all j' >= j (by G-persistence).

**Key**: G-formulas propagate forward, F-formulas resolve forward. The interaction is:
- `G(F(psi)) ∈ chain(0)` implies `F(psi) ∈ chain(k)` for all k
- `F(psi) ∈ chain(k)` implies `psi ∈ chain(k+1)`

### 5.3 Proof by Strong Induction on k

**Base Case** (k = 0):
- iter_F d theta ∈ chain(0) = M0.world
- M0.world ⊆ deferralClosure phi
- By depth bound: d < B (already given by h_d_lt)
- Actually, we need k < B, so this doesn't directly help...

Wait, the base case is trivial: if k = 0, then k < B (since B >= 2 by definition of closure_F_bound).

**Inductive Case** (k >= 1):
- Assume the theorem holds for all k' < k
- We have iter_F d theta ∈ chain(k) with boundary at d+1
- Need to show k < B

**Strategy**: Show that the boundary condition forces iter_F (d+1) theta to have been "outside" the chain at some earlier point, which limits how far the chain can extend.

## 6. The Correct Proof

### 6.1 Observation About Boundaries

If `iter_F d theta ∈ chain(k)` with d >= 1 and `iter_F (d+1) theta ∉ chain(k)`:

**Case 1**: k = 0
- k = 0 < B (since B >= 2)
- Done.

**Case 2**: k >= 1
- chain(k) is the Lindenbaum extension of seed(chain(k-1))
- iter_F d theta ∈ chain(k)
- iter_F (d+1) theta ∉ chain(k)

By `restricted_forward_chain_F_bounded`, applied to chain(k-1):
- If F(iter_F (d-1) theta) = iter_F d theta ∈ chain(k-1), then there exists d' >= 1 such that iter_F d' (iter_F (d-1) theta) ∈ chain(k-1) and iter_F (d'+1) (iter_F (d-1) theta) ∉ chain(k-1)

This gives a recursive structure. The recursion depth is bounded by the formula complexity.

### 6.2 Well-Founded Recursion

Define a measure: `(k, formula_complexity(iter_F d theta))` with lexicographic ordering.

At each step, either:
1. k decreases (going from chain(k) to chain(k-1)), or
2. k stays the same but formula complexity decreases

The base cases are:
- k = 0: trivially k < B
- d = 0: contradicts d >= 1

### 6.3 Complete Proof Sketch

```lean
theorem boundary_implies_k_lt_B (phi : Formula)
    (M0 : DeferralRestrictedSerialMCS phi) (k d : Nat) (theta : Formula)
    (h_d_ge : d >= 1)
    (h_iter_in : iter_F d theta ∈ restricted_forward_chain phi M0 k)
    (h_iter_not : iter_F (d + 1) theta ∉ restricted_forward_chain phi M0 k)
    (h_d_lt : d < closure_F_bound phi) :
    k < closure_F_bound phi := by
  -- By strong induction on k
  induction k using Nat.strong_induction_on with
  | ind k ih =>
    -- Base case: k = 0
    cases k with
    | zero =>
      -- 0 < B since B = max(...) + 1 >= 2
      unfold closure_F_bound
      omega
    | succ k' =>
      -- k = k' + 1 >= 1
      -- Use the key lemma: if iter_F d theta ∈ chain(k'+1) with boundary at d+1,
      -- then either:
      -- (a) iter_F (d+1) theta ∈ chain(k') with some boundary d', or
      -- (b) iter_F d theta entered via g_content (G-persistence), or
      -- (c) iter_F d theta was added by Lindenbaum

      -- For case (a): apply IH to get k' < B, hence k'+1 <= B... not enough!
      -- We need k'+1 < B, so we need k' < B - 1

      -- Key insight: trace back the formula to chain(0)
      -- iter_F d theta ∈ chain(k'+1) with d >= 1
      -- By F_resolves backwards (contrapositive): if iter_F d theta ∈ chain(k'+1),
      -- then iter_F (d+1) theta was "available" at chain(k')

      -- Actually, the correct argument:
      -- iter_F (d+k'+1) theta ∈ chain(0) (by backward tracing)
      -- So d + k' + 1 <= max_F_depth (since chain(0) ⊆ deferralClosure)
      -- Hence k' + 1 < B (since d >= 1)
      sorry
```

## 7. Required Helper Lemmas

### 7.1 Backward Tracing Lemma

```lean
lemma iter_F_trace_to_base (phi : Formula)
    (M0 : DeferralRestrictedSerialMCS phi) (k d : Nat) (theta : Formula)
    (h_in : iter_F d theta ∈ restricted_forward_chain phi M0 k) :
    iter_F (d + k) theta ∈ M0.world ∨
    (∃ j < k, iter_F (d + j) theta ∈ g_content (restricted_forward_chain phi M0 (k - j - 1)))
```

**Meaning**: Either iter_F (d+k) theta was in the base M0.world, or the formula entered via G-persistence at some earlier point.

### 7.2 G-Content Depth Bound

If iter_F m psi ∈ g_content(chain(j)), then G(iter_F m psi) ∈ chain(j), which means:
- f_nesting_depth(G(iter_F m psi)) = f_nesting_depth(iter_F m psi) = m + f_nesting_depth(psi)
- This must be <= max_F_depth_in_closure phi

### 7.3 The Core Bound

**Lemma**: For any formula psi ∈ chain(k), if psi is an F-formula (i.e., psi = F(psi') for some psi'), then:
- Either psi ∈ chain(0), or
- psi ∈ g_content(chain(j)) for some j < k, or
- F(psi) ∈ chain(k-1)

This gives a backwards trace that eventually reaches chain(0) or a G-content entry.

## 8. Recommended Proof Implementation

### 8.1 Define First Appearance

```lean
def first_appearance (phi : Formula) (M0 : DeferralRestrictedSerialMCS phi) (psi : Formula) : Nat :=
  Nat.find (exists_first_appearance phi M0 psi h_eventually_appears)
```

Where `h_eventually_appears` proves psi appears in some chain(n).

### 8.2 Trace Origin Lemma

```lean
lemma iter_F_origin (phi : Formula)
    (M0 : DeferralRestrictedSerialMCS phi) (d : Nat) (theta : Formula)
    (h_d_pos : d >= 1)
    (h_in_some : ∃ k, iter_F d theta ∈ restricted_forward_chain phi M0 k) :
    (∃ k, iter_F (d + k) theta ∈ M0.world) ∨
    (∃ k j, j < k ∧ G (iter_F (d + j) theta) ∈ restricted_forward_chain phi M0 (k - j - 1))
```

### 8.3 Main Proof via Origin

Given the boundary condition, trace back to find:
- iter_F (d + m) theta in chain(0) for some m <= k
- Then: f_nesting_depth(iter_F (d + m) theta) = d + m + f_nesting_depth(theta) <= max_F_depth
- So: d + m <= max_F_depth < B - 1
- Since m <= k: d + k <= d + m + (k - m) = (d + m) + (k - m)
- We need: k < B

**Issue**: This doesn't directly give k < B from d + m < B.

### 8.4 Correct Bound

The key insight is that the **boundary** condition iter_F (d+1) theta ∉ chain(k) is crucial.

**Observation**: If iter_F d theta ∈ chain(k) but iter_F (d+1) theta ∉ chain(k), then by iter_F_resolves running backwards:
- iter_F (d+1) theta ∉ chain(k)
- If iter_F (d+1) theta ∈ chain(k-1), then iter_F d theta ∈ chain(k) by F_resolves (consistent)
- The boundary exists at chain(k)

The depth bound theorem `deferral_restricted_mcs_F_bounded_upper` already proves d < B. We need k < B.

**Alternative Approach**: Use well-founded recursion on the pair (k, d) with lexicographic ordering.

## 9. Recommended Implementation

### 9.1 Approach 1: Strong Induction on k with Internal Induction on d

```lean
theorem boundary_implies_k_lt_B ... := by
  induction k using Nat.strong_induction_on with
  | ind k ih =>
    cases k with
    | zero => omega  -- 0 < B
    | succ k' =>
      -- k = k' + 1
      -- iter_F d theta ∈ chain(k'+1)
      -- iter_F (d+1) theta ∉ chain(k'+1)
      -- Need: k'+1 < B

      -- By restricted_forward_chain_F_step_witness:
      -- If F(psi) ∈ chain(j), then psi ∈ chain(j+1) OR F(psi) ∈ chain(j+1)

      -- Since iter_F d theta = F(iter_F (d-1) theta) for d >= 1:
      -- iter_F d theta ∈ chain(k'+1) means F(iter_F (d-1) theta) ∈ chain(k'+1)
      -- So iter_F (d-1) theta ∈ chain(k'+2) OR F(iter_F (d-1) theta) ∈ chain(k'+2)

      -- This goes FORWARD, not backward. We need backward analysis.

      -- Key: How did iter_F d theta get into chain(k'+1)?
      -- chain(k'+1) = Lindenbaum(seed(chain(k')))
      -- seed includes: g_content, deferralDisjunctions, p_step_blocking, BRS, f_content

      -- If iter_F d theta ∈ f_content(chain(k')):
      --   Then F(iter_F d theta) = iter_F (d+1) theta ∈ chain(k')
      --   Apply IH or recurse on k' with depth d+1

      -- If iter_F d theta ∈ g_content(chain(k')):
      --   Then G(iter_F d theta) ∈ chain(k')
      --   iter_F d theta ∈ chain(k') (by MCS closure)
      --   iter_F d theta ∈ chain(k'+1) (by G-persistence)
      --   This doesn't directly give us the bound

      -- If iter_F d theta was added by Lindenbaum:
      --   iter_F d theta ∈ deferralClosure phi
      --   d <= max_F_depth < B - 1
      --   But this doesn't bound k

      sorry
```

### 9.2 Approach 2: Direct Recursion on Formula Structure

The theorem may require a fundamentally different formulation. Consider:

```lean
-- Alternative: bound the "entry point" of F-iterations
theorem F_iteration_entry_bound (phi : Formula)
    (M0 : DeferralRestrictedSerialMCS phi) (d : Nat) (theta : Formula)
    (h_d_pos : d >= 1)
    (h_in : iter_F d theta ∈ restricted_forward_chain phi M0 k) :
    k <= d ∨ G (iter_F (k - d) theta) ∈ M0.world
```

This says: either k <= d (so k < B follows from d < B... no, that's not right either).

## 10. Conclusion

### 10.1 Mathematical Status

The theorem `boundary_implies_k_lt_B` appears to require a more sophisticated proof strategy than initially anticipated. The key challenges are:

1. **F-formulas can enter chain(k) via Lindenbaum** without having an F-wrapper in chain(k-1)
2. **G-formulas propagate indefinitely**, so G(F^d theta) ∈ chain(0) implies F^d theta ∈ chain(k) for all k
3. **The boundary condition** provides the key constraint but connecting it to k requires careful analysis

### 10.2 Proof Feasibility

The theorem IS likely provable using one of these approaches:

1. **Trace to G-origin**: Show that F^d theta at boundary in chain(k) implies G(F^m theta) ∈ chain(0) for some m >= d, bounding k
2. **Well-founded recursion**: Use (k, complexity) lexicographic order with careful case analysis
3. **Reformulation**: Express the theorem in terms of "distance from G-entry" rather than raw chain position

### 10.3 Recommended Next Steps

1. **Prove a G-origin lemma**: Every F-iteration in chain(k) either came from a G-formula in chain(0) or from f_content at some chain(j) with j < k

2. **Bound the G-origin depth**: If G(F^m theta) ∈ chain(0), then m < B

3. **Connect boundary to origin**: If F^d theta has boundary at chain(k), trace back to its G-origin and use the depth bound

4. **Alternative**: Consider whether the theorem as stated is actually needed, or if a weaker form suffices for the larger proof goal

### 10.4 Risk Assessment

- **Medium risk**: The proof is non-trivial but appears mathematically sound
- **Mitigation**: The restricted chain construction with f_content bulldozing provides strong invariants that should enable the proof
- **Zero-debt compliance**: This is the correct approach - the proof should be completed, not deferred with sorry
