# Research Report: GH-Intersection Seed Modification — Full Mathematical Detail

**Task**: Task 58 - Wire Completeness to Frame Conditions
**Focus**: GH-intersection approach in complete mathematical detail with Lean proof sketches
**Date**: 2026-03-25
**Agent**: math-research-agent (teammate A)

## Executive Summary

This report provides the complete mathematical analysis of the GH-intersection seed approach to resolving the G-theory propagation gap. The key findings are:

1. **`dual_temp_l` IS PROVABLE** (HIGH confidence): `G(a) ∧ H(a) → H(G(a))` follows from the existing `temp_l` axiom via symmetry.

2. **GH_theory(M0) IS H-liftable** (HIGH confidence): Every element of GH_theory(M0) can be H-lifted.

3. **Modified seed consistency IS PROVABLE** (HIGH confidence): `{psi_n} ∪ H_theory(backward(n)) ∪ GH_theory(M0) ∪ box_theory(backward(n))` is consistent.

4. **forward_F sub-case (a) IS RESOLVED** (HIGH confidence): When G(¬phi) ∉ M0.

5. **forward_F sub-case (b) IS BLOCKING** (HIGH confidence): When G(¬phi) ∈ M0 but H(¬phi) ∉ M0, we cannot syntactically derive a witness without circular reasoning.

6. **forward_G from forward_F IS NOT DERIVABLE** in general without the chain construction preserving G-theory.

---

## Part 1: Prove `dual_temp_l`

### 1.1 Theorem Statement

**Theorem (dual_temp_l)**: `G(a) ∧ H(a) → H(G(a))`

In Lean syntax:
```lean
theorem dual_temp_l (a : Formula) :
    [] ⊢ (Formula.and (Formula.all_future a) (Formula.all_past a)).imp
         (Formula.all_past (Formula.all_future a))
```

### 1.2 Proof via temp_l and Temporal Duality

**Step 1: Recall the temp_l axiom**

From `Theories/Bimodal/ProofSystem/Axioms.lean:276`:
```lean
| temp_l (φ : Formula) : Axiom (φ.always.imp (Formula.all_future (Formula.all_past φ)))
```

Where `always φ := H(φ) ∧ φ ∧ G(φ)` (from `Formula.lean:304`).

So temp_l states: `(H(φ) ∧ φ ∧ G(φ)) → G(H(φ))`

**Step 2: Apply temporal duality to temp_l**

The temporal duality transformation `swap_temporal` exchanges:
- `all_future ↔ all_past`
- `some_future ↔ some_past`

Applying `swap_temporal` to temp_l gives:
```
swap_temporal((H(φ) ∧ φ ∧ G(φ)) → G(H(φ)))
= (G(swap(φ)) ∧ swap(φ) ∧ H(swap(φ))) → H(G(swap(φ)))
```

Let `ψ = swap_temporal(φ)`. By involution, `swap_temporal(ψ) = φ`. So:
```
(G(ψ) ∧ ψ ∧ H(ψ)) → H(G(ψ))
```

This is exactly the dual of temp_l: **`always_dual(ψ) → H(G(ψ))`**

**Step 3: Extract the required implication**

We have: `(G(ψ) ∧ ψ ∧ H(ψ)) → H(G(ψ))`

We need: `(G(a) ∧ H(a)) → H(G(a))`

The key insight: from `G(a) ∧ H(a)`, we can derive `a` (via `temp_t_future: G(a) → a` or `temp_t_past: H(a) → a`).

Therefore: `G(a) ∧ H(a) → G(a) ∧ a ∧ H(a) = always(a)`

Then apply the dualized temp_l: `always(a) → H(G(a))`

By transitivity: `G(a) ∧ H(a) → H(G(a))` QED.

### 1.3 Lean Proof Sketch

```lean
theorem dual_temp_l (a : Formula) :
    [] ⊢ (Formula.and a.all_future a.all_past).imp a.all_future.all_past := by
  -- Step 1: Get temp_l for swap_temporal(a)
  have h_temp_l := DerivationTree.axiom [] _ (Axiom.temp_l a.swap_temporal)

  -- Step 2: Apply temporal_duality
  have h_dual := DerivationTree.temporal_duality _ h_temp_l

  -- h_dual : ⊢ (G(a) ∧ a ∧ H(a)) → H(G(a))
  -- (after swap_temporal_involution simplification)

  -- Step 3: Build G(a) ∧ H(a) → G(a) ∧ a ∧ H(a)
  -- Use temp_t_future: G(a) → a
  have h_t : [] ⊢ a.all_future.imp a := DerivationTree.axiom [] _ (Axiom.temp_t_future a)

  -- Combine via propositional reasoning:
  -- G(a) ∧ H(a) → G(a) ∧ (G(a) → a) ∧ H(a) → G(a) ∧ a ∧ H(a) → H(G(a))
  sorry -- propositional combination (routine)
```

**Confidence**: HIGH (95%)

The proof structure is sound. The only complexity is the propositional manipulation to extract `a` from `G(a)` and reassemble the conjunction. This is standard and well-supported by the existing combinator theorems.

---

## Part 2: Prove GH_theory(M0) is H-liftable

### 2.1 Definition

```lean
def GH_theory (M : Set Formula) : Set Formula :=
  { G(a) | G(a) ∈ M ∧ H(a) ∈ M }
```

More precisely (in set-builder notation):
```lean
def GH_theory (M : Set Formula) : Set Formula :=
  { f | ∃ a, f = Formula.all_future a ∧
        Formula.all_future a ∈ M ∧ Formula.all_past a ∈ M }
```

This is the set of G-formulas that are "eternal" — both their G and H versions are in M.

### 2.2 H-liftability Theorem

**Theorem**: For every `G(a) ∈ GH_theory(M0)`, we have `H(G(a)) ∈ M0`.

**Proof**:
1. Let `G(a) ∈ GH_theory(M0)`. By definition, `G(a) ∈ M0` and `H(a) ∈ M0`.
2. By `dual_temp_l` (Part 1): `G(a) ∧ H(a) → H(G(a))`
3. Since M0 is an MCS with both `G(a) ∈ M0` and `H(a) ∈ M0`:
   - By MCS conjunction: `G(a) ∧ H(a) ∈ M0`
   - By MCS modus ponens with `dual_temp_l`: `H(G(a)) ∈ M0`
4. Therefore, `H(G(a)) ∈ M0`. QED.

### 2.3 H-lifting Through Backward Chain

**Theorem**: If `G(a) ∈ GH_theory(M0)`, then for all n, `G(a) ∈ backward(n)`.

**Proof by induction on n**:

**Base case (n = 0)**:
`backward(0) = M0`. We have `G(a) ∈ M0` by definition of GH_theory(M0). Done.

**Inductive case (n → n+1)**:
Assume `G(a) ∈ backward(n)`. We show `G(a) ∈ backward(n+1)`.

The backward chain step uses `past_theory_witness_exists_extended` which produces a witness W with:
- phi ∈ W (the P-witness)
- H_theory(backward(n)) preserved in W
- box_class_agree(backward(n), W)

**Key insight**: We need to show that the modified seed includes `G(a)` in a way that ensures `G(a) ∈ W`.

The modified seed is: `{psi_n} ∪ H_theory(backward(n)) ∪ GH_theory(M0) ∪ box_theory(backward(n))`

Since `G(a) ∈ GH_theory(M0)`, we have `G(a)` in the seed. The Lindenbaum extension includes all seed elements in W. Therefore `G(a) ∈ backward(n+1)`.

**Confidence**: HIGH (90%)

---

## Part 3: Prove Modified Seed Consistency

### 3.1 Extended Consistency Theorem

**Theorem (past_theory_witness_consistent_with_GH)**:
If P(psi) ∈ M (MCS), then the modified seed `{psi} ∪ H_theory(M) ∪ GH_theory(M0) ∪ box_theory(M)` is consistent.

### 3.2 Proof Strategy

The proof mirrors `past_theory_witness_consistent` but needs to handle GH_theory elements in addition to H_theory elements.

**Key insight**: Every element of GH_theory(M0) is H-liftable (Part 2), so the H-lift argument extends.

**Proof**:

Suppose the seed is inconsistent. Then there exists a finite list L ⊆ seed with L ⊢ bot.

Filter L into:
- `L_psi` = occurrences of psi
- `L_H` = elements from H_theory(M)
- `L_GH` = elements from GH_theory(M0)
- `L_box` = elements from box_theory(M)

Weaken L to `[psi] ++ L_H ++ L_GH ++ L_box` (removing duplicates).

By deduction theorem: `L_H ++ L_GH ++ L_box ⊢ neg(psi)`.

Now the H-lift argument:
- For `x ∈ L_H`: `H(x) ∈ M` (by definition of H_theory), so `H(x) ∈ M` — H-liftable
- For `x ∈ L_GH`: `x = G(a)` where `G(a) ∈ M0 ∧ H(a) ∈ M0`
  - By `dual_temp_l`: `H(G(a)) ∈ M0`
  - Need: `H(G(a)) ∈ M` (not just M0)

**CRITICAL POINT**: Here we need the H_theory propagation from M0 through the backward chain to M.

If M = backward(n), then we need `H(G(a)) ∈ backward(n)`.

From Part 2.3, we showed that `G(a) ∈ backward(n)` for all n.

For H-lifting within the proof, we need `H(G(a)) ∈ backward(n)`.

By `dual_temp_l`: `G(a) ∧ H(a) → H(G(a))`

We have `G(a) ∈ backward(n)` (from Part 2.3). We also have `H(a) ∈ M0`.

**Question**: Is `H(a) ∈ backward(n)`?

By the backward chain construction, H_theory(M0) propagates: `H(a) ∈ M0 → H(a) ∈ backward(n)`.

Therefore: `G(a) ∧ H(a) ∈ backward(n)`, so `H(G(a)) ∈ backward(n)` by MCS closure.

This means GH_theory(M0) elements are H-liftable at backward(n).

Continuing the H-lift argument:
- For `x ∈ L_box`: H-liftable (by H_of_box_theory)

All elements of L (excluding psi) are H-liftable. By `H_lift_from_context`:
`H(neg(psi)) ∈ M`.

But `P(psi) ∈ M` and `H(neg(psi)) ∈ M` violates MCS consistency (since P(psi) = ¬H(¬psi)).

Contradiction. Therefore the seed is consistent. QED.

### 3.3 Lean Proof Sketch

```lean
theorem past_theory_witness_consistent_with_GH
    (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0)
    (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (h_H_propagate : ∀ a, Formula.all_past a ∈ M0 → Formula.all_past a ∈ M)
    (h_GH_propagate : ∀ a, Formula.all_future a ∈ GH_theory M0 → Formula.all_future a ∈ M)
    (psi : Formula) (h_P : Formula.some_past psi ∈ M) :
    SetConsistent ({psi} ∪ H_theory M ∪ GH_theory M0 ∪ box_theory M) := by
  intro L h_L_sub ⟨d⟩

  -- Filter L into psi, H_theory, GH_theory, box_theory parts
  let L_no_psi := L.filter (· ≠ psi)

  -- Show all L_no_psi elements are H-liftable at M
  have h_H_lift : ∀ x ∈ L_no_psi, Formula.all_past x ∈ M := by
    intro x hx
    -- Case split on which part of seed x came from
    -- For H_theory(M): direct
    -- For GH_theory(M0): use dual_temp_l + h_H_propagate + h_GH_propagate
    -- For box_theory(M): use H_of_box_theory
    sorry

  -- Apply H_lift_from_context
  have d_neg_psi := deduction_theorem L_no_psi psi Formula.bot (weaken L d)
  have h_H_neg_psi := H_lift_from_context M h_mcs L_no_psi (neg psi) d_neg_psi h_H_lift

  -- Contradiction with P(psi) ∈ M
  exact some_past_excludes_all_past_neg h_mcs psi h_P h_H_neg_psi
```

**Confidence**: HIGH (85%)

---

## Part 4: Construct Modified Backward Chain

### 4.1 OmegaBackwardInvariant_GH

```lean
structure OmegaBackwardInvariant_GH (M0 : Set Formula) (W : Set Formula) : Prop where
  /-- W is an MCS -/
  is_mcs : SetMaximalConsistent W
  /-- H-formulas from M0 propagate to W -/
  H_propagate : ∀ a, Formula.all_past a ∈ M0 → Formula.all_past a ∈ W
  /-- GH-formulas from M0 propagate to W -/
  GH_propagate : ∀ a, Formula.all_future a ∈ GH_theory M0 → Formula.all_future a ∈ W
  /-- W agrees with M0 on Box-formulas -/
  box_agree : box_class_agree M0 W
```

### 4.2 omega_chain_backward_with_GH

```lean
noncomputable def omega_chain_backward_with_GH
    (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0) :
    Nat → { W : Set Formula // OmegaBackwardInvariant_GH M0 W }
  | 0 => ⟨M0, ⟨h_mcs0,
              fun _ h => h,                          -- H_propagate
              fun _ h => GH_theory_subset_mcs M0 h,  -- GH_propagate
              box_class_agree_refl M0⟩⟩
  | n + 1 =>
    let prev := omega_chain_backward_with_GH M0 h_mcs0 n
    let M_n := prev.val
    let inv_n := prev.property
    -- P_top is in M_n
    let h_P_top : P_top ∈ M_n := SetMaximalConsistent.contains_P_top inv_n.is_mcs
    -- Get witness using extended seed
    let witness := omega_step_backward_with_GH M0 M_n inv_n h_P_top
    ⟨witness.val, {
      is_mcs := witness.property.is_mcs
      H_propagate := fun a h_Ha_M0 =>
        witness.property.H_propagate a (inv_n.H_propagate a h_Ha_M0)
      GH_propagate := fun a h_Ga_GH =>
        -- GH_theory elements are preserved
        witness.property.GH_propagate a h_Ga_GH
      box_agree := box_class_agree_trans inv_n.box_agree witness.property.box_agree
    }⟩
```

### 4.3 Invariant Properties

**Theorem**: For all n, `omega_chain_backward_with_GH(n)` satisfies `OmegaBackwardInvariant_GH`.

This follows by construction. The key property is that GH_theory(M0) is preserved through each step because:
1. The seed contains GH_theory(M0)
2. The Lindenbaum extension includes all seed elements
3. Each element of GH_theory(M0) is both G-liftable (from M0) and H-liftable (Part 2)

**Confidence**: HIGH (85%)

---

## Part 5: Prove forward_F for All Cases

### 5.1 Sub-case (a): G(¬phi) ∉ M0

**Scenario**: F(phi) ∈ backward(n), and G(¬phi) ∉ M0.

**Resolution**:
1. F(phi) = ¬G(¬phi). Since G(¬phi) ∉ M0, by MCS negation completeness: F(phi) ∈ M0.
2. F(phi) ∈ M0 means the forward chain (starting from M0) resolves this F-obligation.
3. The forward chain at some index s > 0 has phi (by dovetailing construction).
4. The Z-chain at time s (positive) has phi.
5. Since backward(n) corresponds to time -n, we need s > -n, i.e., s + n > 0, which is satisfied for any s ≥ 1.

**Confidence**: HIGH (95%)

This case is straightforward because the F-obligation is already in M0 and the forward chain handles it.

### 5.2 Sub-case (b): G(¬phi) ∈ M0 but H(¬phi) ∉ M0

**Scenario**: F(phi) ∈ backward(n), G(¬phi) ∈ M0, H(¬phi) ∉ M0.

**Analysis**:

1. F(phi) ∈ backward(n) means: at time -n, "phi will eventually be true".
2. G(¬phi) ∈ M0 means: at time 0, "¬phi will always be true (in the future)".
3. H(¬phi) ∉ M0 means: at time 0, "it's not the case that ¬phi has always been true (in the past)".

**Semantic interpretation**:
- ¬H(¬phi) = P(phi) ∈ M0 (by MCS negation completeness)
- So at time 0, "phi was true at some past time"
- Combined: phi was true at some past time, and ¬phi will be true at all future times

This is semantically consistent! There can be a time t < 0 where phi holds, and for all times ≥ 0, ¬phi holds.

**The problem**: Where does the witness for F(phi) at time -n come from?

Since F(phi) ∈ backward(n):
- We need phi ∈ backward(m) for some m < n (i.e., time -m > time -n)
- Or phi at some time between -n and 0

**Case analysis**:

If phi ∈ backward(m) for some m < n:
- The backward chain at index m is closer to M0
- But the backward chain doesn't construct F-witnesses, only P-witnesses

If phi ∈ M0:
- Then F(phi) is immediately satisfied
- But we're told G(¬phi) ∈ M0, so ¬phi ∈ M0 (by temp_t_future)
- If both phi and ¬phi are in M0, that's a contradiction
- So phi ∉ M0

If phi at some positive time s > 0:
- We have G(¬phi) ∈ M0
- By forward G-propagation: G(¬phi) ∈ forward(s)
- By temp_t_future: ¬phi ∈ forward(s)
- So phi ∉ forward(s) (MCS consistency)

**Conclusion**: In sub-case (b), the witness must be at some time t with -n < t < 0.

The backward chain goes: M0 = backward(0), backward(1), backward(2), ..., backward(n)
In terms of time: 0, -1, -2, ..., -n

We need phi at some backward(m) with m < n.

**Critical observation**: The backward chain does not resolve F-obligations!

The backward chain is constructed by taking P-witnesses at each step. When we have F(phi) ∈ backward(n), the backward chain construction doesn't create a witness for it.

**Is this case actually reachable?**

Consider: F(phi) ∈ backward(n) but F(phi) ∉ M0 (since G(¬phi) ∈ M0).

The backward chain preserves H-theory from M0. Does it preserve F-formulas? Not in general.

Actually, F(phi) can enter backward(n) in two ways:
1. It was already in M0 (ruled out by G(¬phi) ∈ M0)
2. It entered as a P-witness or derived formula

If F(phi) entered backward(n) but wasn't in M0, it must have been derived or come from a witness.

**Key insight**: At each backward step, we add phi_k (the P-witness) to the seed. This phi_k can be any formula. If phi_k = F(some_phi), then we have an F-formula in the chain.

But wait — the seed for backward(n+1) is:
`{phi_n} ∪ H_theory(backward(n)) ∪ GH_theory(M0) ∪ box_theory(backward(n))`

The phi_n is the P-witness for `P(phi_n) ∈ backward(n)`. If phi_n contains F-subformulas, they enter backward(n+1).

**So sub-case (b) IS reachable.**

**Resolution options**:

**Option 1: Modified backward chain with F-witnesses**

At each backward step, also resolve any F-obligations by interleaving F-witnesses. But this brings back the oscillation problem (Architecture 2 from teammate B's report).

**Option 2: Show phi is already in the chain**

If we could prove that whenever F(phi) ∈ backward(n) with the sub-case (b) conditions, phi must already be at some backward(m) with m < n, we'd be done.

But this seems circular — we'd need to know the chain resolves F to prove F is resolved.

**Option 3: Stronger GH_theory definition**

Define GH_theory to also include F-formulas whose negation's G is not eternal:
```
GH_theory_extended(M0) =
  { G(a) | G(a) ∈ M0 ∧ H(a) ∈ M0 } ∪
  { F(a) | G(¬a) ∉ M0 }
```

But F-formulas are not H-liftable (G(F(a)) is derivable but H(F(a)) is not).

**Option 4: Accept as blocking**

This sub-case represents a genuine gap in the construction.

### 5.3 Sub-case (b) Verdict

**STATUS: BLOCKING**

The sub-case where G(¬phi) ∈ M0 but H(¬phi) ∉ M0 cannot be resolved with the current chain construction approach.

**Semantic meaning**: There's a time interval where phi holds, but the backward chain doesn't construct witnesses for F-obligations, only for P-obligations.

**Potential workarounds**:
1. Modify the chain to interleave F and P resolution (leads to oscillation)
2. Weaken temporal coherence to witness-existence (bundle-level approach)
3. Add F-witnesses to the GH-theory seed (but they're not H-liftable)

**Confidence**: HIGH (90%) that this is a genuine blocking case.

---

## Part 6: Address Remaining Gaps

### 6.1 Summary of What IS Provable

| Component | Status | Confidence |
|-----------|--------|------------|
| dual_temp_l | PROVABLE | HIGH (95%) |
| GH_theory H-liftable | PROVABLE | HIGH (90%) |
| Modified seed consistency | PROVABLE | HIGH (85%) |
| forward_F sub-case (a) | PROVABLE | HIGH (95%) |
| forward_F sub-case (b) | BLOCKED | HIGH (90%) |
| forward_G from forward_F | NOT DERIVABLE | HIGH (85%) |

### 6.2 The Sub-case (b) Blocking Analysis

The fundamental issue is:

> The backward chain resolves P-obligations (past witnesses) but not F-obligations (future witnesses). When an F-obligation enters the backward chain (as a derived formula), there's no mechanism to resolve it unless the corresponding witness was already in the chain.

This is a structural limitation of the bidirectional chain approach where:
- Forward chain: resolves F, preserves G
- Backward chain: resolves P, preserves H
- Neither resolves the other's obligations

### 6.3 forward_G from forward_F?

**Question**: Can we derive `forward_G` (G(phi) at t implies phi at all t' > t) from `forward_F` (F(phi) at t implies phi at some t' > t)?

**Answer**: NO, not without the chain construction preserving G-theory.

The backward direction of the truth lemma uses:
- Assume G(phi) ∉ fam.mcs(t)
- Then F(¬phi) ∈ fam.mcs(t) (by MCS duality)
- By forward_F: ∃ s > t with ¬phi ∈ fam.mcs(s)
- If phi ∈ fam.mcs(s) (from hypothesis), contradiction

This works for proving `phi true at all s → G(phi) ∈ mcs(t)`.

But the forward direction needs:
- G(phi) ∈ fam.mcs(t) → phi ∈ fam.mcs(s) for all s > t

This requires G-theory to propagate through the chain, which the backward portion doesn't do.

### 6.4 Recommended Path Forward

**Option A: Bundle-level coherence (Architecture 4)**

Weaken temporal coherence from "phi at all future times" to "phi at some future time with the same box-class". This is the standard approach in modal logic canonical models.

**Pros**:
- Mathematically sound
- Standard in literature
- No chain modification needed

**Cons**:
- Requires restructuring completeness proof
- Truth lemma for G becomes more complex

**Option B: Hybrid chain with F-resolution in backward direction**

Modify backward chain to also resolve F-obligations, using a careful seed construction that preserves both H and G theories for "eternal" formulas.

**Pros**:
- Preserves current FMCS structure
- Directly addresses the gap

**Cons**:
- Complex seed construction
- Risk of oscillation (Architecture 2 problem)
- May not be mathematically feasible

**Option C: Accept partial resolution**

Implement the GH-intersection approach for sub-case (a) only. Document sub-case (b) as a known limitation. This resolves most practical cases.

**Pros**:
- Immediate partial progress
- Clear documentation of limitations

**Cons**:
- Incomplete completeness proof
- Sub-case (b) remains unresolved

### 6.5 Effort Estimates for Each Option

| Option | Estimated Hours | Risk Level |
|--------|-----------------|------------|
| A (Bundle-level) | 8-12 | MEDIUM |
| B (Hybrid chain) | 6-10 | HIGH |
| C (Partial) | 4-6 | LOW |

---

## Appendix A: Key Axioms Reference

### TL (temp_l)
```
always(φ) → G(H(φ))
where always(φ) = H(φ) ∧ φ ∧ G(φ)
```

### Temporal Duality
```
If ⊢ φ then ⊢ swap_temporal(φ)
where swap_temporal exchanges all_future ↔ all_past
```

### Derived dual_temp_l
```
G(φ) ∧ H(φ) → H(G(φ))
```

### temp_t_future
```
G(φ) → φ
```

### temp_t_past
```
H(φ) → φ
```

### temp_4
```
G(φ) → G(G(φ))
```

## Appendix B: Source File Locations

| Definition | File | Line |
|------------|------|------|
| `G_theory` | UltrafilterChain.lean | 959 |
| `H_theory` | UltrafilterChain.lean | 1198 |
| `temporal_box_seed` | UltrafilterChain.lean | 1044 |
| `past_temporal_box_seed` | UltrafilterChain.lean | 1225 |
| `past_theory_witness_consistent` | UltrafilterChain.lean | 1340 |
| `OmegaBackwardInvariant` | UltrafilterChain.lean | 2109 |
| `Z_chain_forward_G` (with sorry) | UltrafilterChain.lean | 2299 |
| `TL_quot` (temp_l algebraic) | TenseS5Algebra.lean | 212 |
| `Axiom.temp_l` | Axioms.lean | 276 |

## Appendix C: Mathematical Summary

**GH-intersection approach resolves**:
- G-theory propagation for eternal formulas (both G and H in M0)
- F-resolution for obligations that are already in M0
- H-theory propagation (as before)

**GH-intersection approach does NOT resolve**:
- G-theory propagation for non-eternal formulas
- F-resolution for obligations that entered the backward chain but weren't in M0
- The fundamental asymmetry between forward (resolves F) and backward (resolves P) chains

**The core mathematical constraint remains**:
> A single bidirectional chain cannot simultaneously resolve F-obligations (future) and P-obligations (past) while preserving G-theory (future universal) and H-theory (past universal) across the entire chain.
