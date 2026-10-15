/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.Extension

/-!
# Nomic frames, law-histories, and the three nomic properties

The frame-level half of the paper's nomic appendix. A **nomic frame** (`def:nomic-frame`) keeps
one carrier `W` but replaces the single task relation by a *relativized family* `⇒ʷ`, one task
relation per world state `w`, each of which must satisfy `def:frame` on its own. The `w`-th member
is the ordinary task frame `F^w := (W, D, ⇒ʷ)`, whose possible worlds are the **law-histories**
`H_F^w`; `H_F` is their union over `w`.

## Why the carrier is a field and the family is derived

`NomicFrame` carries `World : Type` and `PosRel : World → World → D.PositiveCone → World → Prop`,
and `F.at w : FrameOver D` is *built* from them. The alternative — a field
`at : World → FrameOver D` plus a transport hypothesis `∀ w, (at w).WorldState = World` — would
force every consumer to transport along an equality of types. Deriving the family instead makes
`(F.at w).WorldState` literally `F.World`, so every `FrameOver`-level theorem applies at `F.at w`
with no transport at all.

Regularity is a `class` (`NomicFrame.IsRegular`) rather than a bundle of fields, mirroring
`FrameOver`/`FrameOver.IsRegular`: that split is what keeps a partially-constrained frame
expressible, and `instAtIsRegular` is the line that lets `nullity_identity`, `reflection`,
`thm:extension` and `cor:occurrence` all fire at `F.at w` with nothing passed by hand.

`NomicFrame.at` is declared with its dotted name *outside* `namespace NomicFrame`, because `at` is
a reserved token; and it is a plain `def`, not `@[reducible]`, because instance synthesis keys
`instAtIsRegular` on `FrameOver.IsRegular (F.at w)`.

## Law-histories as bare functions

`lawHist F w : Set (↑D → F.World)` is a set of **bare functions**, not of
`WorldHistory (F.at w)`s. This is forced: `H_F := ⋃ w, H_F^w` does not typecheck over a family of
`WorldHistory` types, since each member's type mentions its own `w`. `mem_lawHist_iff` is the only
bridge back to `WorldHistory`, and it is an iff, so nothing is lost.

## Main Definitions

- `NomicFrame` — `def:nomic-frame`: one carrier, one task relation per world state
- `NomicFrame.at` — `F^w`, the `w`-th member of the relativized family
- `NomicFrame.IsRegular` — `def:nomic-frame`'s regularity hypothesis: every member is a task frame
- `NomicFrame.TaskRel` — the relativized derived relation `⇒ʷ`, reflection convention included
- `NomicFrame.lawHist` / `NomicFrame.HF` — `H_F^w` and `H_F := ⋃ w, H_F^w`
- `NomicFrame.Lawful` / `Static` / `Uniform` — the three properties of `def:nomic-properties`

## Main Results

- `NomicFrame.mem_lawHist_iff` — the bridge between `lawHist` and `WorldHistory`
- `NomicFrame.static_of_uniform`, `NomicFrame.lawful_of_uniform` — `prop:nomic-hierarchy`'s first
  sentence: *Uniform* implies both *Static* and *Lawful*
- `NomicFrame.occurrence` — `lem:nomic-occurrence`: every state occurs at every time along some
  law-history at `w`

## Choice dependence, recorded honestly

`occurrence` is a theorem of **ZFC**, not of ZF: it applies `cor:occurrence` at `F.at w`, and that
corollary runs through `thm:extension`, whose proof appeals to Zorn's lemma. `rmk:choice` lists
the paper's choice-free results; `lem:nomic-occurrence` is not among them, and nothing here
advertises it as choice-free. The two definitional properties `static_of_uniform` and
`lawful_of_uniform` take no regularity instance and consume no constraint at all.
-/

namespace FormalSystem.Semantics

/--
`def:nomic-frame`: a nomic frame over `D` is one carrier together with a *relativized family* of
task relations, one per world state. The `w`-th member `F^w = (World, D, PosRel w)` is recovered
as `NomicFrame.at`, and `IsRegular` is the hypothesis that each member satisfies `def:frame`.
-/
structure NomicFrame (D : TemporalOrder) where
  /-- The carrier: one set of world states, shared by every member of the family. -/
  World : Type
  /-- Every nomic frame has at least one world state, as the paper's ambient convention assumes. -/
  [worldNonempty : Nonempty World]
  /-- The relativized positive-cone relation: `PosRel w p x q` is `p ⇒ʷ_x q` for `x` positive. -/
  PosRel : World → World → D.PositiveCone → World → Prop

attribute [instance] NomicFrame.worldNonempty

variable {D : TemporalOrder}

/--
`F^w`, the `w`-th member of the relativized family: the ordinary frame over `D` whose world states
are `F.World` and whose positive-cone relation is `F.PosRel w`.

Declared with its dotted name *outside* `namespace NomicFrame`, because `at` is a reserved token.
Kept a plain `def` rather than `@[reducible]`: instance synthesis keys `instAtIsRegular` on
`FrameOver.IsRegular (F.at w)`, and `FrameOver.ofReflectiveRegular`'s docstring records what
reducibility does to such a key.
-/
def NomicFrame.at (F : NomicFrame D) (w : F.World) : FrameOver D where
  WorldState := F.World
  PosRel := F.PosRel w

namespace NomicFrame

/--
`def:nomic-frame`'s regularity hypothesis: **every** member of the relativized family is a task
frame, i.e. satisfies all four constraints of `def:frame`.
-/
class IsRegular (F : NomicFrame D) : Prop where
  /-- Each member `F^w` satisfies `def:frame`. -/
  regular : ∀ w : F.World, (F.at w).IsRegular

/--
Every member of a regular nomic frame is a regular frame.

This is the load-bearing instance of the module: it is what lets `nullity_identity`, `reflection`,
`thm:extension` and `cor:occurrence` fire at `F.at w` with no argument passed by hand.
-/
instance instAtIsRegular (F : NomicFrame D) [h : F.IsRegular] (w : F.World) :
    (F.at w).IsRegular := h.regular w

/--
The relativized derived relation `⇒ʷ`, defined at every duration — including the negative ones,
through `def:task-relation`'s reflection convention, which `FrameOver.TaskRel` already carries.
-/
def TaskRel (F : NomicFrame D) (w : F.World) : F.World → ↑D → F.World → Prop :=
  (F.at w).TaskRel

/-- `F.TaskRel w` is the derived relation of the member frame `F^w`, definitionally. -/
theorem taskRel_eq (F : NomicFrame D) (w : F.World) : F.TaskRel w = (F.at w).TaskRel := rfl

/--
`H_F^w`, the **law-histories at `w`**: the possible worlds of `F^w`, presented as the bare
functions respecting `⇒ʷ` at every pair of times.

A set of bare functions `↑D → F.World` rather than of `WorldHistory (F.at w)`s, so that the union
over `w` in `HF` typechecks; `mem_lawHist_iff` is the bridge back.
-/
def lawHist (F : NomicFrame D) (w : F.World) : Set (↑D → F.World) :=
  {τ | ∀ x y, F.TaskRel w (τ x) (y - x) (τ y)}

/-- `H_F := ⋃_w H_F^w`, the nomologically possible worlds of a nomic frame. -/
def HF (F : NomicFrame D) : Set (↑D → F.World) := ⋃ w, F.lawHist w

/--
The bridge between `lawHist` and `WorldHistory`: a bare function lies in `H_F^w` exactly when it
is the state function of a possible world of `F^w`.

The forward direction is `WorldHistory.ofTotal` at the all-pairs hypothesis; the converse is
`WorldHistory.respects_task`. Both halves are choice-free: `lawHist` and `WorldHistory` are the
same condition under two presentations, and neither direction touches `thm:extension`.
-/
theorem mem_lawHist_iff (F : NomicFrame D) (w : F.World) (τ : ↑D → F.World) :
    τ ∈ F.lawHist w ↔ ∃ σ : WorldHistory (F.at w).toTaskFrame, σ.state = τ := by
  constructor
  · intro h
    exact ⟨WorldHistory.ofTotal _ τ (fun s t => h s t), rfl⟩
  · rintro ⟨σ, rfl⟩
    intro x y
    exact σ.respects_task x y

/--
`def:nomic-properties`, *Lawful*: along every nomologically possible world, the laws in force at
the state occupied at any time are laws that world itself obeys.
-/
def Lawful (F : NomicFrame D) : Prop := ∀ τ ∈ F.HF, ∀ x, τ ∈ F.lawHist (τ x)

/--
`def:nomic-properties`, *Static*: along every nomologically possible world, the law-histories
determined by the states occupied at any two times coincide.
-/
def Static (F : NomicFrame D) : Prop := ∀ τ ∈ F.HF, ∀ x y, F.lawHist (τ x) = F.lawHist (τ y)

/-- `def:nomic-properties`, *Uniform*: every world state determines the same law-histories. -/
def Uniform (F : NomicFrame D) : Prop := ∀ w, F.lawHist w = F.HF

/-- *Uniform* implies *Static* — the first half of `prop:nomic-hierarchy`'s opening sentence. -/
theorem static_of_uniform {F : NomicFrame D} (h : F.Uniform) : F.Static := by
  intro τ _ x y; rw [h, h]

/-- *Uniform* implies *Lawful* — the second half of `prop:nomic-hierarchy`'s opening sentence. -/
theorem lawful_of_uniform {F : NomicFrame D} (h : F.Uniform) : F.Lawful := by
  intro τ hτ x; rw [h]; exact hτ

/--
`lem:nomic-occurrence`: over a regular nomic frame, every world state occurs at every time along
some law-history at every `w`.

The paper's proof is the one-liner this is: `F^w` is a task frame, so `cor:occurrence` applies at
it, and `mem_lawHist_iff` carries the resulting possible world into `H_F^w`.

**Choice dependence, recorded honestly.** This is a theorem of ZFC, not of ZF: `cor:occurrence`
runs through `thm:extension`, whose proof appeals to Zorn's lemma. `rmk:choice` lists the paper's
choice-free results and this is not one of them.

Constraints consumed: Compositionality, Seriality, Limit, Saturation
-/
theorem occurrence (F : NomicFrame D) [F.IsRegular] (w u : F.World) (x : ↑D) :
    ∃ τ ∈ F.lawHist w, τ x = u := by
  obtain ⟨σ, hσ⟩ := PartialHistory.occurrence (F.at w).toTaskFrame u x
  exact ⟨σ.state, (F.mem_lawHist_iff w σ.state).mpr ⟨σ, rfl⟩, hσ⟩

end NomicFrame

end FormalSystem.Semantics
