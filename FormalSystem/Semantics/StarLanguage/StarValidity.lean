/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.StarLanguage.StarTruth
import FormalSystem.Semantics.ValidityLayer
import FormalSystem.Semantics.PlusLanguage.PlusValidity

/-!
# L⋆ validity, `sent:det`, and the paper's `(∗)` unfolding chain

Validity for the language L⋆ (`FormalSystem/StarLanguage/Formula.lean`), stated against the
native `StarTruthAt` of `Semantics/StarLanguage/StarTruth.lean`, together with the manuscript's sentence
`sent:det` and the biconditional chain `app:deterministic-future`'s proof opens with.

Each predicate is a binder-for-binder mirror of its L⁺ counterpart in `Semantics/PlusLanguage/PlusValidity.lean`,
with **one new binder**: the stored-time vector. Once `v⃗` is a parameter of the point of
evaluation, `def:frame-validity`'s "true at every model, possible world and time" reads "true at
every model, possible world, time, **and stored-time vector**" — the registers are part of the
point, so validity quantifies them exactly as it quantifies the time.

## Main Definitions

- `TaskFrame.StarValidOn`, `StarValidOnFrames`, `StarValidIn`, `StarValid`
- `sentDet` — `sent:det`, transcribed

## Main Results

- `StarValidOnFrames.mono`, `StarValidIn.mono` — monotonicity
- `StarValidOnFrames.of_forall_total` / `.apply_total` and the `StarValidIn` forms
  (`StarValidIn.of_forall_total` / `.apply_total`) — the binder-shape adapters
- `starValidOn_ofPlus` — L⋆ validity of an embedded L⁺ formula is L⁺ validity
- `sentDet_unfold` — the paper's `(∗)` chain, as one reusable biconditional

## `\Future` is the **universal** future — a plan hypothesis the manuscript superseded

The plan for this module recorded a scope hypothesis that `sent:det`'s `\Future` was the tree's
`someFuture` (`F`, existential). Checking the manuscript's own `sent:det` display and the `(∗)`
chain in `app:deterministic-future`'s proof settles it the other way: `\Future` is defined in the
manuscript preamble as a boxed `F` (`\Box` superimposed with a subscript `f`), the *universal*
future, and the `(∗)` chain reads "**for all** `y > x`" at its `\Future` step. `sentDet` below
therefore uses `StarFormula.allFuture`, and `sentDet_unfold`'s conclusion is a `∀ y, x < y → …`,
matching both the manuscript and the plan's own pinned Challenge statement for
`sentDet_unfold`. The plan's scope-hypothesis line is superseded by exactly the mechanism it
provided for: the definition follows the manuscript.

The register indices are `1` and `2`, as the manuscript displays them
(`\timeStore^1 … \timeStore^2 … \timeRecall^1 … \timeRecall^2`). Register `0` is unused and
stays free for a later world register.

## References

* JPL paper `sent:det`, `app:deterministic-future` (the `(∗)` chain), `def:frame-validity`,
  `def:BLstar-semantics`
* `FormalSystem/Semantics/PlusLanguage/PlusValidity.lean` — the L⁺ predicates these mirror

## Tags

validity · star-language · sent:det · store-recall
-/

namespace FormalSystem.Semantics

open FormalSystem.Syntax
open FormalSystem.PlusLanguage
open FormalSystem.StarLanguage

/-! ## `FrameClass`-indexed validity for L⋆ -/

/-- L⋆'s instance of the abstract point-truth class of `Semantics/ValidityLayer.lean`, folding
the stored-time vector into the point predicate.

`v` is the **innermost** binder of every L⋆ validity definition below, and as a `Pi` telescope
`∀ M τ x v, …` is literally `∀ M τ x, (∀ v, …)`. So closing over `v` here changes no binder
telescope and no statement: `TaskFrame.StarValidOn F φ` is *definitionally* the generic
`TaskFrame.GenericValidOn F φ` at this instance, which
`Tests/BimodalTest/Semantics/ValidityLayerTest.lean` pins by `rfl`. This is what settles that one
abstraction covers both point shapes, `(τ, x)` and `(τ, x, v⃗)`. -/
instance : PointTruth StarFormula where
  sat {F} M τ t φ := ∀ v : ℕ → F.Duration, StarTruthAt M τ t v φ

/-- `def:frame-validity` for L⋆: `φ` is valid over the frame `F` iff it is true at every model
over `F`, every possible world `τ ∈ H_F`, every time, and **every stored-time vector**. The L⋆
mirror of `TaskFrame.PlusValidOn`. -/
def TaskFrame.StarValidOn (F : TaskFrame) (φ : StarFormula) : Prop :=
  ∀ (M : TaskModel F) (τ : TaskFrame.HF F) (x : F.Duration) (v : ℕ → F.Duration),
    StarTruthAt M τ.val x v φ

/-- `φ` is valid on every frame satisfying `P`. **The primitive**, indexed by a bare frame
predicate rather than a `FrameClass` tag — which is what lets validity over the deterministic
frames, a class no tag denotes, be stated directly. -/
def StarValidOnFrames (P : TaskFrame → Prop) (φ : StarFormula) : Prop :=
  ∀ F : TaskFrame, P F → F.StarValidOn φ

/-- Class-restricted validity `⊨_C` for L⋆, at a `FrameClass` tag. -/
def StarValidIn (fc : ProofSystem.FrameClass) (φ : StarFormula) : Prop :=
  StarValidOnFrames fc.Sat φ

/-- An L⋆ formula is **valid** if it is true in all models, at all times, at every stored-time
vector, at every possible world, over every task frame. -/
def StarValid (φ : StarFormula) : Prop :=
  StarValidIn ProofSystem.FrameClass.Base φ

/-! ### Monotonicity -/

/-- `StarValidOnFrames` is antitone in its frame predicate. -/
theorem StarValidOnFrames.mono {P Q : TaskFrame → Prop} {φ : StarFormula}
    (h : ∀ F, Q F → P F) (hP : StarValidOnFrames P φ) : StarValidOnFrames Q φ :=
  GenericValidOnFrames.mono (L := StarFormula) (φ := φ) h hP

/-- L⋆ validity is monotone in the `FrameClass` order. -/
theorem StarValidIn.mono {fc₁ fc₂ : ProofSystem.FrameClass} {φ : StarFormula} (h : fc₁ ≤ fc₂)
    (hv : StarValidIn fc₁ φ) : StarValidIn fc₂ φ :=
  GenericValidIn.mono (L := StarFormula) (φ := φ) h hv

/-! ### Binder-shape adapters

The bundled `(τ : TaskFrame.HF F)` of the definitions above versus the unbundled pair
`(τ : PartialHistory F) (hτ : τ.IsTotal)` every proof works with, exactly as on the L⁺ side. -/

/-- Introduce `TaskFrame.StarValidOn` from the unbundled shape. -/
theorem TaskFrame.StarValidOn.of_forall_total {F : TaskFrame} {φ : StarFormula}
    (h : ∀ (M : TaskModel F) (τ : PartialHistory F), τ.IsTotal →
           ∀ (x : F.Duration) (v : ℕ → F.Duration), StarTruthAt M τ x v φ) :
    F.StarValidOn φ :=
  TaskFrame.GenericValidOn.of_forall_total (L := StarFormula) (φ := φ) h

/-- Eliminate `TaskFrame.StarValidOn` into the unbundled shape. -/
theorem TaskFrame.StarValidOn.apply_total {F : TaskFrame} {φ : StarFormula}
    (h : F.StarValidOn φ) (M : TaskModel F) (τ : PartialHistory F) (hτ : τ.IsTotal)
    (x : F.Duration) (v : ℕ → F.Duration) : StarTruthAt M τ x v φ :=
  TaskFrame.GenericValidOn.apply_total (L := StarFormula) (φ := φ) h M τ hτ x v

/-- Introduce `StarValidOnFrames` from the unbundled shape. -/
theorem StarValidOnFrames.of_forall_total {P : TaskFrame → Prop} {φ : StarFormula}
    (h : ∀ (F : TaskFrame), P F → ∀ (M : TaskModel F) (τ : PartialHistory F),
           τ.IsTotal → ∀ (x : F.Duration) (v : ℕ → F.Duration), StarTruthAt M τ x v φ) :
    StarValidOnFrames P φ :=
  GenericValidOnFrames.of_forall_total (L := StarFormula) (φ := φ) h

/-- Eliminate `StarValidOnFrames` into the unbundled shape. -/
theorem StarValidOnFrames.apply_total {P : TaskFrame → Prop} {φ : StarFormula}
    (h : StarValidOnFrames P φ) (F : TaskFrame) (hF : P F) (M : TaskModel F)
    (τ : PartialHistory F) (hτ : τ.IsTotal) (x : F.Duration) (v : ℕ → F.Duration) :
    StarTruthAt M τ x v φ :=
  GenericValidOnFrames.apply_total (L := StarFormula) (φ := φ) h F hF M τ hτ x v

/-- `StarValidOnFrames.of_forall_total` at a `FrameClass` tag. -/
theorem StarValidIn.of_forall_total {fc : ProofSystem.FrameClass} {φ : StarFormula}
    (h : ∀ (F : TaskFrame), fc.Sat F → ∀ (M : TaskModel F) (τ : PartialHistory F),
           τ.IsTotal → ∀ (x : F.Duration) (v : ℕ → F.Duration), StarTruthAt M τ x v φ) :
    StarValidIn fc φ :=
  GenericValidIn.of_forall_total (L := StarFormula) (φ := φ) h

/-- `StarValidOnFrames.apply_total` at a `FrameClass` tag. -/
theorem StarValidIn.apply_total {fc : ProofSystem.FrameClass} {φ : StarFormula}
    (h : StarValidIn fc φ) (F : TaskFrame) (hF : fc.Sat F) (M : TaskModel F)
    (τ : PartialHistory F) (hτ : τ.IsTotal) (x : F.Duration) (v : ℕ → F.Duration) :
    StarTruthAt M τ x v φ :=
  GenericValidIn.apply_total (L := StarFormula) (φ := φ) h F hF M τ hτ x v

/-- Introduce `StarValid` from the unbundled shape; the `Sat .Base` argument (`True`) is
discharged here. -/
theorem StarValid.of_forall_total {φ : StarFormula}
    (h : ∀ (F : TaskFrame) (M : TaskModel F) (τ : PartialHistory F), τ.IsTotal →
           ∀ (x : F.Duration) (v : ℕ → F.Duration), StarTruthAt M τ x v φ) :
    StarValid φ :=
  GenericValid.of_forall_total (L := StarFormula) (φ := φ) h

/-- Eliminate `StarValid` into the unbundled shape. -/
theorem StarValid.apply {φ : StarFormula} (h : StarValid φ) (F : TaskFrame) (M : TaskModel F)
    (τ : PartialHistory F) (hτ : τ.IsTotal) (x : F.Duration) (v : ℕ → F.Duration) :
    StarTruthAt M τ x v φ :=
  GenericValid.apply (L := StarFormula) (φ := φ) h F M τ hτ x v

/-! ## Transfer along the embedding -/

variable {F : TaskFrame}

/-- **L⋆ validity of an embedded L⁺ formula is L⁺ validity**, at a single frame. Immediate from
`starTruthAt_ofPlus`, the extra `v` binder being vacuous on the image of `ofPlus`. -/
theorem starValidOn_ofPlus (F : TaskFrame) (φ : PlusFormula) :
    F.StarValidOn (ofPlus φ) ↔ F.PlusValidOn φ := by
  constructor
  · intro h M τ x
    exact (starTruthAt_ofPlus M τ.val x (fun _ => 0) φ).mp (h M τ x (fun _ => 0))
  · intro h M τ x v
    exact (starTruthAt_ofPlus M τ.val x v φ).mpr (h M τ x)

/-- The same transfer at a bare frame predicate. -/
theorem starValidOnFrames_ofPlus (P : TaskFrame → Prop) (φ : PlusFormula) :
    StarValidOnFrames P (ofPlus φ) ↔ PlusValidOnFrames P φ :=
  forall_congr' fun F => imp_congr_right fun _ => starValidOn_ofPlus F φ

/-! ## `sent:det` and the paper's `(∗)` chain -/

/-- The disjunction `sent:det` tests at each future time: `φ`'s truth at the time held in
register `2` is settled by the present world state, one way or the other. Named so that
`sentDet_unfold`, `sentDet_of_deterministic` and `refute_sentDet` all speak of the same
object. -/
def settledDisj (φ : StarFormula) : StarFormula :=
  StarFormula.or (.stab (.timeRecall 2 φ.neg)) (.stab (.timeRecall 2 φ))

/--
**`sent:det`, transcribed**:
`↑¹ \Future ↑² ↓¹ (⊡ ↓² ¬φ ∨ ⊡ ↓² φ)`.

`\Future` is the manuscript's **universal** future (a boxed `F`), so the tree's `allFuture` is
what stands here; see this module's docstring for the record of that check. Register `1` holds
the time of evaluation, register `2` the future time being tested; `0` is unused.
-/
def sentDet (φ : StarFormula) : StarFormula :=
  .timeStore 1 (StarFormula.allFuture (.timeStore 2 (.timeRecall 1 (settledDisj φ))))

/-- Register `1` survives an update at register `2`. The one arithmetic fact the `(∗)` chain
needs, isolated so the chain itself is four rewrites. -/
theorem update_two_apply_one (v : ℕ → F.Duration) (x y : F.Duration) :
    Function.update (Function.update v 1 x) 2 y 1 = x := by
  simp

/-- Register `2` holds what was last written to it. -/
theorem update_two_apply_two (v : ℕ → F.Duration) (x y : F.Duration) :
    Function.update (Function.update v 1 x) 2 y 2 = y := by
  simp

/--
**The paper's `(∗)` chain for `sent:det`**, as one reusable biconditional.

Four rewrites, one per line of the manuscript's displayed chain in `app:deterministic-future`'s
proof: store the present time in register `1`; run the universal future; store the future time
in register `2`; recall register `1` to return the point of evaluation to the present time. What
remains is `settledDisj φ` at the present time under the twice-updated vector, for every future
`y`.
-/
theorem sentDet_unfold (M : TaskModel F) (τ : PartialHistory F) (x : F.Duration)
    (v : ℕ → F.Duration) (φ : StarFormula) :
    StarTruthAt M τ x v (sentDet φ) ↔
      ∀ y : F.Duration, x < y →
        StarTruthAt M τ x (Function.update (Function.update v 1 x) 2 y) (settledDisj φ) := by
  unfold sentDet
  rw [StarTruth.timeStore_iff, StarTruth.allFuture_iff]
  refine forall_congr' fun y => imp_congr_right fun _ => ?_
  rw [StarTruth.timeStore_iff, StarTruth.timeRecall_iff, update_two_apply_one]

/-- `settledDisj φ` unfolded semantically: at the point `(τ, x, v)`, either every possible world
sharing `τ`'s state at `x` fails `φ` at time `v 2`, or every one of them satisfies it there. -/
theorem settledDisj_iff (M : TaskModel F) (τ : PartialHistory F) (x : F.Duration)
    (v : ℕ → F.Duration) (φ : StarFormula) :
    StarTruthAt M τ x v (settledDisj φ) ↔
      (∀ σ : PartialHistory F, σ.IsTotal → SameStateAt τ σ x → ¬ StarTruthAt M σ (v 2) v φ) ∨
      (∀ σ : PartialHistory F, σ.IsTotal → SameStateAt τ σ x → StarTruthAt M σ (v 2) v φ) :=
  StarTruth.or_iff M τ x v _ _

/--
**The refutation packaging for `sent:det`.**

To refute `sent:det` over a frame it suffices to exhibit a possible world `τ`, a time `x`, a
strictly later time `y`, and two possible worlds `σ₁, σ₂ ∈ ⟨τ⟩ₓ` that *disagree* about `φ` at
`y`: `σ₁` satisfies it and `σ₂` refutes it. Then neither disjunct of `settledDisj φ` can hold at
`(τ, x, ·)` with register `2` holding `y`, and `sentDet_unfold` carries the failure to
`sent:det` itself.

Both `hpos` and `hneg` are stated for *every* stored-time vector, which is what an atomic `φ`
supplies for free — the atom clause of `StarTruthAt` does not read the registers. Packaging the
argument here, where the frame is abstract, is what keeps the two refutation sites
(`Semantics/StarLanguage/StarNonValidities.lean` for `NF`, `Metalogic/Independence/StarDiscrimination.lean`
for `F°`) down to their genuinely frame-specific content.
-/
theorem not_starValidOn_sentDet {φ : StarFormula} (M : TaskModel F)
    (τ : PartialHistory F) (hτ : τ.IsTotal) (x y : F.Duration) (hxy : x < y)
    (σ₁ σ₂ : PartialHistory F) (h₁ : σ₁.IsTotal) (h₂ : σ₂.IsTotal)
    (hs₁ : SameStateAt τ σ₁ x) (hs₂ : SameStateAt τ σ₂ x)
    (hpos : ∀ v : ℕ → F.Duration, StarTruthAt M σ₁ y v φ)
    (hneg : ∀ v : ℕ → F.Duration, ¬ StarTruthAt M σ₂ y v φ) :
    ¬ F.StarValidOn (sentDet φ) := by
  intro h
  have hv := h.apply_total M τ hτ x (fun _ => x)
  rw [sentDet_unfold] at hv
  have h1 := hv y hxy
  rw [settledDisj_iff, update_two_apply_two] at h1
  rcases h1 with hA | hB
  · exact hA σ₁ h₁ hs₁ (hpos _)
  · exact hneg _ (hB σ₂ h₂ hs₂)

end FormalSystem.Semantics
