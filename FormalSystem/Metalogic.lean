/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

-- Re-export commonly used modules for convenience
import FormalSystem.Metalogic.Soundness
import FormalSystem.Metalogic.StrongCompleteness
import FormalSystem.Metalogic.DiscreteNonCompactness
import FormalSystem.Metalogic.Decidability
import FormalSystem.Metalogic.Independence
import FormalSystem.Metalogic.BXCanonical
import FormalSystem.Metalogic.WeakCanonical
import FormalSystem.Metalogic.Conservativity
import FormalSystem.Metalogic.Algebraic

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

## Conservativity (proof-theoretic, no semantics)

- **Backward TM/TM⁺ bridge** (`Conservativity.translate`, `derivable_translate`, and the four
  row corollaries `ceb_backward` / `cef_backward` / `ced_backward` / `cec_backward`):
  SORRY-FREE (axioms: exactly `propext`, `Classical.choice`, `Quot.sound`). `TM ⊢ φ ⟹
  TM⁺ ⊢ tr φ` over the tense-primitive base language of `FormalSystem/BaseLanguage/`. The
  **forward** direction is refuted for the Base and Discrete rows and open for the other two;
  `Metalogic/Conservativity.lean`'s module docstring is the standing record of why it must not
  be attempted or `sorry`-ed.

## Publication-Ready Results

- **Soundness** (`soundness`): SORRY-FREE
- **Soundness (dense)** (`soundness_dense`): SORRY-FREE
- **Soundness (discrete)** (`soundness_discrete`): SORRY-FREE
- **Completeness** (`completeness`): SORRY-FREE (sorryAx-free; axioms: exactly `propext`,
  `Classical.choice`, `Quot.sound`). Its Base-frame discrete branch,
  `WeakCanonical.countermodel_discrete`, is proved in
  `WeakCanonical/GroupModel/CountermodelBase.lean` at the non-Archimedean discrete carrier
  `ℚ ×ₗ ℤ`, off `companionChronicle`
- **Completeness (dense)** (`completeness_dense`): SORRY-FREE (sorryAx-free; axioms: exactly
  `propext`, `Classical.choice`, `Quot.sound`)
- **Completeness (discrete)** (`completeness_discrete`): SORRY-FREE (sorryAx-free; axioms:
  exactly `propext`, `Classical.choice`, `Quot.sound`)
- **Completeness (Dedekind)** (`completeness_dedekind`): SORRY-FREE (sorryAx-free; axioms:
  exactly `propext`, `Classical.choice`, `Quot.sound`). Weak completeness for
  `FrameClass.Dedekind` against `ValidDedekindDense`, on the real line. It is a corollary of
  the consequence form below, not an independent construction.
- **Consequence completeness (Dedekind)** (`consequence_completeness_dedekind`): SORRY-FREE
  (sorryAx-free; axioms: exactly `propext`, `Classical.choice`, `Quot.sound`). Finite-context
  consequence completeness. This is **not** strong completeness: `Context` is `List Formula`,
  so it is inter-derivable with the weak form through the deduction theorem — see the module
  docstring of `StrongCompleteness.lean`. The finite-context consequence form now exists for
  **all four** frame classes; the three siblings follow.
- **Consequence completeness (base)** (`consequence_completeness_base`): SORRY-FREE
  (sorryAx-free; axioms: exactly `propext`, `Classical.choice`, `Quot.sound`). Stated against
  the existing general `SemanticConsequence` relation (`Semantics/Validity.lean`) rather than a
  new one, because for `FrameClass.Base` "all carriers" *is* the class. Its soundness guard is
  `soundness_base_consequence` and its weak corollary `completeness_base`, both at the same
  axiom set.
- **Consequence completeness (dense)** (`consequence_completeness_dense`): SORRY-FREE
  (sorryAx-free; axioms: exactly `propext`, `Classical.choice`, `Quot.sound`). Stated against
  `SemanticConsequenceDense`, with guard `soundness_dense_consequence` and weak corollary
  `completeness_dense`, both at the same axiom set.
- **Consequence completeness (discrete)** (`consequence_completeness_discrete`): SORRY-FREE
  (sorryAx-free; axioms: exactly `propext`, `Classical.choice`, `Quot.sound`). Stated against
  `SemanticConsequenceDiscrete`, with guard `soundness_discrete_consequence` and weak corollary
  `completeness_discrete`, both at the same axiom set.

  **Terminology caveat, binding on all four entries above.** `Context` is `List Formula`, so
  every one of these is a *finite*-context result, inter-derivable with the corresponding weak
  form through the deduction theorem. None of them is **strong completeness**, which is reserved
  for consequence from a possibly-infinite `Γ : Set Formula` under a finitary set-derivability
  relation. The infinitary statement has **three distinct statuses** across the four classes,
  which must not be collapsed into one:

  * `FrameClass.Discrete` — **machine-refuted**. `discrete_consequence_not_compact` and
    `strongCompletenessDiscrete_refuted` (entry below) settle it negatively.
  * `FrameClass.Base` and `FrameClass.Dense` — **open**. Neither proved nor refuted;
    `CompactBase`/`CompactDense` and `StrongCompletenessBase`/`StrongCompletenessDense`
    (`Metalogic/SetConsequence.lean`) name the obligations, and
    `strongCompletenessBase_of_compact`/`strongCompletenessDense_of_compact` reduce each to its
    compactness hypothesis alone.
  * `FrameClass.Dedekind` — **unavailable on the primary source's own terms**. Reynolds 1992
    Theorem 7 is weak-only, and this tree contains no `CompactDedekind` definition and no
    refuting theorem, so the class is *unproved* rather than refuted.
- **Non-compactness (discrete)** (`discrete_consequence_not_compact`): SORRY-FREE (sorryAx-free;
  axioms: exactly `propext`, `Classical.choice`, `Quot.sound`). The `FrameClass.Discrete`
  set-based consequence relation is **not** compact: the premise set `{F p} ∪ {¬Xⁿ p : n ∈ ℕ}`
  is finitely satisfiable over `ℤ` yet has no model on any Archimedean discrete carrier. The
  companion `strongCompletenessDiscrete_refuted` (same axiom set) converts this into an outright
  refutation of strong completeness for the class, which is why only the weak form
  (`completeness_discrete`) appears above.
- **Decidability** (`decide`): SORRY-FREE

## Completeness Architecture

The completeness proof uses a three-way case split based on MCS membership:

1. **Dense case** (Box(F'T) in M): Countermodel on Rat via Cantor isomorphism
   (Chronicle/ChronicleToCountermodel.lean, Algebraic/FlowFrame.lean)
2. **Discrete case** (Box(U(T,bot)) in M): Countermodel on Int
   (WeakCanonical/Transfer.lean)
3. **Mixed case**: Eliminated by `mcs_mixed_case_absurd`

The `FrameClass.Dedekind` route has no case split. `Dense <= Dedekind`, so
`Axiom.dense_indicator` is admissible in a Dedekind derivation and `dedekind_box_dense_mem`
(`BXCanonical/CompletenessDedekind.lean`) puts `Box(F'T)` in every Dedekind-MCS
unconditionally: only the dense branch exists. Its countermodel is on the **reals**
(`countermodel_dedekind_dense`), obtained by pushing the rational chronicle through Doets'
theorem (Reynolds 1992, Section 8 Theorem 6) at the chronicle bridge and reading the resulting
`R`-flowed monadic structure back as a `TaskFrame R`.

### Key Components

- **Algebraic/FlowFrame**: generic flow frame, four-axiom conformance, and the D-generic re-hosted truth lemma (core of countermodel)
- **BXCanonical/Chronicle/**: Burgess 1982 chronicle construction for dense case
- **WeakCanonical/**: Reynolds/Doets pipeline for discrete case
- **WeakCanonical/DenseModelSurgery/**, **WeakCanonical/RealModel/**: Reynolds Sections 6-8
  (Theorems 4, 5 and Doets' Theorem 6), the Dedekind route's model surgery and real-flow layer
- **BXCanonical/CompletenessDedekind.lean**: Reynolds Section 9 Theorem 7 — the real-line
  countermodel and the single-formula completeness engine
- **StrongCompleteness.lean**: the per-class finite-context consequence layer — for each of
  Base, Dense, Discrete and Dedekind a semantic deduction theorem, a consequence terminus, a
  soundness guard and a weak corollary — including the Dedekind terminus
  (`consequence_completeness_dedekind`, `completeness_dedekind`); plus the strong-completeness
  programme, the two compactness reductions `strongCompletenessBase_of_compact` and
  `strongCompletenessDense_of_compact` (each keeping its single-formula `engine` hypothesis
  live so that compactness is isolated as the whole remaining obligation), and the
  non-compactness obstruction that bounds the Discrete class
- **SetConsequence.lean**: the `Γ : Set Formula` vocabulary the strong-completeness statements
  are phrased in — `SetDerivable`, the four per-class set consequence relations, and the
  `Prop`-valued names for the open Base and Dense obligations (`StrongCompletenessBase`,
  `CompactBase`, `SatisfiableBaseSet`, `ModelExistenceBase` and their Dense siblings) together
  with the refuted Discrete ones
- **DiscreteNonCompactness.lean**: the machine-checked discharge of one of those obstructions —
  the `{F p} ∪ {¬Xⁿ p}` witness, the first semantic characterisation of `Formula.next`
  (`truthAt_next_iff`), and the two refutations `discrete_consequence_not_compact` and
  `strongCompletenessDiscrete_refuted`
- **Bundle/**: BFMCS infrastructure (shared by all paths)

## Axiom Dependencies

Soundness, decidability, and the completeness theorems (`completeness_dense`,
`completeness_discrete`, `completeness_dedekind`, `consequence_completeness_dedekind`) all use
standard Lean axioms only: `propext`, `Classical.choice`, `Quot.sound`. The former `Lean.ofReduceBool`/`Lean.trustCompiler` dependency was eliminated
by swapping the Syntax-layer `native_decide` sites to `rfl`/`decide` (see the Axiom Audit
in `BXCanonical/Completeness.lean`). No `sorryAx` on any of these paths. The general
Base-frame `completeness` is now on the same footing: its discrete branch
`WeakCanonical.countermodel_discrete` is proved
(`WeakCanonical/GroupModel/CountermodelBase.lean`), so `completeness` too depends on exactly
those three axioms.

## Module Structure

Every subdirectory carries exactly one sibling aggregator `X.lean` beside `X/`.
File and line counts exclude BOTH Boneyards (there are two -- see
`Metalogic/README.md`); run `scripts/check-module-invariants.sh` to re-derive them.

```
Metalogic/
├── Core/                    4 files   # MCS theory, Lindenbaum, deduction theorem
├── Bundle/                 12 files   # BFMCS canonical-frame construction
├── Algebraic/               5 files   # Quotient algebra + flow-frame countermodel engine
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
