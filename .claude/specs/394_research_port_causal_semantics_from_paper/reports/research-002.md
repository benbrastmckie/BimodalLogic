# Research Report: Task #394 (Supplement)

**Task**: Research and port causal semantics from paper
**Date**: 2026-01-12
**Focus**: Integration of hyperintensional causal semantics into recursive-semantics.md

## Summary

This supplementary report focuses on integrating the causal semantics into recursive-semantics.md before Lean implementation. The document currently lacks causal semantics (A ○→ B) despite listing it as a syntactic primitive. Integration requires: (1) extending the Core Frame with a closeness ordering, (2) defining evolutions and subevolutions, (3) adding causal context and background assumptions, (4) specifying propositional operations (inclusion, remainder, inversion), and (5) providing the three-condition truth clause for causation. The document structure already has placeholders for these concepts.

## Findings

### 1. Current Document Structure Analysis

The recursive-semantics.md document has a clear layered structure:

```
1. Constitutive Foundation (hyperintensional base)
   - Mereological state space
   - Bilateral propositions
   - Verification/falsification

2. Explanatory Extension (temporal + modal)
   - Core Frame with task relation
   - World-histories
   - Truth conditions for operators

3. Further Extensions (stubs)
   - Epistemic, Normative, Spatial, Agential
```

**Missing from Explanatory Extension**:
- Causal operator (○→) truth conditions
- Closeness ordering for evolutions
- Evolution and subevolution definitions
- Causal context and background assumptions
- Propositional inclusion, remainder, inversion

### 2. Gap Analysis: What's Present vs. What's Needed

| Concept | Document Status | Paper Section | Notes |
|---------|----------------|---------------|-------|
| Task relation s ⇒_d t | ✓ Present | §4 | Has compositionality, parthood constraints |
| Closeness ≼ₛ | ✗ Missing | §4 lines 538-555 | Need to add as frame extension |
| Accessibility (s) | ✗ Missing | §4 lines 586-590 | Derivable from closeness |
| Expectation [s] | ✗ Missing | §4 lines 586-590 | Derivable from closeness |
| Evolution τ : Z → S | ✗ Missing | §4 lines 601-606 | Need full definition |
| Expected evolution | ✗ Missing | §4 lines 607-611 | τ(n) ↦ τ(n+1) |
| Subevolution δ ⊑ τ | ✗ Missing | §4 line 614 | Pointwise parthood |
| Propositional inclusion | ✗ Missing | §3 line 473 | P ⊑ Q := P ∧ Q = Q |
| Logical remainder | ✗ Missing | §3 lines 475-476 | P - Q |
| Inversion | ✗ Missing | §3 line 485 | P/Q := (P - Q) ∧ ¬Q |
| Causal context c | ✗ Missing | §4 lines 618-621 | ⟨x, y, β⟩ |
| Background β | ✗ Missing | §4 lines 618-621 | β : Z → P_S^+ |
| Causal semantics | ✗ Missing | §4 lines 626-627 | Three conditions |

### 3. Integration Points in recursive-semantics.md

#### 3.1 Core Frame (lines 243-277)

**Current**: Defines task relation with 6 constraints.

**Add after line 277**: Closeness relation section:

```markdown
### Closeness Ordering

The core frame is extended with a closeness relation for defining expected evolutions:

| Component | Description |
|-----------|-------------|
| **Closeness** | ≼ is a ternary relation on S satisfying constraints below |

Where t ≼ₛ r reads "s is at least as likely to transition to t as it is to r".

#### Closeness Constraints

| Constraint | Formulation |
|------------|-------------|
| **Reflexivity** | t ≼ₛ t for all s, t ∈ S |
| **Transitivity** | t ≼ₛ q whenever t ≼ₛ r and r ≼ₛ q |
| **Totality** | t ≼ₛ q or q ≼ₛ t for all s, t, q ∈ S |
| **Inaccessibility** | If t ≼ₛ s for all t, then t ≼ᵣ s and t ≼ₛ r for all t, r |
| **Stability** | If q ≼ₛ s for all q, then r ≼_{s.t} s.t for all r, t |

#### Derived Concepts

| Concept | Definition | Reading |
|---------|------------|---------|
| **Strict closeness** | t ≺ₛ q := q ⋠ₛ t | "t is strictly closer to s than q" |
| **Closest** | s ↦ t := ∀q(t ≼ₛ q) | "t is a closest state to s" |
| **Accessibility** | (s) := {t : ∃q(t ≺ₛ q)} | Accessible states from s |
| **Expectation** | [s] := {t : s ↦ t} | Expected states from s |
```

#### 3.2 After World-History (lines 281-289)

**Add**: Evolution definitions:

```markdown
### Evolutions

A *discrete evolution* over a core frame F is a function τ : Z → S where:
- τ(n) → τ(n+1) for all n ∈ Z (each state is accessible from predecessor)

An evolution is *expected* iff τ(n) ↦ τ(n+1) for all n ∈ Z.

**Notation**: E_F = set of all expected evolutions over F.

#### Subevolutions

| Concept | Definition |
|---------|------------|
| **Subevolution** | δ ⊑ τ iff ∀n(δ(n) ⊑ τ(n)) |
| **Expected subevolution** | δ ⊑* τ iff δ ∈ E_F and δ ⊑ τ |
| **Evolutions at state** | ⟨s⟩ₓ := {τ ∈ E_F : τ(x) = s} |
```

#### 3.3 After Bilateral Propositions (lines 199-214)

**Add**: Propositional operations for causation:

```markdown
### Extended Propositional Operations

For causal semantics, we require additional operations on bilateral propositions:

| Operation | Definition | Reading |
|-----------|------------|---------|
| **Inclusion** | P ⊑ Q := P ∧ Q = Q | "P is included in Q" |
| **Remainder** | P - Q := ⋀{R : R ⊑ P and R ⋢ Q} | "P without Q" |
| **Inversion** | P/Q := (P - Q) ∧ ¬Q | "P with Q inverted" |
| **Inexact verification** | ⟦A⟧⁺ := {t : s ⊑ t for some s ∈ |A|⁺} | Inexact verifiers |
```

#### 3.4 After Store/Recall (lines 399-410)

**Add**: Causal operator section:

```markdown
### Causal Operator (○→)

The causal operator "A ○→ B" expresses that A causes B. Unlike the counterfactual, causation is evaluated relative to a *causal context*.

#### Causal Context

A *causal context* c = ⟨x, y, β⟩ includes:

| Component | Description |
|-----------|-------------|
| **Cause time** x | Time at which the cause occurs |
| **Effect time** y | Time at which the effect occurs (y > x) |
| **Background** β | Function β : Z → P⁺_S assigning verifiable background assumptions to times |

**Terminology**:
- *Augmented cause*: β(x) (the background at cause time)
- *Inverted effect*: β(y)/|B| (result of inverting B in background at effect time)

#### Truth Conditions

> M, c ⊨ A ○→ B iff all three conditions hold:

**Condition 1 (Inclusion)**:
> |A| ⊑ β(x) and |B| ⊑ β(y)

The cause and effect are included in the background assumptions at their respective times.

**Condition 2 (Substantial Contribution)**:
> For all s ∈ β(x)⁺ and τ ∈ ⟨s⟩ₓ, there exists δ ⊑* τ where:
> - δ(y) ∈ ⟦B⟧⁺ (effect inexactly verified at y)
> - For all γ ⊑* δ: if γ(y) ∈ ⟦B⟧⁺, then γ(x) ∈ ⟦A⟧⁺

Every expected evolution verifying the augmented cause has an expected subevolution verifying the effect, where any further subevolution verifying the effect must also verify the cause.

**Condition 3 (Difference-Making)**:
> For all t ∈ (β(y)/|B|)⁺ and λ ∈ ⟨t⟩ᵧ:
> If λ(x) ∈ ⟦A⟧⁺, then there exists d ⊑ λ(x) where:
> - d ∈ ⟦A⟧⁺
> - For all ω ∈ ⟨d⟩ₓ: ω(y) ∈ ⟦B⟧⁺

If the inverted effect's expected evolution includes an inexact verifier for the cause, then some part of that verifier makes the effect occur in all its expected evolutions.

#### Intuitive Reading

"A causes B" in context c means:
1. A and B are included in what is assumed at their times
2. A's occurrence at x leads to B's occurrence at y via expected evolutions, where A makes a substantial (non-redundant) contribution
3. A makes a difference: if B didn't occur but A did, there must be a preventer

#### Causal Axiom Schemata

[DETAILS: Axioms for the causal operator pending formal derivation from the semantic clause]
```

### 4. Document Modification Plan

**Phase 1: Core Frame Extension**
- Insert closeness ordering section after task relation constraints (after line 277)
- Add 5 closeness constraints
- Add derived concepts (accessibility, expectation)

**Phase 2: Evolution Infrastructure**
- Insert evolution definitions after world-history section (after line 289)
- Define discrete evolution, expected evolution
- Define subevolution and expected subevolution
- Define evolution notation ⟨s⟩ₓ

**Phase 3: Propositional Operations**
- Insert extended operations after bilateral propositions (after line 214)
- Define inclusion, remainder, inversion
- Define inexact verification/falsification

**Phase 4: Causal Semantics**
- Insert causal operator section after store/recall (after line 410)
- Define causal context
- Provide three-condition truth clause
- Add intuitive reading
- Leave axiom schemata as [DETAILS] placeholder

### 5. Relationship to Logos Time Model

**Key Difference**: The paper uses Z (integers) while Logos uses T (LinearOrderedAddCommGroup).

**Adaptation Strategy**:
1. Evolutions in Logos: τ : D → S (where D is convex subset of T)
2. Expected evolution: each state is closest to its T-successor
3. Subevolution: pointwise parthood across all times in domain

The paper's discrete Z model can be embedded in Logos's T model by restricting to integer-spaced times. The causal semantics transfers directly with this embedding.

### 6. Comparison: Current vs. Proposed Truth.lean

**Current (Counterfactual Analysis)**:
```
A ○→ B := A ∧ FB ∧ (¬A □→ ¬FB)
```

**Proposed (Hyperintensional)**:
- Not definable in terms of counterfactual
- Primitive operator with three-condition semantics
- Requires evolution quantification
- Context-sensitive (causal context c)

**Migration Path**:
1. Document the correct semantics in recursive-semantics.md first
2. Implement frame extensions (closeness, evolutions) in Frame.lean
3. Implement causal context and background assumptions
4. Replace current derived definition with primitive semantics

## Recommendations

### 1. Document First (Immediate)

Update recursive-semantics.md with the full causal semantics before Lean implementation. This:
- Establishes the specification as single source of truth
- Allows review of the semantics without Lean complexity
- Ensures Lean implementation matches specification

### 2. Phased Documentation Updates

1. **Phase 1**: Add closeness ordering and evolution definitions
2. **Phase 2**: Add propositional operations (inclusion, remainder, inversion)
3. **Phase 3**: Add causal context and truth conditions
4. **Phase 4**: Add example analyses (preemption, overdetermination)

### 3. Mark Current Implementation as Incorrect

The current Truth.lean causal definition should be marked with a clear comment:

```lean
-- NOTE: This counterfactual analysis is a placeholder.
-- See recursive-semantics.md for the correct hyperintensional semantics.
-- Task 394 will implement the proper causal operator.
```

## References

- Brast-McKie, B. (2025). "Counterfactual Worlds" - sn-article.tex
- Current: Theories/Logos/docs/research/recursive-semantics.md
- Current: Theories/Logos/SubTheories/Explanatory/Truth.lean

## Next Steps

1. Update recursive-semantics.md with causal semantics (documentation phase)
2. Update current Truth.lean with deprecation notice
3. Plan Lean implementation of frame extensions
4. Implement causal operator with three-condition semantics
