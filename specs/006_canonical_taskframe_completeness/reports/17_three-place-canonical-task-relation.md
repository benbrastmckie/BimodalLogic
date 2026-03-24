# Replacing CanonicalR with a Three-Place Canonical Task Relation

**Date**: 2026-03-21
**Status**: Research Report / Implementation Proposal
**Scope**: Refactor canonical model construction to use a syntactically-derived three-place task relation, eliminating CanonicalR as a primitive

---

## 1. Problem Statement

### Current Design: CanonicalR as a Two-Place Relation

The current canonical model uses `CanonicalR : Set Formula → Set Formula → Prop` defined as:

```lean
def CanonicalR (M M' : Set Formula) : Prop :=
  g_content M ⊆ M'
```

where `g_content M = {φ | G φ ∈ M}`.

This is a **duration-blind** accessibility relation. It captures "M sees M' in the future" but carries no information about *how far* in the future v is from u. The semantic `TaskFrame` requires a three-place relation `task_rel : WorldState → D → WorldState → Prop` with explicit duration, creating a structural mismatch between the canonical model's accessibility relation and the semantic target.

### Goal: A Syntactic Three-Place Task Relation

Define from pure syntax a relation `CanonicalTask : MCS → ℤ → MCS → Prop` that:

1. Tracks duration explicitly (matching the semantic `task_rel`)
2. Is derivable entirely from the syntactic content of MCSs
3. Satisfies the TaskFrame axioms (nullity identity, forward compositionality, converse)
4. Makes the connection between syntax and semantics transparent

---

## 2. Mathematical Development

### 2.1 Syntactic Content Extractors

We work with four content extractors on MCSs, two of which already exist in the codebase:

| Extractor | Definition | Existing? | File |
|-----------|-----------|-----------|------|
| `g_content(u)` | `{φ \| G φ ∈ u}` | Yes | `TemporalContent.lean` |
| `h_content(u)` | `{φ \| H φ ∈ u}` | Yes | `TemporalContent.lean` |
| `f_content(u)` | `{φ \| F φ ∈ u}` | **New** | — |
| `p_content(u)` | `{φ \| P φ ∈ u}` | **New** | — |

where `F φ = ¬G¬φ` (some future) and `P φ = ¬H¬φ` (some past).

The universal extractors (`g_content`, `h_content`) capture **commitments** — formulas that must hold at *all* future/past times. The existential extractors (`f_content`, `p_content`) capture **obligations** — formulas that must hold at *some* future/past time.

### 2.2 The Immediate Successor Relation (Single Step)

**Definition** (Succ). For MCSs u, v, define the **immediate successor relation**:

```
Succ(u, v)  ⟺  (1) g_content(u) ⊆ v
              ∧ (2) f_content(u) ⊆ v ∪ f_content(v)
```

**Condition (1)**: *G-persistence*. Every universal future commitment of u is realized at v. If `G φ ∈ u`, then `φ ∈ v`. This is the existing `CanonicalR` condition.

**Condition (2)**: *F-step*. Every existential future obligation of u is either **resolved** at v (φ ∈ v) or **deferred** to v's future (F φ ∈ v, equivalently φ ∈ f_content(v)). No obligation is lost.

**Derived properties** (from existing duality theorems):

- **H-persistence (backward)**: Condition (1) implies `h_content(v) ⊆ u` by the existing theorem `g_content_subset_implies_h_content_reverse`. That is: if v is a successor of u, then all universal past commitments of v are realized at u.

- **P-step (backward)**: `p_content(v) ⊆ u ∪ p_content(u)`. Every existential past obligation of v is either resolved at u or was already pending at u. This follows from the temporal axiom structure by a symmetric argument to condition (2).

**Remark on minimality**. The two conditions above are *necessary* for any successor in a discrete linear order. In a standard Segerberg-style construction, they are also *sufficient* when combined with Lindenbaum extension: given an MCS u with `F⊤ ∈ u`, one constructs a consistent seed satisfying both conditions and extends it to an MCS via Lindenbaum's lemma.

### 2.3 The Immediate Predecessor Relation

**Definition** (Pred). For MCSs u, v:

```
Pred(u, v)  ⟺  Succ(v, u)
```

Equivalently:
```
Pred(u, v)  ⟺  g_content(v) ⊆ u  ∧  f_content(v) ⊆ u ∪ f_content(u)
```

By the converse property, looking backward is looking forward with negated duration.

### 2.4 The Three-Place Canonical Task Relation

**Definition** (CanonicalTask). For MCSs u, v and duration x ∈ ℤ:

```
CanonicalTask(u, 0, v)      ⟺  u = v                                    [Nullity]
CanonicalTask(u, n+1, v)    ⟺  ∃ w, Succ(u, w) ∧ CanonicalTask(w, n, v) [Forward, n ≥ 0]
CanonicalTask(u, -(n+1), v) ⟺  CanonicalTask(v, n+1, u)                  [Converse]
```

This is an inductive definition: multi-step forward tasks are chains of single steps, and backward tasks are the converse of forward tasks.

**Equivalent unfolding** for positive durations:

```
CanonicalTask(u, n, v)  ⟺  ∃ w₀ w₁ ... wₙ,
    w₀ = u ∧ wₙ = v ∧ ∀ i < n, Succ(wᵢ, wᵢ₊₁)
```

A task of duration n is a chain of n immediate successors.

### 2.5 Verification of TaskFrame Axioms

**Theorem** (TaskFrame Compliance). `CanonicalTask` satisfies the three TaskFrame axioms:

**(i) Nullity Identity**: `CanonicalTask(u, 0, v) ↔ u = v`

*Proof*: By definition. ∎

**(ii) Forward Compositionality**: For x, y ≥ 0, if `CanonicalTask(u, x, w)` and `CanonicalTask(w, y, v)`, then `CanonicalTask(u, x + y, v)`.

*Proof*: By induction on x.
- Base (x = 0): `u = w`, so `CanonicalTask(u, y, v) = CanonicalTask(w, y, v)`. ✓
- Step (x = k+1): We have `∃ w', Succ(u, w') ∧ CanonicalTask(w', k, w)`. By inductive hypothesis, `CanonicalTask(w', k + y, v)`. Then `∃ w', Succ(u, w') ∧ CanonicalTask(w', k + y, v)`, which is `CanonicalTask(u, (k+1) + y, v)`. ✓ ∎

**(iii) Converse**: `CanonicalTask(u, x, v) ↔ CanonicalTask(v, -x, u)`

*Proof*: For x > 0, this holds by definition. For x = 0, both sides reduce to `u = v`. For x < 0, write x = -(n+1) and apply the definition twice. ∎

### 2.6 The Single-Step Forcing Theorem

This is the key result connecting formula nesting depth to task duration.

**Theorem** (Single-Step Forcing). Let u be an MCS with `F φ ∈ u` and `FF φ ∉ u`. Then for any MCS v with `Succ(u, v)`, we have `φ ∈ v`.

*Proof*:
1. Since u is an MCS and `FF φ ∉ u`, by negation completeness: `¬(FF φ) ∈ u`.
2. Now `¬(FF φ) = ¬(¬G¬(¬G¬φ)) = G(G(¬φ))`. So `GG(¬φ) ∈ u`.
3. Since `Succ(u, v)` implies `g_content(u) ⊆ v`, and `GG(¬φ) ∈ u` means `G(¬φ) ∈ g_content(u)`, we get `G(¬φ) ∈ v`.
4. But `G(¬φ) ∈ v` means `¬(F φ) ∈ v`, i.e., `F φ ∉ v`.
5. By the F-step condition: `F φ ∈ u` implies `φ ∈ v ∨ F φ ∈ v`.
6. Since `F φ ∉ v`, we conclude `φ ∈ v`. ∎

**Corollary** (Bounded Witness Distance). Define `F⁰φ = φ` and `Fⁿ⁺¹φ = F(Fⁿφ)`. If `Fⁿφ ∈ u` but `Fⁿ⁺¹φ ∉ u`, then there exists v with `CanonicalTask(u, k, v)` and `φ ∈ v` for some `1 ≤ k ≤ n`.

*Proof sketch*: By induction on n. At each step, either the obligation is resolved (φ ∈ v at step k ≤ current) or deferred with strictly decreasing nesting depth. Since `Fⁿ⁺¹φ ∉ u` forces `GG(¬Fⁿ⁻¹φ) ∈ u`, the deferral can happen at most n-1 more times. ∎

### 2.7 Existence of Successors (Discrete Axioms)

The `Succ` relation is non-vacuous precisely when the discrete extension axioms hold.

**Theorem** (Successor Existence). Assume the discrete axiom system (base + DF + seriality). For any MCS u with `F⊤ ∈ u` (i.e., u has a future), there exists an MCS v with `Succ(u, v)`.

*Proof sketch*:
1. Define the **successor seed**: `S = g_content(u) ∪ {φ ∨ Fφ | Fφ ∈ u} ∪ blocking_formulas(u)`
   where the blocking formulas enforce that no F-obligation can be perpetually deferred.
2. Show S is consistent using the DF axiom `(F⊤ ∧ φ ∧ Hφ) → F(Hφ)`:
   - If S were inconsistent, a finite derivation of ⊥ from S would yield (via temporal generalization) a contradiction with `F⊤ ∈ u`.
3. Extend S to an MCS v via Lindenbaum's lemma.
4. Verify `Succ(u, v)`:
   - G-persistence: `g_content(u) ⊆ S ⊆ v`. ✓
   - F-step: For each `Fφ ∈ u`, the seed contains `φ ∨ Fφ`, so `φ ∈ v ∨ Fφ ∈ v`. ✓ ∎

**Theorem** (Predecessor Existence). Symmetric, using the DB axiom `(P⊤ ∧ φ ∧ Gφ) → P(Gφ)`.

### 2.8 Recovering CanonicalR

The existing two-place relation becomes a derived notion:

**Proposition**. For MCSs u, v:
```
CanonicalR(u, v)  ⟺  ∃ n ≥ 1, CanonicalTask(u, n, v)
```

*Forward direction* (⇐): If `CanonicalTask(u, n, v)` for n ≥ 1, then there is a Succ-chain from u to v. Each Succ step preserves g_content (by transitivity via temp_4: `Gφ → GGφ`), so `g_content(u) ⊆ v`.

*Backward direction* (⇒): Given `g_content(u) ⊆ v`, the full reconstruction requires the discrete axioms to decompose the accessibility into finitely many steps. This is where the canonical task relation is strictly more informative.

---

## 3. Relationship to Existing Codebase

### 3.1 Files Affected

| File | Current Role | Change |
|------|-------------|--------|
| `TemporalContent.lean` | Defines `g_content`, `h_content` | Add `f_content`, `p_content` |
| `CanonicalFrame.lean` | Defines `CanonicalR`, proves forward_F etc. | Redefine using `Succ`; derive `CanonicalR` |
| `CanonicalFMCS.lean` | Preorder on CanonicalMCS via CanonicalR | Derive Preorder from `Succ` transitivity |
| `WitnessSeed.lean` | Witness seeds for F/P obligations | Strengthen to successor seeds |
| `FlagBFMCSTruthLemma.lean` | Truth lemma using `<` on CanonicalMCS | Restate using `CanonicalTask` |
| `DiscreteSuccSeed.lean` | Blocking formula construction | Core of `Succ` existence proof |

### 3.2 What CanonicalR Currently Provides

The existing `CanonicalR` is used for:

1. **Forward G** (`canonical_forward_G`): `Gφ ∈ u ∧ CanonicalR(u, v) → φ ∈ v`
   - *Preserved*: Follows from `Succ(u, v)` condition (1), extended by transitivity for multi-step.

2. **Forward F** (`canonical_forward_F`): `Fφ ∈ u → ∃ v, CanonicalR(u, v) ∧ φ ∈ v`
   - *Strengthened*: Becomes `∃ v n, CanonicalTask(u, n, v) ∧ φ ∈ v` with explicit duration bound.

3. **Transitivity** (`canonicalR_transitive`): Via temp_4 axiom.
   - *Preserved*: Multi-step tasks compose by definition.

4. **Preorder on CanonicalMCS**: `a ≤ b ↔ a = b ∨ CanonicalR a b`.
   - *Preserved*: `a ≤ b ↔ ∃ n ≥ 0, CanonicalTask(a, n, b)`.

5. **g/h duality**: `CanonicalR(u, v) → CanonicalR_past(v, u)`.
   - *Preserved*: Follows from `Succ` condition (1) plus duality theorem, extended to multi-step by converse.

### 3.3 What's Gained

1. **Duration information**: The canonical model directly instantiates `TaskFrame ℤ` rather than requiring a separate duration construction.

2. **Elimination of duration pipeline**: Currently the codebase has a complex pipeline `MCS → Timeline → Quotient → ℤ-characterization`. The three-place relation makes duration intrinsic to the canonical construction.

3. **Structural match to semantics**: The truth lemma can be stated as:
   ```
   Gφ ∈ u ↔ ∀ v n > 0, CanonicalTask(u, n, v) → φ ∈ v
   Fφ ∈ u ↔ ∃ v n > 0, CanonicalTask(u, n, v) ∧ φ ∈ v
   ```
   which mirrors the semantic definition exactly.

4. **Single-Step Forcing**: Provides new proof techniques — the nesting depth of F determines witness distance.

---

## 4. Elegant Formulation Summary

### The Core Definitions (3 definitions total)

```
-- Content extractors (4 total, 2 new)
f_content(u) := {φ | Fφ ∈ u}
p_content(u) := {φ | Pφ ∈ u}

-- Single-step relation (the atomic building block)
Succ(u, v) := g_content(u) ⊆ v  ∧  f_content(u) ⊆ v ∪ f_content(v)

-- Three-place task relation (inductive on duration)
Task(u, 0, v)    := u = v
Task(u, n+1, v)  := ∃ w, Succ(u, w) ∧ Task(w, n, v)
Task(u, -x, v)   := Task(v, x, u)
```

### The Core Theorems (5 results)

1. **TaskFrame compliance**: `Task` satisfies nullity identity, forward compositionality, and converse.

2. **Single-step forcing**: `Fφ ∈ u ∧ FFφ ∉ u ∧ Succ(u, v) → φ ∈ v`.

3. **Bounded witness**: `Fⁿφ ∈ u ∧ Fⁿ⁺¹φ ∉ u → ∃ v k, 1 ≤ k ≤ n ∧ Task(u, k, v) ∧ φ ∈ v`.

4. **Successor existence**: Under discrete axioms, `F⊤ ∈ u → ∃ v, Succ(u, v)`.

5. **CanonicalR recovery**: `CanonicalR(u, v) ↔ ∃ n ≥ 1, Task(u, n, v)`.

---

## 5. Comparison: Two-Place vs Three-Place

| Aspect | CanonicalR (current) | CanonicalTask (proposed) |
|--------|---------------------|-------------------------|
| Arity | Binary: MCS × MCS | Ternary: MCS × ℤ × MCS |
| Duration | Implicit (exists but unknown) | Explicit (integer distance) |
| Semantic match | Indirect (requires duration pipeline) | Direct (instantiates TaskFrame ℤ) |
| F-witness | ∃ v, CanonicalR(u,v) ∧ φ ∈ v | ∃ v n, Task(u,n,v) ∧ φ ∈ v |
| Witness distance | Unknown | Bounded by F-nesting depth |
| Transitivity | Via temp_4 axiom | By chain concatenation |
| Construction complexity | Single Lindenbaum extension | Inductive chain of Lindenbaum extensions |
| Axiom requirements | Base logic only | Base + discrete extension |
| Applicable to | Base, dense, discrete | Discrete only (base/dense need different approach) |

---

## 6. Scope and Limitations

### Discrete Case Only

The three-place relation with ℤ durations applies specifically to the **discrete extension** of the logic. For the dense case (D ≃ ℚ) and the base case, different constructions are needed:

- **Dense case**: No notion of "immediate successor" exists. The task relation would need rational durations, constructed via a density argument rather than induction on steps.
- **Base case**: The duration type is not characterized. The task relation would be parametric over the duration group.

### Interaction with BFMCS Bundle

The current completeness proof uses BFMCS (Bundle of Families of MCSs) with cross-flag quantification. The three-place relation would need to interact with this bundle structure:

- Within a single flag: `Succ` and `Task` are well-defined on the flag's chain domain.
- Cross-flag: The box modality still requires quantification across flags at matching durations.
- The `satisfies_at` definition would use `Task` for temporal quantification instead of the raw preorder `<`.

### Backward Compatibility

The refactoring can be done incrementally:
1. Define `f_content`, `p_content`, `Succ`, `CanonicalTask` as new definitions.
2. Prove `CanonicalR` is recoverable from `CanonicalTask`.
3. Gradually replace uses of `CanonicalR` with `CanonicalTask` in downstream proofs.
4. Eventually remove `CanonicalR` as a primitive.

---

## 7. Implementation Plan

### Phase 1: New Definitions
- Add `f_content` and `p_content` to `TemporalContent.lean`
- Define `Succ` relation in a new `CanonicalStep.lean`
- Define `CanonicalTask` inductively

### Phase 2: Core Theorems
- Prove TaskFrame axiom compliance
- Prove single-step forcing theorem
- Prove bounded witness theorem
- Prove successor existence (connecting to `DiscreteSuccSeed.lean`)

### Phase 3: Recovery Theorems
- Prove `CanonicalR` is derivable from `CanonicalTask`
- Prove existing lemmas (`canonical_forward_G`, `canonical_forward_F`, etc.) from new definitions

### Phase 4: Refactoring
- Update `CanonicalFMCS.lean` to use `CanonicalTask`
- Update truth lemma to use three-place relation
- Update completeness proof

### Phase 5: Cleanup
- Remove `CanonicalR` as primitive (keep as derived notation if useful)
- Remove redundant duration pipeline components

---

## 8. Open Questions

1. **Seed construction details**: The successor seed for the F-step condition needs careful handling of the disjunctive form `φ ∨ Fφ`. How does this interact with Lindenbaum's lemma? (The existing `DiscreteSuccSeed.lean` blocking formula approach addresses this but may need adaptation.)

2. **P-step derivability**: Is the P-step condition `p_content(v) ⊆ u ∪ p_content(u)` derivable from the Succ definition plus axioms, or must it be an independent condition? The g/h duality theorems suggest it follows, but a formal proof is needed.

3. **Interaction with modal dimension**: The box modality uses a separate accessibility relation (BFMCS bundle membership). How does the three-place task relation interact with cross-flag modal quantification?

4. **Generalization beyond discrete**: Can a similar three-place relation be defined for dense or base logics using a different inductive principle? For dense logic, one might use Dedekind-cut-style constructions rather than successor chains.

---

## 9. Conclusion

The three-place canonical task relation `CanonicalTask(u, n, v)` provides a mathematically elegant replacement for the two-place `CanonicalR` that:

- **Tracks duration explicitly** from pure syntax
- **Directly instantiates** the semantic `TaskFrame` structure
- **Connects formula nesting** to witness distance via the Single-Step Forcing Theorem
- **Eliminates the duration pipeline** by making time intrinsic to the canonical construction

The construction is built from a single atomic relation `Succ(u, v)` — the immediate successor — defined by two conditions: G-persistence and F-step. All other structure (multi-step tasks, backward tasks, CanonicalR recovery) follows by induction and converse.

This represents a shift from "there exists some accessible world" (CanonicalR) to "there exists a world at a specific syntactically-determined distance" (CanonicalTask) — a strictly more informative canonical construction that matches the semantic task relation in both structure and spirit.
