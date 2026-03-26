# Teammate C Findings: Partial Order Construction with Linearization

**Task**: 58 - Wire Completeness to Frame Conditions
**Date**: 2026-03-26
**Focus**: Partial Order Construction with Linearization for Canonical Model

---

## Key Findings

- The partial order construction is a genuine and mathematically sound alternative approach to canonical model completeness
- The `temp_linearity` axiom (`F(phi) ∧ F(psi) → F(phi ∧ psi) ∨ F(phi ∧ F(psi)) ∨ F(F(phi) ∧ psi)`) is the right tool for linearity enforcement within families
- Linearization within families is provable but requires careful treatment of the coinductive/quasimodel style of argument
- The partial order construction does NOT require `f_nesting_is_bounded` to be true - it sidesteps the key obstruction entirely
- The maximization step requires coordinated (not independent) extensions - this is the principal implementation challenge
- The approach generates essentially the same structure as the `boxClassFamilies`/`BFMCS_Bundle` construction, offering a new angle of attack on the "same-family" problem
- **Critical gap**: The linearization argument requires showing that the partial order has no incomparable temporal elements within a family - this requires a non-trivial completeness argument for the linearity axiom itself

---

## Formal Construction

### Step 0: Setup

Let `M0` be a maximal consistent set (MCS) for formula language `L`. We build a rooted partial-order model `(N, ≤, fam)` where:
- Each node is a triple `(Γ, t, f)` where `Γ` is a consistent set, `t ∈ Z` is a time index, and `f` is a family identifier
- The root is `(M0, 0, f₀)` for a fresh family identifier `f₀`

### Step 1: Partial Order Definition

Define a binary relation `≤` on nodes:

```
(Γ, t, f) ≤ (Γ', t', f')  iff:
  (a) f = f' and t ≤ t'   [temporal ordering within same family], OR
  (b) (Γ, t, f) spawned (Γ', t', f') via Diamond
```

More precisely, the Diamond-spawning relation is defined inductively:
- `(Γ, t, f) spawns (Γ', t', f')` if `◇(phi) ∈ Γ` and `Γ' ⊇ {phi}` and `f' ≠ f` (fresh family)
- Transitivity: if `(Γ, t, f) spawns (Δ, s, g)` and `(Δ, s, g) ≤ (Γ', t', f')` then `(Γ, t, f) ≤ (Γ', t', f')`

This makes `≤` a partial order on node triples:
- **Reflexivity**: `(Γ, t, f) ≤ (Γ, t, f)` by (a) with `t ≤ t`
- **Transitivity**: cases (a)+(a) give transitivity by `Int` transitivity; (a)+(b), (b)+(a), (b)+(b) follow by the inductive definition
- **Antisymmetry**: within a family (a), follows from `Int` antisymmetry; across families (b), the DAG structure of Diamond-spawning prevents cycles (each spawn creates a strictly new family)

### Step 2: Node Generation

Starting from the root `(M0, 0, f₀)`, generate nodes by exhaustive application of three rules:

**Rule T+ (Temporal Future)**: If `F(phi) ∈ Γ` for node `(Γ, t, f)`, add a pending obligation to generate a node `(Γ', t+k, f)` for some `k > 0` with `phi ∈ Γ'`, in the same family `f`.

**Rule T- (Temporal Past)**: If `P(phi) ∈ Γ` for node `(Γ, t, f)`, add a pending obligation to generate a node `(Γ', t-k, f)` for some `k > 0` with `phi ∈ Γ'`, in the same family `f`.

**Rule M (Modal Diamond)**: If `◇(phi) ∈ Γ` for node `(Γ, t, f)`, add a node `(Γ', t, f')` at time `t` in a **new** family `f'` with `phi ∈ Γ'`.

The seeds for Rules T+ and T- are:
- For Rule T+: `forward_temporal_witness_seed(Γ, phi) = {phi} ∪ g_content(Γ)`
- For Rule T-: `past_temporal_witness_seed(Γ, phi) = {phi} ∪ h_content(Γ)`

The existing proofs in `WitnessSeed.lean` establish that these seeds are consistent whenever `F(phi) ∈ Γ` (resp. `P(phi) ∈ Γ`). These seeds can then be extended to MCS by Lindenbaum's lemma.

### Step 3: Linearization Within Families

After generating the tree of consistent sets, we must show that within each family `f`, the temporal indices can be linearly ordered. This is where `temp_linearity` plays its role.

The key claim is:

> **Linearity Claim**: For any two nodes `(Γ₁, t₁, f)` and `(Γ₂, t₂, f)` in the same family, the temporal indices `t₁` and `t₂` are comparable: `t₁ ≤ t₂` or `t₂ ≤ t₁`.

This follows from the construction because within each family, nodes are generated at integer positions by Rules T+ and T- which produce them at positions `t+1`, `t+2`, ... and `t-1`, `t-2`, .... The integer indices are already linearly ordered.

The more subtle question is: **do we need to apply `temp_linearity` to eliminate spurious branching?** The answer is: branching cannot arise within a family because:
1. Nodes in the same family are always generated at specific integer offsets
2. Different integer offsets are comparable in `Z`
3. The generation rules only create temporal siblings (same-family, different-time nodes) along a single timeline

Specifically, `temp_linearity` (`F(phi) ∧ F(psi) → F(phi ∧ psi) ∨ F(phi ∧ F(psi)) ∨ F(F(phi) ∧ psi)`) encodes that any two future witnesses are comparable in time. This axiom ensures no branching in the canonical model for future witnesses.

### Step 4: Coordinated Maximization

After generating all consistent seeds, we need to maximize each to an MCS. **This cannot be done independently.** The key constraints are:

1. **G-coherence**: If `G(phi) ∈ Γ` for node `(Γ, t, f)`, then `phi ∈ Γ'` for all `(Γ', t', f)` with `t' > t` in the same family. This must be preserved during maximization.

2. **H-coherence**: Symmetric to G-coherence for the past.

3. **Modal coherence**: If `□(phi) ∈ Γ` for node `(Γ, t, f)`, then `phi ∈ Γ'` for all nodes `(Γ', t, f')` at time `t` in any family. This cross-family constraint must be maintained.

The coordinated maximization can be structured as follows:

**Approach A (Simultaneous Lindenbaum)**: Extend all seeds simultaneously using a single enumeration of all formulas, with the constraint that whenever a formula `phi` is added to node `(Γ, t, f)` where it is required at other nodes (by G/H/□ propagation), it is added consistently there too.

**Approach B (Canonical Construction)**: Use the `SuccChainFMCS` construction for each family independently, with the `constrained_successor_from_seed` construction that already enforces P-step coherence. The existing `boxClassFamilies` construction does exactly this.

**Observation**: Approach B is essentially what `boxClassFamilies` in `UltrafilterChain.lean` already implements. The partial order construction I am describing would converge to the same mathematical object as the `BFMCS_Bundle` construction, approached from a different angle.

### Step 5: Full Construction Summary

```
Given: MCS M0 at time 0

Build:
  1. Root node: (M0, 0, fam₀)

  2. For each F(phi) in a node (Γ, t, f):
     - Compute seed = {phi} ∪ g_content(Γ)
     - Extend seed to MCS Γ' via Lindenbaum
     - Add node (Γ', t+1, f) to the same family

  3. For each P(phi) in a node (Γ, t, f):
     - Compute seed = {phi} ∪ h_content(Γ)
     - Extend seed to MCS Γ' via Lindenbaum
     - Add node (Γ', t-1, f) to the same family

  4. For each ◇(phi) in a node (Γ, t, f):
     - Compute seed = {phi} ∪ box_class(M0)
     - Extend seed to MCS Γ' via Lindenbaum
     - Add node (Γ', t, fam_new) in a NEW family

  5. Linearize each family:
     - Each family is already linearly ordered by Z-indices
     - Verify G-coherence and H-coherence are maintained by construction

  6. Collect all families into a BFMCS structure

Output: BFMCS with BFMCS.temporally_coherent satisfied per-family
```

---

## Linearity Proof Sketch

### How `temp_linearity` Enforces Linear Ordering

The `temp_linearity` axiom in this project is:
```
F(phi) ∧ F(psi) → F(phi ∧ psi) ∨ F(phi ∧ F(psi)) ∨ F(F(phi) ∧ psi)
```
(where `F(phi) = some_future phi = ¬G(¬phi)` and `G = all_future`)

**Semantic meaning**: If there exist future witnesses at times `s₁` and `s₂` for `phi` and `psi` respectively, then:
- Either `s₁ = s₂` (first disjunct: both hold at the same future time)
- Or `s₁ < s₂` (second disjunct: phi's witness precedes psi's witness)
- Or `s₂ < s₁` (third disjunct: psi's witness precedes phi's witness)

This is exactly the trichotomy for a linear order.

**Role in the construction**: Suppose during canonical model construction we have two consistent sets `Γ₁` and `Γ₂` both in family `f` with `t₁` and `t₂` derived from `F(phi)` and `F(psi)` obligations at node `(Γ, t, f)`. The `temp_linearity` axiom, applied to `Γ`, forces a trichotomy. Any extension to MCS must preserve exactly one of the three disjuncts, which determines the ordering between `t₁` and `t₂`.

**The critical subtlety**: This argument works for pairs of F-witnesses derived from the **same** ancestor. For witnesses derived from different ancestors, we need the additional observation that Z itself is already totally ordered, so our construction by definition places them on a line.

### Linearity of the Z-Chain

The existing `succ_chain_fam` construction in `SuccChainFMCS.lean` already builds a Z-indexed family, which is trivially linear. The partial order construction, when restricted to a single family, reduces to this Z-chain construction.

The `temp_linearity` axiom's role is more subtle: it ensures the **canonical model built from an abstract consistent set** (before committing to a specific index) will be linear. This is needed for the canonical frame approach but less critical when the Z-chain is constructed directly.

---

## Comparison with Z-Chain Approach

### Similarities

Both approaches:
1. Start from a base MCS `M0` at time 0
2. Use `forward_temporal_witness_seed` and `past_temporal_witness_seed` to generate new consistent sets
3. Extend seeds to MCS via Lindenbaum's lemma
4. Index the resulting MCS family by integers
5. Use `g_content` and `h_content` propagation to enforce G/H coherence

### Differences

| Aspect | Z-Chain (current) | Partial Order (proposed) |
|--------|-------------------|--------------------------|
| Temporal index | Fixed Z-chain | Flexible placement, then linearize |
| F-obligation handling | One step at a time, may defer | Explicit pending-obligation queue |
| Modal (◇) handling | New FMCS family per obligation | New family in partial order |
| Termination | Uses Nat recursion, then extend to Z | Potentially co-inductive / well-ordering |
| Family coherence | Bundle-level (across families) | Aims for family-level (same family) |
| G-coherence enforcement | `forward_G` field in FMCS | Built into seed construction |

### Key Advantage of Partial Order Approach

The partial order approach provides a cleaner conceptual separation:
1. **Existence phase**: Show a consistent assignment of formulas to nodes exists (without worrying about linear ordering)
2. **Linearization phase**: Show the partial order is actually linear within each family (using `temp_linearity`)
3. **Maximization phase**: Extend to MCS, maintaining coherence

This two-phase approach may make it easier to prove the truth lemma because:
- After linearization, each family is a total order, so `forward_F` (same-family witnesses) holds
- The maximized MCS at each node satisfies the seed constraints by construction

### Why Both Approaches Face the Same Core Obstruction

The partial order approach still must answer: **how do we ensure that an F-obligation at node `(Γ, t, f)` gets resolved in the same family `f`?**

The answer in the partial order approach is: by construction, Rule T+ always places new nodes **in the same family**. This is precisely the content of the rule.

However, the hard question is: can we do this without violating G-coherence? That is, when we add a new node `(Γ', t+1, f)` to satisfy `F(phi) ∈ Γ`, does `Γ'` contain the right g_content from earlier nodes? The answer is yes if we use `forward_temporal_witness_seed(Γ, phi) = {phi} ∪ g_content(Γ)`, which ensures `g_content(Γ) ⊆ Γ'`. Combined with the FMCS `forward_G` property, this propagates G-formulas correctly.

**The obstruction re-emerges**: The issue identified in prior research (`Z_chain_forward_F` sorry) is precisely that the deterministic Z-chain construction resolves F-obligations one-at-a-time, potentially generating a chain where some `F(phi)` from time 0 is always deferred to "later". The partial order approach, if it places new nodes eagerly for each F-obligation, would generate an infinitely branching structure at each time point - which is then "linearized" into a chain, but the linearization might fail to place the required witness in the **same** chain as the original obligation.

This is the sub-case (b) obstruction identified in report 18 (Teammate B):
- When `F(phi) ∈ Γ` at time `t` in family `f`, but `G(¬phi) ∈ Γ'` where `Γ'` is also at future times in family `f`
- Then `phi` cannot appear in any future node of family `f`
- So the F-obligation must be resolved in a **different** family

---

## Implementation Feasibility in Lean

### What Works Directly

1. **Partial order definition**: Easily encoded as an inductive type or a `Prop`-valued relation in Lean 4.

2. **Node generation**: The seed construction (`forward_temporal_witness_seed`, `past_temporal_witness_seed`) is already implemented in `WitnessSeed.lean` with proofs of consistency.

3. **Lindenbaum extension**: Available as `set_lindenbaum` in `MaximalConsistent.lean`.

4. **Integer indexing**: Using `Int` for time indices is well-supported and already used in `SuccChainFMCS`.

### What Requires New Work

1. **Coordinated maximization**: Lean's classical logic infrastructure (`Classical.choice`) can construct MCS extensions, but ensuring they are coordinated across nodes requires a more careful construction. A possible approach:
   - Construct the `boxClassFamilies` function as currently exists, which provides coordinated families
   - Show this function implements the partial order construction

2. **Linearity from `temp_linearity`**: To formally prove that the partial order construction produces linear families using `temp_linearity`, we need:
   - A Lean proof that the `temp_linearity` axiom corresponds to the frame condition of linear order
   - An application of this to show the canonical model's temporal ordering is linear
   - This is a non-trivial Kripke completeness argument (standard, but requires effort)

3. **Well-founded recursion**: The node generation process is in principle transfinite. For Lean formalization, we would need either:
   - A termination argument (e.g., formula subformula depth decreases)
   - Or a direct definition of the final BFMCS without the intermediate construction

### Lean-Specific Challenges

- The construction is **non-computable** (uses Classical.choice), so `noncomputable` declarations are needed throughout
- The partial order relation on `(Set Formula × Int × FamId)` triples requires Lean's `Finset` or `Set` infrastructure
- The "fresh family identifier" concept requires either a well-order on families or an inductive type

### Recommended Implementation Path

Rather than implementing the full partial order construction from scratch, the recommended approach is:

1. **Recognize that `boxClassFamilies` already IS the partial order construction**: The existing `boxClassFamilies M0 h_mcs` in `UltrafilterChain.lean` generates exactly the families that the partial order construction would produce. The families correspond to Diamond-spawned nodes in the partial order.

2. **Focus on same-family F-witnesses**: The main gap is proving `Z_chain_forward_F` for individual families. The partial order insight helps here: by construction, Rule T+ produces same-family witnesses. The question is whether the Z-chain construction can be shown to implement Rule T+ faithfully.

3. **Alternative**: Use the `BFMCS_Bundle` with cross-family witnesses but reformulate the truth lemma to work with cross-family witnesses. This avoids the linearity argument altogether.

---

## Confidence Level

**Medium** overall.

- High confidence that the partial order construction is mathematically correct as a conceptual approach
- High confidence that `temp_linearity` is the right axiom for enforcing linearity within families
- Medium confidence that the coordinated maximization step can be made to work for same-family F-witnesses
- Low confidence that this approach is significantly easier to implement in Lean than the existing `BFMCS_Bundle` approach

---

## Critical Gaps and Potential Issues

### Gap 1: The Same-Family Obstruction Persists

The fundamental obstruction identified in prior research does not disappear in the partial order framework. When we add a node `(Γ', t+1, f)` to family `f` to satisfy `F(phi) ∈ Γ`, we use seed `{phi} ∪ g_content(Γ)`. This seed might not extend to an MCS that is compatible with already-existing nodes in family `f`.

Specifically, if there exists another node `(Δ, t+1, f)` already in family `f` at time `t+1`, then `Γ'` must equal `Δ` (two MCS at the same time index in the same family must be the same set). But the new witness node `{phi} ∪ g_content(Γ)` might not extend to `Δ`.

**Resolution**: In the Z-chain construction, each time step has exactly one MCS. The partial order construction would also need to ensure this uniqueness. This forces us back to the question: does the MCS at time `t+1` in family `f` contain `phi`? This is exactly the same question as `forward_F`.

### Gap 2: Transfinite or Unbounded Generation

The partial order construction as described generates nodes indefinitely (every F-obligation, P-obligation, and ◇-obligation generates new nodes). For an infinite language, this is transfinite.

In the Z-chain approach, this is handled by the Nat recursion in `forwardChainAt` and `backwardChainAt`. In the partial order approach, a similar recursive structure would be needed, but the branching factor is potentially larger.

**Resolution**: The existing `boxClassFamilies` construction handles the ◇-branching by building a family for each MCS in the box-class. The temporal branching (F and P obligations) is handled by the Z-chain within each family. The partial order construction can be seen as an alternative presentation of this same idea.

### Gap 3: Linearity Proof Requires Canonical Frame Completeness

To formally prove that the partial order construction within a family is linear (using `temp_linearity`), we would need to prove that if `temp_linearity` holds in an MCS (which it does as a theorem), then the canonical model based on that MCS has a linear temporal order. This is a frame correspondence argument.

The `temp_linearity` axiom corresponds to the frame condition "the temporal order is a linear order" (Sahlqvist correspondence: `temp_linearity` is valid in a frame iff the temporal order is linear). Proving this correspondence formally in Lean would require:
1. Showing `temp_linearity` is invalid in non-linear frames (to establish the "only if" direction)
2. Showing it is valid in linear frames (soundness, already proven)

The "only if" direction is the hard part for canonical completeness.

### Gap 4: Coordination Requirement

The coordinated maximization step (Step 4 in the construction) requires that MCS extensions across different nodes in the same family are compatible. This coordination is what makes the construction non-trivial.

In the existing `SuccChainFMCS` construction, coordination is achieved by building the chain step by step: each successor is constrained to have `g_content` from the predecessor. This is the `constrained_successor_from_seed` approach.

In the partial order construction, achieving the same coordination for an arbitrary partial order (not just a chain) would require additional machinery.

### Gap 5: The sub-case (b) problem remains unresolved

As analyzed by Teammate B in report 18, there is a specific sub-case where same-family F-witnesses are provably unavailable:

> When `F(phi) ∈ fam.mcs(t)` but `G(¬phi) ∈ M0` (the base MCS).

In this case, G-propagation forces `¬phi ∈ fam.mcs(s)` for all `s > t` in the family. So `phi` cannot appear in any future node of the same family. The F-obligation must be satisfied cross-family.

The partial order construction does not resolve this: if we add a node `(Γ', t', f)` with `phi ∈ Γ'` to family `f`, then `Γ'` will contain both `phi` and `¬phi` (since `¬phi` is in all future MCS of family `f`), making it inconsistent. This is the same mathematical obstruction.

**Conclusion**: The partial order construction, while offering a clean conceptual framework, ultimately faces the same mathematical obstruction as the Z-chain approach. The resolution must be at the bundle level (cross-family witnesses), as identified in report 18 and confirmed in report 19.

### Summary Assessment

The partial order construction with linearization is:
- **Mathematically elegant**: Provides a clean two-phase approach (generate partial order, then linearize)
- **Conceptually clarifying**: Separates modal expansion (Diamond-spawning) from temporal expansion (F/P-obligations)
- **Not a new solution**: It converges to the same construction as `boxClassFamilies`/`BFMCS_Bundle`
- **Blocked by the same obstruction**: Same-family F-witnesses cannot be guaranteed for formulas like `F(phi)` when `G(¬phi)` holds in earlier members of the family

The most actionable insight from this analysis is that the partial order construction provides an alternative **presentation** of why bundle-level (cross-family) witnesses are the correct approach, and why the bundle-level temporal coherence already proven sorry-free in `UltrafilterChain.lean` is both necessary and sufficient.
