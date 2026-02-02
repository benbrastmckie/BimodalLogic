# Parametric Finite Model Property Infrastructure

**Status**: Complete (with known architectural limitation for validity bridge)

This directory contains the parametric FMP (Finite Model Property) infrastructure for TM bimodal logic.

## Overview

The FMP establishes that if a formula is satisfiable, it is satisfiable in a **finite** model with bounded size. The key insight is that the cardinality bound (2^closureSize) is **purely combinatorial** - independent of any specific duration type D.

## Modules

| Module | Purpose | Status |
|--------|---------|--------|
| `Closure.lean` | Subformula closure, closureWithNeg, closure-maximal consistent sets | **Sorry-free** |
| `BoundedTime.lean` | Finite time domain `BoundedTime k = Fin (2*k+1)` | **Sorry-free** |
| `FiniteWorldState.lean` | Finite world states as truth assignments on closure | **Sorry-free** |
| `SemanticCanonicalModel.lean` | Semantic canonical model with finite world states | **Sorry-free** |
| `FiniteModelProperty.lean` | FMP theorem and cardinality bounds | **Sorry-free** |
| `ConsistentSatisfiable.lean` | Bridge from FMP to TaskModel (BLOCKED for modal/temporal) | 6 sorries |

## Key Theorem: semantic_weak_completeness

The canonical sorry-free completeness result:

```lean
noncomputable def semantic_weak_completeness (phi : Formula) :
    (forall (w : SemanticWorldState phi),
     semantic_truth_at_v2 phi w (BoundedTime.origin (temporalBound phi)) phi) ->
    |- phi
```

**Why it works**: Contrapositive approach (unprovable -> countermodel) constructs MCS-derived
countermodels where the assignment IS the MCS membership function. This avoids the
forward truth lemma entirely.

**This is THE completeness theorem for this logic.**

## Key Definitions

### Closure Infrastructure (`Closure.lean`)

```lean
def closure (phi : Formula) : Finset Formula
def closureWithNeg (phi : Formula) : Finset Formula
def closureSize (phi : Formula) : Nat
def ClosureMaximalConsistent (phi : Formula) (S : Set Formula) : Prop
```

### Bounded Time (`BoundedTime.lean`)

```lean
abbrev BoundedTime (k : Nat) := Fin (2 * k + 1)
def temporalBound (phi : Formula) : Nat := phi.temporalDepth
```

### Finite World State (`FiniteWorldState.lean`)

```lean
structure FiniteWorldState (phi : Formula)
structure FiniteHistory (phi : Formula)
def worldStateFromClosureMCS (phi : Formula) (S : Set Formula)
    (h_mcs : ClosureMaximalConsistent phi S) : FiniteWorldState phi
```

### Semantic World State (`SemanticCanonicalModel.lean`)

```lean
def SemanticWorldState (phi : Formula) := Quotient (htSetoid phi)
def semantic_truth_at_v2 (phi : Formula) (w : SemanticWorldState phi)
    (t : BoundedTime (temporalBound phi)) (psi : Formula) : Prop
noncomputable def semantic_weak_completeness (phi : Formula) : ... -> |- phi
theorem semanticWorldState_card_bound (phi : Formula) :
    Fintype.card (SemanticWorldState phi) <= 2 ^ closureSize phi
```

### FMP Theorems (`FiniteModelProperty.lean`)

```lean
theorem finite_model_property (phi : Formula) :
    formula_satisfiable phi -> exists (D : Type) ... truth_at M tau t phi

theorem consistent_implies_satisfiable (phi : Formula) (h_cons : Consistent [phi]) :
    formula_satisfiable phi
```

## Dependencies

- **Core**: MCS theory and Lindenbaum's lemma
- **Semantics**: Truth relation and validity

## Architectural Limitation: Validity Bridge

**IMPORTANT**: The `ConsistentSatisfiable.lean` module attempts to bridge FMP-internal validity
(truth at SemanticWorldStates) with general TaskModel validity. This bridge is **BLOCKED** for
modal and temporal operators.

**What works**:
- `semantic_weak_completeness`: Uses FMP-INTERNAL validity (sorry-free)
- Propositional fragment of truth correspondence

**What doesn't work**:
- Bridging general validity (`valid phi`) to FMP-internal validity
- Extending `consistent_implies_satisfiable` to general TaskModel semantics
- By extension: infinitary strong completeness and compactness via FMP-only path

**Why**: The FMP TaskFrame uses permissive task_rel (all states reachable) and constant histories.
Modal box requires psi true at ALL reachable states (including non-MCS ones), and temporal
operators require structure across time (lost with constant history).

**Recommendation**: Use `semantic_weak_completeness` with FMP-internal validity as the canonical
completeness result. Accept that general TaskModel validity is a different (stronger) notion.

See `ConsistentSatisfiable.lean` header and task 810 research-005 for full analysis.

## References

- Blackburn et al., Modal Logic, Chapter 4 (Finite Model Property)
- Task 810 research-005: Detailed blockage analysis

---

*Last updated: 2026-02-02*
