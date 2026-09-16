# Module Organization for ProofChecker

This document specifies the directory structure, namespace conventions, and module organization for the ProofChecker project (BimodalLogic repository). The primary library is the `Bimodal` theory, residing under `FormalSystem/`.

## 1. Directory Structure

```
BimodalLogic/
├── lakefile.lean               # Lake build configuration
├── lean-toolchain              # Lean version pin
├── FormalSystem.lean           # Library root (re-exports all sub-modules)
├── FormalSystem/               # Main library source
│   ├── Syntax.lean             # Aggregates Syntax/
│   ├── ProofSystem.lean        # Aggregates ProofSystem/
│   ├── MinusLanguage.lean       # Aggregates MinusLanguage/
│   ├── PlusLanguage.lean       # Aggregates PlusLanguage/
│   ├── Semantics.lean          # Aggregates Semantics/
│   ├── Metalogic.lean          # Aggregates Metalogic/
│   ├── Theorems.lean           # Aggregates Theorems/
│   ├── Automation.lean         # Aggregates Automation/
│   ├── Examples.lean           # Aggregates Examples/
│   ├── Syntax/                 # Formula types, atoms, contexts, subformulas
│   ├── ProofSystem/            # Axioms, derivation trees, inference rules
│   ├── MinusLanguage/           # The tense-primitive second object language
│   ├── PlusLanguage/           # L⁺: L plus the stability modal ⊡, and its logic TM⁺
│   ├── Semantics/              # Task frame semantics, truth evaluation, extension
│   │   ├── MinusLanguage/      # L⁻ truth, frames and validity (aggregator Semantics/MinusLanguage.lean)
│   │   ├── PlusLanguage/       # L⁺ truth, validity, pasting, non-validities (aggregator Semantics/PlusLanguage.lean)
│   │   └── StarLanguage/       # L⋆ truth, validity, determinism (aggregator Semantics/StarLanguage.lean)
│   ├── Metalogic/              # Soundness, completeness, decidability, independence
│   ├── Theorems/               # Derived theorems (perpetuity, combinators, propositional)
│   ├── Automation/             # Proof tactics, search, dataset generation
│   ├── Examples/               # Pedagogical examples
│   └── Boneyard/               # Archived work (excluded from every invariant check)
├── Tests/
│   └── BimodalTest/            # Test suite mirroring FormalSystem/ structure
│       ├── Syntax/             # Syntax tests
│       ├── ProofSystem/        # Proof system tests
│       ├── Semantics/          # Semantic tests
│       ├── Metalogic/          # Metalogic tests
│       ├── Theorems/           # Theorem tests
│       ├── Automation/         # Automation tests
│       ├── Integration/        # Integration tests
│       └── Property/           # Property-based tests
├── scripts/                    # Invariant checks and lints
└── docs/                       # Project-level documentation
```

## 2. Namespace Conventions

### Root Namespace

All library code lives under the `FormalSystem` namespace:

```lean
namespace FormalSystem

-- All definitions here

end FormalSystem
```

There is no `Bimodal` namespace. `Bimodal` is the *repository* name, and an earlier version of
this section claimed it was the root namespace; `grep -rn '^namespace Bimodal' FormalSystem/`
returns zero matches, so that claim was false and has been removed.

### Hierarchical Namespaces

**Top-level components** take the namespace matching their directory:

| Directory | Namespace |
|-----------|-----------|
| `FormalSystem/Syntax/` | `FormalSystem.Syntax` |
| `FormalSystem/ProofSystem/` | `FormalSystem.ProofSystem` |
| `FormalSystem/Semantics/` | `FormalSystem.Semantics` |
| `FormalSystem/Metalogic/` | `FormalSystem.Metalogic` |
| `FormalSystem/Theorems/` | `FormalSystem.Theorems` |
| `FormalSystem/Automation/` | `FormalSystem.Automation` |

**Namespaces do not, however, mirror the directory structure below that level.** The real
convention is that a nested subdirectory **keeps its component's namespace** rather than adding
a component of its own. Three pre-existing examples, all verifiable by `grep -n '^namespace'`:

| File | Declares |
|------|----------|
| `Syntax/SubformulaClosure/Closure.lean` | `namespace FormalSystem.Syntax` (not `...Syntax.SubformulaClosure`) |
| `Metalogic/Conservativity/Plus/Forward.lean` | `namespace FormalSystem.Metalogic.Conservativity` (not `...Conservativity.Plus`) |
| `Syntax/MinusLanguage/Formula.lean` | `namespace FormalSystem.MinusLanguage` (not `...Syntax.MinusLanguage`) |

The third case is the L⁻/L⁺/L⋆ language family, nested under `Syntax/` while deliberately
keeping its flat `FormalSystem.MinusLanguage` / `.PlusLanguage` / `.StarLanguage` namespaces.
Renaming them to match the new module depth was considered and rejected: it would have touched
103 call sites and the `#print axioms` baseline in `scripts/check-module-invariants.sh`, for no
gain.

The language family's **semantic** modules follow the same rule one directory over: they are
nested under `Semantics/MinusLanguage/`, `Semantics/PlusLanguage/` and `Semantics/StarLanguage/`
(module `FormalSystem.Semantics.PlusLanguage.PlusTruth`, for instance) while every declaration
keeps the flat `namespace FormalSystem.Semantics`, including the sub-namespaces `MinusTruth`,
`MinusValidity`, `PlusTruth` and `StarTruth`. So the dotted name formed from
`FormalSystem.Semantics` and `PlusTruth` now names only a namespace; the module is
`FormalSystem.Semantics.PlusLanguage.PlusTruth`.

**Consequence for documentation**: a dotted name like `FormalSystem.MinusLanguage` may be a
namespace reading (correct as written) or a module-path reading (which must be
`FormalSystem.Syntax.MinusLanguage`), and the two are textually indistinguishable. `C5` cannot
tell them apart either, which is why `scripts/module-invariants-allowlist.txt` exists and why
each of its entries records which reading it covers.

### Nested Namespaces

Use nested namespaces for logical grouping within a file:

```lean
-- In FormalSystem/Syntax/Formula.lean
namespace FormalSystem.Syntax

inductive Formula : Type
  | atom : String → Formula
  | bot : Formula
  | imp : Formula → Formula → Formula
  | box : Formula → Formula
  | allPast : Formula → Formula
  | allFuture : Formula → Formula

namespace Formula

/-- Complexity measure for formulas -/
def complexity : Formula → Nat
  | atom _ => 1
  | bot => 1
  | imp φ ψ => φ.complexity + ψ.complexity + 1
  | box φ => φ.complexity + 1
  | allPast φ => φ.complexity + 1
  | allFuture φ => φ.complexity + 1

end Formula

end FormalSystem.Syntax
```

### Declaration names: `Prefix.rest`, not `Prefix_rest`

A declaration *about* a named thing is a member of that thing's namespace, written with a dot:
`SubformulaClosure.G_closed`, not `SubformulaClosure_G_closed`. The dotted form buys real
things — dot-notation at use sites, and a name that C17's dead-declaration census can attribute
to the right owner — where the underscore form is merely a name that happens to start with a
capital letter.

The convention has **three recorded exceptions**, and a census that reports them is reporting
correct code:

**1. Tense-operator prefixes are not namespaces.** `F_`, `P_`, `G_`, `H_`, `A_`, `FF_` and
`HF...` name the paper's own temporal operators. `F_until_equiv_valid` is a fact *about the
operator* `F`, and `F.until_equiv_valid` would invent a namespace `F` that does not exist and
should not: `F` is notation, not a type. These are the largest class by far.

**2. A prefix that names no live declaration.** `CAggOdSwap_clause_iff` and `O_zero_correct`
look dotted-shaped but there is no `CAggOdSwap` and no `O` to be a member of, so the dotted
form would name a namespace with exactly one inhabitant and no owner.

**3. A suffix that would capture a live name.** This one bites, and it is not a matter of taste.
Declaring `Prefix.rest` puts `rest` in scope — as `Prefix.rest` — inside *every other*
`Prefix.*` declaration. If a live declaration is already called `rest`, a sibling whose body
mentions it now resolves to the wrong one, silently where the types happen to line up and
loudly where they do not. Renaming `BurgessR3Maximal_burgessR3` to
`BurgessR3Maximal.burgessR3` did exactly this: `BurgessR3Maximal.extension_fails`'s reference to
the standalone `burgessR3` definition started resolving to the theorem, and the build failed
with an application type mismatch. Thirteen names have this shape — the
`FiniteFilteredTaskFrame_*` and `RefinedFilteredTaskFrame_*` frame-property families among them,
whose suffixes `serial`, `limit`, `saturation` and `interpolates` are all live frame conditions —
and all thirteen stay underscored.

The test is mechanical, and has two halves: split at the first underscore, then dot-namespace
the name **if and only if** the prefix is itself a live declaration *and* the suffix is not.
`scripts/check-module-invariants.sh`'s C23 assertion applies exactly that test and carries all
three exception classes, so the population cannot regrow without the exception being written
down.

## 3. Module Dependencies

### Layered Architecture

Dependencies flow in one direction to prevent circular imports:

```
Layer 4: Automation (depends on all below)
    ↑
Layer 3: Metalogic (depends on ProofSystem, Semantics, MinusLanguage, PlusLanguage)
    ↑
Layer 2: Semantics, Theorems (depend on Syntax, ProofSystem; Semantics also on
         MinusLanguage.Formula and PlusLanguage.Formula)
    ↑
Layer 1: ProofSystem (depends on Syntax), MinusLanguage (depends on Syntax),
         PlusLanguage (depends on Syntax, ProofSystem)
    ↑
Layer 0: Syntax (no internal dependencies)
```

**Where `MinusLanguage` sits.** It is a second object language parallel to
`Syntax` + `ProofSystem`, not a layer of its own: `MinusLanguage.Formula` imports only
`Syntax.Atom`, and the rest of `MinusLanguage/` imports only `Syntax` and itself. Nothing under
`MinusLanguage/` imports `Semantics/` — that is the directory's standing module invariant, stated
in `FormalSystem/Syntax/MinusLanguage.lean`.
`PlusLanguage/` follows the same pattern and the same directional invariant (stated in
`FormalSystem/Syntax/PlusLanguage.lean`): `Semantics/PlusLanguage/PlusTruth.lean` imports `PlusLanguage.Formula`,
and nothing under `PlusLanguage/` imports `Semantics/`.

The invariant is **directional**, and the converse edge is both permitted and used:
`Semantics/MinusLanguage/MinusTruth.lean` imports `MinusLanguage.Formula` to define `MinusTruthAt` natively on
`MinusFormula`, and `Metalogic/Conservativity/MinusLanguageSoundness.lean` composes that with `Translation` and
`Conservativity`. So the one `Semantics → MinusLanguage` edge in the tree runs into a
`Syntax.Atom`-only leaf and introduces no cycle.

### Dependency Rules

1. **Syntax** has no internal dependencies.
2. **ProofSystem** depends only on Syntax.
3. **Semantics** depends on Syntax and ProofSystem, plus `MinusLanguage.Formula` (a
   `Syntax.Atom`-only leaf) in `MinusTruth.lean` / `MinusValidity.lean`.
4. **Theorems** depends on Syntax and ProofSystem (and may use Semantics for transport lemmas where needed).
5. **Metalogic** depends on Syntax, ProofSystem, Semantics, and Theorems infrastructure used in proofs.
6. **Automation** (tactics, proof search) may depend on any module.

### Import Guidelines

```lean
-- FormalSystem/ProofSystem/Derivation.lean
-- Good: Only imports from Syntax (lower layer)
import FormalSystem.Syntax.Formula
import FormalSystem.Syntax.Context
import FormalSystem.ProofSystem.Axioms
import FormalSystem.ProofSystem.Derivation

-- Bad: Would create circular dependency
-- import FormalSystem.Semantics.Truth  -- Semantics depends on ProofSystem!
```

### Detecting Circular Dependencies

Lake will report circular dependencies at build time. If you encounter them:
1. Identify the cycle by examining import chains
2. Extract shared definitions to a lower-level module
3. Consider whether the dependency direction should be reversed

## 4. File Structure Template

Every Lean file should follow this structure:

```lean
/-!
# Module Title

Brief description of what this module provides.

## Main Definitions

* `Definition1` - What it represents
* `Definition2` - What it represents

## Main Theorems

* `theorem1` - What it proves
* `theorem2` - What it proves

## Implementation Notes

Any important implementation details or design decisions.

## References

* Reference 1
* Reference 2
-/

-- 1. Imports (ordered by: standard library, mathlib, project)
import Init.Data.List
import FormalSystem.Syntax.Formula

-- 2. Namespace opening
namespace Bimodal.«ModuleName»

-- 3. Local notation (if needed)
local notation "⊥" => Formula.bot

-- 4. Type definitions
/-- Docstring -/
structure MyStructure where
  field1 : Type
  field2 : Type

-- 5. Function definitions
/-- Docstring -/
def myFunction (x : Nat) : Nat := x + 1

-- 6. Theorems and lemmas
/-- Docstring -/
theorem myTheorem : 1 + 1 = 2 := rfl

-- 7. Instances
instance : Inhabited MyStructure where
  default := { field1 := Unit, field2 := Unit }

-- 8. Namespace closing
end Bimodal.«ModuleName»
```

## 5. Library Root File

The `FormalSystem.lean` file aggregates all sub-modules:

```lean
/-!
# Bimodal

Lean 4 formalization of bimodal logic TM (Tense and Modality), combining S5 modal
logic with linear temporal logic. Proven sound and complete.

## Core Modules

### Syntax
* `FormalSystem.Syntax.Formula` -- `untl`/`snce` primitive; H/P/G/F derived
* `FormalSystem.Syntax.Atom`
* `FormalSystem.Syntax.Context` -- `List Formula`, hence finite
* `FormalSystem.Syntax.Subformulas`

### Proof System
* `FormalSystem.ProofSystem.Axioms` -- 45 constructors in four layers
* `FormalSystem.ProofSystem.Derivable`
* `FormalSystem.ProofSystem.Derivation` -- `DerivationTree`, 7 inference rules

### MinusLanguage

A **second object language**, tense-primitive (`H`/`G` are constructors rather than
abbreviations), with its own axioms and proof system, related to the primary language by a
translation. It is the language in which the source paper states TM.

* `FormalSystem.Syntax.MinusLanguage.Formula` -- `MinusFormula`
* `FormalSystem.Syntax.MinusLanguage.Axioms` -- a second `inductive Axiom`
* `FormalSystem.Syntax.MinusLanguage.Derivation` -- the mirror proof system
* `FormalSystem.Syntax.MinusLanguage.Translation` -- `tr : MinusFormula → Formula`
* `FormalSystem.Syntax.MinusLanguage.AxiomDischarge`

The base language's **semantics** deliberately does not live here, so that the directory's
`MinusLanguage/ → Semantics/` invariant stays literally true: see
`FormalSystem.Semantics.MinusLanguage.MinusTruth`, `FormalSystem.Semantics.MinusLanguage.MinusValidity` and
`FormalSystem.Metalogic.Conservativity.MinusLanguageSoundness` below.

### Semantics
* `FormalSystem.Semantics.TaskFrame`
* `FormalSystem.Semantics.PartialHistory`
* `FormalSystem.Semantics.TaskModel`
* `FormalSystem.Semantics.Truth`
* `FormalSystem.Semantics.MinusLanguage.MinusTruth` -- `MinusTruthAt`, the native base-language truth recursion
* `FormalSystem.Semantics.Validity`
* `FormalSystem.Semantics.MinusLanguage.MinusValidity` -- the base-language validity predicates
* `FormalSystem.Semantics.Extension` -- the Extension Theorem: every partial history
  extends to a total one

### Metalogic
* `FormalSystem.Metalogic.Soundness`
* `FormalSystem.Metalogic.Conservativity.MinusLanguageSoundness` -- BL soundness at Base/Dense/ZTime/RTime,
  by composition, plus the truth-transfer bridge `truthAt_tr`
* `FormalSystem.Metalogic.SoundnessLemmas`
* `FormalSystem.Metalogic.Core.DeductionTheorem`
* `FormalSystem.Metalogic.Core.MaximalConsistent` -- `SetConsistent`, `set_lindenbaum`
* `FormalSystem.Metalogic.Bundle` -- FMCS / BFMCS bundle construction
* `FormalSystem.Metalogic.BXCanonical` -- canonical model; the Base/Dense/ZTime
  completeness theorems
* `FormalSystem.Metalogic.WeakCanonical` -- countermodel engines, including the
  Reynolds real-line route
* `FormalSystem.Metalogic.Algebraic` -- flow-frame infrastructure
* `FormalSystem.Metalogic.StrongCompleteness` -- `completeness_rtime`, and the
  terminology discipline separating consequence completeness from strong completeness
* `FormalSystem.Metalogic.SetConsequence` -- the set-based consequence layer;
  `CompactBase` and `CompactDense` state the two compactness properties
* `FormalSystem.Metalogic.Compactness` -- their discharge, by an ultraproduct model-existence
  construction, together with Base and Dense strong completeness
* `FormalSystem.Metalogic.DiscreteNonCompactness` -- the machine refutation of ZTime
  strong completeness
* `FormalSystem.Metalogic.Conservativity` -- the TM⁻/TM backward bridge
* `FormalSystem.Metalogic.Independence` -- underivability results
* `FormalSystem.Metalogic.Decidability` -- the tableau decision procedure and its
  sound-direction correctness proofs

### Theorems
* `FormalSystem.Theorems.Perpetuity`
* `FormalSystem.Theorems.ModalS4`
* `FormalSystem.Theorems.ModalS5`
* `FormalSystem.Theorems.GeneralizedNecessitation`
* `FormalSystem.Theorems.Combinators`
* `FormalSystem.Theorems.Propositional`

### Automation
* `FormalSystem.Automation.Tactics`
* `FormalSystem.Automation.ProofSearch`
-/

import FormalSystem.Syntax
import FormalSystem.ProofSystem
import FormalSystem.Semantics
import FormalSystem.Metalogic
import FormalSystem.Theorems
import FormalSystem.Automation
```

## 6. Public API vs Internal Implementation

### Public API

Definitions that users should use directly:

- Marked with docstrings
- Re-exported from `FormalSystem.lean`
- Stable across versions

```lean
/-- The formula type for TM logic. -/
inductive Formula : Type
  ...

/-- Check if a formula is valid. -/
def valid (φ : Formula) : Prop := ...

/-- The soundness theorem. -/
theorem soundness : Γ ⊢ φ → Γ ⊨ φ := ...
```

### Internal Implementation

Helper functions and intermediate definitions:

- May be placed in `Internal` sub-namespace
- Not re-exported from root
- May change between versions

```lean
namespace FormalSystem.Semantics.«Internal»

/-- Internal helper for canonical model construction. -/
def extend_consistent_set (Γ : Context) : Context := ...

end FormalSystem.Semantics.«Internal»
```

## 7. Module Size Guidelines

### Recommended Limits

- **Lines per file**: ≤1000 lines
- **Definitions per file**: ≤30 major definitions
- **Nesting depth**: ≤4 namespace levels

### When to Split a Module

Split a module when:
1. It exceeds 1000 lines
2. It has multiple independent logical sections
3. Different sections have different dependency requirements
4. Testing becomes difficult

### How to Split

1. Identify logical boundaries
2. Create new file for extracted content
3. Update imports in both files
4. Update re-exports in library root

## 8. Examples Module Organization

Pedagogical examples live in `FormalSystem/Examples/`. These files use only proven
components and mirror the core structure:

- `Examples/ModalProofs.lean` - S5 modal logic examples
- `Examples/TemporalProofs.lean` - Temporal reasoning examples
- `Examples/BimodalProofs.lean` - Combined modal-temporal examples

All examples import `Bimodal` (or targeted sub-modules) and avoid unproven axioms.

## 9. Test Module Organization

See [TESTING_STANDARDS.md](TESTING_STANDARDS.md) for detailed test organization.

Summary:
- `Tests/BimodalTest/` mirrors `FormalSystem/` (Syntax, ProofSystem, Semantics, Metalogic, Theorems, Automation)
- Test files are named `<Module>Test.lean` and collected via `BimodalTest.lean`

## References

- [LEAN Style Guide](LEAN_STYLE_GUIDE.md)
- [Testing Standards](TESTING_STANDARDS.md)
