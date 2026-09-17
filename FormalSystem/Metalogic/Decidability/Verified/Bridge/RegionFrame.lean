/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.Verified.Bridge.Interpolate
import FormalSystem.Semantics.Validity

/-!
# The countermodel's frame and histories

`Bridge/Interpolate.lean` ends with a total valuation on the carrier and the statement that truth
is constant on each region cut out by the placement. This file supplies the objects that
statement is about: a frame and a family of `WorldHistory`s, the possible worlds that `Valid`
quantifies over.

## What `Valid` demands, and the one constraint that is not negotiable

`FormalSystem.Semantics.Valid` reads

```
∀ D, ∀ F : FrameOver D, ∀ M, ∀ τ : WorldHistory F, ∀ t, TruthAt M τ t φ
```

so refuting it means producing a **world history** — a history total on the carrier. That is not
a formality, and it decides the shape of everything below.

### Consequence 1: totality is the whole of the demand, and it is met exactly

An arbitrary partial history is no use here: a history whose domain omits the evaluation point
carries no state there. `TruthAt … (box φ)` is a universal over the world histories at a fixed
time, so admitting partial histories would let a single one falsify `□p` outright and no branch
carrying `T(□p)` could ever be satisfied. Totality is precisely the cut that excludes them, and
it is what `WorldHistory` builds into the type the box clause quantifies over.

The fix is **totality**, not a hand-picked range. Since `regionFrame`'s task relation is the
deterministic clock (see "The frame" below), a world history is pinned by its state at time `0`:
`isTotal_iff_regionHistory` shows every world history *is* some `regionHistory f w Δ`. So the
frame's set of possible worlds `H_F` may be read either as the range the branch calls for or as
the totality cut — they are the same family, and the box clause quantifying over `H_F` costs
nothing to instantiate.

This is what the earlier, maximally-permissive task relation `TaskRel s d s' := d = 0 → s = s'`
could not deliver: above zero it constrained nothing, so *any* assignment of states to all of
`D` was a legal world history and `H_F` was the full function space — strictly larger than the
intended family. Totality fixed the empty-history problem but not the junk-history problem, and
a designated admissible set had to be given as an explicit range because `H_F` was too big to
use. Determinism removes that need, and with it the designated set.

### Consequence 2: `□` is the universal modality

`timeShift_preserves_truth` turns the fixed-time universal into a universal over times as well,
with no closure side condition — `timeShift` maps world histories to world histories outright:

```
TruthAt M τ x (box φ) ↔ ∀ σ : WorldHistory F, ∀ y, TruthAt M σ y φ
```

(`truthAt_box_iff` below). Truth of a boxed formula does not depend on where it is evaluated;
this is the semantic form of the perpetuity of `TM`, and it is what makes the `box` case of the
region-invariance induction *free* rather than an appeal to the induction hypothesis.

The engine agrees, which is worth recording because it is the load-bearing adequacy check for
this design: `□p → □Gp`, `□p → □□p`, `□p → G□p` and `□p → ¬◇F¬p` all close, and so do the
seriality rows `G p → F p`, `¬(Gp ∧ G¬p)`, `¬(Hp ∧ H¬p)`, `F ⊤`, `P ⊤`, while `F p → p` stays
open. See `Checks` at the bottom of this file for the fact that is cheap to state in Lean;
the closure rows are `#eval` probes against `buildTableau`.

### Consequence 3: the global `RegionConstant` hypothesis is NOT satisfiable here

`Interpolate.lean` hands `interpInvariant` over with the hypothesis
`∀ τ : WorldHistory F, RegionConstant f τ` — every world history is constant on the regions of
the *fixed* placement `f`. On this carrier the world histories are exactly the region histories
(`isTotal_iff_regionHistory`), so the hypothesis ranges over the whole family and forces the
model to be trivial. The argument is short enough to state exactly:

Let `τ` be a world history and `r ≠ r'`. Every `timeShift τ Δ` is again a world history, and its
state at `r` is `τ.state (r + Δ)`. Region-constancy of *that* history at `r, r'` says: if `r` and
`r'` are region-mates then `τ.state (r + Δ) = τ.state (r' + Δ)`. Since `ι` is finite, only finitely many
`Δ` place a point of `f` between `r + Δ` and `r' + Δ`; choosing any other `Δ` makes the two
region-mates and forces `τ.state (r + Δ) = τ.state (r' + Δ)` for cofinitely many `Δ`, hence
`τ.state` constant. A history with constant states cannot separate two times, so no branch
asserting `T(p) @ t₁` and `F(p) @ t₂` in one world could be satisfied.

Under the deterministic re-host the situation is sharper still: **no** history is region-constant,
the base history included. `not_regionConstant_regionHistory` proves this for every offset, and
`not_regionConstant_regionHistory_one` keeps the concrete witness on record (`D = ℚ`, one placed
point at `0`, `Δ = 1`, region-mates `-1/2` and `-2`). A deterministic task relation propagates a
state along the clock, so a region-constant history would repeat a state at two distinct times
and be periodic, which the clock forbids.

Region-invariance therefore lives on the **valuation** rather than on histories: `M.V` factors
through `regionCode f` applied to the time component of a state. The truth induction Phase 7
runs is the **per-history** form `InterpInvariantAt` (`Bridge/TruthLemma.lean`), whose `box`
case is discharged by `truthAt_box_iff` instead of by an induction hypothesis at every history,
and whose `atom` case now takes its region hypothesis from the valuation. This is a correction
to the Phase 6 → Phase 7 interface, not a re-opening of Phase 6: every region lemma in
`Interpolate.lean` is consumed unchanged.

## The frame

`regionFrame W ι D` has states `W × D` — a branch world paired with a time — and the
deterministic clock relation `TaskRel s d s' := s.1 = s'.1 ∧ s'.2 = s.2 + d`, the structural
analogue of `multiFamTaskFrameGen` (`Metalogic/Algebraic/FlowFrame.lean`). Determinism is what
makes totality sufficient (Consequence 1 above): `respects_task` propagates the state at time
`0` along the clock, so a world history has no freedom left.

`ι` survives as a parameter of the frame without occurring in its state space, and the placement
`f : ι → D` survives as a parameter of `regionHistory` without occurring in the states. This
keeps every declaration below in the shape its consumers expect while the region structure moves
where determinism forces it to go — into the **valuation**, which reads `regionCode f`
(`Interpolate.lean`) off the time component of a state. `RegionConstant` is correspondingly no
longer provable of any history (`not_regionConstant_regionHistory`); region-invariance of atomic
truth is now a property of `M.V`, not of a history's states.
-/

namespace FormalSystem.Metalogic.Decidability.Verified.Bridge

open FormalSystem.Syntax
open FormalSystem.Semantics
open FormalSystem.Metalogic.Decidability

/-! ## The frame -/

section Frame

set_option linter.unusedVariables false in
/-- Every fibre (`def:task-relation`, *Fiber* clause) of the region clock relation is a
subsingleton: the clock is deterministic, so `Fib R s x ⊆ {(s.1, s.2 + x)}`. Stated on the bare
relation, and **above** `regionFrame`, so that the frame's own *Saturation* field can discharge
itself by Helper D (`TaskFrame.saturation_of_fib_subsingleton`) rather than re-proving the
argument inline. -/
theorem regionRel_fib_subsingleton (W D : Type) [AddCommGroup D] [LinearOrder D]
    [IsOrderedAddMonoid D] [Nontrivial D] (s : W × D) (x : D) :
    (TaskFrame.Fib (fun (s : W × D) (d : D) (s' : W × D) => s.1 = s'.1 ∧ s'.2 = s.2 + d)
      s x).Subsingleton := by
  rintro u ⟨hu₁, hu₂⟩ u' ⟨hu'₁, hu'₂⟩
  exact Prod.ext (hu₁.symm.trans hu'₁) (hu₂.trans hu'₂.symm)

/--
The countermodel's frame: a state is a branch world together with a **time**, and the task
relation is the deterministic clock `(w, x) ⇒_d (w, x + d)` — the structural analogue of
`multiFamTaskFrameGen` (`Metalogic/Algebraic/FlowFrame.lean`).

Deterministic is deliberate, and it is a change from the earlier weakest-possible relation
`TaskRel s d s' := d = 0 → s = s'`. That relation was maximally permissive above zero, so *any*
assignment of states to all of `D` was a legal world history: the frame's set of possible worlds
`H_F` was the full function space, strictly larger than the intended `regionHistory` family. Under
the clock relation, `respects_task` propagates the state at time `0` to every other time, so
totality *alone* pins the history and `isTotal_iff_regionHistory` holds.

The region structure has correspondingly moved out of the state and into the valuation: a state
no longer carries a region code, and region-invariance of atomic truth is imposed on the
valuation rather than read off the history's states. `ι` and the placement `f` are retained as
parameters throughout this file so that the declarations below keep their shape.

`[Nontrivial D]` is carried because `regionFrame_limit` requires it, via
`TaskFrame.limit_of_shift` at `pos := Prod.snd`: over a trivial duration type `0 < x` is
unsatisfiable and *Limit* (`def:frame#Limit`) has nothing to conclude from. Every consumer
elaborates at `ℤ`, `ℚ`, or `ℝ`, each of which supplies the instance.

The result is a value of the fibre over `TemporalOrder.of D` — `def:temporal-order`'s object at
the carrier `D`. The carrier stays ambient here rather than becoming a `(D : TemporalOrder)`
binder because the very same `D` is consumed as a bare type by `FrameConditionFor fc D` and by
`TemporalCarrier` in `Carrier.lean`, which are deliberately left over raw carriers.
-/
def regionFrame (W ι D : Type) [Nonempty W] [AddCommGroup D] [LinearOrder D]
    [IsOrderedAddMonoid D] [Nontrivial D] :
    FrameOver (TemporalOrder.of D) :=
  FrameOver.ofReflective (W × D) (fun s d s' => s.1 = s'.1 ∧ s'.2 = s.2 + d)
    (by
      intro s d s'
      constructor
      · rintro ⟨h₁, h₂⟩
        exact ⟨h₁.symm, by rw [h₂]; abel⟩
      · rintro ⟨h₁, h₂⟩
        exact ⟨h₁.symm, by rw [h₂]; abel⟩)
    (TaskFrame.comp_of
      (by
        rintro s v x y _ _ ⟨h₁, h₂⟩
        refine ⟨(s.1, s.2 + x), ⟨rfl, rfl⟩, h₁, ?_⟩
        show v.2 = s.2 + x + y
        rw [h₂]; abel)
      (by
        rintro s u v x y _ _ ⟨h₁, h₂⟩ ⟨h₃, h₄⟩
        exact ⟨h₁.trans h₃, by rw [h₄, h₂, add_assoc]⟩))
    (fun s x _ =>
      ⟨⟨(s.1, s.2 + x), rfl, rfl⟩,
       ⟨(s.1, s.2 - x), rfl, by show s.2 = s.2 - x + x; abel⟩⟩)
    (TaskFrame.limit_of_shift Prod.snd (fun _ _ _ h => h.2)
      (fun s u h => Prod.ext h.1.symm (by rw [h.2, add_zero])))
    (TaskFrame.saturation_of_fib_subsingleton (regionRel_fib_subsingleton W D))

@[simp]
theorem regionFrame_taskRel (W ι D : Type) [Nonempty W] [AddCommGroup D] [LinearOrder D]
    [IsOrderedAddMonoid D] [Nontrivial D] (s : W × D) (d : D) (s' : W × D) :
    (regionFrame W ι D).TaskRel s d s' ↔ (s.1 = s'.1 ∧ s'.2 = s.2 + d) :=
  FrameOver.ofReflective_taskRel

/-! ### `regionFrame` discharges `def:frame`'s four axioms

The clock relation `s.1 = s'.1 ∧ s'.2 = s.2 + d` makes the duration of a transition recoverable
from its endpoints, via the position function `Prod.snd`. That is exactly the deterministic-shift
contract `TaskFrame.limit_of_shift` consumes, so *Limit* holds over **any** nontrivial duration
type — dense included — and every fiber is a singleton, which discharges *Saturation*.

This supersedes an earlier record flagging this frame as failing dense-polymorphically. That flag
was accurate against the frame's **former** relation, the maximally-permissive
`TaskRel s d s' := d = 0 → s = s'` described in `regionFrame`'s docstring above: above zero that
relation related every pair, so over a dense `D` every state sat in every cone of every other and
*Limit* collapsed. The relation is no longer that one. The four lemmas below elaborate at
polymorphic `D` under `[Nontrivial D]` alone, with **no** discreteness hypothesis — which is the
falsification test the flag needed, and it fails to falsify. -/

/-- Every fiber (`def:task-relation`, *Fiber* clause) of `regionFrame` is a subsingleton: the
clock is deterministic, so `Fib R s x ⊆ {(s.1, s.2 + x)}`. -/
theorem regionFrame_fib_subsingleton (W ι D : Type) [Nonempty W] [AddCommGroup D] [LinearOrder D]
    [IsOrderedAddMonoid D] [Nontrivial D] (s : W × D) (x : D) :
    (TaskFrame.Fib (regionFrame W ι D).TaskRel s x).Subsingleton := by
  have h : TaskFrame.Fib (regionFrame W ι D).TaskRel s x =
      TaskFrame.Fib (fun s d s' => s.1 = s'.1 ∧ s'.2 = s.2 + d) s x :=
    Set.ext fun _ => regionFrame_taskRel W ι D _ _ _
  rw [h]
  exact regionRel_fib_subsingleton W D s x

/-- *Seriality* (`def:frame#Seriality`, verbatim: "$w \Rightarrow_x u$ and $v \Rightarrow_x w$
for some $u, v \in W$") for `regionFrame`: the clock supplies the successor `(s.1, s.2 + x)` and
the predecessor `(s.1, s.2 - x)`. -/
theorem regionFrame_serial (W ι D : Type) [Nonempty W] [AddCommGroup D] [LinearOrder D]
    [IsOrderedAddMonoid D] [Nontrivial D] : TaskFrame.Serial (regionFrame W ι D).TaskRel := by
  intro s x _
  exact ⟨⟨(s.1, s.2 + x), (regionFrame_taskRel W ι D _ _ _).mpr ⟨rfl, rfl⟩⟩,
    ⟨(s.1, s.2 - x), (regionFrame_taskRel W ι D _ _ _).mpr
      ⟨rfl, by show s.2 = s.2 - x + x; abel⟩⟩⟩

/-- The interpolation half of *Compositionality* (`def:frame#Compositionality`, verbatim:
"$w \Rightarrow_{x + y} v$ if and only if $w \Rightarrow_x u$ and $u \Rightarrow_y v$ for some
$u \in W$") for `regionFrame`: interpolate at the unique intermediate `(s.1, s.2 + x)`. -/
theorem regionFrame_interpolates (W ι D : Type) [Nonempty W] [AddCommGroup D] [LinearOrder D]
    [IsOrderedAddMonoid D] [Nontrivial D] :
    TaskFrame.Interpolates (regionFrame W ι D).TaskRel := by
  intro s v x y _ _ h
  obtain ⟨h₁, h₂⟩ := (regionFrame_taskRel W ι D _ _ _).mp h
  refine ⟨(s.1, s.2 + x), (regionFrame_taskRel W ι D _ _ _).mpr ⟨rfl, rfl⟩,
    (regionFrame_taskRel W ι D _ _ _).mpr ⟨h₁, ?_⟩⟩
  show v.2 = s.2 + x + y
  rw [h₂]; abel

/-- *Limit* (`def:frame#Limit`, verbatim: "$\bigcap\limits_{x > 0} (w)_x = \set{w}$") for
`regionFrame`, in the literal transcribed shape, via `TaskFrame.limit_of_shift` with
`pos := Prod.snd`. `[Nontrivial D]` is the only hypothesis on `D` — the axiom holds over dense
duration types as well as discrete ones. -/
theorem regionFrame_limit (W ι D : Type) [Nonempty W] [AddCommGroup D] [LinearOrder D]
    [IsOrderedAddMonoid D] [Nontrivial D] :
    ∀ s u : W × D,
      (∀ x, 0 < x → ∃ y, |y| < x ∧ (regionFrame W ι D).TaskRel s y u) → u = s :=
  (regionFrame W ι D).limit

/-- *Saturation* (`def:frame#Saturation`, verbatim: "$\bigcap \mathcal{S} \neq \emptyset$ for any
$\supseteq$-directed family $\mathcal{S}$ of nonempty fibers and segments") for `regionFrame`,
as the top-level predicate of record: a one-line citation of the frame's own field, which is
itself Helper D applied to `regionRel_fib_subsingleton`. -/
theorem regionFrame_saturation (W ι D : Type) [Nonempty W] [AddCommGroup D] [LinearOrder D]
    [IsOrderedAddMonoid D] [Nontrivial D] :
    TaskFrame.Saturation (regionFrame W ι D).TaskRel :=
  (regionFrame W ι D).saturation

end Frame

/-! ## The histories -/

section Histories

variable {W ι D : Type} [Nonempty W] [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
  [Nontrivial D]

set_option linter.unusedVariables false in
/--
The history of world `w` viewed with time offset `Δ`: total in time, assigning to `r` the state
"world `w`, at time `r + Δ`".

`Δ = 0` is the history the branch is really about; the nonzero offsets are the time-shifts of the
base histories (`timeShift_regionHistory`), and they are world histories exactly as the base
histories are.

The placement `f` is retained as a parameter — it no longer occurs in the states, since the
region code moved out of the frame's state space when the task relation became deterministic —
so that every declaration below keeps its shape. Regions re-enter through the valuation, which
reads `regionCode f` off the time component.
-/
def regionHistory (f : ι → D) (w : W) (Δ : D) : WorldHistory (regionFrame W ι D) :=
  WorldHistory.ofTotal _ (fun r => (w, r + Δ)) (by
    intro s t
    refine (regionFrame_taskRel W ι D _ _ _).mpr ⟨rfl, ?_⟩
    show t + Δ = s + Δ + (t - s)
    abel)

@[simp]
theorem regionHistory_state (f : ι → D) (w : W) (Δ : D) (r : D) :
    (regionHistory f w Δ).state r = (w, r + Δ) := rfl

/-- Time-shifting a region history is again a region history, with the offsets added. -/
theorem timeShift_regionHistory (f : ι → D) (w : W) (Δ Δ' : D) :
    (regionHistory f w Δ).timeShift Δ' = regionHistory f w (Δ' + Δ) := by
  refine WorldHistory.ext_state fun r => ?_
  show ((w, r + Δ' + Δ) : W × D) = (w, r + (Δ' + Δ))
  rw [add_assoc]

/-! ### Totality is now sufficient

The theorem that the deterministic re-host exists to make true. Under the previous
maximally-permissive task relation it was false: totality fixed the empty-history problem but
not the junk-history problem, so the region histories were a strict subset of `H_F`.
-/

/--
**The frame's set of possible worlds `H_F` is exactly the region histories**: every world history
of `regionFrame` is some `regionHistory f w Δ`. `def:world-history` fixes `H_F` as the
totality-cut of the convex histories: "A \textit{possible world} is any convex history whose
domain is total, so that $X = D$. ... The set of all possible worlds over $\F$ is denoted
$H_{\F}$." Here that cut is the type `WorldHistory`.

The direct analogue of `multiFamGen_total_eq` (`Metalogic/Algebraic/FlowFrame.lean`): the state
at time `0` fixes the world and the offset, and `respects_task` propagates the clock to every
other time. Every region history is a world history by construction, so this is the
characterization every downstream proof consumes: the `def:BL-semantics` box clause ("for all
$\sigma \in H_{\F}$") reduces on this carrier to a quantifier over the region histories, with no
designated admissible set in the statement.
-/
theorem isTotal_iff_regionHistory (f : ι → D) (σ : WorldHistory (regionFrame W ι D)) :
    ∃ (w : W) (Δ : D), σ = regionHistory f w Δ := by
  have key : ∀ r : D, σ.state r = ((σ.state 0).1, r + (σ.state 0).2) := by
    intro r
    obtain ⟨h₁, h₂⟩ := (regionFrame_taskRel W ι D _ _ _).mp
      (σ.val.respects_task 0 r (σ.property 0) (σ.property r))
    refine Prod.ext h₁.symm ?_
    rw [WorldHistory.states_eq_state, WorldHistory.states_eq_state] at h₂
    rw [h₂]
    abel_nf
  exact ⟨(σ.state 0).1, (σ.state 0).2, WorldHistory.ext_state key⟩

end Histories

/-! ## `□` is the universal modality

The single semantic fact the region bridge rests on. `TruthAt`'s remaining set argument is inert
and is supplied as `Set.univ`; there is no shift-closure hypothesis, because the box clause
quantifies over world histories and `timeShift` preserves them outright.
-/

section BoxUniversal

variable {D : Type} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]
variable {F : FrameOver (TemporalOrder.of D)}

/--
**Box is evaluation-point independent.** `box φ` holds at one point iff `φ` holds at *every*
world history and *every* time.

The forward direction shifts an arbitrary `(σ, y)` back to `x` — legal because
`WorldHistory.timeShift` is again a world history, with no side condition on the carrier — and
reads the result off `timeShift_preserves_truth`. Shift-closure is no longer a hypothesis
anywhere: the box clause quantifies over world histories, which are shift-stable outright.
-/
theorem truthAt_box_iff (M : TaskModel F)
    (τ : WorldHistory F) (x : D) (φ : Formula) :
    TruthAt M τ x φ.box ↔
      ∀ σ : WorldHistory F, ∀ y : D, TruthAt M σ y φ := by
  simp only [TruthAt]
  constructor
  · intro h σ y
    exact (TimeShift.timeShift_preserves_truth M σ x y φ).mp (h (σ.timeShift (y - x)))
  · intro h σ
    exact h σ x

/-- Truth of a boxed formula does not depend on the time it is evaluated at. -/
theorem truthAt_box_congr (M : TaskModel F)
    (τ : WorldHistory F) (x y : D) (φ : Formula) :
    TruthAt M τ x φ.box ↔ TruthAt M τ y φ.box := by
  rw [truthAt_box_iff M τ x φ, truthAt_box_iff M τ y φ]

/-- Nor on the history it is evaluated in. -/
theorem truthAt_box_congr_history (M : TaskModel F)
    (τ σ : WorldHistory F) (x y : D) (φ : Formula) :
    TruthAt M τ x φ.box ↔ TruthAt M σ y φ.box := by
  rw [truthAt_box_iff M τ x φ, truthAt_box_iff M σ y φ]

end BoxUniversal

/-! ## Reduction to the base histories

The nonzero offsets carry no independent semantic content: every world history is a time-shift of
a base history, so every truth value in the model is a truth value at some `regionHistory f w 0`. `truthAt_box_iff_base`
is the form the truth lemma's `box` case consumes.
-/

section BaseReduction

variable {W ι D : Type} [Nonempty W] [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
  [Nontrivial D]

/-- Every region history is a time-shift of the base history of its world. -/
theorem regionHistory_eq_timeShift (f : ι → D) (w : W) (Δ : D) :
    regionHistory f w Δ = (regionHistory f w (0 : D)).timeShift Δ := by
  rw [timeShift_regionHistory, add_zero]

/-- Truth at an offset history is truth at its base history, read at the offset time. -/
theorem truthAt_regionHistory_offset (M : TaskModel (regionFrame W ι D)) (f : ι → D)
    (w : W) (Δ r : D) (φ : Formula) :
    TruthAt M (regionHistory f w Δ) r φ ↔
      TruthAt M (regionHistory f w (0 : D)) (r + Δ) φ := by
  have h := TimeShift.timeShift_preserves_truth M
    (regionHistory f w (0 : D)) r (r + Δ) φ
  rw [add_sub_cancel_left] at h
  rw [regionHistory_eq_timeShift]
  exact h

/--
**The `box` interface for the truth lemma.** `box φ` holds anywhere in the countermodel iff `φ`
holds at every world's base history, at every point of the carrier.

Both quantifiers are unavoidable and both are what the branch has to pay for: the world
quantifier is discharged by `sat_box_pos` (the `boxPos` rule propagates to every known world),
the time quantifier by the `boxTemporal` chain together with region invariance.
-/
theorem truthAt_box_iff_base (M : TaskModel (regionFrame W ι D)) (f : ι → D)
    (τ : WorldHistory (regionFrame W ι D)) (x : D) (φ : Formula) :
    TruthAt M τ x φ.box ↔
      ∀ (w : W) (y : D), TruthAt M (regionHistory f w (0 : D)) y φ := by
  rw [truthAt_box_iff M τ x φ]
  constructor
  · intro h w y
    -- A base history is a world history, which is exactly what the box clause instantiates
    -- against now that it no longer mentions a designated admissible set.
    exact h _ y
  · intro h σ y
    obtain ⟨w, Δ, rfl⟩ := isTotal_iff_regionHistory f σ
    exact (truthAt_regionHistory_offset M f w Δ y φ).mpr (h w (y + Δ))

end BaseReduction

/-! ## Region-constancy: what holds, and what provably does not -/

section RegionConstancy

variable {W ι D : Type} [Nonempty W] [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
  [Nontrivial D]

/--
**No region history is region-constant** as soon as some region contains two distinct points —
at *any* offset, the base history `Δ = 0` included.

This is a deliberate reversal of the situation under the previous, maximally-permissive
`regionFrame`, where a state was a world paired with a region *code*, the base history's state
at `r` was the code of `r` itself, and `RegionConstant f (regionHistory f w 0)` was therefore
provable.

The reversal is forced, not incidental. A deterministic task relation propagates the state at
one time to every other time, so a history's states determine the time they are read at; a
region-constant history would have to repeat a state at two distinct times and so be periodic,
which the clock forbids. Region-invariance consequently cannot be read off a history's states
any more. It has to be imposed on the **valuation** instead — `M.V` factoring through
`regionCode f` applied to the time component of the state — which is the interface
`Bridge/Valuation.lean` and `Bridge/TruthLemma.lean` now take it from.
-/
theorem not_regionConstant_regionHistory (f : ι → D) (w : W) (Δ : D) (r r' : D)
    (hne : r ≠ r') (hsame : SameRegion f r r') :
    ¬ RegionConstant f (regionHistory f w Δ) := by
  intro hRC
  have h : ((w, r + Δ) : W × D) = (w, r' + Δ) := hRC.state_congr hsame
  exact hne (add_right_cancel (congrArg Prod.snd h))

end RegionConstancy

/-! ## Sanity checks

Exercised by name so that a definition that stops elaborating fails here rather than downstream.
-/

section Checks

/--
**The translates are not region-constant** — the concrete refutation of the Phase 6 hypothesis
`∀ τ : WorldHistory _, RegionConstant f τ` promised in the module docstring.

One placed point at `0 : ℚ`; `-1/2` and `-2` are region-mates (both strictly below the only
placed point), but the `Δ = 1` history reads their states off the distinct times `1/2` and `-1`.
-/
theorem not_regionConstant_regionHistory_one :
    ¬ RegionConstant (fun _ : Fin 1 => (0 : ℚ)) (regionHistory (W := Unit) (fun _ : Fin 1 => (0 : ℚ)) () 1) := by
  refine not_regionConstant_regionHistory _ _ _ (-1/2) (-2) (by norm_num) ?_
  intro i
  constructor
  · constructor <;> intro h <;> norm_num at h
  · constructor <;> intro _ <;> norm_num

/-- The frame elaborates at each of the three dense carriers and at `ℤ`. -/
example : Nonempty (FrameOver (TemporalOrder.of ℚ)) := ⟨regionFrame Unit (Fin 1) ℚ⟩
example : Nonempty (FrameOver (TemporalOrder.of ℝ)) := ⟨regionFrame Unit (Fin 1) ℝ⟩
example : Nonempty (FrameOver (TemporalOrder.of ℤ)) := ⟨regionFrame Unit (Fin 1) ℤ⟩

/-- The base histories are world histories at a concrete carrier, which is all `□` now asks of
them. -/
example : (regionHistory (W := Unit) (fun _ : Fin 1 => (0 : ℚ)) () 1).state 0 = ((), 0 + 1) :=
  rfl

end Checks

end FormalSystem.Metalogic.Decidability.Verified.Bridge
