/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.BiLasso.Basic

/-!
# `PlacedBiLasso` — a Bi-Lasso Anchored at an Arbitrary Absolute Time

`BiLasso.unrollOf` pins the `mid` segment to the times `[0, |mid|)`. That is the right convention
for the structure itself — it is what makes `coherent` a single contiguous `Fin`-indexed window —
but it means a `BiLasso` alone cannot represent a bounded history observed at, say, the times
`[-7, -3]`: everything strictly left of `0` is already spoken for by the periodic `back` segment.

A model checker does not get to choose the absolute times at which its search finds a window. So
this module adds the missing degree of freedom **additively**, over a `Basic.lean` that is held
byte-stable for the concurrent bi-lasso decision-layer work: a `PlacedBiLasso` is a `BiLasso`
together with an `origin : ℤ`, and its decoding is the underlying decoding shifted so that lasso
time `0` sits at absolute time `origin`.

## Why not re-normalize the origin to zero instead

Rotating `back` / `mid` / `fwd` so that the window starts at `0` is possible but strictly worse:
it is a seam-and-wrap-around exercise with no compensating benefit, and it forces the *producer*
of a certificate to do that rotation, when the producer is exactly the component that knows the
window only at whatever absolute times its search happened to use. Shifting the decoding is one
subtraction and makes shift-invariance a three-line lemma.

## Main Definitions

- `PlacedBiLasso` — a `BiLasso` together with the absolute time of its lasso-time origin
- `PlacedBiLasso.unroll` — the decoding, re-based at `origin`
- `PlacedBiLasso.toHF` — the decoded path as an element of `H_F`

## Main Results

- `isStepPath_shift` — a time-shift of a bi-infinite step path is a bi-infinite step path
- `PlacedBiLasso.unroll_isStepPath` — the re-based decoding is a step path of the presented frame
- `PlacedBiLasso.unroll_sub_back_length` / `PlacedBiLasso.unroll_add_fwd_length` — the two
  periodicities of `Basic.lean`, restated at thresholds measured from `origin`
-/

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.Semantics

/--
**Shift-invariance of step paths.** Translating a bi-infinite step path in time yields a
bi-infinite step path. This is what lets a `BiLasso`, whose decoding is anchored at lasso time
`0`, be re-based at an arbitrary absolute time without re-doing any adjacency reasoning.
-/
theorem isStepPath_shift {F : ParamTaskFrame ℤ} {f : ℤ → F.WorldState} (h : IsStepPath F f) (k : ℤ) :
    IsStepPath F (fun t => f (t - k)) := by
  intro n
  have := h (n - k)
  simpa [show n + 1 - k = (n - k) + 1 by omega] using this

/--
A **placed bi-lasso**: a `BiLasso` together with the absolute time at which its lasso-time origin
sits. This is the certificate a model checker emits — three finite lists plus one integer.
-/
structure PlacedBiLasso (P : IntPresentation) where
  /-- The underlying bi-lasso, anchored at lasso time `0`. -/
  lasso : BiLasso P
  /-- The absolute time of lasso time `0`. -/
  origin : ℤ

namespace PlacedBiLasso

variable {P : IntPresentation}

/-- The decoding, re-based at the origin: absolute time `origin` decodes to lasso time `0`. -/
def unroll (L : PlacedBiLasso P) (t : ℤ) : Fin P.card := L.lasso.unroll (t - L.origin)

theorem unroll_def (L : PlacedBiLasso P) (t : ℤ) :
    L.unroll t = L.lasso.unroll (t - L.origin) := rfl

/-- **The re-based decoding is a step path of the presented frame.** -/
theorem unroll_isStepPath (L : PlacedBiLasso P) : IsStepPath P.toFibre L.unroll :=
  isStepPath_shift L.lasso.unroll_isStepPath L.origin

/-- The decoded path as an element of `H_F` — the form `TruthAt` consumes. -/
def toHF (L : PlacedBiLasso P) : TaskFrame.HF P.toTaskFrame :=
  FrameOver.HFofStepPath P.toFibre L.unroll L.unroll_isStepPath

@[simp]
theorem toHF_path (L : PlacedBiLasso P) : L.toHF.path = L.unroll := rfl

/-- **Leftward periodicity, at the offset.** Strictly left of the origin the re-based decoding has
period `|back|`. -/
theorem unroll_sub_back_length (L : PlacedBiLasso P) {t : ℤ} (ht : t < L.origin) :
    L.unroll (t - (L.lasso.back.length : ℤ)) = L.unroll t := by
  rw [unroll_def, unroll_def,
    show t - (L.lasso.back.length : ℤ) - L.origin = (t - L.origin) - (L.lasso.back.length : ℤ) by
      omega]
  exact L.lasso.unroll_sub_back_length (by omega)

/-- **Rightward periodicity, at the offset.** At or past `origin + |mid|` the re-based decoding has
period `|fwd|`. -/
theorem unroll_add_fwd_length (L : PlacedBiLasso P) {t : ℤ}
    (ht : L.origin + (L.lasso.mid.length : ℤ) ≤ t) :
    L.unroll (t + (L.lasso.fwd.length : ℤ)) = L.unroll t := by
  rw [unroll_def, unroll_def,
    show t + (L.lasso.fwd.length : ℤ) - L.origin = (t - L.origin) + (L.lasso.fwd.length : ℤ) by
      omega]
  exact L.lasso.unroll_add_fwd_length (by omega)

/-- The window of a placed bi-lasso reads its `mid` segment directly. -/
theorem unroll_mid (L : PlacedBiLasso P) {t : ℤ} (h0 : L.origin ≤ t)
    (ht : t < L.origin + (L.lasso.mid.length : ℤ)) :
    L.unroll t = L.lasso.mid.getD (t - L.origin).toNat default := by
  have h1 : ¬ (t - L.origin < 0) := by omega
  have h2 : t - L.origin < (L.lasso.mid.length : ℤ) := by omega
  simp [unroll_def, BiLasso.unroll, BiLasso.unrollOf, h1, h2]

end PlacedBiLasso

end FormalSystem.Metalogic.Decidability
