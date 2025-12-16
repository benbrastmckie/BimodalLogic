# Proof Theory Concepts

## Overview
Core proof-theoretic concepts for bimodal logic systems, including axioms, inference rules, and derived rules.

## Bimodal Logic Proof System

### Axioms
- **K Axiom (Necessity)**: □(p → q) → (□p → □q)
- **K Axiom (Possibility)**: ◇(p → q) → (◇p → ◇q)
- **Dual Axioms**: □p ↔ ¬◇¬p, ◇p ↔ ¬□¬p
- **Distribution**: Modal operators distribute over logical connectives

### Inference Rules
- **Modus Ponens**: From p and p → q, infer q
- **Necessitation**: From ⊢ p, infer ⊢ □p
- **Uniform Substitution**: Replace propositional variables uniformly

### Derived Rules
- **Modal Modus Ponens**: From □p and □(p → q), infer □q
- **Modal Transitivity**: From □p → □q and □q → □r, infer □p → □r

## LEAN 4 Representation

### Axiom Encoding
```lean
axiom K_necessity {p q : Prop} : □(p → q) → (□p → □q)
axiom K_possibility {p q : Prop} : ◇(p → q) → (◇p → ◇q)
axiom dual_box_diamond {p : Prop} : □p ↔ ¬◇¬p
```

### Inference Rule Encoding
```lean
theorem modus_ponens {p q : Prop} (hp : p) (hpq : p → q) : q := hpq hp
theorem necessitation {p : Prop} (hp : ⊢ p) : ⊢ □p := ...
```

## Layer Structure
- **Layer 1**: Proof system (axioms, rules)
- **Layer 2**: Semantics (models, satisfaction)
- **Layer 3**: Metalogic (soundness, completeness, consistency)

## References
- Modal Logic textbooks
- LEAN mathlib modal logic implementations
- Bimodal logic research papers
