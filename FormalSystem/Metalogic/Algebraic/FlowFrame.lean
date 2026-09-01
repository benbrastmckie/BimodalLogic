/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.TaskFrame
import FormalSystem.Semantics.Truth
import FormalSystem.Metalogic.Bundle.TemporalCoherence
import FormalSystem.Syntax.SubformulaClosure.TemporalFormulas
import FormalSystem.Theorems.Propositional.Core

/-!
# FlowFrame - Generic Flow-Frame Conformance and Totality Layer

This module defines the deterministic multi-family flow frame `multiFamTaskFrameGen` over an
arbitrary ordered abelian group (previously hosted beside the chronicle monadic bridge; moved
here so the chronicle-side countermodel modules can consume the bundle flow frame without an
import cycle), proves — once and D-generically — that it satisfies all four axioms of the
paper's frame definition (`def:frame`), characterizes its total histories as flow lines, and
re-hosts the dense truth lemma onto its bundle-index instantiation `bundleFlowFrame`.

The `ℤ` originals (`multiFamTaskFrame` and siblings, `ReynoldsBridge.lean`) are certified as
the definitional `D := ℤ` specializations of these generic definitions by the `_int` lemmas in
`ChronicleMonadicBridge.lean`, which imports this module.

## Paper Specification Reference

**Frame axioms (`def:frame`)**: "A *frame* is any $\F = \tuple{W, \D, \Rightarrow}$ where $W$
is a nonempty set of world states, $\D$ is a temporal order, and $\Rightarrow$ is a task
relation satisfying the following for $x, y \geq 0$":

- *Compositionality* (`def:frame#Compositionality`, verbatim): "$w \Rightarrow_{x + y} v$ if
  and only if $w \Rightarrow_x u$ and $u \Rightarrow_y v$ for some $u \in W$" — a
  BICONDITIONAL; `multiFamGen_comp_iff` below proves both directions, the `→` (interpolation)
  direction through the unique intermediate `(f, w.2 + x)`.
- *Seriality* (`def:frame#Seriality`, verbatim): "$w \Rightarrow_x u$ and
  $v \Rightarrow_x w$ for some $u, v \in W$" — `multiFamGen_serial`, via the clock.
- *Limit* (`def:frame#Limit`, verbatim): "$\bigcap\limits_{x > 0} (w)_x = \set{w}$" —
  `multiFamGen_limit`, via `ParamTaskFrame.limit_of_shift` with `pos := Prod.snd`.
- *Spherical* (`def:frame#Spherical`, verbatim): "$\bigcap \mathcal{S} \neq \emptyset$ for
  any $\supseteq$-directed family $\mathcal{S}$ of nonempty fibers and segments" —
  `multiFamGen_spherical`, via `sInter_nonempty_of_directed_subsingleton`: determinism makes
  every fiber a singleton and every segment a subsingleton.

**Fiber/segment apparatus (`def:task-relation`)** and **directed families (`def:directed`)**
are consumed from `Semantics/TaskFrame.lean` (`TaskFrame.Fib`, `TaskFrame.Seg`,
`TaskFrame.DirectedFamily`, `TaskFrame.IsFiber`, `TaskFrame.IsSegment`).

**Totality (`def:world-history`)**: "A world history is *total* — equivalently, a *possible
world* — just in case X = D. ... The set of all total world histories over F is denoted
H_F." `multiFamGen_total_eq` characterizes the total histories of the flow frame: every
history with full domain IS a flow line `multiFamHistoryGen f w₀`. Since the flow lines are
total by construction, the frame's total-history set H_F coincides exactly with the flow-line
family — the internalization on which the total-history countermodel constructions rest.

**Derived, not cited**: the segment identity `w ⇒_{x+y} v ↔ [w,v]_x^y ≠ ∅`
(`taskRel_add_iff_seg_nonempty`) is DERIVED here from the compositionality biconditional, the
converse convention, and `mem_Seg`. It is not paper text and must not be cited as such.

## Main Results

- `sInter_nonempty_of_directed_subsingleton`: a directed family of nonempty subsingleton
  sets has nonempty intersection (the generic *Spherical* discharge helper, reusable for
  every deterministic frame)
- `taskRel_add_iff_seg_nonempty`: the derived segment identity
- `multiFamGen_comp_iff` / `multiFamGen_comp_iff_of_nonneg`: biconditional
  *Compositionality* (strong all-durations form, plus the positive-cone projection)
- `multiFamGen_serial`: *Seriality*
- `multiFamGen_limit`: *Limit* (requires `[Nontrivial D]`, as `def:temporal-order` mandates)
- `multiFamGen_spherical`: *Spherical*
- `multiFamGen_total_eq`: the totality characterization (every total history is a flow line)
- `multiFamTaskFrameGen_serial` / `_interpolates` / `_limit` / `_spherical`: the same four
  axioms restated in the bare-relation predicates of record (`TaskFrame.Serial`,
  `TaskFrame.Interpolates`, `TaskFrame.Spherical`, and *Limit*'s literal transcribed shape), so
  they are citable verbatim when the frame structure grows the corresponding fields

## `bundleFlowFrame` is a specialization, not a construction site

`bundleFlowFrame B` is *definitionally* `multiFamTaskFrameGen D {fam // fam ∈ B.families}` — a
`def` whose body is an application of the generic frame, not a `where`-block of its own. It
therefore carries **no field obligations of its own**: whatever discharges
`multiFamTaskFrameGen`'s fields discharges its, automatically and by definition. The
`bundleFlow_*` axiom lemmas below are that specialization made explicit for readers, not an
independent conformance proof, and `bundleFlowFrame` must not be counted as a separate frame
construction site in any inventory of sites that owe the structure a field.

## References

* [TaskFrame.lean](../../Semantics/TaskFrame.lean) - frame structure, apparatus, Limit helpers
* [ChronicleMonadicBridge.lean](../BXCanonical/Chronicle/ChronicleMonadicBridge.lean) -
  the generic flow frame `multiFamTaskFrameGen` / `multiFamHistoryGen`
* JPL Paper anchors `def:frame` (sub-anchors `def:frame#Compositionality`,
  `def:frame#Seriality`, `def:frame#Limit`, `def:frame#Spherical`), `def:task-relation`,
  `def:directed`, `def:world-history` — cited by `\label` anchor, never by line number
-/

namespace FormalSystem.Metalogic.Algebraic

open FormalSystem.Syntax
open FormalSystem.ProofSystem
open FormalSystem.Semantics
open FormalSystem.Metalogic.Core
open FormalSystem.Metalogic.Bundle

/-! ## The generic Spherical helper

Determinism-shaped discharge of `def:frame#Spherical`: in a frame whose fibers are all
subsingletons, every set the axiom ranges over is a nonempty subsingleton, and a directed
family of nonempty subsingletons has nonempty intersection. Stated for an arbitrary carrier
`W`, with no relation in sight, so it is reusable verbatim for every deterministic frame. -/

/-- A directed family (`def:directed`) of nonempty subsingleton sets has nonempty
intersection. Pick `a` in some member `s₀`; for any member `s₁`, directedness gives a member
`s' ⊆ s₀ ∩ s₁`, whose element must be `a` by subsingleton-ness of `s₀` — so `a ∈ s₁`. -/
theorem sInter_nonempty_of_directed_subsingleton
    {W : Type} {S : Set (Set W)} (hdir : TaskFrame.DirectedFamily S)
    (hne : ∀ s ∈ S, s.Nonempty) (hsub : ∀ s ∈ S, s.Subsingleton) :
    (⋂₀ S).Nonempty := by
  obtain ⟨⟨s₀, hs₀⟩, hdir₂⟩ := hdir
  obtain ⟨a, ha⟩ := hne s₀ hs₀
  refine ⟨a, Set.mem_sInter.mpr fun s₁ hs₁ => ?_⟩
  obtain ⟨s', hs', hsub'⟩ := hdir₂ s₀ hs₀ s₁ hs₁
  obtain ⟨b, hb⟩ := hne s' hs'
  have hb₀ : b ∈ s₀ ∩ s₁ := hsub' hb
  have hba : b = a := hsub s₀ hs₀ hb₀.1 ha
  exact hba ▸ hb₀.2

section FlowFrameConformance

variable {D : Type} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]

/-! ## The generic multi-family flow frame

The discreteness-free multi-family frame over an arbitrary ordered abelian group `D`: world
states are pairs `(f, x)` of a family index and a time, and the task relation is the
deterministic clock stepping by `d` from `(f, x)` to `(f, x + d)`. The `ℤ` originals
(`multiFamTaskFrame`/`multiFamHistory`, `ReynoldsBridge.lean`) are recovered
as definitional specializations by `ChronicleMonadicBridge.lean`'s `_int` lemmas. -/

/-- `ParamTaskFrame` with `WorldState = FamIdx × D` over an arbitrary ordered abelian group `D`.
The generic form of `multiFamTaskFrame` (`ReynoldsBridge.lean`); the task relation is
deterministic, stepping by `d` from `(f, x)` to `(f, x + d)`.

`[Nontrivial D]` is carried because `multiFamTaskFrameGen_limit` requires it, via
`ParamTaskFrame.limit_of_shift`: over a trivial duration type `0 < x` is unsatisfiable and *Limit*
(`def:frame#Limit`) has no content to conclude from. The binder propagates to
`bundleFlowFrame` and everything stated over it; every consumer elaborates at `ℤ`, `ℚ`, or `ℝ`,
each of which supplies the instance. -/
noncomputable def multiFamTaskFrameGen (D : Type) [AddCommGroup D] [LinearOrder D]
    [IsOrderedAddMonoid D] [Nontrivial D] (FamIdx : Type) [Nonempty FamIdx] : ParamTaskFrame D where
  WorldState := FamIdx × D
  worldNonempty := inferInstance
  TaskRel := fun p d q => p.1 = q.1 ∧ q.2 = p.2 + d
  nullity_identity := fun p q => by
    constructor
    · rintro ⟨h1, h2⟩
      refine Prod.ext h1 ?_
      rw [h2, add_zero]
    · rintro rfl; exact ⟨rfl, (add_zero _).symm⟩
  comp := TaskFrame.comp_of
    (fun w v x y _ _ h => by
      obtain ⟨h₁, h₂⟩ := h
      refine ⟨(w.1, w.2 + x), ⟨rfl, rfl⟩, h₁, ?_⟩
      show v.2 = w.2 + x + y
      rw [h₂]; abel)
    (fun _ _ _ _ _ _ _ ⟨h1, h2⟩ ⟨h3, h4⟩ => ⟨h1.trans h3, by rw [h4, h2, add_assoc]⟩)
  converse := fun _ _ _ => by
    constructor
    · rintro ⟨h1, h2⟩; exact ⟨h1.symm, by rw [h2]; abel⟩
    · rintro ⟨h1, h2⟩; exact ⟨h1.symm, by rw [h2]; abel⟩
  serial := fun w x _ =>
    ⟨⟨(w.1, w.2 + x), rfl, rfl⟩, ⟨(w.1, w.2 - x), rfl, by show w.2 = w.2 - x + x; abel⟩⟩
  limit :=
    ParamTaskFrame.limit_of_shift Prod.snd (fun _ _ _ h => h.2)
      (fun w u h => Prod.ext h.1.symm (by rw [h.2, add_zero]))
  spherical := by
    intro S hdir hmem
    refine sInter_nonempty_of_directed_subsingleton hdir (fun s hs => (hmem s hs).2)
      fun s hs => ?_
    rcases (hmem s hs).1 with ⟨w, x, rfl⟩ | ⟨w, v, x, y, _, _, rfl⟩
    · rintro u ⟨hu₁, hu₂⟩ u' ⟨hu'₁, hu'₂⟩
      exact Prod.ext (hu₁.symm.trans hu'₁) (hu₂.trans hu'₂.symm)
    · refine Set.Subsingleton.anti ?_ Set.inter_subset_left
      rintro u ⟨hu₁, hu₂⟩ u' ⟨hu'₁, hu'₂⟩
      exact Prod.ext (hu₁.symm.trans hu'₁) (hu₂.trans hu'₂.symm)

/-- World history for `multiFamTaskFrameGen`, visiting `(f, w₀ + t)` at each time `t`.
Generic form of `multiFamHistory` (`ReynoldsBridge.lean`). -/
noncomputable def multiFamHistoryGen [Nontrivial D] {FamIdx : Type} [Nonempty FamIdx] (f : FamIdx) (w₀ : D) :
    WorldHistory (multiFamTaskFrameGen D FamIdx) where
  domain := fun _ => True
  nonempty_domain := ⟨0, trivial⟩
  convex := fun _ _ _ _ _ _ _ => trivial
  states := fun t _ => (f, w₀ + t)
  respects_task := fun s t _ _ => by
    refine ⟨rfl, ?_⟩
    show w₀ + t = w₀ + s + (t - s)
    abel

/-- Time-shifting `multiFamHistoryGen f w₀` by `Δ` gives `multiFamHistoryGen f (w₀ + Δ)`.
Generic form of `multiFamHistory_shift_eq` (`ReynoldsBridge.lean`). -/
theorem multiFamHistoryGen_shift_eq [Nontrivial D] {FamIdx : Type} [Nonempty FamIdx] (f : FamIdx) (w₀ Δ : D) :
    WorldHistory.timeShift
        (multiFamHistoryGen f w₀ : WorldHistory (multiFamTaskFrameGen D FamIdx)) Δ =
      multiFamHistoryGen f (w₀ + Δ) := by
  have h_states : (fun (t : D) (_ : True) => ((f, w₀ + (t + Δ)) : FamIdx × D)) =
      (fun (t : D) (_ : True) => ((f, w₀ + Δ + t) : FamIdx × D)) := by
    funext t _; congr 1; abel
  change WorldHistory.mk (PartialHistory.mk _ _ _ _) _ =
    WorldHistory.mk (PartialHistory.mk _ _ _ _) _
  congr 2

/-- Every generic multi-family history is total (`def:world-history`'s cut `X = D`, spelled
`∀ t, σ.domain t`). Definitional: `multiFamHistoryGen` carries `domain := fun _ => True`. This
is what the totality-targeted box clause (`def:BL-semantics`) consumes. -/
theorem multiFamHistoryGen_total [Nontrivial D] {FamIdx : Type} [Nonempty FamIdx] (f : FamIdx) (w₀ : D) :
    (multiFamHistoryGen f w₀ : WorldHistory (multiFamTaskFrameGen D FamIdx)).IsTotal :=
  fun _ => trivial

/-! ## The derived segment identity

`w ⇒_{x+y} v ↔ [w,v]_x^y ≠ ∅`, derived from the compositionality biconditional
(`def:frame#Compositionality`), the converse convention (`def:task-relation`), and
`mem_Seg`. This identity is a Lean derivation, not paper text. -/

omit [LinearOrder D] [IsOrderedAddMonoid D] in
/-- The derived segment identity: the composite step `w ⇒_{x+y} v` exists exactly when the
segment `[w, v]_x^y` (`def:task-relation`, bracket form) is nonempty. Derived from the
compositionality biconditional and the converse convention; never cited to the paper. -/
theorem taskRel_add_iff_seg_nonempty {W : Type} {R : W → D → W → Prop}
    (hcomp : ∀ w v x y, R w (x + y) v ↔ ∃ u, R w x u ∧ R u y v)
    (hconv : ∀ w d u, R w d u ↔ R u (-d) w)
    (w v : W) (x y : D) :
    R w (x + y) v ↔ (TaskFrame.Seg R w v x y).Nonempty := by
  rw [hcomp]
  constructor
  · rintro ⟨u, h₁, h₂⟩
    exact ⟨u, TaskFrame.mem_Seg.mpr ⟨h₁, (hconv u y v).mp h₂⟩⟩
  · rintro ⟨u, hu⟩
    obtain ⟨h₁, h₂⟩ := TaskFrame.mem_Seg.mp hu
    exact ⟨u, h₁, (hconv u y v).mpr h₂⟩

/-! ## Four-axiom conformance of the generic flow frame

The task relation of `multiFamTaskFrameGen D FamIdx` is the deterministic clock
`R p d q ↔ p.1 = q.1 ∧ q.2 = p.2 + d`. Each axiom of `def:frame` discharges by elementary
group algebra on the second coordinate. -/

/-- Biconditional *Compositionality* (`def:frame#Compositionality`) for the generic flow
frame, in the strong form holding for ALL durations `x, y`. The `←` direction is
composition; the `→` (interpolation) direction goes through the unique intermediate
`(w.1, w.2 + x)`. The paper's positive-cone form is the projection
`multiFamGen_comp_iff_of_nonneg`. -/
theorem multiFamGen_comp_iff [Nontrivial D] {FamIdx : Type} [Nonempty FamIdx] (w v : FamIdx × D) (x y : D) :
    (multiFamTaskFrameGen D FamIdx).TaskRel w (x + y) v ↔
      ∃ u, (multiFamTaskFrameGen D FamIdx).TaskRel w x u ∧
        (multiFamTaskFrameGen D FamIdx).TaskRel u y v := by
  constructor
  · rintro ⟨h₁, h₂⟩
    refine ⟨(w.1, w.2 + x), ⟨rfl, rfl⟩, h₁, ?_⟩
    show v.2 = w.2 + x + y
    rw [h₂]; abel
  · rintro ⟨u, ⟨h₁, h₂⟩, ⟨h₃, h₄⟩⟩
    exact ⟨h₁.trans h₃, by rw [h₄, h₂, add_assoc]⟩

/-- The positive-cone projection of `multiFamGen_comp_iff`: `def:frame#Compositionality`
exactly as the paper states it, "for $x, y \geq 0$". The sign hypotheses are unused because
the strong form holds for all durations. -/
theorem multiFamGen_comp_iff_of_nonneg [Nontrivial D] {FamIdx : Type} [Nonempty FamIdx] (w v : FamIdx × D) (x y : D)
    (_ : 0 ≤ x) (_ : 0 ≤ y) :
    (multiFamTaskFrameGen D FamIdx).TaskRel w (x + y) v ↔
      ∃ u, (multiFamTaskFrameGen D FamIdx).TaskRel w x u ∧
        (multiFamTaskFrameGen D FamIdx).TaskRel u y v :=
  multiFamGen_comp_iff w v x y

/-- *Seriality* (`def:frame#Seriality`) for the generic flow frame: at every duration the
clock supplies both a successor `(w.1, w.2 + x)` and a predecessor `(w.1, w.2 - x)`. Stated
for all durations, so the paper's `x ≥ 0` proviso is subsumed. -/
theorem multiFamGen_serial [Nontrivial D] {FamIdx : Type} [Nonempty FamIdx] (w : FamIdx × D) (x : D) :
    (∃ u, (multiFamTaskFrameGen D FamIdx).TaskRel w x u) ∧
      (∃ v, (multiFamTaskFrameGen D FamIdx).TaskRel v x w) :=
  ⟨⟨(w.1, w.2 + x), rfl, rfl⟩, ⟨(w.1, w.2 - x), rfl, by show w.2 = w.2 - x + x; abel⟩⟩

/-- *Limit* (`def:frame#Limit`) for the generic flow frame, discharged by
`ParamTaskFrame.limit_of_shift` with position function `Prod.snd`: the clock relation makes the
duration of a transition recoverable from its endpoints. `[Nontrivial D]` is required,
matching `def:temporal-order`'s mandate that the temporal order be nontrivial. -/
theorem multiFamGen_limit [Nontrivial D] {FamIdx : Type} [Nonempty FamIdx] :
    ∀ w u : FamIdx × D,
      (∀ x, 0 < x → ∃ y, |y| < x ∧ (multiFamTaskFrameGen D FamIdx).TaskRel w y u) → u = w :=
  ParamTaskFrame.limit_of_shift Prod.snd
    (fun _ _ _ h => h.2)
    (fun w u h => (((multiFamTaskFrameGen D FamIdx).nullity_identity w u).mp h).symm)

/-- Every fiber (`def:task-relation`, *Fiber* clause) of the generic flow frame is a
subsingleton: the clock is deterministic, so `Fib R w x ⊆ {(w.1, w.2 + x)}`. -/
theorem multiFamGen_fib_subsingleton [Nontrivial D] {FamIdx : Type} [Nonempty FamIdx] (w : FamIdx × D) (x : D) :
    (TaskFrame.Fib (multiFamTaskFrameGen D FamIdx).TaskRel w x).Subsingleton := by
  rintro u ⟨hu₁, hu₂⟩ u' ⟨hu'₁, hu'₂⟩
  exact Prod.ext (hu₁.symm.trans hu'₁) (hu₂.trans hu'₂.symm)

/-- *Spherical* (`def:frame#Spherical`) for the generic flow frame: every fiber is a
singleton and every segment is an intersection of fibers, hence a subsingleton, so a
directed family (`def:directed`) of nonempty fibers and segments meets the hypotheses of
`sInter_nonempty_of_directed_subsingleton`. -/
theorem multiFamGen_spherical [Nontrivial D] {FamIdx : Type} [Nonempty FamIdx] (S : Set (Set (FamIdx × D)))
    (hdir : TaskFrame.DirectedFamily S)
    (hne : ∀ s ∈ S, s.Nonempty)
    (hfs : ∀ s ∈ S, TaskFrame.IsFiber (multiFamTaskFrameGen D FamIdx).TaskRel s ∨
      TaskFrame.IsSegment (multiFamTaskFrameGen D FamIdx).TaskRel s) :
    (⋂₀ S).Nonempty := by
  refine sInter_nonempty_of_directed_subsingleton hdir hne fun s hs => ?_
  rcases hfs s hs with ⟨w, x, rfl⟩ | ⟨w, v, x, y, _, _, rfl⟩
  · exact multiFamGen_fib_subsingleton w x
  · exact (multiFamGen_fib_subsingleton w x).anti Set.inter_subset_left

/-! ### The same four axioms in the bare-relation predicate form

The four lemmas above are stated pointwise, in the shapes their own proofs produce. The four
below restate exactly the same content in `TaskFrame.Serial` / `TaskFrame.Interpolates` /
`TaskFrame.Spherical` — the bare-relation predicates of record (`TaskFrame.lean`) — so that they
are citable verbatim when the frame structure grows the corresponding fields. *Limit* needs no
restatement: `multiFamGen_limit` is already in the literal transcribed shape. Nothing here is a
new argument; each is a repackaging of the lemma directly above it. -/

/-- *Seriality* (`def:frame#Seriality`, verbatim: "$w \Rightarrow_x u$ and $v \Rightarrow_x w$
for some $u, v \in W$") for the generic flow frame, as the predicate of record. Repackages
`multiFamGen_serial`; the paper's `x ≥ 0` proviso is `Serial`'s own hypothesis and is unused,
since the clock supplies witnesses at every duration. -/
theorem multiFamTaskFrameGen_serial [Nontrivial D] {FamIdx : Type} [Nonempty FamIdx] :
    TaskFrame.Serial (multiFamTaskFrameGen D FamIdx).TaskRel :=
  fun w x _ => multiFamGen_serial w x

/-- The interpolation half of *Compositionality* (`def:frame#Compositionality`, verbatim:
"$w \Rightarrow_{x + y} v$ if and only if $w \Rightarrow_x u$ and $u \Rightarrow_y v$ for some
$u \in W$") for the generic flow frame, as the predicate of record. This is the `→` direction of
`multiFamGen_comp_iff`, whose `←` direction is the frame's `forward_comp` field. -/
theorem multiFamTaskFrameGen_interpolates [Nontrivial D] {FamIdx : Type} [Nonempty FamIdx] :
    TaskFrame.Interpolates (multiFamTaskFrameGen D FamIdx).TaskRel :=
  fun w v x y _ _ h => (multiFamGen_comp_iff w v x y).mp h

/-- *Limit* (`def:frame#Limit`, verbatim: "$\bigcap\limits_{x > 0} (w)_x = \set{w}$") for the
generic flow frame, in the literal transcribed shape. An alias of `multiFamGen_limit` under this
section's naming convention; `[Nontrivial D]` is required, per `def:temporal-order`. -/
theorem multiFamTaskFrameGen_limit [Nontrivial D] {FamIdx : Type} [Nonempty FamIdx] :
    ∀ w u : FamIdx × D,
      (∀ x, 0 < x → ∃ y, |y| < x ∧ (multiFamTaskFrameGen D FamIdx).TaskRel w y u) → u = w :=
  multiFamGen_limit

/-- *Spherical* (`def:frame#Spherical`, verbatim: "$\bigcap \mathcal{S} \neq \emptyset$ for any
$\supseteq$-directed family $\mathcal{S}$ of nonempty fibers and segments") for the generic flow
frame, as the predicate of record. Repackages `multiFamGen_spherical`, splitting `Spherical`'s
single per-member conjunction into that lemma's two separate hypotheses. -/
theorem multiFamTaskFrameGen_spherical [Nontrivial D] {FamIdx : Type} [Nonempty FamIdx] :
    TaskFrame.Spherical (multiFamTaskFrameGen D FamIdx).TaskRel :=
  fun S hdir hmem =>
    multiFamGen_spherical S hdir (fun s hs => (hmem s hs).2) (fun s hs => (hmem s hs).1)

/-! ## The totality characterization

`def:world-history`: "A world history is *total* — equivalently, a *possible world* — just
in case X = D." For the deterministic flow frame, every total history is a flow line: the
state at time `0` fixes the family index and the offset, and `respects_task` propagates the
clock to every other time. Together with the (definitional) totality of
`multiFamHistoryGen`, this identifies the frame's total-history set H_F with the flow-line
family — the internalization the total-history countermodels rest on. -/

/-- Every total history of the generic flow frame is a flow line: if `σ.domain` is full
(`def:world-history`'s totality, X = D), then `σ = multiFamHistoryGen f w₀` for the family
index and offset read off from `σ` at time `0`. -/
theorem multiFamGen_total_eq [Nontrivial D] {FamIdx : Type} [Nonempty FamIdx]
    (σ : WorldHistory (multiFamTaskFrameGen D FamIdx)) (htot : ∀ t, σ.domain t) :
    ∃ f w₀, σ = multiFamHistoryGen f w₀ := by
  -- The state at any time is the state at time 0 advanced by the clock.
  have key : ∀ (t : D) (ht : σ.domain t),
      σ.states t ht = ((σ.states 0 (htot 0)).1, (σ.states 0 (htot 0)).2 + t) := by
    intro t ht
    rcases le_total 0 t with _h0t | _ht0
    · obtain ⟨h₁, h₂⟩ := σ.respects_task 0 t (htot 0) ht
      refine Prod.ext h₁.symm ?_
      rw [h₂]; abel_nf
    · obtain ⟨h₁, h₂⟩ := σ.respects_task t 0 ht (htot 0)
      refine Prod.ext h₁ ?_
      rw [h₂]; abel_nf
  refine ⟨(σ.states 0 (htot 0)).1, (σ.states 0 (htot 0)).2, ?_⟩
  obtain ⟨⟨dom, nedom, sts, resp⟩, conv⟩ := σ
  -- Totality collapses the domain to the full predicate.
  have hdom : dom = fun _ => True :=
    funext fun t => propext ⟨fun _ => trivial, fun _ => htot t⟩
  subst hdom
  have h_states : sts = fun t (_ : True) =>
      ((sts 0 (htot 0)).1, (sts 0 (htot 0)).2 + t) :=
    funext fun t => funext fun ht => key t ht
  change WorldHistory.mk (PartialHistory.mk _ _ _ _) _ =
    WorldHistory.mk (PartialHistory.mk _ _ _ _) _
  congr 2

/-- The generic flow frame's total-history set `H_F` **is** the set of flow lines, as a set
equation.

`def:world-history` fixes `H_F` as the totality-cut of the world histories: "A world history is
*total* --- equivalently, a *possible world* --- just in case $X = D$. ... The set of all total
world histories over $\F$ is denoted $H_{\F}$." Here the totality predicate `X = D` is spelled
`∀ t, σ.domain t`.

The `⊇` direction is definitional: `multiFamHistoryGen` carries `domain := fun _ => True`. The
`⊆` direction is `multiFamGen_total_eq`. This is the extensional content the box clause
(`def:BL-semantics`, "for all $\sigma \in H_{\F}$") quantifies over on this carrier. -/
theorem multiFamGen_total_eq_range [Nontrivial D] (FamIdx : Type) [Nonempty FamIdx] :
    {σ : WorldHistory (multiFamTaskFrameGen D FamIdx) | ∀ t, σ.domain t} =
      Set.range (fun (p : FamIdx × D) => multiFamHistoryGen p.1 p.2) := by
  ext σ
  constructor
  · intro htot
    obtain ⟨f, w₀, rfl⟩ := multiFamGen_total_eq σ htot
    exact ⟨⟨f, w₀⟩, rfl⟩
  · rintro ⟨⟨f, w₀⟩, rfl⟩ t
    trivial

end FlowFrameConformance

/-! ## The bundle flow frame

The dense/Dedekind countermodel carrier: the generic flow frame instantiated at the index of
a bundle's own families. Because the carrier contains ONLY bundle families, the frame's total
histories (`def:world-history`'s H_F) are exactly the bundle's flow lines — the countermodel
family IS H_F, by `bundleFlow_total_eq`. The four `def:frame` axioms and the totality
characterization are inherited from the generic layer by specialization; no new proof content
appears here.

The carrier `{fam // fam ∈ B.families} × D` with position function `Prod.snd` and
`TaskRel w y u → u.2 = w.2 + y` (`bundleFlow_pos_shift`) is the deterministic-shift shape
`ParamTaskFrame.limit_of_shift` consumes. -/

section BundleFlow

variable {D : Type} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]
variable {fc : FrameClass}

/-- The bundle's family index is nonempty, so the bundle flow frame's carrier is.

**This is derived, not postulated**, and no new `BFMCS` field was added for it: `BFMCS` already
carries `evalFamily` together with `eval_family_mem : evalFamily ∈ families`, which is exactly an
inhabitant of the subtype. (`BFMCS.nonempty : families.Nonempty` would serve equally; the
distinguished evaluation family is used because it is the canonical choice and needs no
`choice`.) Every consumer of `bundleFlowFrame` therefore keeps its present binder list. -/
instance bundleFamilies_nonempty (B : BFMCS (fc := fc) D) :
    Nonempty {fam : FMCS (fc := fc) D // fam ∈ B.families} :=
  ⟨⟨B.evalFamily, B.eval_family_mem⟩⟩

/-- The bundle flow frame: the generic flow frame `multiFamTaskFrameGen` at the index of the
bundle's families. World states are pairs of a bundle family and a time; the task relation is
the deterministic clock. -/
noncomputable def bundleFlowFrame [Nontrivial D] (B : BFMCS (fc := fc) D) : ParamTaskFrame D :=
  multiFamTaskFrameGen D {fam : FMCS (fc := fc) D // fam ∈ B.families}

/-- The flow line of the bundle flow frame through family `fam` at offset `w₀`: the total
history visiting `(fam, w₀ + t)` at each time `t`. -/
noncomputable def bundleFlowHistory [Nontrivial D] {B : BFMCS (fc := fc) D}
    (fam : {fam : FMCS (fc := fc) D // fam ∈ B.families}) (w₀ : D) :
    WorldHistory (bundleFlowFrame B) :=
  multiFamHistoryGen fam w₀

/-- The bundle flow model: an atom holds at `(fam, w)` exactly when it is in `fam`'s MCS at
time `w`. -/
noncomputable def bundleFlowModel [Nontrivial D] (B : BFMCS (fc := fc) D) : TaskModel (bundleFlowFrame B) where
  valuation := fun w p => Formula.atom p ∈ w.1.val.mcs w.2

/-- Every flow line of the bundle flow frame is total (`def:world-history`: X = D). -/
theorem bundleFlowHistory_total [Nontrivial D] {B : BFMCS (fc := fc) D}
    (fam : {fam : FMCS (fc := fc) D // fam ∈ B.families}) (w₀ : D) :
    ∀ t, (bundleFlowHistory fam w₀).domain t :=
  fun _ => trivial

/-- Deterministic-shift conformance of the bundle flow frame: the duration of a transition is
recoverable from the endpoint positions (`Prod.snd`). This is the position-function contract
`ParamTaskFrame.limit_of_shift` consumes. -/
theorem bundleFlow_pos_shift [Nontrivial D] {B : BFMCS (fc := fc) D}
    {w u : (bundleFlowFrame B).WorldState} {y : D}
    (h : (bundleFlowFrame B).TaskRel w y u) : u.2 = w.2 + y :=
  h.2

/-- Biconditional *Compositionality* (`def:frame#Compositionality`) at the bundle flow frame,
by specialization of `multiFamGen_comp_iff`. -/
theorem bundleFlow_comp_iff [Nontrivial D] {B : BFMCS (fc := fc) D}
    (w v : (bundleFlowFrame B).WorldState) (x y : D) :
    (bundleFlowFrame B).TaskRel w (x + y) v ↔
      ∃ u, (bundleFlowFrame B).TaskRel w x u ∧ (bundleFlowFrame B).TaskRel u y v :=
  multiFamGen_comp_iff w v x y

/-- *Seriality* (`def:frame#Seriality`) at the bundle flow frame, by specialization of
`multiFamGen_serial`. -/
theorem bundleFlow_serial [Nontrivial D] {B : BFMCS (fc := fc) D}
    (w : (bundleFlowFrame B).WorldState) (x : D) :
    (∃ u, (bundleFlowFrame B).TaskRel w x u) ∧
      (∃ v, (bundleFlowFrame B).TaskRel v x w) :=
  multiFamGen_serial w x

/-- *Limit* (`def:frame#Limit`) at the bundle flow frame, by specialization of
`multiFamGen_limit`. -/
theorem bundleFlow_limit [Nontrivial D] {B : BFMCS (fc := fc) D} :
    ∀ w u : (bundleFlowFrame B).WorldState,
      (∀ x, 0 < x → ∃ y, |y| < x ∧ (bundleFlowFrame B).TaskRel w y u) → u = w :=
  multiFamGen_limit

/-- *Spherical* (`def:frame#Spherical`) at the bundle flow frame, by specialization of
`multiFamGen_spherical`. -/
theorem bundleFlow_spherical [Nontrivial D] {B : BFMCS (fc := fc) D}
    (S : Set (Set (bundleFlowFrame B).WorldState))
    (hdir : TaskFrame.DirectedFamily S)
    (hne : ∀ s ∈ S, s.Nonempty)
    (hfs : ∀ s ∈ S, TaskFrame.IsFiber (bundleFlowFrame B).TaskRel s ∨
      TaskFrame.IsSegment (bundleFlowFrame B).TaskRel s) :
    (⋂₀ S).Nonempty :=
  multiFamGen_spherical S hdir hne hfs

/-- The totality characterization at the bundle flow frame: every total history is a flow
line through a bundle family. Together with `bundleFlowHistory_total`, this identifies the
frame's total-history set H_F (`def:world-history`) with the bundle's flow-line family. -/
theorem bundleFlow_total_eq [Nontrivial D] {B : BFMCS (fc := fc) D}
    (σ : WorldHistory (bundleFlowFrame B)) (htot : ∀ t, σ.domain t) :
    ∃ fam w₀, σ = bundleFlowHistory fam w₀ :=
  multiFamGen_total_eq σ htot

/-! ## The bundle flow frame's total-history set

The bundle flow frame's total-history set H_F (`def:world-history`) is exactly its set of flow
lines, by `bundleFlowHistory_total` and `bundleFlow_total_eq`. This is what the box clause
quantifies over per `def:BL-semantics` ("M,σ,x ⊨ φ for all σ ∈ H_F"). -/

/-- The bundle flow frame's total-history set `H_F` (`def:world-history`: "The set of all total
world histories over $\F$ is denoted $H_{\F}$") **is** its set of flow lines.

Immediate specialization of `multiFamGen_total_eq_range` at the bundle index, since
`bundleFlowFrame` is `multiFamTaskFrameGen` at that index by definition. -/
theorem bundleFlow_total_eq_range [Nontrivial D] (B : BFMCS (fc := fc) D) :
    {σ : WorldHistory (bundleFlowFrame B) | ∀ t, σ.domain t} =
      Set.range (fun (p : {fam : FMCS (fc := fc) D // fam ∈ B.families} × D) =>
        bundleFlowHistory p.1 p.2) :=
  multiFamGen_total_eq_range _

/-! ## Helper tautologies for the implication case

Classical propositional facts about `neg (ψ → χ)`, transcribed unchanged from the private
helpers of the retired restricted parametric truth-lemma module (deleted with the rest of the
parametric canonical stack; this module's truth lemma is its replacement). -/

/-- Classical tautology: `neg (ψ → χ) → ψ`. -/
private noncomputable def neg_imp_antecedent (ψ χ : Formula) :
    DerivationTree fc [] ((ψ.imp χ).neg.imp ψ) := by
  have h_efq : DerivationTree FrameClass.Base [] (ψ.neg.imp (ψ.imp χ)) :=
    FormalSystem.Theorems.Propositional.impOfNeg ψ χ
  have h_efq_ctx : [ψ.neg, (ψ.imp χ).neg] ⊢ ψ.neg.imp (ψ.imp χ) :=
    DerivationTree.weakening [] [ψ.neg, (ψ.imp χ).neg] _ h_efq (by intro; simp)
  have h_neg_psi : [ψ.neg, (ψ.imp χ).neg] ⊢ ψ.neg :=
    DerivationTree.assumption _ _ (by simp)
  have h_imp : [ψ.neg, (ψ.imp χ).neg] ⊢ ψ.imp χ :=
    DerivationTree.modus_ponens _ _ _ h_efq_ctx h_neg_psi
  have h_neg_imp : [ψ.neg, (ψ.imp χ).neg] ⊢ (ψ.imp χ).neg :=
    DerivationTree.assumption _ _ (by simp)
  have h_bot : [ψ.neg, (ψ.imp χ).neg] ⊢ Formula.bot :=
    DerivationTree.modus_ponens _ _ _ h_neg_imp h_imp
  have h_neg_neg_psi : [(ψ.imp χ).neg] ⊢ ψ.neg.neg :=
    FormalSystem.Metalogic.Core.deductionTheorem [(ψ.imp χ).neg] ψ.neg Formula.bot h_bot
  have h_deduct : [] ⊢ (ψ.imp χ).neg.imp ψ.neg.neg :=
    FormalSystem.Metalogic.Core.deductionTheorem [] (ψ.imp χ).neg ψ.neg.neg h_neg_neg_psi
  have h_dne : [] ⊢ ψ.neg.neg.imp ψ :=
    FormalSystem.Theorems.Propositional.doubleNegation ψ
  have h_b : [] ⊢ (ψ.neg.neg.imp ψ).imp
      (((ψ.imp χ).neg.imp ψ.neg.neg).imp ((ψ.imp χ).neg.imp ψ)) :=
    FormalSystem.Theorems.Combinators.bCombinator
  have h_step1 : [] ⊢ ((ψ.imp χ).neg.imp ψ.neg.neg).imp ((ψ.imp χ).neg.imp ψ) :=
    DerivationTree.modus_ponens _ _ _ h_b h_dne
  have h_base : [] ⊢ (ψ.imp χ).neg.imp ψ :=
    DerivationTree.modus_ponens _ _ _ h_step1 h_deduct
  exact h_base.lift (by cases fc <;> trivial)

/-- Classical tautology: `neg (ψ → χ) → neg χ`. -/
private noncomputable def neg_imp_neg_consequent (ψ χ : Formula) :
    DerivationTree fc [] ((ψ.imp χ).neg.imp χ.neg) := by
  have h_prop_s : [] ⊢ χ.imp (ψ.imp χ) :=
    DerivationTree.axiom [] _ (Axiom.prop_s χ ψ) trivial
  have h_prop_s_ctx : [χ, (ψ.imp χ).neg] ⊢ χ.imp (ψ.imp χ) :=
    DerivationTree.weakening [] [χ, (ψ.imp χ).neg] _ h_prop_s (by intro; simp)
  have h_chi : [χ, (ψ.imp χ).neg] ⊢ χ := DerivationTree.assumption _ _ (by simp)
  have h_imp : [χ, (ψ.imp χ).neg] ⊢ ψ.imp χ :=
    DerivationTree.modus_ponens _ _ _ h_prop_s_ctx h_chi
  have h_neg_imp : [χ, (ψ.imp χ).neg] ⊢ (ψ.imp χ).neg :=
    DerivationTree.assumption _ _ (by simp)
  have h_bot : [χ, (ψ.imp χ).neg] ⊢ Formula.bot :=
    DerivationTree.modus_ponens _ _ _ h_neg_imp h_imp
  have h_neg_chi : [(ψ.imp χ).neg] ⊢ χ.neg :=
    FormalSystem.Metalogic.Core.deductionTheorem [(ψ.imp χ).neg] χ Formula.bot h_bot
  have h_base : [] ⊢ (ψ.imp χ).neg.imp χ.neg :=
    FormalSystem.Metalogic.Core.deductionTheorem [] (ψ.imp χ).neg χ.neg h_neg_chi
  exact h_base.lift (by cases fc <;> trivial)

/-! ## Box persistence

`□φ` in an FMCS at one time is `□φ` at every time, via the TF axiom (`□φ → G□φ`) and its
temporal dual (`□φ → H□φ`). Relocated from the superseded parametric truth-lemma module;
purely MCS-level, frame-independent. -/

/-- Past analog of TF axiom: `□φ → H(□φ)`, derived via temporal duality. -/
private def past_tf_deriv (φ : Formula) :
    DerivationTree fc [] ((Formula.box φ).imp (Formula.box φ).allPast) := by
  have h_tf_swap : DerivationTree fc [] _ :=
      FormalSystem.Theorems.Combinators.temporalFutureDerived (Formula.swapTemporal φ)
  have h_dual := DerivationTree.temporal_duality _ h_tf_swap
  have h_eq : Formula.swapTemporal ((Formula.box (Formula.swapTemporal φ)).imp
      (Formula.box (Formula.swapTemporal φ)).allFuture) =
    (Formula.box φ).imp (Formula.box φ).allPast := by
    simp [Formula.swapTemporal, Formula.swap_temporal_involution]
  rw [h_eq] at h_dual
  exact h_dual

omit [AddCommGroup D] [IsOrderedAddMonoid D] in
/-- `□φ` at time `t` implies `□φ` at every time `s`, for any FMCS family.

The proof uses the TF axiom (`□φ → G□φ`), its temporal dual (`□φ → H□φ`), and
`forward_G`/`backward_H` to extract `□φ` at the target time. -/
theorem fmcs_box_persistent
    (fam : FMCS (fc := fc) D)
    (φ : Formula) (t s : D)
    (h_box : Formula.box φ ∈ fam.mcs t) :
    Formula.box φ ∈ fam.mcs s := by
  have h_tf : (Formula.box φ).imp (Formula.box φ).allFuture ∈ fam.mcs t :=
    theorem_in_mcs (fam.is_mcs t) (FormalSystem.Theorems.Combinators.temporalFutureDerived φ)
  have h_G_box : (Formula.box φ).allFuture ∈ fam.mcs t :=
    SetMaximalConsistent.implication_property (fam.is_mcs t) h_tf h_box
  have h_past_tf : (Formula.box φ).imp (Formula.box φ).allPast ∈ fam.mcs t :=
    theorem_in_mcs (fam.is_mcs t) (past_tf_deriv φ)
  have h_H_box : (Formula.box φ).allPast ∈ fam.mcs t :=
    SetMaximalConsistent.implication_property (fam.is_mcs t) h_past_tf h_box
  rcases lt_trichotomy t s with h_lt | h_eq | h_gt
  · exact fam.forward_G t s (Formula.box φ) h_lt h_G_box
  · exact h_eq ▸ h_box
  · exact fam.backward_H t s (Formula.box φ) h_gt h_H_box

/-! ## The re-hosted dense truth lemma

Re-host of the fully-restricted parametric shifted truth lemma (from the retired restricted
parametric truth-lemma module, deleted with the parametric canonical stack whose frame
violated `def:frame#Limit` over dense duration types) onto the bundle flow frame: the flow line
`bundleFlowHistory fam w₀` at evaluation time `t` visits `(fam, w₀ + t)`, so truth at `t`
corresponds to MCS membership at absolute time `w₀ + t` — the flow history at offset `w₀` IS
the shifted history, and the separate "shifted" formulation dissolves. Because the carrier
contains ONLY bundle families, the frame's full total-history set is exactly the flow-line
family (`bundleFlow_total_eq`): internalization holds by construction, with no transfer or
realization lemma.

Case inventory: atom is definitional MCS membership; bot/imp use MCS consistency and closure;
untl/snce use the bundle's restricted Until/Since coherence (frame-independent, preserved
verbatim modulo the `± w₀` clock translation); box uses `fmcs_box_persistent` plus
`B.modal_forward`/`B.modal_backward`, destructuring the quantified history against
**totality** (`bundleFlow_total_eq`) rather than against an admissible-history parameter — the
box clause quantifies over `H_F` per `def:BL-semantics`, and `TruthAt` carries no set argument
at all. -/

/--
**Re-hosted dense truth lemma.** For `φ ∈ subformulaClosure root`, membership of `φ` in a
bundle family's MCS at absolute time `w₀ + t` coincides with truth of `φ` at evaluation time
`t` along the flow line through that family at offset `w₀`.
-/
theorem bundleFlow_truth_lemma [Nontrivial D] (B : BFMCS (fc := fc) D) (root : Formula)
    (_h_rtc : B.RestrictedTemporallyCoherent root)
    (h_buc : B.RestrictedBackwardUntilSinceCoherent root)
    (h_fuc : B.RestrictedForwardUntilSinceCoherent root) (φ : Formula)
    (h_sub : φ ∈ subformulaClosure root)
    (fam : {fam : FMCS (fc := fc) D // fam ∈ B.families}) (w₀ t : D) :
    φ ∈ fam.val.mcs (w₀ + t) ↔
    TruthAt (bundleFlowModel B) (bundleFlowHistory fam w₀) t φ := by
  induction φ generalizing fam w₀ t with
  | atom p =>
    simp only [TruthAt, bundleFlowModel, bundleFlowHistory, multiFamHistoryGen]
    constructor
    · intro h_mem
      exact ⟨trivial, h_mem⟩
    · intro ⟨_, h_val⟩
      exact h_val
  | bot =>
    simp only [TruthAt]
    constructor
    · intro h_mem
      exfalso
      have h_cons := (fam.val.is_mcs (w₀ + t)).1
      have h_deriv : DerivationTree fc [Formula.bot] Formula.bot :=
        DerivationTree.assumption [Formula.bot] Formula.bot (by simp)
      exact h_cons [Formula.bot] (fun psi hpsi => by simp only
          [List.mem_cons, List.not_mem_nil, or_false] at hpsi; rw [hpsi]; exact h_mem) ⟨h_deriv⟩
    · intro h; exact h.elim
  | imp ψ χ ih_ψ ih_χ =>
    have h_ψ_sub : ψ ∈ subformulaClosure root := closure_imp_left root ψ χ h_sub
    have h_χ_sub : χ ∈ subformulaClosure root := closure_imp_right root ψ χ h_sub
    simp only [TruthAt]
    have h_mcs := fam.val.is_mcs (w₀ + t)
    constructor
    · intro h_imp h_ψ_true
      have h_ψ_mem := (ih_ψ h_ψ_sub fam w₀ t).mpr h_ψ_true
      exact (ih_χ h_χ_sub fam w₀ t).mp
        (SetMaximalConsistent.implication_property h_mcs h_imp h_ψ_mem)
    · intro h_truth_imp
      rcases SetMaximalConsistent.negation_complete h_mcs (ψ.imp χ) with h_imp | h_neg_imp
      · exact h_imp
      · exfalso
        have h_ψ_mcs : ψ ∈ fam.val.mcs (w₀ + t) :=
          SetMaximalConsistent.closed_under_derivation h_mcs [(ψ.imp χ).neg]
            (by simp [h_neg_imp])
            (DerivationTree.modus_ponens _ _ _
              (DerivationTree.weakening [] _ _ (neg_imp_antecedent ψ χ) (by intro; simp))
              (DerivationTree.assumption _ _ (by simp)))
        have h_neg_χ_mcs : χ.neg ∈ fam.val.mcs (w₀ + t) :=
          SetMaximalConsistent.closed_under_derivation h_mcs [(ψ.imp χ).neg]
            (by simp [h_neg_imp])
            (DerivationTree.modus_ponens _ _ _
              (DerivationTree.weakening [] _ _ (neg_imp_neg_consequent ψ χ) (by intro; simp))
              (DerivationTree.assumption _ _ (by simp)))
        have h_χ_mcs : χ ∈ fam.val.mcs (w₀ + t) :=
          (ih_χ h_χ_sub fam w₀ t).mpr (h_truth_imp ((ih_ψ h_ψ_sub fam w₀ t).mp h_ψ_mcs))
        exact set_consistent_not_both (fam.val.is_mcs (w₀ + t)).1 χ h_χ_mcs h_neg_χ_mcs
  | box ψ ih =>
    have h_ψ_sub : ψ ∈ subformulaClosure root := closure_box root ψ h_sub
    constructor
    · intro h_box σ h_σ_mem
      obtain ⟨fam', w₀', rfl⟩ := bundleFlow_total_eq σ h_σ_mem
      have h_box' : Formula.box ψ ∈ fam.val.mcs (w₀' + t) :=
        fmcs_box_persistent fam.val ψ (w₀ + t) (w₀' + t) h_box
      have h_ψ_fam' : ψ ∈ fam'.val.mcs (w₀' + t) :=
        B.modal_forward fam.val fam.property ψ (w₀' + t) h_box' fam'.val fam'.property
      exact (ih h_ψ_sub fam' w₀' t).mp h_ψ_fam'
    · intro h_all_σ
      have h_all_fam : ∀ fam' ∈ B.families, ψ ∈ fam'.mcs (w₀ + t) := by
        intro fam' hfam'
        exact (ih h_ψ_sub ⟨fam', hfam'⟩ w₀ t).mpr
          (h_all_σ (bundleFlowHistory ⟨fam', hfam'⟩ w₀) (bundleFlowHistory_total _ _))
      exact B.modal_backward fam.val fam.property ψ (w₀ + t) h_all_fam
  | untl β α ih_β ih_α =>
    have h_α_sub : α ∈ subformulaClosure root := closure_untl_left root α β h_sub
    have h_β_sub : β ∈ subformulaClosure root := closure_untl_right root α β h_sub
    simp only [TruthAt]
    obtain ⟨h_fwd_U, _⟩ := h_fuc fam.val fam.property
    obtain ⟨h_bwd_U, _⟩ := h_buc fam.val fam.property
    constructor
    · intro h_U
      obtain ⟨s, h_ts, h_α_s, h_β_guard⟩ := h_fwd_U (w₀ + t) α β h_sub h_U
      refine ⟨s - w₀, lt_sub_iff_add_lt'.mpr h_ts, ?_, ?_⟩
      · refine (ih_α h_α_sub fam w₀ (s - w₀)).mp ?_
        rw [show w₀ + (s - w₀) = s from by abel]
        exact h_α_s
      · intro r h_tr h_rs
        exact (ih_β h_β_sub fam w₀ r).mp
          (h_β_guard (w₀ + r) ((add_lt_add_iff_left w₀).mpr h_tr) (lt_sub_iff_add_lt'.mp h_rs))
    · rintro ⟨s, h_ts, h_α_s, h_β_guard⟩
      refine h_bwd_U (w₀ + t) α β h_sub
        ⟨w₀ + s, (add_lt_add_iff_left w₀).mpr h_ts, (ih_α h_α_sub fam w₀ s).mpr h_α_s, ?_⟩
      intro r h_tr h_rs
      have h_mem := (ih_β h_β_sub fam w₀ (r - w₀)).mpr
        (h_β_guard (r - w₀) (lt_sub_iff_add_lt'.mpr h_tr) (sub_lt_iff_lt_add'.mpr h_rs))
      rwa [show w₀ + (r - w₀) = r from by abel] at h_mem
  | snce β α ih_β ih_α =>
    have h_α_sub : α ∈ subformulaClosure root := closure_snce_left root α β h_sub
    have h_β_sub : β ∈ subformulaClosure root := closure_snce_right root α β h_sub
    simp only [TruthAt]
    obtain ⟨_, h_fwd_S⟩ := h_fuc fam.val fam.property
    obtain ⟨_, h_bwd_S⟩ := h_buc fam.val fam.property
    constructor
    · intro h_S
      obtain ⟨s, h_st, h_α_s, h_β_guard⟩ := h_fwd_S (w₀ + t) α β h_sub h_S
      refine ⟨s - w₀, sub_lt_iff_lt_add'.mpr h_st, ?_, ?_⟩
      · refine (ih_α h_α_sub fam w₀ (s - w₀)).mp ?_
        rw [show w₀ + (s - w₀) = s from by abel]
        exact h_α_s
      · intro r h_sr h_rt
        exact (ih_β h_β_sub fam w₀ r).mp
          (h_β_guard (w₀ + r) (sub_lt_iff_lt_add'.mp h_sr) ((add_lt_add_iff_left w₀).mpr h_rt))
    · rintro ⟨s, h_st, h_α_s, h_β_guard⟩
      refine h_bwd_S (w₀ + t) α β h_sub
        ⟨w₀ + s, (add_lt_add_iff_left w₀).mpr h_st, (ih_α h_α_sub fam w₀ s).mpr h_α_s, ?_⟩
      intro r h_sr h_rt
      have h_mem := (ih_β h_β_sub fam w₀ (r - w₀)).mpr
        (h_β_guard (r - w₀) (lt_sub_iff_add_lt'.mpr h_sr) (sub_lt_iff_lt_add'.mpr h_rt))
      rwa [show w₀ + (r - w₀) = r from by abel] at h_mem

/--
**Re-hosted countermodel engine.** If `φ.neg` is in a bundle family's MCS at absolute time
`w₀ + t`, then `φ` is false at evaluation time `t` along that family's flow line at offset
`w₀`. This is the bundle-flow form of
`fully_restricted_parametric_completeness_from_neg_membership`.
-/
theorem bundleFlow_completeness_from_neg_membership [Nontrivial D] (B : BFMCS (fc := fc) D) (root : Formula)
    (h_rtc : B.RestrictedTemporallyCoherent root)
    (h_buc : B.RestrictedBackwardUntilSinceCoherent root)
    (h_fuc : B.RestrictedForwardUntilSinceCoherent root)
    (φ : Formula) (h_sub : φ ∈ subformulaClosure root)
    (fam : {fam : FMCS (fc := fc) D // fam ∈ B.families}) (w₀ t : D)
    (h_neg_in : φ.neg ∈ fam.val.mcs (w₀ + t)) :
    ¬TruthAt (bundleFlowModel B) (bundleFlowHistory fam w₀) t φ := by
  intro h_phi_true
  have h_phi_in :=
    (bundleFlow_truth_lemma B root h_rtc h_buc h_fuc φ h_sub fam w₀ t).mpr h_phi_true
  exact set_consistent_not_both (fam.val.is_mcs (w₀ + t)).1 φ h_phi_in h_neg_in

end BundleFlow

end FormalSystem.Metalogic.Algebraic
