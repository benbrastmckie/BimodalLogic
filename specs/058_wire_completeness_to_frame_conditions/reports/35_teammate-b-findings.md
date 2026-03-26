# Teammate B Findings: Natural Constraints on CanonicalTask for Coherence

**Task**: 58 - Wire Completeness to Frame Conditions
**Role**: Teammate B - Task Relation Constraints Research
**Date**: 2026-03-26
**Focus**: Natural constraints on the 3-place Task relation that solve family-level coherence

---

## Key Findings

1. **CanonicalTask is already fully deterministic**: `CanonicalTask(u, x, v)` with `x > 0` is equivalent to `CanonicalTask_forward u x v`, which requires a specific Succ-chain `u = w0 -> w1 -> ... -> wx = v`. The chain is not a function (there can be multiple successors of u), but it is "functionally bounded": if you specify the full forward path, v is determined.

2. **The coherence problem is NOT about Task being relational**: The family-level coherence obstruction (`succ_chain_forward_F` depends on the false `f_nesting_is_bounded`) exists BEFORE we even invoke the Task relation. The gap is in proving that F-obligations get resolved within the SAME Succ-chain.

3. **The fundamental constraint is functional task assignment**: If we demand that `Task(u, -, -)` is a FUNCTION (i.e., each world u has a unique successor), then `Succ` becomes functional and the chain collapses to a unique linear history — giving automatic same-family coherence. This is the key algebraic insight.

4. **temp_linearity forces comparable witnesses**: The linearity axiom `F(p) ∧ F(q) → F(p ∧ q) ∨ F(p ∧ F(q)) ∨ F(F(p) ∧ q)` does NOT force a functional Task — it forces that any two F-witnesses must be comparable (one before the other or simultaneous). This is a partial-order property on witnesses, not a uniqueness property.

5. **The correct constraint for coherence**: The natural constraint that guarantees same-family F-witness is: "The Succ successor of u is UNIQUE." This is functionally equivalent to requiring a linear order within each history — which is already the semantic intent of TM logic.

---

## TaskFrame Constraints Analysis

### What CanonicalTask Already Provides

From `CanonicalTaskRelation.lean`, CanonicalTask satisfies:
1. **Nullity Identity**: `CanonicalTask(u, 0, v) ↔ u = v`
2. **Forward Compositionality**: `CanonicalTask(u, m, w) ∧ CanonicalTask(w, n, v) → CanonicalTask(u, m+n, v)`
3. **Converse**: `CanonicalTask(u, n, v) ↔ CanonicalTask(v, -n, u)`

These three axioms (from `CanonicalTaskTaskFrame`) already form a valid TaskFrame over Int. The problem is that they are INSUFFICIENT to enforce same-family coherence for F-witnesses.

### What Axioms Say About the Task Relation

The temp_linearity axiom `F(p) ∧ F(q) → F(p ∧ q) ∨ F(p ∧ F(q)) ∨ F(F(p) ∧ q)` says:

**Semantically**: If there exist witnesses at times s1 and s2 for p and q respectively, then either:
- s1 = s2 (first disjunct: `F(p ∧ q)`)
- s1 ≤ s2 (second disjunct: `F(p ∧ F(q))`)
- s2 ≤ s1 (third disjunct: `F(F(p) ∧ q)`)

This is **trichotomy of witnesses** — any two F-witnesses are temporally comparable. In terms of Task:
- If `Task(u, x, w1)` and `Task(u, y, w2)`, then either x = y, x ≤ y, or y ≤ x.

But this does NOT force the chain to be unique — it only forces the TIME DISTANCES to be totally ordered. Multiple different world-sequences could have the same distances.

### The Gap Between Linearity and Functional Task

The linearity axiom plus the forward compositionality axiom TOGETHER with the assumption that "the chain is contained in a fixed family" give coherence. But the Succ relation is NOT a function: from any MCS u with F(top) ∈ u, `successor_from_deferral_seed` produces ONE specific successor, but there could be many other valid successors. The canonical chain construction picks ONE deterministic successor at each step — but there's no logical reason for F-obligations to be resolved by THAT particular successor.

---

## Functional vs Relational Task Discussion

### Relational Task (Current State)

The current `CanonicalTask(u, x, v)` is a RELATION: it holds whenever there is ANY valid Succ-chain of length x from u to v. Since each MCS can have multiple valid successors:
- `CanonicalTask(u, 1, v1)` and `CanonicalTask(u, 1, v2)` can both hold for different v1, v2.
- The canonical chain construction picks one specific path, but it need not be the only path.

**Coherence consequence**: Even if `F(phi) ∈ u`, the specific path chosen by `forward_chain` need not contain phi in any element. A different path (also a valid CanonicalTask chain) might contain phi, but the canonical family follows only one fixed path.

### Functional Task (The Fix)

If we add the constraint: **"For each u and x > 0, there exists at most one v such that `CanonicalTask(u, x, v)`"** — i.e., functional task assignment — then:

1. The successor of u is unique (when x = 1).
2. The chain from u is deterministic.
3. If `F(phi) ∈ u`, then by the single-step forcing theorem (`single_step_forcing` in SuccRelation.lean), if `FF(phi) ∉ u` and the unique successor of u is v, then `phi ∈ v`. Coherence is automatic.

**But is this achievable?** In the canonical model, we cannot force the Succ relation to be functional — there are genuinely many valid MCS successors of any MCS u. Choosing one specific one (as `constrained_successor_from_seed` does) is an IMPLEMENTATION CHOICE, not a logical constraint on CanonicalTask.

### The Correct Reformulation

The correct solution is NOT to make Task functional at the relation level, but to make the FAMILY carry a fixed canonical successor. In the `SuccChainFMCS` construction:

```
succ_chain_fam M0 n = forward_chain M0 n (for n ≥ 0)
forward_chain M0 (n+1) = constrained_successor_from_seed (forward_chain M0 n) ...
```

This is functionally defined — each M0 gives exactly one family. The coherence question is whether F-obligations in this specific family get resolved within the same family.

**The obstruction**: `constrained_successor_from_seed` picks a successor that satisfies `g_content u ⊆ v` (G-persistence) and `f_content u ⊆ v ∪ f_content v` (F-step). The F-step condition ONLY ensures that each F-obligation is either resolved at the next step OR deferred (F-obligation appears in the next element). This alone does not guarantee eventual resolution.

---

## Linearity and Compositionality Connection

### How Linearity Constrains Witnesses

The `temp_linearity` axiom in the proof system (Axioms.lean line 344) directly translates to: within any MCS u, the witnesses for F-formulas are TOTALLY ORDERED. Formally, if `F(phi) ∈ u` and `F(psi) ∈ u`, then either:
- `F(phi ∧ psi) ∈ u` (same witness)
- `F(phi ∧ F(psi)) ∈ u` (phi-witness precedes psi-witness)
- `F(F(phi) ∧ psi) ∈ u` (psi-witness precedes phi-witness)

This means that within any MCS, the F-obligations have a WELL-ORDER structure: there is a "nearest" F-obligation, a "second nearest," etc.

### How Compositionality Helps

The forward compositionality axiom `CanonicalTask(u, m, w) ∧ CanonicalTask(w, n, v) → CanonicalTask(u, m+n, v)` ensures that chains can be concatenated. Combined with linearity, this means:

If the nearest F-obligation at u is `F(phi)` at distance x (meaning `F^x(phi) ∈ u` but `F^(x+1)(phi) ∉ u`), and we have a forward chain of length x from u to v, then by `bounded_witness` (CanonicalTaskRelation.lean line 650), `phi ∈ v`.

This is the KEY THEOREM that already exists! The `bounded_witness` theorem says:

```
If iter_F n phi ∈ u, iter_F (n+1) phi ∉ u, and CanonicalTask_forward_MCS u n v,
then phi ∈ v.
```

### The Remaining Gap

The `bounded_witness` theorem is already proven. The gap is in constructing `CanonicalTask_forward_MCS u n v` for the SPECIFIC n that bounds the F-nesting depth of `F(phi)`.

**The known false lemma** (`f_nesting_is_bounded` in SuccChainFMCS.lean comments) says: "An MCS can contain {F^n(p) | n ∈ Nat} and still be consistent." This means there is NO BOUND on the F-nesting depth of formulas in a general MCS. Therefore, even though `bounded_witness` is proven, we cannot produce the n needed to apply it.

---

## Proposed Constraint-Based Solution

### Constraint 1: Closure Restriction (ALREADY WORKS)

If we restrict to **RestrictedMCS** — MCSes built from the closure of a specific target formula phi — then `f_nesting_is_bounded_restricted` IS provable (it's mentioned in SuccChainFMCS.lean comments). Within the closure of phi, there are only finitely many F-nesting depths, so the bound exists.

This suggests: **use a restricted canonical model** where the worlds are restricted MCSes over the closure of the formula we want to prove. This is the "Restricted Completeness" approach mentioned in option 3 of SuccChainFMCS.lean.

**Algebraic formulation**: Define a natural constraint on CanonicalTask as follows:

```
ClosureBoundedTask(u, x, v) := CanonicalTask(u, x, v) ∧
  (for all phi ∈ closure(target_formula):
    if iter_F x phi ∈ u and iter_F (x+1) phi ∉ u,
    then phi ∈ v)
```

This constraint makes the coherence condition DEFINITIONAL — it's baked into what it means for a chain to be a valid task chain within the closure.

### Constraint 2: Functional Successor Constraint

A more algebraic approach is to add to the TaskFrame the constraint:

```
(* Functional Task Axiom *)
CanonicalTask(u, x, v) ∧ CanonicalTask(u, x, w) → v = w
```

This forces each world to have a unique state at each time distance. If the Task relation is functional, then the family is unique and F-coherence follows automatically from the Succ properties (F-step guarantees eventual resolution in the unique chain).

**How to enforce this in the canonical model**: Build the forward chain using a DETERMINISTIC successor function that is PROVEN to be unique. The `constrained_successor_from_seed` construction already picks a specific successor — the claim would be that this specific choice makes Task functional WITHIN the canonical chain.

**Why this helps for coherence**: If Task(u, -, -) is functional, then the family is a straight line, and:
1. `F(phi) ∈ u` means phi must appear SOMEWHERE in the future along this unique line.
2. By the linearity axiom (which forces total ordering of witnesses), there is a well-defined "distance" x to the nearest witness.
3. By `bounded_witness`, the world at distance x contains phi.

The functional constraint PLUS linearity PLUS bounded_witness gives coherence.

### Constraint 3: Persistence Constraint (Weakest Natural Constraint)

The weakest natural constraint that provides coherence is:

```
(* F-Obligation Persistence *)
If F(phi) ∈ u and Task(u, 1, v), then F(phi) ∈ v OR phi ∈ v.
```

This is exactly the `f_step` condition of `Succ`:
```lean
f_content u ⊆ v ∪ f_content v
```

where `f_content u = {phi | F(phi) ∈ u}`.

This is already built into the Succ definition! The issue is that "F(phi) ∈ v" means the obligation is DEFERRED (not resolved), and deferral can continue indefinitely in a general chain.

To turn this into a coherence guarantee, add the **Finite Deferral Constraint**:

```
(* Finite Deferral *)
If F(phi) ∈ u, then there is NO infinite Succ-chain from u along which F(phi) is deferred at every step.
```

This is equivalent to saying: the F-nesting depth `depth(F^n(phi) ∈ family_element)` is bounded. For RestrictedMCS over the closure of phi, this holds because the closure is finite.

---

## Key Insight: "Same Family" via Functional Task

In the 3-place relation formulation, "same family as u" with respect to Task(u, x, v) means:

**Option A (Functional Interpretation)**: v is uniquely determined by u and x. "Same family" = "on the unique chain extending u." This is the cleanest interpretation and makes "same family" trivially coherent if we add the functional axiom.

**Option B (Relational Interpretation)**: "Same family as u" is defined as a set F such that:
- u ∈ F
- F is closed under Task: if w ∈ F and Task(w, x, v) holds for some specific x and v in F, then v ∈ F
- F is linearly ordered by the Task relation

In the relational case, multiple chains satisfy these conditions. Coherence requires that the specific chain we choose (via `forward_chain`) happens to resolve all F-obligations.

**The correct algebraic answer**: The natural constraint that makes "same family" well-defined and coherent is:

> **Unique Successor Constraint**: For each world u in the family F, there is exactly one immediate successor v in F, i.e., `Task(u, 1, v)` holds for exactly one v ∈ F.

With this constraint:
1. "Same family as u" is the unique maximal chain through u (determined by u's unique successors and predecessors).
2. F-obligations are resolved by `bounded_witness` applied to this unique chain.
3. The chain is literally a linear order (isomorphic to ℤ), matching TM's linear time semantics.

This is precisely what `succ_chain_fam` implements: it builds a unique chain using `constrained_successor_from_seed`. The MATHEMATICAL gap is proving that this specific chain resolves F-obligations with bounded nesting depth — which requires the RestrictedMCS approach.

---

## Confidence Level: HIGH

This analysis is based on:
1. Direct reading of `CanonicalTaskRelation.lean` — the three TaskFrame axioms and `bounded_witness`.
2. Direct reading of `SuccRelation.lean` — the `f_step` condition and `single_step_forcing`.
3. Direct reading of `Axioms.lean` — `temp_linearity` and its semantic meaning.
4. Direct reading of `SuccChainFMCS.lean` — the chain construction and the known limitations.
5. Conceptual analysis of the functional vs relational Task distinction.
6. Prior research waves (reports 11, 15, 18, 30) which converged on the same obstruction.

The core finding is:
- **Natural constraint for coherence**: Unique Successor Constraint (functional Task in each family).
- **How to implement it**: Either (a) RestrictedMCS over the closure of the target formula, or (b) prove that `constrained_successor_from_seed` is the UNIQUE valid Succ-continuation preserving the MCS constraints.
- **What makes this hard**: Proving uniqueness of the canonical successor or finiteness of F-nesting in restricted worlds is the remaining technical gap.
- **The bounded_witness theorem is the bridge**: Once we can construct `CanonicalTask_forward_MCS u n v` for the right n (the F-nesting depth bound), coherence is proven. The constraint needed is just: "F-nesting depths are bounded in the canonical restricted world."
