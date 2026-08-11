/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.TaskFrame
import FormalSystem.Metalogic.BXCanonical.Chronicle.ChronicleMonadicBridge

/-!
# FlowFrame - Generic Flow-Frame Conformance and Totality Layer

This module proves, once and D-generically, that the deterministic multi-family flow frame
`multiFamTaskFrameGen` (`ChronicleMonadicBridge.lean`) satisfies all four axioms of the
paper's frame definition (`def:frame`), and characterizes its total histories as flow lines.

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
  `multiFamGen_limit`, via `TaskFrame.limit_of_shift` with `pos := Prod.snd`.
- *Spherical* (`def:frame#Spherical`, verbatim): "$\bigcap \mathcal{S} \neq \emptyset$ for
  any directed family $\mathcal{S}$ of nonempty fibers and segments" —
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

## References

* [TaskFrame.lean](../../Semantics/TaskFrame.lean) - frame structure, apparatus, Limit helpers
* [ChronicleMonadicBridge.lean](../BXCanonical/Chronicle/ChronicleMonadicBridge.lean) -
  the generic flow frame `multiFamTaskFrameGen` / `multiFamHistoryGen`
* JPL Paper anchors `def:frame` (sub-anchors `def:frame#Compositionality`,
  `def:frame#Seriality`, `def:frame#Limit`, `def:frame#Spherical`), `def:task-relation`,
  `def:directed`, `def:world-history` — cited by `\label` anchor, never by line number
-/

namespace FormalSystem.Metalogic.Algebraic

open FormalSystem.Semantics
open FormalSystem.Metalogic.BXCanonical.Chronicle

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

variable {D : Type} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]

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
theorem multiFamGen_comp_iff {FamIdx : Type} (w v : FamIdx × D) (x y : D) :
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
theorem multiFamGen_comp_iff_of_nonneg {FamIdx : Type} (w v : FamIdx × D) (x y : D)
    (_ : 0 ≤ x) (_ : 0 ≤ y) :
    (multiFamTaskFrameGen D FamIdx).TaskRel w (x + y) v ↔
      ∃ u, (multiFamTaskFrameGen D FamIdx).TaskRel w x u ∧
        (multiFamTaskFrameGen D FamIdx).TaskRel u y v :=
  multiFamGen_comp_iff w v x y

/-- *Seriality* (`def:frame#Seriality`) for the generic flow frame: at every duration the
clock supplies both a successor `(w.1, w.2 + x)` and a predecessor `(w.1, w.2 - x)`. Stated
for all durations, so the paper's `x ≥ 0` proviso is subsumed. -/
theorem multiFamGen_serial {FamIdx : Type} (w : FamIdx × D) (x : D) :
    (∃ u, (multiFamTaskFrameGen D FamIdx).TaskRel w x u) ∧
      (∃ v, (multiFamTaskFrameGen D FamIdx).TaskRel v x w) :=
  ⟨⟨(w.1, w.2 + x), rfl, rfl⟩, ⟨(w.1, w.2 - x), rfl, by show w.2 = w.2 - x + x; abel⟩⟩

/-- *Limit* (`def:frame#Limit`) for the generic flow frame, discharged by
`TaskFrame.limit_of_shift` with position function `Prod.snd`: the clock relation makes the
duration of a transition recoverable from its endpoints. `[Nontrivial D]` is required,
matching `def:temporal-order`'s mandate that the temporal order be nontrivial. -/
theorem multiFamGen_limit [Nontrivial D] {FamIdx : Type} :
    ∀ w u : FamIdx × D,
      (∀ x, 0 < x → ∃ y, |y| < x ∧ (multiFamTaskFrameGen D FamIdx).TaskRel w y u) → u = w :=
  TaskFrame.limit_of_shift Prod.snd
    (fun _ _ _ h => h.2)
    (fun w u h => (((multiFamTaskFrameGen D FamIdx).nullity_identity w u).mp h).symm)

/-- Every fiber (`def:task-relation`, *Fiber* clause) of the generic flow frame is a
subsingleton: the clock is deterministic, so `Fib R w x ⊆ {(w.1, w.2 + x)}`. -/
theorem multiFamGen_fib_subsingleton {FamIdx : Type} (w : FamIdx × D) (x : D) :
    (TaskFrame.Fib (multiFamTaskFrameGen D FamIdx).TaskRel w x).Subsingleton := by
  rintro u ⟨hu₁, hu₂⟩ u' ⟨hu'₁, hu'₂⟩
  exact Prod.ext (hu₁.symm.trans hu'₁) (hu₂.trans hu'₂.symm)

/-- *Spherical* (`def:frame#Spherical`) for the generic flow frame: every fiber is a
singleton and every segment is an intersection of fibers, hence a subsingleton, so a
directed family (`def:directed`) of nonempty fibers and segments meets the hypotheses of
`sInter_nonempty_of_directed_subsingleton`. -/
theorem multiFamGen_spherical {FamIdx : Type} (S : Set (Set (FamIdx × D)))
    (hdir : TaskFrame.DirectedFamily S)
    (hne : ∀ s ∈ S, s.Nonempty)
    (hfs : ∀ s ∈ S, TaskFrame.IsFiber (multiFamTaskFrameGen D FamIdx).TaskRel s ∨
      TaskFrame.IsSegment (multiFamTaskFrameGen D FamIdx).TaskRel s) :
    (⋂₀ S).Nonempty := by
  refine sInter_nonempty_of_directed_subsingleton hdir hne fun s hs => ?_
  rcases hfs s hs with ⟨w, x, rfl⟩ | ⟨w, v, x, y, _, _, rfl⟩
  · exact multiFamGen_fib_subsingleton w x
  · exact (multiFamGen_fib_subsingleton w x).anti Set.inter_subset_left

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
theorem multiFamGen_total_eq {FamIdx : Type}
    (σ : WorldHistory (multiFamTaskFrameGen D FamIdx)) (htot : ∀ t, σ.domain t) :
    ∃ f w₀, σ = multiFamHistoryGen f w₀ := by
  -- The state at any time is the state at time 0 advanced by the clock.
  have key : ∀ (t : D) (ht : σ.domain t),
      σ.states t ht = ((σ.states 0 (htot 0)).1, (σ.states 0 (htot 0)).2 + t) := by
    intro t ht
    rcases le_total 0 t with h0t | ht0
    · obtain ⟨h₁, h₂⟩ := σ.respects_task 0 t (htot 0) ht h0t
      refine Prod.ext h₁.symm ?_
      rw [h₂]; abel_nf
    · obtain ⟨h₁, h₂⟩ := σ.respects_task t 0 ht (htot 0) ht0
      refine Prod.ext h₁ ?_
      rw [h₂]; abel_nf
  refine ⟨(σ.states 0 (htot 0)).1, (σ.states 0 (htot 0)).2, ?_⟩
  obtain ⟨dom, conv, sts, resp⟩ := σ
  -- Totality collapses the domain to the full predicate.
  have hdom : dom = fun _ => True :=
    funext fun t => propext ⟨fun _ => trivial, fun _ => htot t⟩
  subst hdom
  have h_states : sts = fun t (_ : True) =>
      ((sts 0 (htot 0)).1, (sts 0 (htot 0)).2 + t) :=
    funext fun t => funext fun ht => key t ht
  change WorldHistory.mk _ _ _ _ = WorldHistory.mk _ _ _ _
  congr 1

end FlowFrameConformance

end FormalSystem.Metalogic.Algebraic
