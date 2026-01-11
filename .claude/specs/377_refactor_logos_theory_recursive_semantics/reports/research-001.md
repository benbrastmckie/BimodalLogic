# Research Report: Task #377

**Task**: Refactor Logos theory for recursive semantics
**Date**: 2026-01-11
**Focus**: Analysis of gap between current Logos state and RECURSIVE_SEMANTICS.md target

## Summary

Logos/ currently consists of thin re-export wrappers around Bimodal/ with stub modules for planned extensions. The refactoring goal is to implement a self-contained layered semantic framework matching RECURSIVE_SEMANTICS.md: a Constitutive Foundation (hyperintensional mereological state space) and Core Extension (task-based intensional semantics), with modular extensions for epistemic, normative, spatial, and agential operators.

## Findings

### 1. Current Logos Structure

The current Logos/ directory contains:

| File | Content | Lines |
|------|---------|-------|
| `Core.lean` | Re-exports `Bimodal` | 28 |
| `Syntax.lean` | Imports `Bimodal.Syntax.*`, empty namespace | 40 |
| `Semantics.lean` | Imports `Bimodal.Semantics.*` | 40 |
| `ProofSystem.lean` | Imports `Bimodal.ProofSystem.*` | 37 |
| `Metalogic.lean` | Re-export wrapper | ~20 |
| `Theorems.lean` | Re-export wrapper | ~20 |
| `Automation.lean` | Re-export wrapper | ~20 |
| `Examples.lean` | Re-export wrapper | ~20 |
| `Epistemic/Epistemic.lean` | Stub (22 lines) | 22 |
| `Normative/Normative.lean` | Stub (21 lines) | 21 |
| `Explanatory/Explanatory.lean` | Stub (21 lines) | 21 |

**Assessment**: Logos is not a theory implementation. It is backward-compatibility re-exports from Bimodal plus empty namespace stubs for planned extensions. There is no self-contained code.

### 2. RECURSIVE_SEMANTICS.md Target Architecture

The target defines a layered semantic framework:

```
┌─────────────────────────────────────────────────┐
│           Constitutive Foundation               │
│         (hyperintensional base layer)           │
└───────────────────────┬─────────────────────────┘
                        │ required
                        ▼
┌─────────────────────────────────────────────────┐
│              Core Extension                     │
│    (modal, temporal, counterfactual operators)  │
└───────────────────────┬─────────────────────────┘
                        │
       ┌────────────────┼────────────────┐
       │ optional       │ optional       │ optional
       ▼                ▼                ▼
┌──────────────┐ ┌──────────────┐ ┌──────────────┐
│  Epistemic   │ │  Normative   │ │   Spatial    │
│  Extension   │ │  Extension   │ │  Extension   │
└──────┬───────┘ └──────┬───────┘ └──────┬───────┘
       │                │                │
       └────────────────┼────────────────┘
                        │ at least one required
                        ▼
┌─────────────────────────────────────────────────┐
│             Agential Extension                  │
│           (multi-agent reasoning)               │
└─────────────────────────────────────────────────┘
```

### 3. Key Semantic Components Needed

#### 3.1 Constitutive Foundation (Hyperintensional Layer)

**Frame Structure**: Complete lattice `⟨S, ⊑⟩` with:
- Null state (□): Bottom element
- Full state (■): Top element
- Fusion (s.t): Least upper bound

**Model Structure**:
- Interpretation I for function symbols: `f → I(f) : Sⁿ → S`
- Bilateral propositions: `⟨v_F, f_F⟩` (verifier/falsifier function sets)
- Variable assignment: `σ : Var → S`

**Operators**:
| Operator | Notation | Type |
|----------|----------|------|
| Propositional Identity | A ≡ B | Hyperintensional |
| Essence | A ⊑ B | Constitutive relation |
| Ground | A ≤ B | Constitutive relation |

**Semantics**: Verification/falsification clauses for:
- Negation (¬) - exchanges verification and falsification
- Conjunction (∧) - fusion of verifiers, sum of falsifiers
- Disjunction (∨) - sum of verifiers, fusion of falsifiers
- Top (⊤), Bottom (⊥), Identity (≡)

#### 3.2 Core Extension (Intensional Layer)

**Frame Extension**: Core frame = Constitutive frame + temporal order D + task relation ⇒

**State Modality Definitions**:
- Possible state: `s ∈ P iff s ⇒₀ s`
- Compatible states: `s ∘ t iff s.t ∈ P`
- World-state: Maximal possible state
- World-history: Function `τ : X → W` respecting task relation

**Operators**:
| Category | Operators |
|----------|-----------|
| Modal | □ (necessity), ◇ (possibility) |
| Temporal | H, G, P, F, ◁ (since), ▷ (until) |
| Counterfactual | □→ (would-conditional) |
| Temporal Reference | ↑ⁱ (store), ↓ⁱ (recall) |

**Truth Conditions**: Relative to model M, history τ, time x, assignment σ, index i⃗

### 4. Comparison with Bimodal Implementation

Bimodal implements a simplified version of the Core Extension:

| Feature | Bimodal | RECURSIVE_SEMANTICS Target |
|---------|---------|---------------------------|
| State space | WorldState (any type) | Complete lattice with parthood |
| Temporal order | LinearOrderedAddCommGroup | Totally ordered abelian group ✓ |
| Task relation | Nullity + Compositionality | + Parthood (L/R) + Containment (L/R) + Maximality |
| Modal operators | □, ◇ | Same ✓ |
| Temporal operators | H, G, P, F | + Since (◁), Until (▷) |
| Counterfactual | Not implemented | □→ (would-conditional) |
| Store/Recall | Not implemented | ↑ⁱ, ↓ⁱ operators |
| Hyperintensional | Not implemented | Constitutive Foundation required |
| Bilateral propositions | Not implemented | Verifier/falsifier pairs required |
| Variable assignment | Not implemented | σ : Var → S required |
| Lambda abstraction | Not implemented | λx.A required |
| Universal quantifier | Not implemented | ∀y.A required |

### 5. Implementation Gap Analysis

#### 5.1 Major New Components Required

1. **Constitutive Frame** (`Logos/Foundation/Frame.lean`)
   - Complete lattice structure for state space
   - Null state, full state, fusion operations
   - Parthood relation as partial order

2. **Bilateral Propositions** (`Logos/Foundation/Proposition.lean`)
   - Ordered pairs `⟨V, F⟩` of verifier/falsifier sets
   - Product (⊗), sum (⊕) operations
   - Exclusivity and exhaustivity constraints

3. **Hyperintensional Semantics** (`Logos/Foundation/Semantics.lean`)
   - Verification clauses (⊩⁺)
   - Falsification clauses (⊩⁻)
   - Lambda abstraction, identity operator

4. **Extended Core Frame** (`Logos/Core/Frame.lean`)
   - All 6 task relation constraints (not just 2)
   - State modality definitions (possible, compatible, maximal, world-state)

5. **Extended Formula Type** (`Logos/Core/Formula.lean`)
   - Since (◁), Until (▷) binary temporal operators
   - Counterfactual conditional (□→)
   - Store (↑ⁱ), Recall (↓ⁱ) operators
   - Universal quantifier (∀), Lambda abstraction (λ)
   - Variable terms and individual constants

6. **Extended Truth Evaluation** (`Logos/Core/Truth.lean`)
   - Temporal index parameter `i⃗`
   - Since/Until semantics
   - Counterfactual semantics (mereological formulation)
   - Store/Recall semantics

#### 5.2 Mathlib Dependencies

From Loogle/LeanSearch results, key Mathlib imports needed:

```lean
import Mathlib.Order.CompleteLattice.Defs  -- CompleteLattice
import Mathlib.Order.Lattice               -- Lattice operations
import Mathlib.Data.Set.Lattice            -- Set lattice operations
import Mathlib.Algebra.Order.Group.Defs    -- LinearOrderedAddCommGroup (already used)
```

### 6. Architectural Decisions

#### 6.1 Module Organization

Proposed structure for self-contained Logos:

```
Logos/
├── Foundation/              # Constitutive Foundation
│   ├── Frame.lean          # Complete lattice state space
│   ├── Proposition.lean    # Bilateral propositions
│   ├── Semantics.lean      # Verification/falsification
│   └── Consequence.lean    # Propositional identity logic
├── Core/                    # Core Extension
│   ├── Frame.lean          # Extended task frame
│   ├── Formula.lean        # Full formula type
│   ├── WorldHistory.lean   # World-histories
│   ├── Truth.lean          # Full truth conditions
│   └── Validity.lean       # Logical consequence
├── Extensions/              # Optional extensions
│   ├── Epistemic/
│   ├── Normative/
│   ├── Spatial/
│   └── Agential/
├── ProofSystem/             # Axiom system and derivation
├── Theorems/                # Derived theorems
├── Metalogic/               # Soundness, completeness
├── Automation/              # Tactics and proof search
└── Examples/                # Usage examples
```

#### 6.2 Relationship with Bimodal

Options:
1. **Import Bimodal as dependency**: Extend Bimodal structures
2. **Independent implementation**: Build from scratch
3. **Shared foundation**: Extract common parts to a shared library

**Recommendation**: Option 3 aligns with Task 376 (TheoryLib structure). Extract common patterns (e.g., temporal operators, task frame basics) to a shared library, then specialize for each theory.

### 7. Complexity Assessment

| Component | Effort Estimate | Difficulty |
|-----------|-----------------|------------|
| Constitutive Frame | 4-6 hours | Medium |
| Bilateral Propositions | 3-4 hours | Medium |
| Hyperintensional Semantics | 6-8 hours | High |
| Extended Core Frame | 4-6 hours | Medium |
| Extended Formula Type | 3-4 hours | Low |
| Since/Until Operators | 4-6 hours | Medium |
| Counterfactual Semantics | 8-12 hours | High |
| Store/Recall Operators | 3-4 hours | Medium |
| Quantifiers + Lambda | 6-8 hours | High |
| **Total** | **41-58 hours** | **High** |

## Recommendations

1. **Phase the implementation**: Start with Constitutive Foundation, then Core Extension operators incrementally

2. **Leverage Mathlib**: Use `CompleteLattice` and related typeclasses for the mereological state space rather than defining from scratch

3. **Coordinate with Task 376**: The TheoryLib structure should be designed to support shared foundations between Bimodal and Logos

4. **Start with minimal viable semantics**: Implement the Constitutive Foundation with propositional identity first, then extend with Core modal/temporal operators before adding counterfactuals and store/recall

5. **Test-driven development**: Create LogosTest/ with examples from RECURSIVE_SEMANTICS.md as acceptance criteria

## References

- Logos/docs/Research/RECURSIVE_SEMANTICS.md - Full semantic specification
- Logos/docs/Research/LAYER_EXTENSIONS.md - Extension architecture
- Bimodal/Semantics/TaskFrame.lean - Current task frame implementation
- Bimodal/Semantics/Truth.lean - Current truth evaluation
- Mathlib.Order.CompleteLattice.Defs - Complete lattice structures

## Next Steps

1. Create implementation plan with phased approach
2. Coordinate with Task 376 for shared library design
3. Define minimal Constitutive Foundation structures
4. Extend incrementally toward full RECURSIVE_SEMANTICS specification
