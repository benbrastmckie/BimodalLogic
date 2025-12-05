# Logical Operators Glossary

**Navigation**: [Documentation](../) > [Architecture](../../UserGuide/ARCHITECTURE.md) > Glossary

## Purpose

This glossary provides a comprehensive reference for all logical operators, symbols, and principles used in the Logos bimodal logic TM system. It serves as a single source of truth for symbol meanings, formal definitions, LEAN code representations, and semantic interpretations.

**Audience**: Developers, researchers, and users working with Logos's formal proof system.

---

## Table of Contents

1. [Propositional Operators](#propositional-operators)
2. [Modal Operators](#modal-operators)
3. [Temporal Operators](#temporal-operators)
4. [Meta-logical Symbols](#meta-logical-symbols)
5. [Perpetuity Principles](#perpetuity-principles)
6. [Variable Conventions](#variable-conventions)

---

## Propositional Operators

### ⊥ (bottom / falsum)
Logical falsity, the proposition that is always false.

**Formal Definition**: The formula that evaluates to false in all models
**LEAN Code**: `Formula.bot`
**Semantics**: `⊨ ⊥` is false in all task models
**See also**: [⊤ (top)](#-top--verum)
**Examples**: Used as a basis for defining negation via `¬φ := φ → ⊥`

### ⊤ (top / verum)
Logical truth, the proposition that is always true.

**Formal Definition**: `⊤ := ⊥ → ⊥` (interdefinable with bottom)
**LEAN Code**: Defined from `Formula.bot` via implication
**Semantics**: `⊨ ⊤` is true in all task models
**See also**: [⊥ (bottom)](#-bottom--falsum)
**Examples**: Used in tautologies and axiom schemata

### ¬ (not / negation)
Logical negation, reverses truth value.

**Formal Definition**: `¬φ := φ → ⊥`
**LEAN Code**: Defined via implication to bottom
**Semantics**: `M,h,t ⊨ ¬φ` iff `M,h,t ⊭ φ`
**See also**: [→ (implication)](#-implication), [⊥ (bottom)](#-bottom--falsum)
**Examples**: `¬(p ∧ q)` expresses "not both p and q"

### ∧ (and / conjunction)
Logical conjunction, true when both conjuncts are true.

**Formal Definition**: `φ ∧ ψ := ¬(φ → ¬ψ)`
**LEAN Code**: Defined from implication and negation
**Semantics**: `M,h,t ⊨ φ ∧ ψ` iff `M,h,t ⊨ φ` and `M,h,t ⊨ ψ`
**See also**: [∨ (disjunction)](#-or--disjunction), [¬ (negation)](#-not--negation)
**Examples**: `□p ∧ ◇q` expresses "p is necessary and q is possible"

### ∨ (or / disjunction)
Logical disjunction, true when at least one disjunct is true.

**Formal Definition**: `φ ∨ ψ := ¬φ → ψ`
**LEAN Code**: Defined from implication and negation
**Semantics**: `M,h,t ⊨ φ ∨ ψ` iff `M,h,t ⊨ φ` or `M,h,t ⊨ ψ`
**See also**: [∧ (conjunction)](#-and--conjunction)
**Examples**: `Past p ∨ Future p` expresses "p was true or will be true"

### → (implication / conditional)
Material implication, false only when antecedent is true and consequent false.

**Formal Definition**: Primitive operator in TM logic
**LEAN Code**: `Formula.imp φ ψ`
**Semantics**: `M,h,t ⊨ φ → ψ` iff `M,h,t ⊭ φ` or `M,h,t ⊨ ψ`
**See also**: [↔ (biconditional)](#-biconditional)
**Examples**: Axiom MT uses implication: `□φ → φ`

### ↔ (biconditional / equivalence)
Logical equivalence, true when both sides have the same truth value.

**Formal Definition**: `φ ↔ ψ := (φ → ψ) ∧ (ψ → φ)`
**LEAN Code**: Defined from conjunction and implication
**Semantics**: `M,h,t ⊨ φ ↔ ψ` iff `M,h,t ⊨ φ` exactly when `M,h,t ⊨ ψ`
**See also**: [→ (implication)](#-implication--conditional)
**Examples**: `□φ ↔ ¬◇¬φ` expresses modal duality

---

## Modal Operators

### □ (box / necessity)
Modal necessity operator from S5 modal logic - expresses metaphysical necessity.

**Formal Definition**: Primitive operator quantifying over all possible worlds
**LEAN Code**: `Formula.box φ`
**Semantics**: `M,h,t ⊨ □φ` iff for all world histories h', `M,h',t ⊨ φ`
**Axioms**: MT (`□φ → φ`), M4 (`□φ → □□φ`), MB (`φ → □◇φ`)
**See also**: [◇ (possibility)](#-diamond--possibility)
**Duality**: `□φ ↔ ¬◇¬φ`
**Examples**: `□(p → q)` means "necessarily, if p then q"

### ◇ (diamond / possibility)
Modal possibility operator from S5 modal logic - expresses metaphysical possibility.

**Formal Definition**: `◇φ := ¬□¬φ` (interdefinable with necessity)
**LEAN Code**: Defined via `Formula.box` and negation
**Semantics**: `M,h,t ⊨ ◇φ` iff there exists some world history h' such that `M,h',t ⊨ φ`
**See also**: [□ (necessity)](#-box--necessity)
**Duality**: `◇φ ↔ ¬□¬φ`
**Examples**: `◇(p ∧ q)` means "possibly both p and q"

---

## Temporal Operators

### H (all_past / universal past)
Universal past operator - expresses that a formula held at all past times.

**Formal Definition**: Primitive temporal operator quantifying over past times
**LEAN Code**: `Formula.all_past φ`
**Alternative Notation**: `H` (from "Historically" or "Has always been")
**Semantics**: `M,h,t ⊨ H φ` iff for all times t' < t in domain(h), `M,h,t' ⊨ φ`
**See also**: [P (some_past)](#p-some_past--existential-past), [G (all_future)](#g-all_future--universal-future)
**Examples**: `H p` means "p has always been true (in the past)"

### P (some_past / existential past)
Existential past operator - expresses that a formula held at some past time.

**Formal Definition**: `P φ := ¬H¬φ` (dual of universal past)
**LEAN Code**: Defined via `Formula.all_past` and negation as `some_past`
**Alternative Notation**: `P` (from "Previously" or "Past occurrence")
**Semantics**: `M,h,t ⊨ P φ` iff there exists time t' < t in domain(h) such that `M,h,t' ⊨ φ`
**See also**: [H (all_past)](#h-all_past--universal-past), [F (some_future)](#f-some_future--existential-future)
**Duality**: `P φ ↔ ¬H¬φ`
**Examples**: `P □p` means "at some past time, p was necessary"

### G (all_future / universal future)
Universal future operator - expresses that a formula will hold at all future times.

**Formal Definition**: Primitive temporal operator quantifying over future times
**LEAN Code**: `Formula.all_future φ`
**Alternative Notation**: `G` (from "Globally" or "Going to always be")
**Semantics**: `M,h,t ⊨ G φ` iff for all times t' > t in domain(h), `M,h,t' ⊨ φ`
**Axioms**: T4 (`G φ → G G φ`), TA (`φ → G P φ`)
**See also**: [F (some_future)](#f-some_future--existential-future), [H (all_past)](#h-all_past--universal-past)
**Examples**: `G p` means "p will always be true (in the future)"

### F (some_future / existential future)
Existential future operator - expresses that a formula will hold at some future time.

**Formal Definition**: `F φ := ¬G¬φ` (dual of universal future)
**LEAN Code**: Defined via `Formula.all_future` and negation as `some_future`
**Alternative Notation**: `F` (from "Future occurrence" or "Finally")
**Semantics**: `M,h,t ⊨ F φ` iff there exists time t' > t in domain(h) such that `M,h,t' ⊨ φ`
**See also**: [G (all_future)](#g-all_future--universal-future), [P (some_past)](#p-some_past--existential-past)
**Duality**: `F φ ↔ ¬G¬φ`
**Examples**: `F ◇p` means "at some future time, p will be possible"

### always (henceforth operator)
Temporal operator - expresses that a formula holds at all future times (including now).

**Formal Definition**: `always φ := all_future φ` (henceforth operator)
**Alternative Notation**: `△φ` (U+25B3 WHITE UP-POINTING TRIANGLE)
**LEAN Code**: Defined as alias to `Formula.all_future`, notation `prefix:80 "△" => Formula.always`
**Semantics**: `M,h,t ⊨ always φ` iff for all times t' ≥ t in domain(h), `M,h,t' ⊨ φ`
**Note**: This is "henceforth" (from now onwards), not "eternal truth" (all past, present, and future times)
**See also**: [sometimes](#sometimes-eventual-occurrence), [G (all_future)](#g-all_future--universal-future)
**Perpetuity**: Used in P1-P6 to connect necessity and temporal truth
**Examples**: `always □p` or `△□p` means "from now on, p is necessary"

### sometimes (eventual occurrence)
Temporal operator - expresses that a formula holds at some future time (including now).

**Formal Definition**: `sometimes φ := ¬always¬φ` (dual of always)
**Alternative Notation**: `▽φ` (U+25BD WHITE DOWN-POINTING TRIANGLE)
**LEAN Code**: Defined as `φ.neg.always.neg`, notation `prefix:80 "▽" => Formula.sometimes`
**Semantics**: `M,h,t ⊨ sometimes φ` iff there exists time t' ≥ t in domain(h) such that `M,h,t' ⊨ φ`
**Note**: This is "eventually" (at some point from now onwards), dual to "henceforth"
**See also**: [always](#always-henceforth-operator), [F (some_future)](#f-some_future--existential-future)
**Perpetuity**: Used in P2, P4, P5, P6 perpetuity principles
**Duality**: `sometimes φ ↔ ¬always¬φ` or equivalently `▽φ ↔ ¬△¬φ`
**Examples**: `sometimes □p` or `▽□p` means "at some future time, p will be necessary"

---

## Meta-logical Symbols

### ⊢ (turnstile / provability)
Syntactic provability relation - expresses derivability in the TM proof system.

**Formal Definition**: `Γ ⊢ φ` means φ is derivable from premises Γ using TM axioms and rules
**LEAN Code**: `Derivable Γ φ` (inductive type)
**Rules**: Axiom schemas, Modus Ponens (MP), Modal K (MK), Temporal K (TK), Temporal Duality (TD)
**See also**: [⊨ (semantic consequence)](#-models--semantic-consequence)
**Soundness**: If `Γ ⊢ φ` then `Γ ⊨ φ`
**Examples**: `⊢ □p → p` means "necessarily p implies p" is a theorem (axiom MT)

### ⊨ (models / semantic consequence)
Semantic consequence relation - expresses validity in task frame models.

**Formal Definition**: `Γ ⊨ φ` means φ is true in all task models where all formulas in Γ are true
**LEAN Code**: `valid Γ φ` (semantic validity definition)
**Semantics**: Based on task frame structures with world histories and time domains
**See also**: [⊢ (provability)](#-turnstile--provability)
**Completeness**: If `Γ ⊨ φ` then `Γ ⊢ φ`
**Examples**: `⊨ □p → ◇p` means "necessary implies possible" is valid in all models

### ∀ (universal quantifier)
Universal quantification over variables (used in meta-theory).

**Formal Definition**: Standard first-order universal quantifier
**LEAN Code**: LEAN's built-in `∀` (Pi type)
**Usage Context**: Meta-logical statements about formulas, not object-level TM logic
**See also**: [∃ (existential)](#-existential-quantifier)
**Examples**: `∀φ. ⊢ φ → φ` (reflexivity of implication)

### ∃ (existential quantifier)
Existential quantification over variables (used in meta-theory).

**Formal Definition**: Standard first-order existential quantifier
**LEAN Code**: LEAN's built-in `∃` (Sigma type)
**Usage Context**: Meta-logical statements, semantic definitions
**See also**: [∀ (universal)](#-universal-quantifier)
**Examples**: `∃h. M,h,t ⊨ φ` (satisfiability)

### ∈ (element of)
Set membership relation.

**Formal Definition**: Standard set-theoretic membership
**LEAN Code**: LEAN's `∈` for sets and types
**Usage Context**: Time domains, world state sets, formula contexts
**See also**: [⊆ (subset)](#-subset-relation)
**Examples**: `t ∈ domain(h)` (time in world history domain)

### ⊆ (subset relation)
Subset relation between sets.

**Formal Definition**: `A ⊆ B` means all elements of A are in B
**LEAN Code**: LEAN's `⊆` for sets
**Usage Context**: Context extension, time interval containment
**See also**: [∈ (element of)](#-element-of)
**Examples**: `Γ ⊆ Δ` (context Γ is subset of context Δ)

### ∅ (empty set)
The set with no elements.

**Formal Definition**: `∅ := {x | false}`
**LEAN Code**: LEAN's `∅` for sets
**Usage Context**: Empty context, vacuous domains
**Examples**: `∅ ⊢ φ` means φ is a theorem (derivable from no premises)

---

## Perpetuity Principles

The perpetuity principles (P1-P6) are key derived theorems in TM logic connecting modal and temporal operators. They express relationships between necessity, possibility, and temporal persistence.

### P1: Necessity Implies Perpetuity
**Statement**: `□φ → always φ`
**Natural Language**: What is necessary is always the case.
**LEAN Code**: `perpetuity_1 φ : ⊢ (φ.box.imp (always φ))`
**Proof Strategy**: From modal axiom MT and temporal semantics
**Intuition**: If φ holds in all possible worlds, it holds at all times in the actual world
**See also**: [P3 (necessity of perpetuity)](#p3-necessity-of-perpetuity)

### P2: Occurrence Implies Possibility
**Statement**: `sometimes φ → ◇φ`
**Natural Language**: What is sometimes the case is possible.
**LEAN Code**: `perpetuity_2 φ : ⊢ ((sometimes φ).imp φ.dia)`
**Proof Strategy**: From temporal existential and modal semantics
**Intuition**: If φ occurs at some time, there exists a possible world where φ holds
**See also**: [P4 (possibility of occurrence)](#p4-possibility-of-occurrence)

### P3: Necessity of Perpetuity
**Statement**: `□φ → □always φ`
**Natural Language**: Necessity implies the necessity of perpetuity.
**LEAN Code**: `perpetuity_3 φ : ⊢ (φ.box.imp (always φ).box)`
**Proof Strategy**: From S5 axiom M4 (□φ → □□φ) and P1
**Intuition**: If φ is necessary, then it's necessarily true that φ holds always
**See also**: [P1 (necessity implies perpetuity)](#p1-necessity-implies-perpetuity)

### P4: Possibility of Occurrence
**Statement**: `◇sometimes φ → ◇φ`
**Natural Language**: The possibility of occurrence implies possibility.
**LEAN Code**: `perpetuity_4 φ : ⊢ ((sometimes φ).dia.imp φ.dia)`
**Proof Strategy**: From modal-temporal interaction and P2
**Intuition**: If it's possible that φ occurs at some time, then φ is possible
**See also**: [P2 (occurrence implies possibility)](#p2-occurrence-implies-possibility)

### P5: Persistent Possibility
**Statement**: `◇sometimes φ → always ◇φ`
**Natural Language**: Possible occurrence implies persistent possibility.
**LEAN Code**: `perpetuity_5 φ : ⊢ ((sometimes φ).dia.imp (always φ.dia))`
**Proof Strategy**: From S5 Brouwersche axiom MB and temporal semantics
**Intuition**: If φ possibly occurs, it remains possible at all times
**See also**: [P6 (occurrent necessity is perpetual)](#p6-occurrent-necessity-is-perpetual)

### P6: Occurrent Necessity is Perpetual
**Statement**: `sometimes □φ → □always φ`
**Natural Language**: If φ is necessary at some time, it is necessarily perpetual.
**LEAN Code**: `perpetuity_6 φ : ⊢ ((sometimes φ.box).imp (always φ).box)`
**Proof Strategy**: From modal axioms and temporal interaction axioms (MF, TF)
**Intuition**: Necessity doesn't vary across time - if necessary once, necessary always
**See also**: [P3 (necessity of perpetuity)](#p3-necessity-of-perpetuity)

---

## Variable Conventions

Logos follows consistent naming conventions for variables across documentation and code. These conventions are established in the [LEAN Style Guide](../../Development/LEAN_STYLE_GUIDE.md).

### Formulas
- **φ** (phi) - Primary formula variable
- **ψ** (psi) - Secondary formula variable
- **χ** (chi) - Tertiary formula variable

**LEAN Usage**: `(φ ψ χ : Formula)`
**Examples**: `φ → ψ`, `□φ ∧ ◇ψ`

### Contexts
- **Γ** (Gamma) - Primary context (list of formulas)
- **Δ** (Delta) - Secondary context

**LEAN Usage**: `(Γ Δ : List Formula)`
**Examples**: `Γ ⊢ φ`, `Γ ⊆ Δ`

### Time Points
- **τ** (tau) - Primary time point variable
- **σ** (sigma) - Secondary time point variable

**LEAN Usage**: `(τ σ : Time)`
**Examples**: `τ < σ`, `τ ∈ domain(h)`

### World Histories
- **h** - Primary world history variable
- **h'** - Alternative world history

**LEAN Usage**: `(h : WorldHistory)`
**Examples**: `M,h,τ ⊨ φ`

### Models
- **M** - Task model variable

**LEAN Usage**: `(M : TaskModel)`
**Examples**: `M ⊨ φ` (validity in model M)

### Propositional Atoms
- **p, q, r** - Propositional atom names

**LEAN Usage**: `Formula.atom "p"` or DSL `"p"`
**Examples**: `□"p" → "p"` (axiom MT instantiation)

---

## Related Documentation

- [Architecture Guide](../../UserGuide/ARCHITECTURE.md) - Complete TM logic specification with formal semantics
- [LEAN Style Guide](../../Development/LEAN_STYLE_GUIDE.md) - Coding conventions and variable naming
- [Tutorial](../../UserGuide/TUTORIAL.md) - Practical examples using these operators
- [Examples](../../UserGuide/EXAMPLES.md) - Modal, temporal, and bimodal proof examples

---

**Last Updated**: 2025-12-01
**Version**: 1.0
**Maintainer**: Logos Development Team
