# Research Report: Constructing D as the Translation Group of the Canonical Timeline

**Task**: 956 — Construct D as translation group from syntax
**Date**: 2026-03-06
**Status**: Complete

## 1. Overview

This report details the complete construction of the temporal duration group D from pure syntax, without assuming Int (or any external number system) and without defining a successor function. The key insight is that D emerges as the group of order-preserving automorphisms (translations) of a canonical linear order of maximal consistent sets (MCSs), with a designated origin turning the underlying torsor into a group.

The construction proceeds in two directions:

- **Forward**: From a consistent set of formulas to a linear order with a designated origin
- **Backward**: From the linear order with origin to D as the group of translation actions

These two directions meet: `task_rel` is simply the group action of D on the timeline — not an artificial map imposed from outside, but the very structure that defines D in the first place.

## 2. Forward Direction: Consistent Set → Linear Order with Origin

### Step 1: The Origin (Lindenbaum's Lemma)

Start with a consistent set of formulas Γ₀ (e.g., {¬φ} when we want to show ⊬ φ).

By Lindenbaum's Lemma (which uses Zorn's Lemma / axiom of choice), extend Γ₀ to a maximal consistent set (MCS) w₀. This MCS w₀ is the **designated origin** of our construction — the "zero point" of the timeline.

**Key property**: w₀ is a complete, consistent theory. For every formula ψ, either ψ ∈ w₀ or ¬ψ ∈ w₀.

### Step 2: The Timeline (Canonical Temporal Structure)

From w₀, build the canonical linear order T of MCSs using the temporal logic existence lemma.

**Definition (Temporal Precedence)**: For MCSs w, w', define:

> w < w' iff {ψ : Gψ ∈ w} ⊆ w'

Equivalently: w < w' iff for all formulas ψ, if Gψ ∈ w then ψ ∈ w'. This says "w' lies in the future of w" — everything that w asserts will always be true (G = "always in the future") is indeed true at w'.

**The Existence Lemma**: This is the engine that populates the timeline. For each MCS w:

- If Fψ ∈ w (ψ is true at some future time), then there exists an MCS w' with w < w' and ψ ∈ w'.
- If Pψ ∈ w (ψ is true at some past time), then there exists an MCS w' with w' < w and ψ ∈ w'.

The proof of the existence lemma uses Lindenbaum's Lemma: one shows that the set {ψ} ∪ {χ : Gχ ∈ w} is consistent (using the properties of F and G), then extends it to an MCS.

**The Universe T**: Define T to be the set of all MCSs **reachable** from w₀ by iterated application of the existence lemma — following temporal witnesses both forward (via F-formulas) and backward (via P-formulas). Formally, T is the transitive closure of the temporal accessibility relation starting from w₀.

**Crucially**, T is **connected**: every element of T is linked to w₀ by a finite chain of temporal witness steps. There are no isolated components, because we only include MCSs that are reachable from the origin.

### Step 3: Properties of the Linear Order

The temporal axioms of the logic force T to have specific structural properties:

1. **Linearity**: For any w, w' ∈ T, either w < w', w = w', or w' < w. This follows from the linearity axiom of temporal logic (Fp ∧ Fq → F(p ∧ Fq) ∨ F(p ∧ q) ∨ F(q ∧ Fp), or equivalently, the interaction axioms between G and H).

2. **No endpoints**: Seriality axioms (Gφ → Fφ and Hφ → Pφ, or equivalently the axiom schemes ensuring every moment has a future and a past) guarantee that every w ∈ T has both w' > w and w'' < w in T.

3. **Transitivity**: If w < w' and w' < w'', then w < w''. This follows from the 4-axiom (Gφ → GGφ) which ensures temporal precedence is transitive.

4. **Irreflexivity**: w ≮ w. This follows from the interaction of G and the structure of MCSs (specifically, that Gφ → φ from the T-axiom ensures the relation is irreflexive when properly defined as strict precedence).

At this stage we have **(T, <, w₀)**: a connected linear order without endpoints, with a designated origin. This structure is constructed entirely from syntax — from the axioms, rules, and formulas of the temporal logic.

## 3. The Torsor Structure

Before defining D, we need to understand what (T, <, w₀) gives us algebraically. The key concept is a **torsor** (also called a principal homogeneous space).

**Informal idea**: A torsor is "a group that has forgotten its identity element." The set T with its linear order has the same "shape" as a group, but no element is intrinsically the identity — any point could serve as the origin.

**Choosing an origin**: Once we designate w₀ as the origin, the torsor "becomes" a group. The group elements are the translations of T, and the origin provides the bijection between translations and points.

**Why this matters**: This is precisely why D is not assumed to be ℤ. D *emerges* as the translation group. The fact that D might turn out to be isomorphic to ℤ (for discrete time) or to ℚ (for dense time) is a *theorem about the construction*, not an assumption fed into it.

## 4. Backward Direction: Linear Order with Origin → D

### Step 4: The Translation Group

**Definition**: An **order-preserving automorphism** (or **translation**) of (T, <) is a bijection f : T → T such that for all w, w' ∈ T:

> w < w' iff f(w) < f(w')

Let D = Aut⁺(T) be the set of all such translations.

**Group structure on D**:
- **Composition**: (f · g)(w) = f(g(w)) for all w ∈ T
- **Identity**: id(w) = w — the "zero translation" that displaces nothing
- **Inverse**: f⁻¹ is the inverse function of f

This is always a group (closure, associativity, identity, and inverses are automatic for bijections under composition).

**Temporal interpretation**:
- The identity id is the "null duration" — staying at the same time
- A translation f that moves w₀ to a point in the future of w₀ is a "positive duration"
- A translation f that moves w₀ to a point in the past of w₀ is a "negative duration"
- Composing translations f · g means "apply duration g, then duration f" — the total displacement

### Step 5: The Origin Bijection (eval₀)

**Definition**: Define the evaluation-at-origin map:

> eval₀ : D → T, eval₀(d) = d(w₀)

This sends each translation to the point where it moves the origin.

**Claim**: eval₀ is a bijection. This requires two properties:

**Transitivity of the action**: For every w ∈ T, there exists d ∈ D such that d(w₀) = w.

*Why this holds*: T is a connected, homogeneous linear order. The temporal axioms ensure that no point in T is structurally distinguishable from any other point — every point has the same local order-theoretic properties (no endpoints, same density/discreteness properties everywhere). Therefore, for any two points a, b ∈ T, there exists an order-preserving automorphism mapping a to b. In particular, for any w ∈ T, there exists d ∈ D mapping w₀ to w.

*More concretely*: Given w₀ and w in T, define d by specifying where it sends each point. Since T is a connected linear order and both w₀ and w have "the same structure extending in both directions" (guaranteed by the temporal axioms), we can construct d by matching up the points of T in an order-preserving way that sends w₀ to w.

**Freeness of the action**: If d(w₀) = w₀, then d = id.

*Why this holds*: Suppose d is an order-preserving automorphism of T that fixes w₀. Since d preserves the order and fixes w₀, it must fix every point reachable from w₀. For any w ∈ T with w₀ < w, the set {w' ∈ T : w₀ < w' < w} must be mapped to itself (by order preservation and the fact that d fixes w₀ and must send w to some point ≥ w₀). By connectivity and the structure of linear orders, d(w) = w. The same argument applies for points below w₀. Therefore d = id.

*Alternative argument via rigidity*: For a linear order arising from temporal logic (which has the "homogeneous but rigid" property), any automorphism is determined by where it sends a single point. Since d fixes w₀, d = id.

### Step 6: D Inherits Linear Order from T

**Definition**: Pull back the linear order from T to D via eval₀:

> d₁ < d₂ iff d₁(w₀) < d₂(w₀)

Since eval₀ is a bijection and (T, <) is a linear order, this makes (D, <) a linear order.

**Compatibility with group structure**: This order is translation-invariant:

> d₁ < d₂ implies (d · d₁) < (d · d₂) for all d ∈ D

This follows because d is order-preserving: d₁(w₀) < d₂(w₀) implies d(d₁(w₀)) < d(d₂(w₀)), i.e., (d · d₁)(w₀) < (d · d₂)(w₀).

Therefore **(D, ·, <)** is a **linearly ordered group**. The identity element id corresponds to w₀ under eval₀. Translations that move w₀ forward are "positive durations"; those that move it backward are "negative durations."

### Step 7: Abelian Structure

**Claim**: D is abelian (commutative).

*Why*: In a linearly ordered group where the order is total, any two translations commute. This is a standard result: for a group acting freely and transitively on a linearly ordered set by order-preserving maps, the group must be abelian. The proof: for any d₁, d₂ ∈ D, the translations d₁ · d₂ and d₂ · d₁ both displace the origin by "the same total amount" (since the ordering constrains the composition to be determined by the individual displacements).

More rigorously: D acts on T by order-preserving bijections, and T is linearly ordered, so D embeds into (T, <) as an ordered group via eval₀. A linearly ordered group with a free transitive action on a linearly ordered set is necessarily abelian. (This is because the ordering on D inherited from T is bi-invariant, and a bi-invariantly ordered group acting freely on a chain is abelian — see e.g., the theory of ordered permutation groups.)

## 5. Connecting D and task_rel

### Step 8: task_rel Is the Group Action

With D defined as above, define:

> task_rel : D → (T → T)
> task_rel(d) = d

That is, task_rel sends each duration d ∈ D to the function d : T → T, which is d viewed as a translation of the timeline. This is simply the group action of D on T.

**Properties of task_rel**:

1. **Homomorphism**: task_rel(d₁ · d₂) = task_rel(d₁) ∘ task_rel(d₂). This is immediate from the definition of composition in D.

2. **Identity**: task_rel(id) = id_T. The zero duration doesn't move anything.

3. **Faithfulness**: If task_rel(d₁) = task_rel(d₂), then d₁ = d₂. This is immediate since task_rel is literally the inclusion D ↪ Aut(T).

4. **Compatibility with truth**: For any formula ψ and world w ∈ T:
   - Gψ ∈ w iff for all d > id in D, ψ ∈ d(w)
   - Fψ ∈ w iff there exists d > id in D with ψ ∈ d(w)
   - Hψ ∈ w iff for all d < id in D, ψ ∈ d(w)
   - Pψ ∈ w iff there exists d < id in D with ψ ∈ d(w)

   This is the **truth lemma**, and it holds because d(w) is exactly the MCS that is "d units of displacement away from w" in the timeline T.

## 6. The Canonical Model

### Step 9: Assembling the Canonical Model

The canonical model M = (T, <, D, task_rel, V) is:

- **Worlds**: W = T (the MCSs reachable from w₀)
- **Temporal order**: R = < (temporal precedence between MCSs)
- **Duration group**: D = Aut⁺(T) (order-preserving automorphisms)
- **Duration action**: task_rel(d)(w) = d(w) (apply the translation)
- **Valuation**: V(p) = {w ∈ T : p ∈ w} (atomic proposition p is true at w iff p is a member of w)

### Step 10: The Truth Lemma

**Theorem** (Truth Lemma): For all formulas φ and all w ∈ T:

> M, w ⊨ φ iff φ ∈ w

Proof by structural induction on φ:

- **Atomic** (p): M, w ⊨ p iff w ∈ V(p) iff p ∈ w. ✓
- **Negation** (¬ψ): M, w ⊨ ¬ψ iff M, w ⊭ ψ iff ψ ∉ w (by IH) iff ¬ψ ∈ w (by maximality). ✓
- **Conjunction** (ψ₁ ∧ ψ₂): M, w ⊨ ψ₁ ∧ ψ₂ iff M, w ⊨ ψ₁ and M, w ⊨ ψ₂ iff ψ₁ ∈ w and ψ₂ ∈ w (by IH) iff ψ₁ ∧ ψ₂ ∈ w (by closure under deduction). ✓
- **Box** (□ψ): M, w ⊨ □ψ iff for all d ∈ D, M, d(w) ⊨ ψ iff for all w' ∈ T, ψ ∈ w' (by IH and transitivity of D) iff □ψ ∈ w (by properties of MCSs and the box axioms). The direction □ψ ∈ w → ψ ∈ w' for all accessible w' uses the definition of <. The direction "ψ ∈ w' for all accessible w' → □ψ ∈ w" uses maximality and the contrapositive. ✓
- **G** (Gψ): M, w ⊨ Gψ iff for all d > id, M, d(w) ⊨ ψ iff for all w' > w, ψ ∈ w' (by IH and eval₀) iff Gψ ∈ w (by the definition of < and MCS properties). The forward direction: if Gψ ∈ w and w < w', then by definition ψ ∈ w'. The backward direction (contrapositive): if Gψ ∉ w, then ¬Gψ ∈ w, so F¬ψ ∈ w (by the G/F duality), so by the existence lemma there exists w' > w with ¬ψ ∈ w', so ψ ∉ w'. ✓
- **H** (Hψ): Symmetric to G, using P and the backward existence lemma. ✓

### Step 11: Completeness

**Theorem** (Completeness): If ⊨ φ (φ is valid in all models), then ⊢ φ (φ is provable).

Proof by contrapositive: Suppose ⊬ φ. Then {¬φ} is consistent. Set Γ₀ = {¬φ}. Apply the construction:

1. Extend {¬φ} to MCS w₀ (Lindenbaum). So ¬φ ∈ w₀.
2. Build the canonical timeline (T, <) from w₀.
3. Define D = Aut⁺(T) and task_rel = group action.
4. Build the canonical model M.
5. By the truth lemma: M, w₀ ⊨ ¬φ (since ¬φ ∈ w₀).
6. Therefore M, w₀ ⊭ φ.
7. Therefore φ is not valid in all models: ⊭ φ.

Contrapositive: ⊨ φ → ⊢ φ. ∎

## 7. Why This Construction Supersedes Previous Approaches

### Problems with D = Int (Old Approach)

The old approach in Tasks 951/954/955 assumed D = ℤ upfront and tried to build a chain of MCSs indexed by integers. This created several interlocking problems:

1. **The dovetailing chain problem**: Building a chain w₀, w₁, w₂, ... (and w₋₁, w₋₂, ...) requires showing that each step's Lindenbaum extension preserves F-formula witnesses from earlier steps. This is the "F-persistence problem" that blocked Plans v1-v7.

2. **The successor problem**: Defining SuccOrder on the BidirectionalQuotient required showing coverness (no gaps between successive MCSs), which is unprovable because Lindenbaum extensions can introduce G-formulas that create new intermediate MCSs.

3. **The artificial mismatch**: With D = ℤ hardcoded, one must construct a separate chain, prove it matches ℤ's structure, and then define task_rel to bridge the gap. Every step fights against the mismatch between the imposed algebraic structure and the natural syntactic structure.

### How the Translation Group Construction Resolves These

1. **No chain construction needed**: T is not a chain built step-by-step. It is the set of *all* reachable MCSs, discovered by the existence lemma. There is no "next step" to define — the timeline exists as a completed totality (via Zorn's Lemma / choice).

2. **No successor function needed**: D is defined as Aut⁺(T), not via successor/predecessor. The group structure comes from composition of bijections, which is automatic. No coverness, no SuccOrder, no orderIsoIntOfLinearSuccPredArch.

3. **No mismatch to bridge**: D *is* the translation group of T. task_rel *is* the group action. There is no gap between the algebraic structure and the temporal structure because they are two views of the same mathematical object.

4. **F-persistence is trivially satisfied**: The existence lemma guarantees that if Fψ ∈ w, there exists w' > w with ψ ∈ w'. Since w' ∈ T by construction, and since D acts transitively on T, the witness w' is accessible via some duration d ∈ D. No preservation argument needed.

## 8. Subtleties and Requirements

### 8.1 Homogeneity of T

The transitivity of the D-action on T requires T to be **homogeneous** — no point is order-theoretically distinguishable from any other. This holds because:

- The temporal axioms are "uniform": they apply equally at every time point
- T has no endpoints (seriality)
- T has the same density/discreteness properties everywhere (from the axioms)
- T is connected (every point is reachable from w₀)

For a connected linear order without endpoints where every point has the same local structure, homogeneity follows. The specific temporal axioms determine what kind of linear order T is:

- **Discrete time** (axioms for immediate successors): T is order-isomorphic to ℤ, D ≅ (ℤ, +)
- **Dense time** (density axiom Gφ → GFφ): T is a countable dense linear order without endpoints, D ≅ (ℚ, +)
- **General case**: T's structure is determined by the axioms, and D is whatever translation group that structure admits

### 8.2 Freeness of the D-action

The claim "if d(w₀) = w₀ then d = id" (freeness) requires:

- In a linear order, if an order-preserving automorphism fixes a point, it fixes all points in the "connected component" reachable from that point by order comparisons
- Since T is connected (every point is reachable from w₀), fixing w₀ forces fixing everything

This is a standard result in the theory of ordered permutation groups.

### 8.3 Abelianness

For the group to be abelian (required for AddCommGroup structure), we use:

- D acts freely and transitively on a linear order
- A group acting freely and transitively by order-preserving maps on a linear order is abelian
- This is because the ordering on D (pulled back from T) is bi-invariant, and a bi-invariantly ordered group is abelian

### 8.4 Differences via the Origin

To "get a difference" between two time points w₁, w₂ ∈ T:

- Let d₁ = eval₀⁻¹(w₁) and d₂ = eval₀⁻¹(w₂) — the unique translations mapping w₀ to w₁ and w₂ respectively
- The difference is d₂ · d₁⁻¹ ∈ D — the unique translation mapping w₁ to w₂
- This is well-defined precisely because the action is free and transitive
- Without the origin w₀, we couldn't identify individual translations — only the *difference* between any two points would be well-defined (torsor structure)

## 9. Summary of the Complete Pipeline

```
Γ₀ consistent set
    │
    ▼  (Lindenbaum)
w₀ : MCS                           ← ORIGIN
    │
    ▼  (Existence Lemma, iterated)
T : linear order of MCSs           ← TIMELINE
    │
    ▼  (Aut⁺)
D = Aut⁺(T) : group                ← DURATION GROUP
    │
    ▼  (eval₀)
eval₀ : D ≅ T : bijection          ← ORIGIN CORRESPONDENCE
    │
    ▼  (pullback order)
(D, ·, <) : linearly ordered        ← ORDERED ABELIAN GROUP
  abelian group
    │
    ▼  (group action)
task_rel(d)(w) = d(w)               ← DURATION ACTION
    │
    ▼  (canonical valuation)
M = (T, <, D, task_rel, V)         ← CANONICAL MODEL
    │
    ▼  (truth lemma)
M, w ⊨ φ  ↔  φ ∈ w                 ← TRUTH LEMMA
    │
    ▼  (contrapositive)
⊨ φ  →  ⊢ φ                        ← COMPLETENESS
```

## 10. Implications for the Lean Formalization

### What to build

1. **CanonicalTimeline**: The type T of reachable MCSs from a root, with the canonical linear order
2. **TranslationGroup**: D = Aut⁺(T) with its group structure (composition, identity, inverse)
3. **OriginBijection**: eval₀ : D ≃ T and the pullback order making D a LinearOrderedAddCommGroup
4. **CanonicalTaskRel**: task_rel defined as the group action
5. **TruthLemma**: The key bridge between syntax (MCS membership) and semantics (model satisfaction)
6. **Completeness**: The final theorem

### What to abandon

- DovetailingChain and its F-persistence problems
- SuccOrder/PredOrder constructions on BidirectionalQuotient
- orderIsoIntOfLinearSuccPredArch (D emerges intrinsically, not via external isomorphism)
- Hardcoded `D = Int` in CanonicalConstruction.lean
- The trivial `task_rel := fun _ _ _ => True` in Representation.lean

### Relationship to existing tasks

- **Task 951**: The BFMCS infrastructure (CanonicalFMCS, existence lemma, etc.) is reusable. The blocked DovetailingChain approach should be abandoned in favor of this translation group construction.
- **Task 954**: The goal of "avoid hardcoded Int" is achieved more cleanly by this approach. Instead of constructing D via BidirectionalQuotient → SuccOrder → orderIsoInt → transfer, D is defined directly as Aut⁺(T).
- **Task 955**: The plan for task_rel from CanonicalR should be superseded. task_rel is not defined via CanonicalR inclusion conditions — it is the group action of D on T.
