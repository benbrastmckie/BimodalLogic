# Finite Model Property (FMP) Completeness Module

**Status**: SORRY-FREE and AXIOM-FREE (publication ready)

This directory contains the parametric FMP (Finite Model Property) infrastructure for TM bimodal
logic.

## Overview

The FMP establishes that if a formula is satisfiable, it is satisfiable in a **finite** model
with bounded size. The key insight is that the cardinality bound (`2^closureSize`) is **purely
combinatorial** - independent of any specific duration type D.

## Modules

| Module | Purpose | Status |
|--------|---------|--------|
| `Closure.lean` | Subformula closure, closureWithNeg, closure-MCS | Sorry-free |
| `BoundedTime.lean` | Finite time domain `BoundedTime k = Fin (2*k+1)` | Sorry-free |
| `FiniteWorldState.lean` | Finite world states as truth assignments on closure | Sorry-free |
| `SemanticCanonicalModel.lean` | Semantic canonical model, `fmp_weak_completeness` | Sorry-free |

## Key Theorem: fmp_weak_completeness

The canonical sorry-free completeness result:

```lean
noncomputable def fmp_weak_completeness (phi : Formula) :
    (forall (w : SemanticWorldState phi),
     semantic_truth_at_v2 phi w (BoundedTime.origin (temporalBound phi)) phi) ->
    |- phi
```

**Why it works**: Contrapositive approach (unprovable -> countermodel) constructs MCS-derived
countermodels where the assignment IS the MCS membership function. This avoids the forward
truth lemma entirely.

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

### Semantic Canonical Model (`SemanticCanonicalModel.lean`)

```lean
def SemanticWorldState (phi : Formula) := Quotient (htSetoid phi)
def semantic_truth_at_v2 (phi : Formula) (w : SemanticWorldState phi)
    (t : BoundedTime (temporalBound phi)) (psi : Formula) : Prop
theorem semanticWorldState_card_bound (phi : Formula) :
    Fintype.card (SemanticWorldState phi) <= 2 ^ closureSize phi
```

## Dependency Flowchart

```
┌─────────────────────────────────────────────────┐
│          SemanticCanonicalModel.lean            │
│           (fmp_weak_completeness)               │
└─────────────────────────────────────────────────┘
                       │
       ┌───────────────┼───────────────┐
       v               v               v
┌─────────────┐ ┌─────────────┐ ┌─────────────┐
│ FiniteWorld │ │ BoundedTime │ │ Soundness   │
│ State.lean  │ │   .lean     │ │   .lean     │
└─────────────┘ └─────────────┘ └─────────────┘
       │
       v
┌─────────────┐
│ Closure.lean│
└─────────────┘
       │
       v
┌─────────────────────────────────────────────────┐
│                    Core/                        │
│   MaximalConsistent, MCSProperties, Deduction   │
└─────────────────────────────────────────────────┘
```

## Dependencies

- **Core**: MCS theory and Lindenbaum's lemma
- **Semantics**: Truth relation and validity
- **Soundness**: Used for verification in contrapositive proofs

## Related Documentation

- [Metalogic README](../README.md) - Overall metalogic architecture
- [Core README](../Core/README.md) - MCS foundations (dependency)
- [Bundle README](../Bundle/README.md) - BFMCS completeness approach (alternative)
- [Decidability README](../Decidability/README.md) - Decision procedure using FMP insights
- [Soundness README](../Soundness/README.md) - Soundness theorem (dependency)

## References

- Blackburn et al., Modal Logic, Chapter 4 (Finite Model Property)

---

## Publication Claims

The following claims are supported by this implementation:

1. **Completeness** is proven without sorries (`fmp_weak_completeness`)
2. **No custom axioms** are used (only standard Lean axioms: `propext`, `Classical.choice`, `Quot.sound`)
3. **Finite Model Property** is established via `semanticWorldState_card_bound`

To verify:
```bash
# Check axiom dependencies in Lean REPL:
#print axioms Bimodal.Metalogic.FMP.fmp_weak_completeness
```

---

*Last updated: 2026-02-04*
