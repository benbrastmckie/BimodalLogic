/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

-- Re-export commonly used modules for convenience
import FormalSystem.Metalogic.Soundness
import FormalSystem.Metalogic.Decidability
import FormalSystem.Metalogic.BXCanonical
import FormalSystem.Metalogic.WeakCanonical

/-!
# Bimodal Metalogic

This module re-exports the metalogical foundations for bimodal logic TM:
soundness, completeness, and decidability.

## Irreflexive Temporal Semantics

Under irreflexive semantics, G and H quantify over strictly future/past
times (s > t and s < t respectively, excluding the current time). Until uses strict
witness (s > t) with open guard (t, s). Since uses strict witness (s < t) with open
guard (s, t).

The modal T-axiom (Box phi -> phi) is valid (S5 universal accessibility), but the
temporal analogs (G phi -> phi, H phi -> phi) are NOT valid under irreflexive semantics.

## Publication-Ready Results

- **Soundness** (`soundness`): SORRY-FREE
- **Soundness (dense)** (`soundness_dense`): SORRY-FREE
- **Soundness (discrete)** (`soundness_discrete`): SORRY-FREE
- **Completeness** (`completeness`): SORRY (sole source: the deprecated Base-frame discrete
  branch `WeakCanonical.countermodel_discrete`; the dense and mixed branches are sorryAx-free
  — see `completeness_discrete` for the sorry-free discrete result)
- **Completeness (dense)** (`completeness_dense`): SORRY-FREE (sorryAx-free; axioms: exactly
  `propext`, `Classical.choice`, `Quot.sound`)
- **Completeness (discrete)** (`completeness_discrete`): SORRY-FREE (sorryAx-free; axioms:
  exactly `propext`, `Classical.choice`, `Quot.sound`)
- **Decidability** (`decide`): SORRY-FREE

## Completeness Architecture

The completeness proof uses a three-way case split based on MCS membership:

1. **Dense case** (Box(F'T) in M): Countermodel on Rat via Cantor isomorphism
   (Chronicle/ChronicleToCountermodel.lean, Algebraic/ParametricCompleteness.lean)
2. **Discrete case** (Box(U(T,bot)) in M): Countermodel on Int
   (WeakCanonical/Transfer.lean)
3. **Mixed case**: Eliminated by `mcs_mixed_case_absurd`

### Key Components

- **Algebraic/ParametricTruthLemma**: D-parametric truth lemma (core of countermodel)
- **BXCanonical/Chronicle/**: Burgess 1982 chronicle construction for dense case
- **WeakCanonical/**: Reynolds/Doets pipeline for discrete case
- **Bundle/**: BFMCS infrastructure (shared by all paths)

## Axiom Dependencies

Soundness, decidability, and the completeness theorems (`completeness_dense`,
`completeness_discrete`) all use standard Lean axioms only: `propext`, `Classical.choice`,
`Quot.sound`. The former `Lean.ofReduceBool`/`Lean.trustCompiler` dependency was eliminated
by swapping the Syntax-layer `native_decide` sites to `rfl`/`decide` (see the Axiom Audit
in `BXCanonical/Completeness.lean`). No `sorryAx` on any of these paths. The general
Base-frame `completeness` still carries `sorryAx` via the deprecated
`WeakCanonical.countermodel_discrete` branch.

## Module Structure

Every subdirectory carries exactly one sibling aggregator `X.lean` beside `X/`.
File and line counts exclude BOTH Boneyards (there are two -- see
`Metalogic/README.md`); run `scripts/check-module-invariants.sh` to re-derive them.

```
Metalogic/
├── Core/                    4 files   # MCS theory, Lindenbaum, deduction theorem
├── Bundle/                 12 files   # BFMCS canonical-frame construction
├── Algebraic/               9 files   # Parametric/algebraic completeness route
├── BXCanonical/            20 files   # Chronicle completeness route -- the wired entry point
│   ├── Chronicle/           8 files   # Burgess chronicle construction
│   ├── Quasimodel/          5 files   # Hintikka points, realization
│   └── Filtration/          1 file    # Sigma ordering
├── WeakCanonical/         135 files   # Kamp/Reynolds route; largest subtree in the repository
│   ├── Kamp/               99 files   # Separation machinery; has its OWN local Boneyard/
│   ├── EFGames/             8 files   # Ehrenfeucht-Fraisse game engine
│   ├── IntegerModel/        6 files   # Integer model construction
│   ├── Expressiveness/      5 files   # Expressiveness separation results
│   └── Separation/          3 files   # Separation theorem
├── Decidability/           19 files   # Tableau decision procedure
│   └── Propositional/       3 files   # Propositional fragment (Kalmar)
├── Soundness.lean                     # Soundness theorem, incl. dense/discrete variants
├── SoundnessLemmas/         3 files   # Per-axiom validity lemmas feeding Soundness.lean
└── {Core,Bundle,Algebraic,BXCanonical,WeakCanonical,Decidability,SoundnessLemmas}.lean
                                       # sibling aggregators
```

`SoundnessLemmas` is a DIRECTORY with a sibling aggregator, not a loose file.
There is no top-level `Completeness.lean`: it had no live importer and is archived
under `Boneyard/SupersededCompleteness/`. The completeness results live on the three
routes above.
-/
