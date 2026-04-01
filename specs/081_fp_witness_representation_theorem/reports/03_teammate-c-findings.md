# Research Findings: CanonicalMCS as Domain D

**Analyst**: math-research-agent (teammate-c)
**Task**: 81 - F/P Witness Representation Theorem
**Date**: 2026-03-31
**Focus**: Can CanonicalMCS serve as the duration type D, bypassing Z-embedding?

---

## Key Findings

| Finding | Confidence |
|---------|------------|
| CanonicalMCS cannot be given AddCommGroup structure | **High** |
| The W=D conflation is conceptually incoherent | **High** |
| R_G chains do not provide group operation | **High** |
| The identity mapping trivializes F/P obligations | **High** |
| No salvageable variant exists | **Medium** |

---

## Best Defense of the Approach

Before explaining why this fails, let me present the strongest possible argument FOR using CanonicalMCS as D:

### The Appeal

1. **Avoids Z-embedding entirely**: No need to embed MCSs into a linear timeline.

2. **Natural task relation**: `parametric_canonical_task_rel` already uses `ExistsTask M N` (g_content M ⊆ N) as the core relation. If D = CanonicalMCS, the task relation becomes directly expressible.

3. **Uniform structure**: Both worlds AND durations come from the same source — the space of all MCSs. This feels "natural" from a certain mathematical perspective.

4. **R_G chains as "temporal shift"**: Moving from M to N along an R_G chain (ExistsTask M N) could be interpreted as a "temporal shift" operation. The chain structure might provide something group-like.

### Why It Seems Plausible

The ParametricRepresentation constraints are:
```lean
variable {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
```

One might hope that:
- **AddCommGroup**: R_G chain concatenation provides "addition"
- **LinearOrder**: Some derivable order on MCSs
- **IsOrderedAddMonoid**: Order compatibility with chain operations

---

## Algebraic Structure Analysis

### AddCommGroup Requirements

For `CanonicalMCS = { M : Set Formula // SetMaximalConsistent M }` to be an `AddCommGroup`, we need:

1. **Binary operation (+)**: What would `M + N` mean?
2. **Identity element (0)**: Which MCS is the identity?
3. **Inverse (neg)**: For each M, what is -M?
4. **Associativity**: `(M + N) + P = M + (N + P)`
5. **Commutativity**: `M + N = N + M`
6. **Inverse laws**: `M + (-M) = 0`

#### Candidate: R_G Chain Concatenation

The only natural operation on MCSs is the R_G accessibility relation:
- `ExistsTask M N` iff `g_content M ⊆ N`

Could chain concatenation work?

**Problem 1: Not a function**. `ExistsTask M N` is a *relation*, not a function. Given M, there are many N such that `ExistsTask M N` — indeed, infinitely many (via Lindenbaum extensions of different seed sets). For addition to be well-defined, `M + N` must yield a *unique* result, but R_G chains are non-deterministic.

**Problem 2: No identity**. For 0 ∈ CanonicalMCS, we'd need `M + 0 = M` for all M. This requires an MCS `Z` such that for all M, the R_G chain from M to Z and back gives M. But R_G chains are directed by g_content inclusion — there's no universal "neutral" MCS.

**Problem 3: No inverse**. For `-M`, we'd need an MCS such that `M + (-M) = 0`. Given the non-determinism and lack of identity, this is hopeless.

**Problem 4: Non-composability**. Even if we had an operation, chains don't compose cleanly. `ExistsTask M N` and `ExistsTask N P` gives `ExistsTask M P` (via `canonicalR_transitive`), but this uses the Temporal 4 axiom (G phi -> GG phi) and the MCS property of M. This is transitivity of a *relation*, not addition of group elements.

#### Verdict: No AddCommGroup Structure

**CanonicalMCS has no natural AddCommGroup structure.** The space of MCSs is:
- A discrete unstructured collection of sets
- Connected by non-deterministic accessibility relations
- Lacking any algebraic combining operation

The only operations available (Lindenbaum extension, set union, intersection) produce results that may not be MCS, or produce many possible results, or don't satisfy group axioms.

### LinearOrder Requirements

For a `LinearOrder` on CanonicalMCS, we need:
- Total comparability: For all M, N, either `M ≤ N` or `N ≤ M`
- Reflexivity, antisymmetry, transitivity

#### Candidate: Set Inclusion

Could `M ≤ N ↔ M ⊆ N` work?

**Problem**: MCSs are incomparable. Two different MCSs M and N typically have neither M ⊆ N nor N ⊆ M. MCSs are "maximally spread out" — they contain exactly one of {phi, neg phi} for each phi, and different MCSs make different choices.

#### Candidate: R_G Reachability

Could `M ≤ N ↔ ExistsTask* M N` (transitive closure) work?

**Problem**: Not total. Many pairs of MCSs are not R_G-connected at all. The R_G relation forms disconnected components — MCSs with different G-commitments live in different components.

#### Verdict: No LinearOrder Structure

**CanonicalMCS has no natural linear order.** The space of MCSs is an unordered "cloud" — neither inclusion nor accessibility gives totality.

### IsOrderedAddMonoid Requirements

This requires:
- Order compatible with addition: `a ≤ b → a + c ≤ b + c`

Without AddCommGroup or LinearOrder, this is moot.

---

## The W=D Conflation Problem

The codebase warning at FMCSDef.lean:24-31 states:

> "The D=CanonicalMCS pattern has been removed. It was architecturally confused: using all MCS as the indexing type created an identity mapping `mcs(w) = w.world` that trivialized F/P witness obligations rather than proving them."

### The Core Issue

In task frame semantics:
- **W (WorldState)** = What is true (the world's propositional content)
- **D (Duration)** = When things are true (temporal indexing)

These are fundamentally different concepts:
- W answers: "Which formulas hold?"
- D answers: "At what time?"

### The Identity Mapping Problem

If D = CanonicalMCS, then an FMCS `fam : D → Set Formula` with `fam.mcs : D → Set Formula` becomes:

```lean
fam.mcs : CanonicalMCS → Set Formula
fam.mcs M = M.val  -- the identity mapping
```

Why? Because the only natural function from an MCS to a Set of formulas is... the MCS itself.

This means:
- `fam.mcs(M)` = M (just unwrap the subtype)
- Every MCS is trivially "present" at itself
- The temporal structure collapses

### Why This Trivializes F/P Witnesses

Consider `forward_F`: "F(phi) ∈ fam.mcs(t) → ∃ s ≥ t, phi ∈ fam.mcs(s)"

With identity mapping:
- If F(phi) ∈ M (where t = M)
- We need s ≥ t (some ordering on MCSs — but there isn't one!)
- We need phi ∈ s (phi ∈ fam.mcs(s) = s.val = s)

The "witness" s would just be any MCS containing phi. By `canonical_forward_F`, given `F(phi) ∈ M`, we can construct such an MCS W with `phi ∈ W` and `ExistsTask M W`.

But here's the problem: **what does s ≥ t mean?** Without a linear order on CanonicalMCS:
- If we use ExistsTask as the ordering, s ≥ t means `ExistsTask t s`
- And W is precisely constructed to satisfy `ExistsTask M W`

So the "proof" becomes:
1. F(phi) ∈ M
2. By `canonical_forward_F`: exists W with ExistsTask M W and phi ∈ W
3. Take s = W, and s ≥ t holds by definition (ExistsTask M W)
4. phi ∈ s = phi ∈ W ✓

This looks like a proof! **But it's circular.** We're using the existence of the canonical witness (which lives in arbitrary MCS space) to claim we've solved the F/P witness problem (which requires witnesses in a *specific family's timeline*).

The whole point of the F/P witness problem is that witnesses must be **within the same temporal family**. With D = CanonicalMCS, there's no notion of "family" — every MCS is its own world at its own time. The temporal structure is destroyed.

---

## Task Semantics Perspective

### What Task Semantics Requires

In the JPL paper's task semantics:
- D = ⟨D, +, ≤⟩ is a **totally ordered abelian group** of "durations"
- Tasks have **duration values in D** (not arbitrary world-state relationships)
- The task relation `task_rel w d u` connects world w to world u via duration d
- **Compositionality**: `task_rel w x u ∧ task_rel u y v → task_rel w (x+y) v`

The duration d is a **measure of temporal extent**, not a world state.

### Does CanonicalMCS Have Duration Structure?

**No.** CanonicalMCS is a space of propositional contents, not temporal measures.

The R_G relation encodes "future accessibility" — if `ExistsTask M N`, then N is a possible future of M. But:
- This doesn't assign a *duration* to the transition
- Multiple different "durations" could lead to the same N
- The same "duration" could lead to different N's

Duration is meant to be a quantitative measure: "how much time passes." R_G accessibility is qualitative: "is N a possible future of M?"

### The Converse Property

Task frames require: `task_rel w d u ↔ task_rel u (-d) w`

If D = CanonicalMCS:
- `task_rel M d N` with d ∈ CanonicalMCS
- What is `-d`? We established there's no negation operation.
- The converse property cannot even be stated.

---

## Verdict: Non-Viable

**CanonicalMCS cannot serve as the domain D.** The approach fails at multiple levels:

### Level 1: Algebraic (Fatal)
- No AddCommGroup structure: no addition, no identity, no inverse
- No LinearOrder structure: MCSs are incomparable
- No IsOrderedAddMonoid structure: follows from above

### Level 2: Conceptual (Fatal)
- Conflates world states (WHAT) with time indices (WHEN)
- Destroys the temporal family structure essential to the truth lemma
- Creates an identity mapping that trivializes rather than solves F/P witnesses

### Level 3: Semantic (Fatal)
- Durations should be measures, not propositional contents
- Task composition requires additive structure on D
- Converse property requires negation on D

---

## Salvageable Insights

Despite the negative verdict, some insights emerge:

### 1. The Quotient Approach Hint

The D=CanonicalMCS idea fails because MCSs are too "granular" — each represents a complete propositional state. However, **quotients of CanonicalMCS** might be viable:
- Equivalence classes of MCSs sharing temporal behavior
- `TimelineQuot` (from DFromCantor.lean) is exactly such a quotient
- The quotient collapses propositional differences, keeping temporal structure

### 2. The Canonical Frame IS D-Independent

The ParametricCanonicalWorldState is defined as:
```lean
def ParametricCanonicalWorldState : Type :=
  { M : Set Formula // SetMaximalConsistent M }
```

This is **independent of D**. The world states are MCSs regardless of what D is. Only the *task relation* involves D — determining which MCSs are connected by which durations.

### 3. The Two-Level Structure

The correct picture has two levels:
- **World level**: CanonicalMCS (MCSs as world states)
- **Time level**: D (Int, Rat, or other ordered group)

The FMCS `fam : D → Set Formula` is the bridge: it assigns to each time point t ∈ D a world state (MCS). D provides temporal indexing; CanonicalMCS provides propositional content.

Trying to collapse these levels (D = CanonicalMCS) destroys the bridge.

### 4. Why the Warning Exists

The codebase warning isn't arbitrary conservatism — it reflects deep structural understanding. The authors recognized that D=CanonicalMCS is a category error. The warning preserves this insight for future developers.

---

## Summary Table

| Aspect | Requirement | CanonicalMCS Status |
|--------|-------------|-------------------|
| Addition (+) | Binary group operation | **Absent** — no combining operation |
| Identity (0) | Neutral element | **Absent** — no universal MCS |
| Inverse (-) | Group inverse | **Absent** — no negation |
| Linear Order | Total comparability | **Absent** — MCSs incomparable |
| Duration meaning | Temporal measure | **Wrong type** — propositional content |
| Family structure | Time-indexed MCS assignment | **Collapses** — identity mapping |
| F/P witnesses | Within-family existence | **Trivializes** — circular construction |

---

## Conclusion

The idea of using CanonicalMCS as domain D is **fundamentally flawed** at the algebraic, conceptual, and semantic levels. It represents a category error — conflating the space of "what is true" (world states) with the structure of "when things are true" (temporal indices).

The F/P witness problem remains genuinely hard and must be solved through proper temporal constructions (dovetailed chains, Zorn's lemma on partial families, or similar approaches) that preserve the distinction between world states and time indices.
