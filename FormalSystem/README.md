# Bimodal

**Production-ready** core library for TM bimodal logic (Tense and Modality) with task semantics and **complete soundness and completeness proofs**.

## Reference Document

For the complete formal specification, see **BimodalReference** ([tex](../latex/BimodalReference.tex) | [pdf](../latex/BimodalReference.pdf)).

This README provides an overview; BimodalReference contains the detailed specification of syntax, semantics, proof theory, and metalogic.

## Counting Live Files: Exclude the Archive

Archived code lives in exactly one place, [`Boneyard/`](Boneyard/README.md), and must be excluded
from any count of this tree. It used to live in two places -- there was a second archive nested at
`Metalogic/WeakCanonical/Kamp/Boneyard/`, and a filter naming only the top-level directory counted
it as live. That is not hypothetical: repeated past descriptions of this repository's size were
wrong for exactly that reason. The archives are now consolidated, and B0 in the invariant script
asserts the directory count is exactly **1**, so a second one reappearing fails the gate.

**Do not hand-roll the count, and do not restate it here.** The archive's own counts are stated in
exactly one place -- [`Boneyard/README.md`](Boneyard/README.md) -- and the live source for both
archived and live figures is the invariant script, which filters on the `*/Boneyard/*` **name
glob** rather than a path prefix for every traversal:

```bash
bash scripts/check-module-invariants.sh              # B0 self-test, C7 live inventory
bash scripts/check-module-invariants.sh --no-build   # structural checks, no build
```

It also verifies the build, the flagship axiom sets, the structural-`sorry` inventory
(asserted at zero, by content, never by line number), dangling imports across every live `.lean`, dangling
module paths in markdown, and the aggregator convention. It is the correct answer to
"is this tree still consistent".

## About Bimodal Logic

Bimodal is a **complete propositional intensional logic** implementing TM (Tense and Modality) with verified metalogic.

| Aspect | Description |
|--------|-------------|
| **Type** | Propositional intensional logic |
| **Status** | Production-ready with soundness/completeness proofs |
| **Semantic primitives** | World-states in a Kripke-style framework |
| **Interpretation** | Sentence letters are interpreted by sets of world-states |
| **Logical level** | Propositional (zeroth-order) |

## Syntax Quick Reference

### Primitive and Derived Operators

`Formula` (`Syntax/Formula.lean`) has **six** constructors — `atom`, `bot`, `imp`, `box`, `untl`,
`snce`. The temporal operators `H`/`G`/`P`/`F` are *derived* from `untl`/`snce`, not primitive.

For the symbol/definition tables, see the [top-level README's Operators
section](../README.md), which is the single maintained copy: its primitive table lists `bot`,
`imp`, `box`, `untl`, `snce` (the five primitive *connectives* — `atom` is the sixth constructor
but is not a connective), and its derived table gives the definition of each derived operator in
terms of those primitives.

The Lean names for the derived operators are **camelCase**: `neg`, `top`, `and`, `or`, `diamond`,
`someFuture`, `somePast`, `allFuture`, `allPast`, `always`, `sometimes`
(`Syntax/Formula.lean:134-616`). The snake_case spellings that earlier revisions of this table
used are not identifiers in this tree; use the camelCase names above.

**Argument order.** `untl` and `snce` are *guard-first* (`untl guard event`); the top-level
README's `U(·,·)` / `S(·,·)` notation is *event-first*. See that README's argument-order note
before cross-referencing either against the paper.

## Proof System Overview

### Axiom System

The axiom system uses the `Axiom` inductive type with **45 constructors** organized into nine layers:

| Layer | Constructors | Frame Class | Description |
|-------|------------:|-------------|-------------|
| 1. Propositional | 4 | Base | K, S, EFQ, Peirce |
| 2. S5 Modal | 5 | Base | T, 4, B, 5-collapse, K-distribution |
| 3. BX Temporal | 18 | Base | Burgess-Xu Until/Since axioms (paired G/H forms) |
| 3b. Additional BX Temporal | 4 | Base | `temp_linearity`, `temp_linearity_past`, `F_until_equiv`, `P_since_equiv` |
| 4. Interaction | 1 | Base | MF (`□φ → □Gφ`); TF is now derived |
| 5. Uniformity | 5 | Base | Discrete uniformity (valid on all ordered abelian groups) |
| 6. Prior | 2 | Discrete | Prior-UZ/SZ for discrete well-ordering |
| 7. Z1 | 1 | Discrete | IsSuccArchimedean characteristic axiom |
| 8. Density | 2 | Dense | `density` (`GGφ → Gφ`) and `dense_indicator` (`¬U(⊤,⊥)`) |
| 9. Reynolds Dedekind | 3 | Dedekind | `prior_U_gap`, `prior_S_gap`, `sep` — definable-gap-freeness for real flow |
| **Total** | **45** | | |

**Schema vs. constructor count**: The 45 constructors implement a smaller set of logical schemas —
G-monotonicity and H-monotonicity, for instance, count as one schema with two constructors. The
`Axiom` inductive type represents all paired temporal forms explicitly.

**Frame classification**: 37 Base constructors (valid on all linear orders), 3 Discrete-only, 2 Dense-only,
3 Dedekind-only. Cumulatively (`Dense ≤ Dedekind`): Base 37, Dense 39, Discrete 40, Dedekind 42.

See [ProofSystem/Axioms.lean](ProofSystem/Axioms.lean) for the complete definition.

### Inference Rules (7 total)

- **Modus Ponens**: From `⊢ φ → ψ` and `⊢ φ`, derive `⊢ ψ`
- **Necessitation**: From `⊢ φ`, derive `⊢ □φ`
- **Temporal Necessitation**: From `⊢ φ`, derive `⊢ Gφ`
- **Temporal Duality**: From `⊢ φ`, derive `⊢ swap(φ)` (swap H/G, P/F)
- **Axiom**: Any axiom instance is derivable
- **Assumption**: Hypotheses in context are derivable
- **Weakening**: Derivations extend to larger contexts

**Note**: `DerivationTree` is `Type` (not `Prop`) for computability.

See BimodalReference Section 3 for full proof system presentation.

## Semantics Overview

### Task Frame Structure

A task frame `(W, T, R)` consists of:
- **W**: Set of world-states (metaphysically possible states)
- **T**: Set of times with linear order `<`
- **R : W → T → W → Prop**: Task relation (accessibility across time)

Properties: Nullity (reflexive at each time) and Compositionality (forward composition).

### Truth Conditions

- **Atoms**: `M,τ,t ⊨ p` iff `p ∈ V(τ(t))`
- **Modal**: `M,τ,t ⊨ □φ` iff `∀σ. R(τ,t,σ) → M,σ,t ⊨ φ`
- **Temporal**: `M,τ,t ⊨ Gφ` iff `∀s > t. M,τ,s ⊨ φ`

The interaction axiom MF ensures coherence between modal and temporal reasoning.

See BimodalReference Section 2 for formal semantic definitions.

## Logic Variants

TM logic has four variants based on frame conditions:

### TM Base (37 constructor axioms)

The core logic valid on all linear orders. See `FrameClass.Base` in [ProofSystem/Axioms.lean](ProofSystem/Axioms.lean).

- **Soundness**: `axiom_valid` - all base axioms valid on linear orders
- **Frame**: Linear temporal order (no additional constraints)

### TM Dense (Base + 2 density constructors)

Extension requiring densely ordered temporal domains. See `FrameClass.Dense`.

- **Additional Axioms**: `density` (`GGφ → Gφ`) and `dense_indicator` (`¬U(⊤,⊥)`)
- **Completeness**: `completeness_dense` in [BXCanonical/Completeness.lean](Metalogic/BXCanonical/Completeness.lean)
- **Frame**: `DenselyOrdered D` - between any two times exists another

### TM Discrete (Base + 3 discrete constructors)

Extension requiring discretely ordered temporal domains. See `FrameClass.Discrete`.

- **Additional Axioms**: `prior_UZ`, `prior_SZ` (Prior's axioms), `z1` (IsSuccArchimedean)
- **Completeness**: `completeness_discrete` in [StrongCompleteness.lean](Metalogic/StrongCompleteness.lean)
- **Frame**: `SuccOrder D`, `PredOrder D`, `NoMaxOrder D`, `NoMinOrder D`

### TM Dedekind (Base + 2 Dense + 3 Dedekind constructors)

Extension for dense Dedekind-complete temporal domains — the real flow. See `FrameClass.Dedekind`.
Because `Dense ≤ Dedekind`, a Dedekind derivation admits the two density axioms as well.

- **Additional Axioms**: Reynolds' `prior_U_gap`, `prior_S_gap`, `sep` (definable-gap-freeness),
  on top of `density` and `dense_indicator`
- **Soundness**: `soundness_dedekind` in [Soundness.lean](Metalogic/Soundness.lean)
- **Completeness**: `completeness_dedekind` in [StrongCompleteness.lean](Metalogic/StrongCompleteness.lean)
- **Binder caveat**: both results are stated against `ValidDedekindDense`, *not* the density-free
  `ValidDedekind`. `density` and `dense_indicator` are admissible at `.Dedekind` and both are false
  on ℤ, which is nonetheless conditionally complete.
- **Frame**: `DenselyOrdered D` plus Dedekind completeness

**`FrameClass.Dedekind` *is* the paper's TM⁺_c.** The live `cor:tm-completeness` reads
"TM⁺_c — Weakly complete over the dense-and-complete class", and `FrameClass.Dedekind` is exactly
that class (`DenselyOrdered D` plus Dedekind completeness). An earlier revision of this file said
TM⁺_c was completeness *simpliciter*, with models `{ℤ, ℝ}` and theory `Th(ℤ) ∩ Th(ℝ)`, and that
no element of `FrameClass` picked it out. Both halves are stale: that footnote is commented out in
the live `def:TMplus-c`, and the paper's class for TM⁺_c is dense-and-complete. There is no gap.

What remains open is an axiom-basis question on the paper's side: `def:TMplus-c` builds BX_c from
`TMP-PU` and `TMP-SEP` with no density axiom, while `FrameClass.Dedekind` admits `density` and
`dense_indicator` in addition to Reynolds' triple, so `completeness_dedekind` proves a
stronger-premise statement than the paper's corollary as literally written. Resolving that is an
author decision, not a tree change.

### Variant Incompatibility

Dense and discrete extensions are **incompatible** on any non-degenerate domain. Discrete and
Dedekind are likewise incomparable, and `Dedekind ≰ Dense` — the order on `FrameClass` places
`Dedekind` strictly above `Dense` and unrelated to `Discrete`.

## Key Results Proven

| Result | Statement | Status |
|--------|-----------|--------|
| Soundness | `(Γ ⊢ φ) → (Γ ⊨ φ)` | Proven |
| Deduction Theorem | `((A :: Γ) ⊢ B) → (Γ ⊢ A → B)` | Proven |
| Dense Completeness | `valid_dense φ → (⊢ φ)` | Proven |
| Discrete Completeness | `valid_discrete φ → (⊢ φ)` | Proven |
| Decidability | `decide φ : DecisionResult φ` | Implemented |

## Module Structure

The Bimodal library follows a layered architecture:

### Root Entry Point

The Lake library root is a **pair** of files, not one: `lean_lib FormalSystem` sets
`srcDir := "."` and ``roots := #[`FormalSystem]``, so module `FormalSystem` resolves to the
**repository-root** `FormalSystem.lean`, which in turn imports module `FormalSystem.FormalSystem`
— the file `FormalSystem/FormalSystem.lean`. That self-named indirection is load-bearing, and the
invariant check allowlists it by name (check C8).

| File | Lines | Description |
|------|------:|-------------|
| `../FormalSystem.lean` | 50 | Repository-root Lake root module for `lean_lib FormalSystem` |
| `FormalSystem.lean` | 107 | Library aggregator: imports all submodules for unified access |
| `Automation.lean` | 102 | Re-export for Automation submodule |
| `BaseLanguage.lean` | 34 | Re-export for BaseLanguage submodule |
| `Examples.lean` | 33 | Re-export for Examples submodule |
| `Metalogic.lean` | 199 | Re-export for Metalogic submodule |
| `ProofSystem.lean` | 88 | Re-export for ProofSystem submodule |
| `Semantics.lean` | 137 | Re-export for Semantics submodule |
| `Syntax.lean` | 75 | Re-export for Syntax submodule |
| `Theorems.lean` | 88 | Re-export for Theorems submodule |

### Layer 0 — Foundation

| Module | File | Description |
|--------|------|-------------|
| Syntax | `Syntax.lean` | Formula type, atoms, contexts, subformula closure |
| ProofSystem | `ProofSystem.lean` | 45 axiom constructors, 7 inference rules, derivation trees |

### Layer 1 — Semantics

| Module | File | Description |
|--------|------|-------------|
| Semantics | `Semantics.lean` | Task frame structure, world histories, truth evaluation |

### Layer 2 — Metalogic

| Module | File | Description |
|--------|------|-------------|
| Metalogic | `Metalogic.lean` | Soundness, completeness, deduction theorem, decidability |

### Layer 3 — Theorems

| Module | File | Description |
|--------|------|-------------|
| Theorems | `Theorems.lean` | Derived theorems: perpetuity, combinators, modal S4/S5 |

### Layer 4 — Automation

| Module | File | Description |
|--------|------|-------------|
| Automation | `Automation.lean` | Tactics, Aesop rules, ML dataset pipeline |

### Layer 5 — Examples

| Module | File | Description |
|--------|------|-------------|
| Examples | `Examples.lean` | Pedagogical examples and proof demonstrations |

## Submodule Navigation

| Submodule | README | Description |
|-----------|--------|-------------|
| [Syntax/](Syntax/README.md) | Yes | Formula types and proof contexts |
| [ProofSystem/](ProofSystem/README.md) | Yes | Axioms and derivation trees |
| [Semantics/](Semantics/README.md) | Yes | Task frame semantics |
| [Metalogic/](Metalogic/README.md) | Yes | Soundness, completeness, decidability |
| [Theorems/](Theorems/README.md) | Yes | Derived theorems |
| [Automation/](Automation/README.md) | Yes | Proof tactics and ML pipeline |
| [Examples/](Examples/README.md) | Yes | Pedagogical examples |
| `BaseLanguage/` | No | Shared base-language definitions (no README yet) |
| [Boneyard/](Boneyard/README.md) | Yes | ARCHIVE — 156 archived `.lean` files, excluded from the live build |

## Quick Reference

**Where to find specific functionality**:

- **Formulas**: `Syntax/Formula.lean` - Inductive formula type
- **Contexts**: `Syntax/Context.lean` - Proof context lists
- **Axioms**: `ProofSystem/Axioms.lean` - TM axiom constructors (45)
- **Derivation Trees**: `ProofSystem/Derivation.lean` - DerivationTree type
- **Task Frames**: `Semantics/TaskFrame.lean` - Task frame structure
- **Models**: `Semantics/TaskModel.lean` - Models with valuation
- **Truth**: `Semantics/Truth.lean` - Truth evaluation
- **BL truth**: `Semantics/BLTruth.lean` - Native truth evaluation for the base language BL
- **Validity**: `Semantics/Validity.lean` - Semantic consequence
- **BL validity**: `Semantics/BLValidity.lean` - Base-language validity predicates
- **Soundness**: `Metalogic/Soundness.lean` - Soundness theorem
- **BL soundness**: `Metalogic/BaseLanguageSoundness.lean` - Soundness for BL, by composition
- **Completeness**: `Metalogic/BXCanonical/Completeness.lean` - Canonical model
- **Perpetuity**: `Theorems/Perpetuity.lean` - P1-P6 principles
- **Tactics**: `Automation/Tactics/Commands.lean` - Custom tactics

## Building and Type-Checking

```bash
# Build the FormalSystem library
lake build FormalSystem

# Build entire project
lake build

# Type-check specific file
lake env lean FormalSystem/Syntax/Formula.lean
lake env lean FormalSystem/ProofSystem/Axioms.lean
```

## Implementation Status

| Layer | Component | Status |
|-------|-----------|--------|
| 0 | Syntax | Complete |
| 0 | ProofSystem | Complete (45 axiom constructors, 7 rules) |
| 1 | Semantics | Complete (TaskFrame, TaskModel, Truth) |
| 2 | Metalogic | Soundness, weak and finite-context completeness, and the deduction theorem for all four frame classes; decidability **sound direction only** |
| 3 | Theorems | Complete (P1-P6 perpetuity principles, S4/S5 modal) |
| 4 | Automation | Complete (tactics); ML pipeline active |

**Key Results**: soundness, weak completeness, finite-context consequence completeness, and the
deduction theorem are proven for **all four** frame classes (Base, Dense, Discrete, Dedekind),
each `SORRY-FREE (sorryAx-free; axioms: exactly propext, Classical.choice, Quot.sound)`.

**Decidability is not "fully proven" and must not be described that way.** Only the *sound*
direction of the `isValid`-shaped statement is landed — `sound_of_isValid` and `isValid_sound`
(`Metalogic/Decidability/Correctness.lean`). The *completeness* direction
`⊨ φ → isValid φ fc = true`, and hence `valid_iff_allClosed`, the biconditional, and the four
`Decidable (⊨ φ)` instances, are **open**. Two declarations, `validity_decidable` and
`validity_has_decision_procedure`, previously papered over exactly this gap and are recorded in
`Correctness.lean` as *retired as vacuous* because their names claimed a decidability result their
proofs did not contain; restating the claim in prose would reproduce that defect.

## Theory-Specific Documentation

For Bimodal-specific guides and references, see [docs/](../docs/README.md):

| Document | Description |
|----------|-------------|
| [Quick Start](../docs/user-guide/quickstart.md) | Get started with Bimodal proofs |
| [Proof Patterns](../docs/user-guide/proof-patterns.md) | Common proof strategies |
| [Axiom Reference](../docs/reference/axiom-reference.md) | Complete axiom schemas |
| [Tactic Reference](../docs/reference/tactic-reference.md) | Custom tactic usage |

## Navigation

- **Parent**: [Project Root](../) | [Tests](../Tests/)
- **Docs**: [docs/](../docs/README.md)
- **Boneyard**: [Boneyard/](Boneyard/README.md) (archived code)

---

*Last verified: 2026-08-25 — `lake build` clean and sorry-free, `scripts/check-module-invariants.sh`
all-green (including the widened C14 and the new C15), `scripts/check-paper-definitions.sh` exit 0,
`scripts/typst-sync-check.sh` PASS.*
