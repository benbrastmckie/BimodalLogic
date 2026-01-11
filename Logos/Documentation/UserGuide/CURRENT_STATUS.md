# Logos Current Status

Current development status of the Logos second-order hyperintensional logic.

## Overview

Logos is designed to be a **second-order hyperintensional logic** with state-based semantics.
Currently, it exists as a re-export layer over Bimodal with stubs for planned extensions.

## Theoretical Foundation

### Planned Logos Theory

| Aspect | Description |
|--------|-------------|
| **Type** | Second-order hyperintensional logic |
| **Semantic primitives** | States (more fine-grained than possible worlds) |
| **Interpretation** | Functions, constants, predicates with variable assignments |
| **Order** | Second-order with first and second-order variables |

### Current Bimodal Implementation

| Aspect | Description |
|--------|-------------|
| **Type** | Propositional intensional logic |
| **Semantic primitives** | World-states in Kripke framework |
| **Interpretation** | Sentence letters → sets of world-states |
| **Order** | Propositional (zeroth-order) |

## Module Status

### Core Logic (Re-exports Bimodal)

| Module | Status | Notes |
|--------|--------|-------|
| Logos/Syntax | Re-export | From Bimodal/Syntax |
| Logos/ProofSystem | Re-export | From Bimodal/ProofSystem |
| Logos/Semantics | Re-export | From Bimodal/Semantics |
| Logos/Metalogic | Re-export | From Bimodal/Metalogic |
| Logos/Theorems | Re-export | From Bimodal/Theorems |
| Logos/Automation | Re-export | From Bimodal/Automation |

### Extension Modules (Stubs Only)

| Module | Status | Purpose |
|--------|--------|---------|
| Logos/Epistemic | Stub | Knowledge and belief operators |
| Logos/Normative | Stub | Deontic operators (obligation, permission) |
| Logos/Explanatory | Stub | Grounding and explanation operators |

## Development Phases

### Phase 1: Current (Bimodal Re-export)

The current phase provides:
- Complete propositional intensional logic via Bimodal
- Namespace structure for future extensions
- Stubs documenting planned module architecture

### Phase 2: Planned (First-Order Extension)

Will add:
- Individual variables and quantifiers
- Predicate symbols
- First-order Kripke semantics

### Phase 3: Planned (Second-Order Extension)

Will add:
- Predicate variables
- Second-order quantifiers
- Hyperintensional semantics with states

### Phase 4: Planned (Domain Extensions)

Will implement:
- Epistemic operators (`K`, `B` for knowledge, belief)
- Normative operators (`O`, `P` for obligation, permission)
- Explanatory operators (grounding relations)

## Key Differences from Bimodal

When Logos is fully implemented, it will differ from Bimodal in:

1. **Granularity**: States vs world-states
   - Worlds: Maximal consistent states
   - States: May be partial, support hyperintensional distinctions

2. **Expressiveness**: Second-order vs propositional
   - Bimodal: Sentence letters only
   - Logos: Variables, quantifiers, predicates

3. **Semantics**: Hyperintensional vs intensional
   - Intensional: Substitution of logical equivalents
   - Hyperintensional: Distinguishes logically equivalent contents

## What Works Now

Since Logos re-exports Bimodal, all Bimodal functionality is available:

- ✅ All 14 TM axiom schemas
- ✅ All 7 inference rules
- ✅ Full soundness proof
- ✅ Task frame semantics
- ✅ Core tactics (`modal_t`, `apply_axiom`)
- ✅ Perpetuity principles P1-P5

## What's Not Yet Implemented

- ❌ First-order quantification
- ❌ Second-order quantification
- ❌ State-based semantics
- ❌ Epistemic operators
- ❌ Normative operators
- ❌ Explanatory operators

## See Also

- [Theory Comparison](../../../Documentation/Research/THEORY_COMPARISON.md) - Bimodal vs Logos
- [Roadmap](../ProjectInfo/ROADMAP.md) - Development timeline
- [Extension Stubs](../Reference/EXTENSION_STUBS.md) - Planned extension modules
