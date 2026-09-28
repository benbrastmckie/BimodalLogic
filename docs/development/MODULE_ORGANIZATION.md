# Module Organization for ProofChecker

This document specifies the directory structure, namespace conventions, and module organization for the ProofChecker project (BimodalLogic repository). The primary library is the `Bimodal` theory, residing under `FormalSystem/`.

## 1. Directory Structure

```
BimodalLogic/
├── lakefile.toml               # Lake build configuration (package BimodalLogic)
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
│   ├── MinusLanguage/          # L⁻: syntax, TM⁻, and its semantics, in one directory
│   ├── PlusLanguage/           # L⁺: L plus the stability modal ⊡, TM⁺, and its semantics
│   ├── StarLanguage/           # L⋆: L⁺ plus the time registers, TM⋆, and its semantics
│   ├── Semantics/              # Task frame semantics for L, truth evaluation, extension
│   ├── Metalogic/              # Soundness, completeness, decidability, independence
│   ├── Theorems/               # Derived theorems (perpetuity, combinators, propositional)
│   ├── Tactic/                 # Layer 0: Attr.lean (the library's attributes, imported by Init.lean), Meta.lean
│   ├── Automation/             # Proof tactics and proof search (the dataset tooling is lean_lib BimodalTools)
│   ├── Examples/               # Pedagogical examples
│   └── Boneyard/               # Archived work (excluded from every invariant check)
├── Tests/
│   ├── BimodalTest/            # Test suite mirroring FormalSystem/ structure
│   │   ├── Syntax/             # Syntax tests
│   │   ├── ProofSystem/        # Proof system tests
│   │   ├── Semantics/          # Semantic tests
│   │   ├── Metalogic/          # Metalogic tests
│   │   ├── Theorems/           # Theorem tests
│   │   ├── Automation/         # Automation tests
│   │   ├── Integration/        # Integration tests
│   │   └── Property/           # Property-based tests
│   ├── BimodalToolsTest/       # Test suite for lean_lib BimodalTools
│   └── fixtures/               # Committed, shareable data files: tracked in git, so a consumer outside this repository can obtain them
├── data/                       # Gitignored in its entirety (`data/*.jsonl`, `/data`) — large datasets from Hugging Face Hub; cannot hold a shared artifact
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

The L⁻/L⁺/L⋆ language family used to supply a third row here, and no longer does. Its syntax
half sat under `Syntax/` while keeping a flat `FormalSystem.MinusLanguage` /
`.PlusLanguage` / `.StarLanguage` namespace, and its **semantic** half was the larger half of
the same mismatch: modules under `Semantics/{Minus,Plus,Star}Language/` whose every declaration
kept the flat `namespace FormalSystem.Semantics`, sub-namespaces `MinusTruth`, `MinusValidity`,
`PlusTruth` and `StarTruth` included.

The language-extension merge closed both halves at once. Each family now occupies one root-level
directory — `FormalSystem/MinusLanguage/`, `FormalSystem/PlusLanguage/`,
`FormalSystem/StarLanguage/` — and every declaration in it, semantic modules included, lives in
the matching flat `FormalSystem.{X}Language` namespace. Path and namespace agree, so
`FormalSystem.PlusLanguage.PlusTruth` reads the same whether taken as a module path or as a
namespace.

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

**Where the language family sits.** `MinusLanguage/`, `PlusLanguage/` and `StarLanguage/` are
object languages parallel to `Syntax` + `ProofSystem` + `Semantics`, not layers of their own.
Each is self-contained: `MinusLanguage.Formula` imports only `Syntax.Atom`, the rest of the
syntax half imports only `Syntax` and itself, and the semantic modules beside them import
`Semantics/` to build their truth relations on top of it. `OpenLanguage/` — L⁺ plus the
open-future and open-past modals — is a fourth such directory; it is semantic only, so its syntax
half is the single file `OpenLanguage.Formula`, which imports only `PlusLanguage.Formula`.
`HybridLanguage/` — L⁺ plus the same-state modality, state registers and the state binder — and
`QuantLanguage/` — L plus propositional quantifiers — are a fifth and a sixth, semantic only too:
`HybridLanguage.Formula` imports only `PlusLanguage.Formula`, and `QuantLanguage.Formula` only
`Syntax.Formula`.

The old invariant was a *directory* separation — nothing under `Syntax/{X}Language/` imports
`Semantics/`. The merge replaced it with a **file-level** ordering within each directory, stated
in each family's aggregator docstring (`FormalSystem/MinusLanguage.lean` and its siblings):
the syntax modules import nothing from `Semantics/`; the semantic modules beside them do, and
that edge is what gives each language its meaning. `MinusLanguage/MinusTruth.lean` imports
`MinusLanguage.Formula` to define `MinusTruthAt` natively on `MinusFormula`, and
`MinusLanguage/Soundness.lean` composes that with `Translation` and `Conservativity`. The one
`Semantics → MinusLanguage` edge in the tree runs into a `Syntax.Atom`-only leaf and introduces
no cycle.

No mechanical check enforces the file-level ordering. Before the merge, the directory boundary
did; see `docs/ARCHITECTURE.md`'s note on what the layer table stops measuring.

### Dependency Rules

1. **Syntax** has no internal dependencies.
2. **ProofSystem** depends only on Syntax.
3. **Semantics** depends on Syntax and ProofSystem. The six language-family directories
   depend on Semantics in their semantic half; the two cross-language bridges
   (`DeterministicBridge.lean`, `StateLocalTransfer.lean`) stay under `Semantics/` and depend on
   them in turn.
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
* `FormalSystem.ProofSystem.Axioms` -- 29 constructors in four layers
* `FormalSystem.ProofSystem.DerivedAxioms` -- the TR-derived mirror schemata
* `FormalSystem.ProofSystem.Derivable`
* `FormalSystem.ProofSystem.Derivation` -- `DerivationTree`, 7 inference rules

### MinusLanguage

A **second object language**, tense-primitive (`H`/`G` are constructors rather than
abbreviations), with its own axioms and proof system, related to the primary language by a
translation. It is the language in which the source paper states TM.

* `FormalSystem.MinusLanguage.Formula` -- `MinusFormula`
* `FormalSystem.MinusLanguage.Axioms` -- a second `inductive Axiom`
* `FormalSystem.MinusLanguage.Derivation` -- the mirror proof system
* `FormalSystem.MinusLanguage.Translation` -- `tr : MinusFormula → Formula`
* `FormalSystem.MinusLanguage.AxiomDischarge`

The base language's **semantics** deliberately does not live here, so that the directory's
`MinusLanguage/ → Semantics/` invariant stays literally true: see
`FormalSystem.MinusLanguage.MinusTruth`, `FormalSystem.MinusLanguage.MinusValidity` and
`FormalSystem.MinusLanguage.Soundness` below.

### Semantics
* `FormalSystem.Semantics.TaskFrame`
* `FormalSystem.Semantics.PartialHistory`
* `FormalSystem.Semantics.TaskModel`
* `FormalSystem.Semantics.Truth`
* `FormalSystem.MinusLanguage.MinusTruth` -- `MinusTruthAt`, the native base-language truth recursion
* `FormalSystem.Semantics.Validity`
* `FormalSystem.MinusLanguage.MinusValidity` -- the base-language validity predicates
* `FormalSystem.Semantics.Extension` -- the Extension Theorem: every partial history
  extends to a total one

### Metalogic
* `FormalSystem.Metalogic.Soundness`
* `FormalSystem.MinusLanguage.Soundness` -- BL soundness at Base/Dense/ZTime/RTime,
  by composition, plus the truth-transfer bridge `truthAt_tr`
* `FormalSystem.Metalogic.SoundnessLemmas`
* `FormalSystem.Theorems.DeductionTheorem`
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
