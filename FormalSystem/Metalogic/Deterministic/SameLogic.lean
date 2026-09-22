/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.ShiftSet
import FormalSystem.Metalogic.Deterministic.Validity

/-!
# The deterministic task frames determine the same logic as all task frames

`validIn_iff_validDetIn`: for every frame class `fc` and every `L` formula `φ`,
`ValidIn fc φ ↔ ValidDetIn fc φ`. Restricting validity to the deterministic frames
(`def:deterministic`, `app:deterministic`) changes nothing about which formulas are valid, at any
of the four classes. The class-generic statement underneath, `validOnFrames_iff_deterministic`,
holds for *any* frame predicate stable under the shift-set construction, and the paper's
unbundled sentence at `.Base` is `valid_iff_valid_deterministic`.

## The argument

The shift-set representation in `Semantics/ShiftSet.lean` is a round trip between models and
shift sets: `ShiftSet.reverse_repr` says truth in a model `M` over `F` at `(τ, t)` is shift-set
truth in `ShiftSet.ofModel F M` at `(τ, t)`, and `ShiftSet.forward_repr` says shift-set truth in
`S` is truth in `S.model` over `S.frame` at `(S.hist w, t)`. Composed, every point `(F, M, τ, t)`
is matched by a point `((ofModel F M).frame, (ofModel F M).model, hist τ, t)` that agrees with it
on every formula. That composition alone does not give the theorem: it needs the third fact that
the matched frame is **deterministic**, which is `ShiftSet.frame_deterministic` — the task relation
of a shift set's frame is the graph of the shift map, so every fibre is a subsingleton. That
helper is declared here, beside its consumer, rather than in `ShiftSet.lean`; it may later move
next to `reverse_repr` without renaming.

## Why this route, when a completeness detour already exists

`Engines.lean` proves `derivable_of_validDet fc φ : ValidDetIn fc φ → Derivable fc [] φ`, and TM
soundness turns derivability back into `ValidIn fc φ`; so at the four tagged classes the same
biconditional is already *derivable* by going through the proof system. The theorem here is the
deliverable anyway, for three reasons. It is semantic and per-model: each `(F, M, τ, t)` is
matched by a deterministic `(F', M', τ', t)` agreeing on every formula, which is strictly more
than equality of validity sets. It does not route through Lindenbaum or canonical models, so it
is an independent check on the engines' narrowing. And its general form
`validOnFrames_iff_deterministic` covers *every* frame predicate stable under `ShiftSet.ofModel`
(the four tags, but also `TaskFrame.IsComplete`, `TaskFrame.IsQTime`, and their conjunctions),
not only the classes for which a completeness engine exists.

## What is not claimed

No `L⁺` corollary. `⊡`-erasure is truth-preserving only on deterministic frames
(`Erasure.lean`), so restricting `PlusValidIn` to the deterministic frames genuinely changes the
valid set — that is the content of `Metalogic/Deterministic/` — and no analogue of
`validIn_iff_validDetIn` for `PlusFormula` is stated here.
-/

namespace FormalSystem.Semantics

open FormalSystem.Syntax

/--
**A shift set's frame is deterministic.** Its task relation is `u = S.sh w d`, the graph of the
shift map (`ShiftSet.fibre_taskRel`), so every fibre is a subsingleton and `def:deterministic`
holds.

This is the fact the pure composition `reverse_repr ∘ forward_repr` was missing: the round trip
matches every model point with a shift-set model point, and this lemma says the matching frame
lies in the deterministic class. Declared here beside its consumer; it may later relocate beside
`reverse_repr` in `ShiftSet.lean` without renaming.
-/
theorem ShiftSet.frame_deterministic {D : TemporalOrder} (S : ShiftSet D) :
    S.frame.Deterministic :=
  fun w d => TaskFrame.fib_subsingleton_of_functional (f := S.sh)
    (fun w d u => S.fibre_taskRel w d u) w d

end FormalSystem.Semantics

namespace FormalSystem.Metalogic.Deterministic

open FormalSystem.Syntax FormalSystem.Semantics
open FormalSystem.ProofSystem (FrameClass)

/--
**Validity over `P` equals validity over the deterministic members of `P`**, for any frame
predicate `P` stable under the shift-set construction.

The (⇒) direction is monotonicity. For (⇐), a point `(F, M, τ, t)` with `P F` is transported to
`((ofModel F M).frame, (ofModel F M).model, hist τ, t)`, which satisfies `P` by `hP` and is
deterministic by `ShiftSet.frame_deterministic`; `forward_repr` and `reverse_repr` carry the
truth of `φ` back. The stability hypothesis `hP` is what a concrete class has to supply; for
the four `FrameClass` tags it is a case split (`validIn_iff_validDetIn`).
-/
theorem validOnFrames_iff_deterministic {P : TaskFrame → Prop}
    (hP : ∀ (F : TaskFrame) (M : TaskModel F), P F → P (ShiftSet.ofModel F M).frame)
    (φ : Formula) :
    ValidOnFrames P φ ↔ ValidOnFrames (fun F => P F ∧ F.Deterministic) φ := by
  constructor
  · exact ValidOnFrames.mono (fun _ h => h.1)
  · intro h F hF M τ t
    have h3 := h _ ⟨hP F M hF, ShiftSet.frame_deterministic (ShiftSet.ofModel F M)⟩
      (ShiftSet.ofModel F M).model ((ShiftSet.ofModel F M).hist τ) t
    exact (ShiftSet.reverse_repr F M τ t φ).mp
      ((ShiftSet.forward_repr (ShiftSet.ofModel F M) τ t φ).mp h3)

/--
**The deterministic task frames determine the same logic as all task frames, at every class.**
`ValidIn fc φ ↔ ValidDetIn fc φ` for each of the four `FrameClass` tags.

`DetSat fc` is definitionally `fun F => fc.Sat F ∧ F.Deterministic`, so this is
`validOnFrames_iff_deterministic` at `P := fc.Sat`; the stability of each tag under
`ShiftSet.ofModel` is a case split, since the shift-set frame has the same duration group as
`F` and every tag is a condition on the duration group alone.

Paper: `app:deterministic`
-/
theorem validIn_iff_validDetIn (fc : FrameClass) (φ : Formula) :
    ValidIn fc φ ↔ ValidDetIn fc φ :=
  validOnFrames_iff_deterministic (fun F M h => by cases fc <;> exact h) φ

/--
**The same at `.Base`, in the manuscript's unbundled shape**: `φ` is valid iff it is true at
every point of every model over every deterministic task frame.

`Valid φ` is `ValidIn .Base φ`; `validIn_iff_validDetIn` and the `ValidDetIn` binder adapters
do the rest.

Paper: `app:deterministic`
-/
theorem valid_iff_valid_deterministic (φ : Formula) :
    Valid φ ↔ ∀ (F : TaskFrame), F.Deterministic → ∀ (M : TaskModel F)
      (τ : WorldHistory F) (t : F.Duration), TruthAt M τ t φ := by
  rw [Valid, validIn_iff_validDetIn]
  exact ⟨fun h F hD M τ t => h.apply F trivial hD M τ t,
    fun h => ValidDetIn.of_forall fun F _ hD => h F hD⟩

end FormalSystem.Metalogic.Deterministic
