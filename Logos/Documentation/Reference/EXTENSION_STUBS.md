# Logos Extension Stubs

Documentation of planned extension modules in Logos.

## Overview

Logos includes stub modules for planned extensions that will add hyperintensional operators
beyond the base TM (Tense and Modality) logic inherited from Bimodal.

## Extension Modules

### Epistemic/ - Knowledge and Belief

**Purpose**: Formal reasoning about knowledge and belief states.

**Planned Operators**:
| Operator | Symbol | Meaning |
|----------|--------|---------|
| Knowledge | `K` | Agent knows φ |
| Belief | `B` | Agent believes φ |
| Common Knowledge | `C` | It is common knowledge that φ |
| Distributed Knowledge | `D` | It is distributed knowledge that φ |

**Key Properties**:
- Factivity: `Kφ → φ` (knowledge implies truth)
- Positive Introspection: `Kφ → KKφ`
- Negative Introspection: `¬Kφ → K¬Kφ`
- Distribution: `K(φ → ψ) → (Kφ → Kψ)`

**Current Status**: Stub only. No implementation.

**Location**: `Logos/Epistemic/`

---

### Normative/ - Obligation and Permission

**Purpose**: Formal reasoning about obligations, permissions, and prohibitions.

**Planned Operators**:
| Operator | Symbol | Meaning |
|----------|--------|---------|
| Obligation | `O` | It is obligatory that φ |
| Permission | `P` | It is permitted that φ |
| Prohibition | `F` | It is forbidden that φ |

**Key Properties**:
- Deontic interdefinability: `Pφ ↔ ¬O¬φ`
- Obligation-permission: `Oφ → Pφ`
- Deontic distribution: `O(φ → ψ) → (Oφ → Oψ)`

**Current Status**: Stub only. No implementation.

**Location**: `Logos/Normative/`

---

### Explanatory/ - Grounding and Explanation

**Purpose**: Formal reasoning about metaphysical grounding and explanation.

**Planned Operators**:
| Operator | Symbol | Meaning |
|----------|--------|---------|
| Grounding | `<` | φ grounds ψ |
| Full Ground | `<<` | φ fully grounds ψ |
| Partial Ground | `<p` | φ partially grounds ψ |
| Explanation | `⊏` | φ explains ψ |

**Key Properties**:
- Irreflexivity: `¬(φ < φ)`
- Asymmetry: `(φ < ψ) → ¬(ψ < φ)`
- Transitivity: `(φ < ψ) ∧ (ψ < χ) → (φ < χ)`
- Hyperintensionality: Grounding distinguishes logical equivalents

**Current Status**: Stub only. No implementation.

**Location**: `Logos/Explanatory/`

## Implementation Plan

### Phase 1: Infrastructure

1. Define semantic framework for hyperintensional contexts
2. Extend Formula type with new operators
3. Add extension-specific axiom schemas

### Phase 2: Epistemic Extension

1. Implement multi-agent epistemic logic
2. Add accessibility relations for agents
3. Prove key theorems (factivity, introspection)

### Phase 3: Normative Extension

1. Implement standard deontic logic (SDL)
2. Add conditional obligations
3. Handle deontic paradoxes

### Phase 4: Explanatory Extension

1. Implement grounding logic
2. Define state-based semantics for hyperintensionality
3. Integrate with modal-temporal base

## File Structure

Current stub files:
```
Logos/
├── Epistemic/
│   └── Epistemic.lean          # Stub: re-exports, comments planned structure
├── Normative/
│   └── Normative.lean          # Stub: re-exports, comments planned structure
└── Explanatory/
    └── Explanatory.lean        # Stub: re-exports, comments planned structure
```

## See Also

- [Current Status](../UserGuide/CURRENT_STATUS.md) - Overall Logos status
- [Roadmap](../ProjectInfo/ROADMAP.md) - Development timeline
- [Theory Comparison](../../../Documentation/Research/THEORY_COMPARISON.md)
