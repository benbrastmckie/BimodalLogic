/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.WitnessFamily.Closure
import FormalSystem.Metalogic.Decidability.WitnessFamily.Basic
import FormalSystem.Metalogic.Decidability.WitnessFamily.Predicates
import FormalSystem.Metalogic.Decidability.WitnessFamily.Std
import FormalSystem.Metalogic.Decidability.WitnessFamily.Agreement
import FormalSystem.Metalogic.Decidability.WitnessFamily.Decide
import FormalSystem.Metalogic.Decidability.WitnessFamily.Examples

/-!
# FormalSystem.Metalogic.Decidability.WitnessFamily — Certificates for ℤ-Time Refutation

A **witness family** is the finite object a model checker returns when it refutes a ℤ-time
consequence `Γ ⊨ σ`: a box guess together with a non-empty list of labelled bi-lassos. This layer
supplies the datatype, the four conditions that make such an object a certificate, the model it
presents, the theorem that its labels **are** truth in that model, and decision procedures for
all four conditions.

## What this layer proves, and what it does not

Given a family satisfying `LocalCoherentLab`, `FulfillingLab` and `BoxFaithful` with a `Target`
at some time, `Agreement.lean` produces an explicit ℤ-time frame, model, world history and time
at which every premise of `Γ` is true and every conclusion of `Δ` is false. That is the
**soundness** half of the certificate format, and it is unconditional.

The **completeness** half — that every ℤ-time countermodel compresses to such a family — is not
here, and neither is the `Decidable (ValidZTime φ)` assembly that would follow from it. Those
belong to the compression work, and nothing in this directory presupposes them.

## Presentation-free, unlike `BiLasso/`

`BiLasso/`'s `Annot P φ` labels the positions of a path *through an `IntPresentation`*. Here
there is no presentation: the labels are the object, and the presented model's valuation is read
off their atom part. `Probe476.fmp_false` rules out finite `IntPresentation`s as the searched
object and `BiLasso/Agreement.lean`'s three limits rule out bare windows, so the labelled family
is what is left. The only dependency on `BiLasso/` is `Periodic.lean`, which is deliberately
directory-independent.

## Submodules

- `Closure`: `closureOf`, the set-level subformula closure a context-indexed certificate needs,
  with the seven projections the agreement induction consumes
- `Basic`: `LabelledLasso` — `back`, `mid`, `fwd` label segments decoded by `Periodic.unrollOf` —
  and `WitnessFamily`, a box guess plus a non-empty list of them. Field names are the model
  checker's JSON export contract
- `Predicates`: `LocalCoherentLab`, `FulfillingLab`, `BoxFaithful` and `Target`, with the
  clause-by-clause correspondence to `BiLasso/Annotation.lean`'s `LocalCoherent` and `Fulfilling`
- `Std`: `WitnessFamily.std`, the presented `ShiftSet intOrder`, with `std_isZTime`,
  `std_sat_ztime` and `std_sat_base`
- `Agreement`: `shiftTruth_iff_mem` and `truth_iff_mem` (**T1**), and the three consequence
  corollaries `not_consequence_ztime`, `not_consequence_base` and `joint_countermodel` (**T1'**)
- `Decide`: the window collapses and the four named instances `decidableLocalCoherentLab`,
  `decidableFulfillingLab`, `decidableBoxFaithful` and `decidableTarget` (**T2**)
- `Examples`: the non-vacuity witness `posFamily`, the separation witness `sepFamily`, and the
  impossibility theorems `no_witnessFamily_of_validZTime` and `no_witnessFamily_of_MF` (**T3**)

## `BiLasso/Basic.lean` is untouched

`BiLasso/Basic.lean` is held stable for the concurrent effective-periodic-extension work, and
nothing in this directory modifies it or `BiLasso/Decide.lean`. The arithmetic duplication that
results is recorded in `Basic.lean` and `Decide.lean` here, each with the same named retirement
trigger, rather than refactored away.
-/
