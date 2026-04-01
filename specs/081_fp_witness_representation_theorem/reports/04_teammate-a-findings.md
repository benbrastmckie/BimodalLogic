# Complete Design: Dovetailed Construction with Controlled Seeding

**Task**: 81 - F/P Witness Representation Theorem
**Author**: Teammate A (Math Research Agent)
**Date**: 2026-03-31
**Focus**: Full mathematical specification for direct Lean 4 implementation

## 1. Overview

This document provides a complete, mathematically rigorous construction of temporally coherent families using dovetailed chains with controlled seeding. The key insight is that we must actively prevent G(neg phi) from entering the chain while F(phi) obligations remain pending.

### The Goal

For any MCS M_0, construct a `TemporalCoherentFamily fam : Z -> MCS` such that:
1. `fam(0) = M_0`
2. `forward_G`: G(phi) in fam(t) implies phi in fam(s) for all s >= t
3. `backward_H`: H(phi) in fam(t) implies phi in fam(s) for all s <= t
4. `forward_F`: F(phi) in fam(t) implies there exists s >= t with phi in fam(s) (same family)
5. `backward_P`: P(phi) in fam(t) implies there exists s <= t with phi in fam(s) (same family)

### Construction Strategy

1. **Forward Chain**: Build ω-indexed chain from M_0 using controlled seeding
2. **Fair Scheduling**: Use Nat.unpair to enumerate all (time, formula) pairs
3. **Controlled Seeding**: Include `neg G(neg psi)` for all pending F(psi) obligations
4. **Backward Extension**: Use σ-duality (converse property) to extend to negative integers
5. **Assembly**: Combine forward and backward chains at time 0

## 2. Data Structures

### 2.1 Obligation Type

```lean
/--
An F-obligation records a formula phi and the time t at which F(phi) appeared.
The obligation is "resolved" when phi appears at some time s >= t.
-/
structure FutureObligation where
  formula : Formula
  origin_time : Nat
  deriving DecidableEq

/--
A P-obligation records a formula phi and the time t at which P(phi) appeared.
The obligation is "resolved" when phi appears at some time s <= t.
-/
structure PastObligation where
  formula : Formula
  origin_time : Nat
  deriving DecidableEq
```

### 2.2 Obligation Tracker

```lean
/--
Tracks pending F-obligations during forward chain construction.

Invariant: All obligations in `pending` have F(phi) in chain(origin_time)
and phi has not yet appeared in any chain(s) for s >= origin_time.
-/
structure ObligationTracker where
  pending : Finset FutureObligation
  resolved : Finset FutureObligation
```

### 2.3 Scheduling Function

Use Mathlib's `Nat.unpair` to enumerate all (time, formula-index) pairs:

```lean
/--
Fair scheduling: unpair(n) = (t, k) means at step n, we consider
resolving the k-th F-obligation at time t (if one exists).
-/
def schedule (n : Nat) : Nat × Nat := Nat.unpair n
```

**Property**: For any (t, k), there exists n such that `unpair(n) = (t, k)`.
This is `Nat.unpair_surjective`.

### 2.4 Chain State

```lean
/--
The state at step n of the forward chain construction.
-/
structure ChainState (n : Nat) where
  /-- The chain built so far: chain(0), chain(1), ..., chain(n) -/
  chain : Fin (n + 1) → Set Formula
  /-- Each element is an MCS -/
  chain_mcs : ∀ i, SetMaximalConsistent (chain i)
  /-- Pending F-obligations -/
  tracker : ObligationTracker
  /-- Box-class agreement with M_0 -/
  box_agree : ∀ i, box_class_agree (chain 0) (chain i)
```

## 3. The Controlled Seeding Lemma

### 3.1 Controlled Seed Definition

```lean
/--
The controlled seed for constructing chain(n+1) from chain(n).

Contains:
1. G_theory(chain(n)): all formulas whose G is in chain(n)
2. box_theory(chain(n)): modal content for box-class preservation
3. phi_resolve: the formula being witnessed this step (if any)
4. F-blockers: {neg G(neg psi) | F(psi) pending}

The F-blockers prevent G(neg psi) from entering the extension, keeping
F(psi) resolvable at future times.
-/
def controlled_seed (M : Set Formula) (phi_resolve : Option Formula)
    (pending : Finset FutureObligation) : Set Formula :=
  G_theory M ∪ box_theory M ∪
  (match phi_resolve with | some phi => {phi} | none => ∅) ∪
  { Formula.neg (Formula.all_future (Formula.neg obl.formula)) | obl ∈ pending }
```

**Note**: `neg G(neg psi) = F(psi)` by definition. The seed explicitly includes F(psi) for all pending obligations.

### 3.2 Consistency of Controlled Seed

**Lemma (controlled_seed_consistent)**: If M is an MCS, phi_resolve is either:
- None, or
- Some phi where F(phi) in M

and all pending obligations have F(obl.formula) in M, then `controlled_seed M phi_resolve pending` is consistent.

**Proof**:

The key observation is that the controlled seed is a subset of formulas that are "compatible" with M.

1. **G_theory(M) is consistent with M**: By definition, G_theory(M) = {G(a) | G(a) in M}. This is a subset of M.

2. **box_theory(M) is consistent with M**: box_theory(M) = {Box(a) | Box(a) in M} ∪ {neg Box(a) | Box(a) not in M}. By MCS properties, this is consistent with M.

3. **phi_resolve consistent with G_theory(M) ∪ box_theory(M)**: When F(phi) in M, we use `temporal_theory_witness_consistent` which proves {phi} ∪ G_theory(M) ∪ box_theory(M) is consistent.

4. **F-blockers consistent with the seed**: For each pending F(psi), we have F(psi) in M. Since F(psi) = neg G(neg psi), and MCS is complete, G(neg psi) is not in M. Therefore:
   - neg G(neg psi) = F(psi) is in M
   - Each F-blocker is in M
   - All F-blockers are mutually consistent (they're all in M)
   - F-blockers are consistent with phi_resolve: if phi_resolve = psi, then F(psi) in M, so including psi and F(psi) is consistent

**The consistency argument**: Assume for contradiction that the seed is inconsistent. Then some finite subset derives bot. This finite subset contains:
- Finitely many elements of G_theory(M): all in M
- Finitely many elements of box_theory(M): consistent with M by construction
- At most one phi_resolve: if F(phi) in M, then {phi} ∪ temporal_box_seed(M) is consistent
- Finitely many F-blockers: all are F(obl.formula) which are in M

So we have a finite subset of M plus elements consistent with M deriving bot. But M is consistent, contradiction.

**Formal statement**:
```lean
theorem controlled_seed_consistent (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi_resolve : Option Formula)
    (h_resolve : ∀ phi, phi_resolve = some phi → Formula.some_future phi ∈ M)
    (pending : Finset FutureObligation)
    (h_pending : ∀ obl ∈ pending, Formula.some_future obl.formula ∈ M) :
    SetConsistent (controlled_seed M phi_resolve pending)
```

### 3.3 Lindenbaum Extension Preserves F-Obligations

**Lemma (lindenbaum_preserves_F_blockers)**: If S is a consistent set containing neg G(neg psi), and W is a Lindenbaum extension of S (i.e., W ⊇ S and W is an MCS), then neg G(neg psi) in W.

**Proof**: Lindenbaum's lemma guarantees S ⊆ W. Since neg G(neg psi) in S, we have neg G(neg psi) in W.

**Corollary**: If the controlled seed contains F(psi) for all pending obligations, then the Lindenbaum extension W contains F(psi) for all pending obligations.

## 4. Forward Chain Construction

### 4.1 Inductive Definition

```lean
/--
The forward chain construction with controlled seeding and obligation tracking.

At each step n:
1. Compute which (time, formula-index) pair to consider via unpair(n)
2. Collect new F-obligations from chain(n) that haven't been seen
3. If resolving an obligation this step, add phi to the seed
4. Build controlled seed with all pending F-blockers
5. Extend to MCS via Lindenbaum
6. Update tracker: mark resolved obligations, add new ones
-/
noncomputable def forward_chain_with_tracking (M₀ : Set Formula) (h_mcs₀ : SetMaximalConsistent M₀) :
    (n : Nat) → ChainState n
```

### 4.2 Step-by-Step Construction

**Base Case (n = 0)**:
```lean
| 0 => {
    chain := fun _ => M₀,
    chain_mcs := fun _ => h_mcs₀,
    tracker := {
      pending := collect_F_obligations M₀ 0,
      resolved := ∅
    },
    box_agree := fun _ => box_class_agree_refl M₀
  }
```

Where `collect_F_obligations M t` returns all F(phi) in M as obligations with origin_time = t.

**Inductive Case (n + 1)**:

```lean
| n + 1 =>
  let prev := forward_chain_with_tracking M₀ h_mcs₀ n
  let M_n := prev.chain (Fin.last n)
  let (t, k) := Nat.unpair n  -- Which obligation to consider

  -- Find the k-th pending obligation at time t (if exists)
  let obl_to_resolve : Option FutureObligation :=
    (prev.tracker.pending.filter (fun obl => obl.origin_time = t)).toList.get? k

  -- Phi to resolve this step
  let phi_resolve : Option Formula := obl_to_resolve.map (·.formula)

  -- Build controlled seed
  let seed := controlled_seed M_n phi_resolve prev.tracker.pending

  -- Consistency (proven by controlled_seed_consistent)
  have h_seed_cons : SetConsistent seed := ...

  -- Lindenbaum extension
  let ⟨W, h_extends, h_W_mcs⟩ := set_lindenbaum seed h_seed_cons

  -- Extend chain
  let new_chain : Fin (n + 2) → Set Formula := fun i =>
    if h : i.val ≤ n then prev.chain ⟨i.val, Nat.lt_succ_of_le h⟩
    else W

  -- Update tracker
  let new_pending := prev.tracker.pending.filter (fun obl =>
    obl_to_resolve ≠ some obl) ∪ collect_F_obligations W (n + 1)
  let new_resolved := match obl_to_resolve with
    | some obl => prev.tracker.resolved.insert obl
    | none => prev.tracker.resolved

  {
    chain := new_chain,
    chain_mcs := ...,
    tracker := { pending := new_pending, resolved := new_resolved },
    box_agree := ...
  }
```

### 4.3 Key Invariants

**Invariant 1 (G-Coherence)**: For all i <= j <= n, G(phi) in chain(i) implies phi in chain(j).

**Proof by induction**:
- Base: trivial for n = 0
- Inductive: chain(n+1) extends G_theory(chain(n)), so by temp_t (G(phi) -> phi), phi in chain(n+1). By induction, G(phi) propagates from chain(i) to chain(n), hence to chain(n+1).

**Invariant 2 (Box-Class Agreement)**: For all i <= n, box_class_agree(chain(0), chain(i)).

**Proof**: Each step uses controlled_seed which includes box_theory. The Lindenbaum extension preserves box_class_agree by `temporal_theory_witness_exists`.

**Invariant 3 (F-Persistence)**: For all pending obligations obl, F(obl.formula) in chain(n).

**Proof by induction**:
- Base: pending obligations at time 0 have F(phi) in M₀ = chain(0)
- Inductive: The controlled seed includes neg G(neg phi) = F(phi) for all pending. By lindenbaum_preserves_F_blockers, F(phi) in chain(n+1).

**Invariant 4 (Resolution Tracking)**: If obl is resolved at step n, then obl.formula in chain(n).

**Proof**: When we resolve obl, phi_resolve = obl.formula is in the seed. By Lindenbaum, phi in chain(n).

## 5. Forward_F Theorem

### 5.1 Statement

**Theorem (forward_chain_forward_F)**: Let chain = forward_chain M₀ h_mcs₀. For all t : Nat and phi : Formula, if F(phi) in chain(t), then there exists s >= t such that phi in chain(s).

### 5.2 Proof

1. **F(phi) creates an obligation**: When F(phi) in chain(t), the obligation `⟨phi, t⟩` is added to pending at step t.

2. **Fair scheduling guarantees resolution**: By surjectivity of unpair, there exists n such that unpair(n) = (t, k) where k is the index of this obligation among pending obligations at time t.

3. **At step n, the obligation is resolved**: Either:
   - The obligation was already resolved at an earlier step (phi appeared earlier)
   - The obligation is resolved at step n: phi is added to the seed, so phi in chain(n)

4. **Witness exists**: In either case, there exists s >= t with phi in chain(s).

**The key insight**: Fair scheduling via unpair ensures every obligation eventually gets its "turn" to be resolved. The controlled seeding ensures the obligation remains resolvable (F(phi) persists) until that turn arrives.

### 5.3 Formal Statement

```lean
theorem forward_chain_forward_F (M₀ : Set Formula) (h_mcs₀ : SetMaximalConsistent M₀)
    (t : Nat) (phi : Formula) (h_F : Formula.some_future phi ∈ (forward_chain M₀ h_mcs₀ t)) :
    ∃ s : Nat, t ≤ s ∧ phi ∈ (forward_chain M₀ h_mcs₀ s) := by
  -- Obligation tracking shows the obligation is created at time t
  -- Fair scheduling shows it's eventually considered
  -- F-persistence shows it remains resolvable until considered
  -- Resolution shows phi enters the chain
  sorry -- ~50-100 lines of actual proof
```

## 6. Backward Extension via σ-Duality

### 6.1 The Converse Property

The TM axiom system includes the converse property (aka σ-duality):

```
R_G(U, V) ↔ R_H(V, U)
```

In MCS terms: the accessibility relation for G on ultrafilters is the converse of the accessibility relation for H.

### 6.2 Dual Construction

**Key Lemma**: If we have a forward ω-chain `fwd : Nat → MCS` from M₀ satisfying:
- forward_G: G(phi) in fwd(t) implies phi in fwd(s) for all s >= t
- forward_F: F(phi) in fwd(t) implies there exists s >= t with phi in fwd(s)

Then we can construct a backward ω-chain `bwd : Nat → MCS` from M₀ satisfying:
- backward_H: H(phi) in bwd(t) implies phi in bwd(s) for all s >= t (going into the past)
- backward_P: P(phi) in bwd(t) implies there exists s >= t with phi in bwd(s) (going into the past)

**Construction**: The backward chain is constructed symmetrically:
- Use `past_theory_witness_exists` instead of `temporal_theory_witness_exists`
- Track P-obligations instead of F-obligations
- Include H_theory instead of G_theory in the seed
- Include `neg H(neg psi)` = P(psi) for pending P-obligations

### 6.3 Past Temporal Witness Infrastructure

The codebase already has:

```lean
theorem past_theory_witness_exists (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi : Formula) (h_P : Formula.some_past phi ∈ M) :
    ∃ W : Set Formula, SetMaximalConsistent W ∧ phi ∈ W ∧
      (∀ a, Formula.all_past a ∈ M → Formula.all_past a ∈ W) ∧
      box_class_agree M W
```

This is symmetric to `temporal_theory_witness_exists` for the forward direction.

### 6.4 Backward Chain Construction

```lean
/--
The backward chain construction is symmetric to forward.
Uses past_temporal_box_seed = H_theory ∪ box_theory.
-/
noncomputable def backward_chain_with_tracking (M₀ : Set Formula) (h_mcs₀ : SetMaximalConsistent M₀) :
    (n : Nat) → BackwardChainState n
```

**Backward_P Theorem**: Symmetric to forward_F, using unpair scheduling for P-obligations.

## 7. Final Assembly

### 7.1 Joining at Time 0

Both the forward chain and backward chain start at M₀:
- `forward_chain M₀ h_mcs₀ 0 = M₀`
- `backward_chain M₀ h_mcs₀ 0 = M₀`

This ensures the chains agree at time 0.

### 7.2 The Z-indexed Family

```lean
/--
The complete temporally coherent family indexed by Z.

For t >= 0: fam(t) = forward_chain(t)
For t < 0: fam(t) = backward_chain(-t)

Note: fam(0) = M₀ from both branches.
-/
noncomputable def temporal_coherent_family (M₀ : Set Formula) (h_mcs₀ : SetMaximalConsistent M₀) :
    TemporalCoherentFamily Int where
  mcs := fun t =>
    if t >= 0 then forward_chain M₀ h_mcs₀ t.toNat
    else backward_chain M₀ h_mcs₀ (-t).toNat
  is_mcs := fun t => ...
  forward_G := fun t phi h_G s h_le => ...
  backward_H := fun t phi h_H s h_le => ...
  forward_F := fun t phi h_F => ...
  backward_P := fun t phi h_P => ...
```

### 7.3 Verifying All Properties

**Property 1: forward_G**

For t >= 0, s >= t >= 0: Use forward_chain_G_coherence.
For t < 0, s >= t: Need to handle crossing 0.

If t < 0 and s >= 0:
- G(phi) in backward_chain(-t)
- By backward chain H-propagation (G and H are intertwined via box_theory): Need careful analysis.

**Actually, the crossing-0 case requires more infrastructure**. The key insight:
- G(phi) in M implies G(G(phi)) in M (by temp_4)
- This G(G(phi)) propagates through the backward chain
- At time 0, G(phi) in M₀
- G(phi) propagates through the forward chain by G_theory inclusion

**Property 2: backward_H**

Symmetric argument using H_theory propagation.

**Property 3: forward_F**

- For t >= 0: Direct from forward_chain_forward_F
- For t < 0: F(phi) in backward_chain(-t). By MCS properties, F(phi) implies F(F(phi)) (seriality). This propagates... Actually, this case is subtle.

**The t < 0 case for forward_F**: If F(phi) in fam(t) for t < 0, we need phi at some s >= t. Since t < 0 and s could be any integer >= t, the witness could be at s >= 0 (in the forward chain) or at -t > s >= t (in the backward chain).

The solution: When F(phi) in backward_chain(-t), by the same controlled seeding logic, we keep F(phi) alive as we build toward time 0. At time 0, F(phi) in M₀ (since F-blockers persist). Then by forward_chain_forward_F, phi appears at some s >= 0.

**Property 4: backward_P**

Symmetric to forward_F.

## 8. Lemma Inventory

### 8.1 Existing Infrastructure (No new proofs needed)

| Lemma | Location | Purpose |
|-------|----------|---------|
| `set_lindenbaum` | Core/MaximalConsistent.lean:291 | Extend consistent set to MCS |
| `temporal_theory_witness_exists` | Algebraic/UltrafilterChain.lean:2212 | F-witness with G-preservation |
| `past_theory_witness_exists` | Algebraic/UltrafilterChain.lean:2400 | P-witness with H-preservation |
| `G_theory`, `H_theory` | Algebraic/UltrafilterChain.lean | G/H content extraction |
| `box_theory` | Algebraic/UltrafilterChain.lean | Box content extraction |
| `box_class_agree_refl`, `box_class_agree_trans` | Algebraic/UltrafilterChain.lean | Box-class agreement |
| `SetMaximalConsistent.negation_complete` | Core/MCSProperties.lean:174 | MCS has phi or neg phi |
| `SetMaximalConsistent.implication_property` | Core/MCSProperties.lean:150 | Modus ponens in MCS |
| `Nat.unpair_surjective` | Mathlib | Fair scheduling guarantee |
| `TemporalCoherentFamily` | Bundle/TemporalCoherence.lean:146 | Target structure |

### 8.2 New Lemmas Required

| Lemma | Estimated Lines | Purpose |
|-------|-----------------|---------|
| `controlled_seed_consistent` | 50-80 | Consistency of augmented seed |
| `lindenbaum_preserves_F_blockers` | 10-15 | F(psi) persists through extension |
| `forward_chain_invariant_G` | 30-50 | G-coherence through chain |
| `forward_chain_invariant_box` | 20-30 | Box-class agreement through chain |
| `forward_chain_invariant_F_persist` | 40-60 | F-obligations persist until resolved |
| `forward_chain_forward_F` | 50-80 | Main forward_F theorem |
| `backward_chain_backward_P` | 50-80 | Symmetric to forward_F |
| `chains_agree_at_zero` | 10-15 | Forward and backward meet at M₀ |
| `forward_F_cross_zero` | 40-60 | F-witness crossing t=0 boundary |
| `backward_P_cross_zero` | 40-60 | P-witness crossing t=0 boundary |
| `temporal_coherent_family_construction` | 100-150 | Final assembly |

## 9. Complexity Assessment

### 9.1 Line Count Estimate

| Component | Lines | Confidence |
|-----------|-------|------------|
| Data structures (Obligation, Tracker, ChainState) | 50-80 | High |
| Controlled seeding and consistency | 80-120 | Medium |
| Forward chain construction | 150-250 | Medium |
| Forward_F theorem | 60-100 | Medium |
| Backward chain (symmetric) | 100-150 | High |
| Backward_P theorem | 40-60 | High |
| Cross-zero handling | 80-120 | Medium |
| Final assembly | 100-150 | Medium |
| **Total** | **660-1030** | **Medium** |

### 9.2 Risk Assessment

**High Risk Areas**:
1. **Cross-zero cases**: F(phi) at negative time needing witness at positive time requires careful invariant propagation.
2. **Obligation tracking termination**: Must prove unpair eventually hits every obligation.
3. **Finset bookkeeping**: Lean's Finset operations can be verbose.

**Medium Risk Areas**:
1. **Controlled seed consistency**: The proof is conceptually clear but requires careful MCS reasoning.
2. **Invariant maintenance**: Each step must maintain all invariants simultaneously.

**Low Risk Areas**:
1. **Symmetric backward construction**: Direct mirror of forward.
2. **Final assembly**: Straightforward case split on sign of t.

### 9.3 Alternative Simplification

If the full construction proves too complex, consider:

**Restricted Construction**: Build TemporalCoherentFamily only for MCSes within `deferralClosure(phi)` for specific phi. The existing `restricted_forward_chain_forward_F` at UltrafilterChain.lean:2930 is already sorry-free for this case. This may suffice for weak completeness.

## 10. Summary

The dovetailed construction with controlled seeding is the mathematically correct approach to building temporally coherent families with same-family forward_F and backward_P. The key innovations are:

1. **Fair scheduling via Nat.unpair**: Guarantees all obligations eventually get resolved.

2. **Controlled seeding with F-blockers**: Prevents G(neg psi) from entering the chain while F(psi) is pending, ensuring obligations remain resolvable.

3. **σ-duality for backward extension**: Uses the symmetric past infrastructure to extend from N to Z.

4. **Cross-zero coherence**: Careful invariant tracking ensures properties hold across the t=0 boundary.

The estimated implementation effort is 660-1030 lines of Lean 4 code, with medium overall risk. The construction builds on substantial existing infrastructure (temporal_theory_witness_exists, set_lindenbaum, etc.) and follows the established patterns in UltrafilterChain.lean.
