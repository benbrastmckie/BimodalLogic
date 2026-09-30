/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.Basic
import FormalSystem.Semantics.SlicedFrame
import FormalSystem.PlusLanguage.PlusTruth

/-!
# The Frame a Time-Sliced Certificate Presents

`G.frame h` is `FrameOver.ofSlicedStep` at the certificate's own decoded edge relation, on the
carrier `ℤ × Fin G.n`. `G.model h` values an atom at `(t, w)` by its membership in `G.slab t w`.

## What is cashed out here

The carrier is **infinite with finite fibres**, not finite. That is the amendment this subtree
exists for, and it is not a matter of taste: there is a `⊡`-free ℤ-time non-validity that **no**
`FrameOver.ofStep` frame satisfies, so a certificate presenting a finite-carrier frame cannot
certify it, while the landed `Formula`-side witness family already does.
`FrameOver.ofSlicedStep` is therefore not a convenience over `FrameOver.ofStep`; it is the only
available route.

`ofSlicedStep_not_finite_worldState` proves the carrier is not finite rather than asserting it,
and `frame_worldState_not_finite` restates that at `G.frame h`.

## Every history is an *offset* step path, and that is what keeps the position space finite

`mem_HF_iff_slicedPath` is `FrameOver.ofSlicedStep_mem_HF_iff` at `G`, in both directions: a
history of `G.frame h` is exactly a pair of an offset `k` and a state sequence following `G.edge`
at the shifted slice times. `plusTruthAt_shiftBack` then normalizes the offset away —
`plusTruthAt_timeShift` (`PlusLanguage/PlusTruth.lean`) lets every truth question be asked at a
history that occupies slice `t` at time `t` — and `timeShift_offset_zero` is the companion fact
that the shifted history really does have offset `0`.

Together those two are what later phases cite for "a position is `(t, w)`, with `t` the slice time
and no separate origin". There is nothing to align: the slice time is the only time.

## Main definitions

- `PlusSlicedCertificate.stepRel` — the decoded edge relation, `Prop`-valued
- `PlusSlicedCertificate.frame` — the presented frame, on `ℤ × Fin G.n`
- `PlusSlicedCertificate.model` — the presented model, valuing atoms by the slice labelling
- `PlusSlicedCertificate.pathHistory` — the history of a `PlusGraphPath` following `G.edge`
- `PlusSlicedCertificate.mem_HF_iff_slicedPath` — the history space, in both directions
- `PlusSlicedCertificate.plusTruthAt_shiftBack` — shift-normalization

## Tags

plus-language · certificate · time-sliced · frame · infinite-carrier
-/

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.PlusLanguage
open FormalSystem.Semantics

namespace PlusSlicedCertificate

variable {Γ Del : PlusContext}

/-! ## The decoded edge relation, and its two seriality obligations -/

/--
`G.n` is nonzero, as an instance, so that `Nonempty (Fin G.n)` and `Finite (Fin G.n)` are found by
synthesis at every later site rather than threaded by hand. This is what lets `G.frame h` be a
bare `FrameOver.ofSlicedStep` application whose instance arguments reproduce at every call.
-/
instance instNeZeroN (G : PlusSlicedCertificate Γ Del) : NeZero G.n :=
  ⟨by have := G.n_pos; omega⟩

/-- The decoded edge relation, as a `Prop`-valued time-indexed relation: the shape
`FrameOver.ofSlicedStep` consumes. -/
def stepRel (G : PlusSlicedCertificate Γ Del) (t : ℤ) (w u : Fin G.n) : Prop :=
  G.edge t w u = true

/-- Forward seriality of the decoded edge relation, from bi-seriality at the slice. -/
theorem stepRel_fwd (G : PlusSlicedCertificate Γ Del) (h : G.BiSerial) :
    ∀ (t : ℤ) (w : Fin G.n), ∃ u, G.stepRel t w u :=
  fun t w => (h t).1 w

/-- Backward seriality of the decoded edge relation, from bi-seriality at the previous slice. -/
theorem stepRel_bwd (G : PlusSlicedCertificate Γ Del) (h : G.BiSerial) :
    ∀ (t : ℤ) (w : Fin G.n), ∃ v, G.stepRel (t - 1) v w :=
  fun t w => (h (t - 1)).2 w

/-! ## The presented frame -/

/--
**The presented frame**, on the carrier `ℤ × Fin G.n`.

`FrameOver.ofSlicedStep` at the decoded edge relation, with both seriality obligations discharged
from `h : G.BiSerial`. Nothing else is asked of the certificate: *Compositionality*, the reflection
law, *Limit* and *Saturation* are the generic module's named lemmas.
-/
def frame (G : PlusSlicedCertificate Γ Del) (h : G.BiSerial) : FrameOver intOrder :=
  FrameOver.ofSlicedStep G.stepRel (G.stepRel_fwd h) (G.stepRel_bwd h)

/-- The frame's carrier is `ℤ × Fin G.n`, on the nose. -/
theorem frame_worldState_eq (G : PlusSlicedCertificate Γ Del) (h : G.BiSerial) :
    (G.frame h).WorldState = (ℤ × Fin G.n) := rfl

/-- **The presented frame is regular.** -/
instance instIsRegular (G : PlusSlicedCertificate Γ Del) (h : G.BiSerial) :
    (G.frame h).IsRegular :=
  FrameOver.ofSlicedStep_isRegular _ _ _

/-- Regularity at the total space as well as at the fibre: instance synthesis does not project
through `FrameOver.toTaskFrame` on its own. -/
instance instIsRegularTask (G : PlusSlicedCertificate Γ Del) (h : G.BiSerial) :
    (G.frame h).toTaskFrame.IsRegular :=
  G.instIsRegular h

/--
**The presented frame's carrier is not finite**, and that is proved rather than asserted. It is
the whole reason this subtree does not present its frame through `FrameOver.ofStep`; see the module
header and `Probe706.no_ofStep_sat`.
-/
theorem frame_worldState_not_finite (G : PlusSlicedCertificate Γ Del) (h : G.BiSerial) :
    ¬ Finite (G.frame h).WorldState :=
  FrameOver.ofSlicedStep_not_finite_worldState _ _ _

/-- The frame's one-step relation advances the slice by one and follows `G.edge`. -/
theorem frame_step (G : PlusSlicedCertificate Γ Del) (h : G.BiSerial) (p q : ℤ × Fin G.n) :
    (G.frame h).step p q ↔ q.1 = p.1 + 1 ∧ G.edge p.1 p.2 q.2 = true :=
  FrameOver.ofSlicedStep_step G.stepRel (G.stepRel_fwd h) (G.stepRel_bwd h) p q

/-! ## The presented model -/

/--
**The presented model.** An atom is true at `(t, w)` exactly when it is in the slice labelling
`G.slab t w`.

The labelling is per slice, so the valuation is a function of the carrier element and nothing else
— which is what makes it well defined on an infinite carrier with no choice and no alignment.
-/
def model (G : PlusSlicedCertificate Γ Del) (h : G.BiSerial) :
    TaskModel (G.frame h).toTaskFrame where
  valuation := fun p a =>
    PlusFormula.atom a ∈ G.slab (show ℤ × Fin G.n from p).1 (show ℤ × Fin G.n from p).2

@[simp]
theorem model_valuation (G : PlusSlicedCertificate Γ Del) (h : G.BiSerial)
    (p : ℤ × Fin G.n) (a : FormalSystem.Syntax.Atom) :
    (G.model h).valuation p a ↔ PlusFormula.atom a ∈ G.slab p.1 p.2 := Iff.rfl

/-! ## The history space -/

/--
**The history space of the presented frame is exactly the set of offset step paths.**

Both directions, by `FrameOver.ofSlicedStep_mem_HF_iff` at `G`: Phase 18's soundness proof needs
`←` (it builds a history from the target path) and Phase 19's completeness proof needs `→` (it has
an arbitrary history and must read it as a labelled path).
-/
theorem mem_HF_iff_slicedPath (G : PlusSlicedCertificate Γ Del) (h : G.BiSerial)
    (f : ℤ → ℤ × Fin G.n) :
    (∃ τ : WorldHistory (G.frame h), τ.path = f) ↔
      ∃ (k : ℤ) (g : ℤ → Fin G.n),
        (∀ t : ℤ, G.edge (t + k) (g t) (g (t + 1)) = true) ∧ f = fun t => (t + k, g t) :=
  FrameOver.ofSlicedStep_mem_HF_iff G.stepRel (G.stepRel_fwd h) (G.stepRel_bwd h) f

/--
**The history of a labelled path.** A `PlusGraphPath` whose state sequence follows `G.edge` at
every time is an offset-zero step path, hence a history of the presented frame.
-/
def pathHistory (G : PlusSlicedCertificate Γ Del) (h : G.BiSerial)
    (P : PlusGraphPath G.n (plusClosureOf (Γ ++ Del)))
    (hP : ∀ t : ℤ, G.edge t (P.st t) (P.st (t + 1)) = true) :
    WorldHistory (G.frame h) :=
  FrameOver.worldHistoryOfStepPath (G.frame h) (fun t => ((t, P.st t) : ℤ × Fin G.n))
    (fun n => (G.frame_step h _ _).mpr ⟨rfl, hP n⟩)

@[simp]
theorem pathHistory_path (G : PlusSlicedCertificate Γ Del) (h : G.BiSerial)
    (P : PlusGraphPath G.n (plusClosureOf (Γ ++ Del)))
    (hP : ∀ t : ℤ, G.edge t (P.st t) (P.st (t + 1)) = true) (t : ℤ) :
    (G.pathHistory h P hP).state t = ((t, P.st t) : ℤ × Fin G.n) := rfl

/-! ## Shift-normalization: the offset can always be moved to `0`

The two lemmas later phases cite for "a position is `(t, w)`, with `t` the slice time and no
separate origin carried". The first moves the offset into the time argument; the second says the
shifted history really has offset `0`. Together they keep the position space finite per slice.
-/

/--
**Shift-normalization.** Every truth question on `G.frame h` can be asked at a time-shifted
history, by `plusTruthAt_timeShift`. Taking `k` to be the asking history's own offset moves that
offset to `0`, which is what `timeShift_offset_zero` then records.
-/
theorem plusTruthAt_shiftBack (G : PlusSlicedCertificate Γ Del) (h : G.BiSerial)
    (τ : WorldHistory (G.frame h).toTaskFrame) (φ : PlusFormula) (t k : ℤ) :
    PlusTruthAt (G.model h) τ t φ ↔ PlusTruthAt (G.model h) (τ.timeShift (-k)) (t + k) φ := by
  simpa using (plusTruthAt_timeShift (G.model h) φ τ (t + k) (-k)).symm

/--
**The shifted history has offset `0`**: it occupies slice `t` at time `t`. Stated for a history
whose offset is `k`, which `mem_HF_iff_slicedPath` always supplies.
-/
theorem timeShift_offset_zero (G : PlusSlicedCertificate Γ Del) (h : G.BiSerial)
    (τ : WorldHistory (G.frame h).toTaskFrame) (k : ℤ)
    (hk : ∀ t : ℤ, (show ℤ × Fin G.n from τ.state t).1 = t + k) (t : ℤ) :
    (show ℤ × Fin G.n from (τ.timeShift (-k)).state t).1 = t := by
  have h1 : (τ.timeShift (-k)).state t = τ.state (t + -k) := rfl
  have h2 := hk (t + -k)
  rw [show (show ℤ × Fin G.n from (τ.timeShift (-k)).state t)
      = (show ℤ × Fin G.n from τ.state (t + -k)) from by rw [h1]]
  omega

end PlusSlicedCertificate

end FormalSystem.Metalogic.Decidability
