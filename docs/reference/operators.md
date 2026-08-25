# Logical Operators Glossary

**Navigation**: [Documentation](../) > [Architecture](../user-guide/architecture.md) > Glossary

## Purpose

This glossary provides a comprehensive reference for all logical operators, symbols, and principles used in the ProofChecker bimodal logic TM system. It serves as a single source of truth for symbol meanings, formal definitions, LEAN code representations, and semantic interpretations.

**Audience**: Developers, researchers, and users working with the TM formal proof system.

---

## Table of Contents

1. [Propositional Operators](#propositional-operators)
2. [Modal Operators](#modal-operators)
3. [Primitive Temporal Operators](#primitive-temporal-operators)
4. [Temporal Operators](#temporal-operators)
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

## Primitive Temporal Operators

`untl` and `snce` are the **only** primitive temporal constructors of `Formula`
(`FormalSystem/Syntax/Formula.lean:96` and `:106`). Every H/P/G/F entry in the next section is a
*derived* form defined from them. Documenting only the derived forms would misrepresent the
language.

### U (untl / until)
Binary primitive - **argument 1 is the guard, argument 2 is the event**.

**LEAN Code**: `Formula.untl φ ψ`
**Alternative Notation**: `U(φ, ψ)`
**Semantics**: `M,h,t ⊨ U(φ,ψ)` iff the *event* `ψ` is witnessed at some strictly later time
`s`, and the *guard* `φ` holds at every time in the open interval `(t, s)`
**Axioms**: `left_mono_until_G`, `right_mono_until`, `enrichment_until`, `self_accum_until`,
`absorb_until`, `linear_until`, `until_F`, `F_until_equiv`
**Note**: the argument order is guard-first. Written with the arguments swapped, definitions
built on it silently never fire -- see the guard-first warning at
`FormalSystem/Metalogic/DiscreteNonCompactness.lean:102` and following.

### S (snce / since)
Binary primitive - the past mirror image of `untl`.

**LEAN Code**: `Formula.snce φ ψ`
**Alternative Notation**: `S(φ, ψ)`
**Semantics**: `M,h,t ⊨ S(φ,ψ)` iff `ψ` is witnessed at some strictly earlier time `s`, and `φ`
holds at every time in the open interval `(s, t)`

### X (next)
Derived from `untl` with a `⊥` guard: the guard condition is vacuous exactly on an immediate
successor.

**Formal Definition**: `next φ := U(⊥, φ)`
**LEAN Code**: `Formula.next` (`FormalSystem/Syntax/Formula.lean:511`)
**Note**: This is a genuine next-step operator on discrete orders, and is what makes the
Discrete non-compactness witness set work.

### K⁺ (kPlus) and K⁻ (kMinus)
Reynolds's gap operators, used to state the Dedekind-layer axioms.

**Formal Definition**: `K⁺φ := ¬U(¬φ, ⊤)`, `K⁻φ := ¬S(¬φ, ⊤)`
**LEAN Code**: `Formula.kPlus` (`:196`), `Formula.kMinus` (`:209`)
**Meaning**: "φ holds arbitrarily soon" / "φ held arbitrarily recently"
**Used by**: `Axiom.prior_U_gap`, `Axiom.prior_S_gap`, `Axiom.sep`

---

## Temporal Operators

Every operator in this section is **derived** from `untl`/`snce`, not primitive:

| Operator | Definition | Source |
|----------|-----------|--------|
| `someFuture` (F) | `U(⊤, φ)` | `Formula.lean:147` |
| `somePast` (P) | `S(⊤, φ)` | `Formula.lean:157` |
| `allFuture` (G) | `¬F¬φ` | `Formula.lean:167` |
| `allPast` (H) | `¬P¬φ` | `Formula.lean:177` |

### H (allPast / universal past)
Universal past operator - expresses that a formula held at all past times.

**Formal Definition**: Primitive temporal operator quantifying over past times
**LEAN Code**: `Formula.allPast φ`
**Alternative Notation**: `H` (from "Historically" or "Has always been")
**Semantics**: `M,h,t ⊨ H φ` iff for all times t' < t in domain(h), `M,h,t' ⊨ φ`
**See also**: [P (somePast)](#p-somePast--existential-past), [G (allFuture)](#g-allFuture--universal-future)
**Examples**: `H p` means "p has always been true (in the past)"

### P (somePast / existential past)
Existential past operator - expresses that a formula held at some past time.

**Formal Definition**: `P φ := ¬H¬φ` (dual of universal past)
**LEAN Code**: Defined via `Formula.allPast` and negation as `somePast`
**Alternative Notation**: `P` (from "Previously" or "Past occurrence")
**Semantics**: `M,h,t ⊨ P φ` iff there exists time t' < t in domain(h) such that `M,h,t' ⊨ φ`
**See also**: [H (allPast)](#h-allPast--universal-past), [F (someFuture)](#f-someFuture--existential-future)
**Duality**: `P φ ↔ ¬H¬φ`
**Examples**: `P □p` means "at some past time, p was necessary"

### G (allFuture / universal future)
Universal future operator - expresses that a formula will hold at all future times.

**Formal Definition**: Primitive temporal operator quantifying over future times
**LEAN Code**: `Formula.allFuture φ`
**Alternative Notation**: `G` (from "Globally" or "Going to always be")
**Semantics**: `M,h,t ⊨ G φ` iff for all times t' > t in domain(h), `M,h,t' ⊨ φ`
**Formal Definition**: `G φ := ¬F¬φ` (`FormalSystem/Syntax/Formula.lean:167`) -- derived, not primitive
**Axioms**: `connect_future` (`φ → G P φ`). Note that `G φ → G G φ` is the *derived* theorem `temporal4Derived` (`FormalSystem/Theorems/TemporalDerived.lean`), not an axiom
**See also**: [F (someFuture)](#f-someFuture--existential-future), [H (allPast)](#h-allPast--universal-past)
**Examples**: `G p` means "p will always be true (in the future)"

### F (someFuture / existential future)
Existential future operator - expresses that a formula will hold at some future time.

**Formal Definition**: `F φ := U(⊤, φ)` (`FormalSystem/Syntax/Formula.lean:147`). The duality
`F φ ↔ ¬G¬φ` holds, but the *definitional* direction runs the other way: `allFuture` is defined
from `someFuture`, which is defined from `untl`.
**LEAN Code**: `Formula.someFuture`
**Alternative Notation**: `F` (from "Future occurrence" or "Finally")
**Semantics**: `M,h,t ⊨ F φ` iff there exists time t' > t in domain(h) such that `M,h,t' ⊨ φ`
**See also**: [G (allFuture)](#g-allFuture--universal-future), [P (somePast)](#p-somePast--existential-past)
**Duality**: `F φ ↔ ¬G¬φ`
**Examples**: `F ◇p` means "at some future time, p will be possible"

### always (eternal truth / omnitemporality)
Temporal operator - expresses that a formula holds at all times (past, present, and future).

**Formal Definition**: `always φ := H φ ∧ φ ∧ G φ` (conjunction of all past, present, and all future)
**Alternative Notation**: `△φ` (U+25B3 WHITE UP-POINTING TRIANGLE)
**LEAN Code**: `Formula.always`, notation `prefix:80 "△" => Formula.always`
**Semantics**: `M,h,t ⊨ always φ` iff for all times t' in domain(h), `M,h,t' ⊨ φ`
**Note**: This is "eternal truth" (all past, present, and future times), not "henceforth" (from now onwards)
**See also**: [sometimes](#sometimes-occurrence-at-some-time), [H (allPast)](#h-allPast--universal-past), [G (allFuture)](#g-allFuture--universal-future)
**Perpetuity**: Used in P1-P6 to connect necessity and temporal truth
**Examples**: `always □p` or `△□p` means "at all times, p is necessary"

### sometimes (occurrence at some time)
Temporal operator - expresses that a formula holds at some time (past, present, or future).

**Formal Definition**: `sometimes φ := P φ ∨ φ ∨ F φ` (equivalently, `¬always¬φ`)
**Alternative Notation**: `▽φ` (U+25BD WHITE DOWN-POINTING TRIANGLE)
**LEAN Code**: `Formula.sometimes`, notation `prefix:80 "▽" => Formula.sometimes`
**Semantics**: `M,h,t ⊨ sometimes φ` iff there exists time t' in domain(h) such that `M,h,t' ⊨ φ`
**Note**: This is "at some time" (past, present, or future), dual to "eternal truth"
**See also**: [always](#always-eternal-truth--omnitemporality), [P (somePast)](#p-somePast--existential-past), [F (someFuture)](#f-someFuture--existential-future)
**Perpetuity**: Used in P2, P4, P5, P6 perpetuity principles
**Duality**: `sometimes φ ↔ ¬always¬φ` or equivalently `▽φ ↔ ¬△¬φ`
**Examples**: `sometimes □p` or `▽□p` means "at some time, p is necessary"

---

## Meta-logical Symbols

### ⊢ (turnstile / provability)
Syntactic provability relation - expresses derivability in the TM proof system.

**Formal Definition**: `Γ ⊢ φ` means φ is derivable from premises Γ using TM axioms and rules
**LEAN Code**: `Derivable (fc : FrameClass) (G : Context) (p : Formula)`
(`FormalSystem/ProofSystem/Derivable.lean:69`) -- note the **frame-class parameter**: derivability
is always relative to a frame class, and the invariant `ax.minFrameClass ≤ fc` governs which
axioms may appear.
**Rules**: the 7 `DerivationTree` constructors -- `axiom`, `assumption`, `modus_ponens`,
`necessitation`, `temporal_necessitation`, `temporal_duality`, `weakening`
**See also**: [⊨ (semantic consequence)](#-models--semantic-consequence)
**Soundness**: If `Γ ⊢ φ` then `Γ ⊨ φ`
**Examples**: `⊢ □p → p` means "necessarily p implies p" is a theorem (axiom MT)

### ⊨ (models / semantic consequence)
Semantic consequence relation - expresses validity in task frame models.

**Formal Definition**: `Γ ⊨ φ` means φ is true in all task models where all formulas in Γ are true
**LEAN Code**: `valid Γ φ` (semantic validity definition)
**Semantics**: Based on task frame structures with world histories and time domains
**See also**: [⊢ (provability)](#-turnstile--provability)
**Completeness**: available in the **finite-context** form only. `Context` is `List Formula`,
so `consequence_completeness` (`FormalSystem/Metalogic/StrongCompleteness.lean`) is
inter-derivable with weak completeness through the deduction theorem. The unqualified
arbitrary-`Γ` reading -- *strong* completeness over a possibly-infinite `Γ : Set Formula` -- is
**not** available uniformly: it is machine-refuted for Discrete, open for Base and Dense, and
outside the primary source's scope for Dedekind. See
`FormalSystem/Metalogic/StrongCompleteness.lean:25-41` and
[known-limitations.md](../project-info/known-limitations.md).
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
**LEAN Code**: `perpetuity3 φ : ⊢ (φ.box.imp (always φ).box)`
**Proof Strategy**: From S5 axiom M4 (□φ → □□φ) and P1
**Intuition**: If φ is necessary, then it's necessarily true that φ holds always
**See also**: [P1 (necessity implies perpetuity)](#p1-necessity-implies-perpetuity)

### P4: Possibility of Occurrence
**Statement**: `◇sometimes φ → ◇φ`
**Natural Language**: The possibility of occurrence implies possibility.
**LEAN Code**: `perpetuity4 φ : ⊢ ((sometimes φ).dia.imp φ.dia)`
**Proof Strategy**: From modal-temporal interaction and P2
**Intuition**: If it's possible that φ occurs at some time, then φ is possible
**See also**: [P2 (occurrence implies possibility)](#p2-occurrence-implies-possibility)

### P5: Persistent Possibility
**Statement**: `◇sometimes φ → always ◇φ`
**Natural Language**: Possible occurrence implies persistent possibility.
**LEAN Code**: `perpetuity5 φ : ⊢ ((sometimes φ).dia.imp (always φ.dia))`
**Proof Strategy**: From S5 Brouwersche axiom MB and temporal semantics
**Intuition**: If φ possibly occurs, it remains possible at all times
**See also**: [P6 (occurrent necessity is perpetual)](#p6-occurrent-necessity-is-perpetual)

### P6: Occurrent Necessity is Perpetual
**Statement**: `sometimes □φ → □always φ`
**Natural Language**: If φ is necessary at some time, it is necessarily perpetual.
**LEAN Code**: `perpetuity6 φ : ⊢ ((sometimes φ.box).imp (always φ).box)`
**Proof Strategy**: From modal axioms and temporal interaction axioms (MF, TF)
**Intuition**: Necessity doesn't vary across time - if necessary once, necessary always
**See also**: [P3 (necessity of perpetuity)](#p3-necessity-of-perpetuity)

---

## Variable Conventions

ProofChecker follows consistent naming conventions for variables across documentation and code. These conventions are established in the [LEAN Style Guide](../development/LEAN_STYLE_GUIDE.md).

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

- [Architecture Guide](../user-guide/architecture.md) - Complete TM logic specification with formal semantics
- [LEAN Style Guide](../development/LEAN_STYLE_GUIDE.md) - Coding conventions and variable naming
- [Tutorial](../user-guide/tutorial.md) - Practical examples using these operators
- [Examples](../user-guide/examples.md) - Modal, temporal, and bimodal proof examples

---

**Last Updated**: 2025-12-01
**Version**: 1.0
**Maintainer**: ProofChecker Development Team
