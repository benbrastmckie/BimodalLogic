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
statement is about: a `TaskFrame` and a family of `WorldHistory`s, among them the *total* ones
that `valid` quantifies over.

## What `valid` demands, and the one constraint that is not negotiable

`FormalSystem.Semantics.valid` reads

```
∀ D, ∀ F : TaskFrame D, ∀ M, ∀ τ, τ.IsTotal → ∀ t, TruthAt M τ t φ
```

so refuting it means producing a **total** history. That is not a formality, and it decides the
shape of everything below.

### Consequence 1: totality is the whole of the demand, and it is met exactly

An arbitrary world history is no use here: a history whose domain omits the evaluation point
carries no state there. `TruthAt … (box φ)` is a universal over the total histories at a fixed
time, so admitting partial histories would let a single one falsify `□p` outright and no branch
carrying `T(□p)` could ever be satisfied. Totality is precisely the cut that excludes them, and
it is what the box clause now quantifies over.

The fix is **totality**, not a hand-picked range. Since `regionFrame`'s task relation is the
deterministic clock (see "The frame" below), a total history is pinned by its state at time `0`:
`regionFrame_total_eq` shows every total history *is* some `regionHistory f w Δ`, and
`isTotal_iff_regionHistory` records the resulting characterization. So the frame's total-history
set `H_F` may be read either as the range the branch calls for or as the totality cut — they are
the same family, and the box clause quantifying over `H_F` costs nothing to instantiate.

This is what the earlier, maximally-permissive task relation `TaskRel s d s' := d = 0 → s = s'`
could not deliver: above zero it constrained nothing, so *any* assignment of states to all of
`D` was a legal total history and `H_F` was the full function space — strictly larger than the
intended family. Totality fixed the empty-history problem but not the junk-history problem, and
a designated admissible set had to be given as an explicit range because `H_F` was too big to
use. Determinism removes that need, and with it the designated set.

### Consequence 2: `□` is the universal modality

`time_shift_preserves_truth` turns the fixed-time universal into a universal over times as well,
with no closure side condition — totality is preserved by `timeShift` outright:

```
TruthAt M τ x (box φ) ↔ ∀ σ, σ.IsTotal → ∀ y, TruthAt M σ y φ
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
`∀ τ, τ.IsTotal → RegionConstant f τ` — every *total* history is constant on the regions of the
*fixed* placement `f`. On this carrier the total histories are exactly the region histories
(`isTotal_iff_regionHistory`), so the hypothesis ranges over the whole family and forces the
model to be trivial. The argument is short enough to state exactly:

Let `τ` be total and `r ≠ r'`. Every `timeShift τ Δ` is again total, and its state at `r` is
`τ.states (r + Δ)`. Region-constancy of *that* history at `r, r'` says: if `r` and `r'` are
region-mates then `τ.states (r + Δ) = τ.states (r' + Δ)`. Since `ι` is finite, only finitely many
`Δ` place a point of `f` between `r + Δ` and `r' + Δ`; choosing any other `Δ` makes the two
region-mates and forces `τ.states (r + Δ) = τ.states (r' + Δ)` for cofinitely many `Δ`, hence
`τ.states` constant. A history with constant states cannot separate two times, so no branch
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
`0` along the clock, so a total history has no freedom left.

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

/-! ## Extensionality for histories

`WorldHistory` carries two proof fields, so equality of two histories is decided by the domain
and the state assignment alone. Needed to identify a time-shifted history with another member of
the `regionHistory` family.
-/

/-- Two histories with the same domain and the same states are equal. -/
theorem worldHistory_ext {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    {F : TaskFrame D} {σ τ : WorldHistory F} (hd : σ.domain = τ.domain)
    (hs : ∀ (r : D) (h : σ.domain r) (h' : τ.domain r), σ.states r h = τ.states r h') :
    σ = τ := by
  obtain ⟨⟨d₁, n₁, s₁, t₁⟩, c₁⟩ := σ
  obtain ⟨⟨d₂, n₂, s₂, t₂⟩, c₂⟩ := τ
  simp only at hd hs
  subst hd
  have : s₁ = s₂ := by
    funext r h
    exact hs r h h
  subst this
  rfl

/-! ## The frame -/

section Frame

set_option linter.unusedVariables false in
/--
The countermodel's frame: a state is a branch world together with a **time**, and the task
relation is the deterministic clock `(w, x) ⇒_d (w, x + d)` — the structural analogue of
`multiFamTaskFrameGen` (`Metalogic/Algebraic/FlowFrame.lean`).

Deterministic is deliberate, and it is a change from the earlier weakest-possible relation
`TaskRel s d s' := d = 0 → s = s'`. That relation was maximally permissive above zero, so *any*
assignment of states to all of `D` was a legal total history: the frame's total-history set
`H_F` was the full function space, strictly larger than the intended `regionHistory` family. Under
the clock relation, `respects_task` propagates the state at time `0` to every other time
(`regionFrame_total_eq`), so totality *alone* pins the history and `isTotal_iff_regionHistory`
holds.

The region structure has correspondingly moved out of the state and into the valuation: a state
no longer carries a region code, and region-invariance of atomic truth is imposed on the
valuation rather than read off the history's states. `ι` and the placement `f` are retained as
parameters throughout this file so that the declarations below keep their shape.

`[Nontrivial D]` is carried because `regionFrame_limit` requires it, via
`TaskFrame.limit_of_shift` at `pos := Prod.snd`: over a trivial duration type `0 < x` is
unsatisfiable and *Limit* (`def:frame#Limit`) has nothing to conclude from. Every consumer
elaborates at `ℤ`, `ℚ`, or `ℝ`, each of which supplies the instance.
-/
def regionFrame (W ι D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    [Nontrivial D] :
    TaskFrame D where
  WorldState := W × D
  TaskRel := fun s d s' => s.1 = s'.1 ∧ s'.2 = s.2 + d
  nullity_identity := by
    intro s s'
    constructor
    · rintro ⟨h₁, h₂⟩
      refine Prod.ext h₁ ?_
      rw [h₂, add_zero]
    · rintro rfl
      exact ⟨rfl, (add_zero _).symm⟩
  comp := TaskFrame.comp_of
    (by
      rintro s v x y _ _ ⟨h₁, h₂⟩
      refine ⟨(s.1, s.2 + x), ⟨rfl, rfl⟩, h₁, ?_⟩
      show v.2 = s.2 + x + y
      rw [h₂]; abel)
    (by
      rintro s u v x y _ _ ⟨h₁, h₂⟩ ⟨h₃, h₄⟩
      exact ⟨h₁.trans h₃, by rw [h₄, h₂, add_assoc]⟩)
  serial := fun s x _ =>
    ⟨⟨(s.1, s.2 + x), rfl, rfl⟩,
     ⟨(s.1, s.2 - x), rfl, by show s.2 = s.2 - x + x; abel⟩⟩
  limit :=
    TaskFrame.limit_of_shift Prod.snd (fun _ _ _ h => h.2)
      (fun s u h => Prod.ext h.1.symm (by rw [h.2, add_zero]))
  spherical := by
    intro S hdir hmem
    refine TaskFrame.sInter_nonempty_of_directed_of_univ_or_singleton hdir
      (fun s hs => (hmem s hs).2) (fun s hs => ?_)
    obtain ⟨hcl, hne⟩ := hmem s hs
    obtain ⟨a, ha⟩ := hne
    have hfib : ∀ (t : W × D) (x : D),
        (TaskFrame.Fib (fun (s : W × D) (d : D) (s' : W × D) =>
          s.1 = s'.1 ∧ s'.2 = s.2 + d) t x).Subsingleton := by
      rintro t x u ⟨hu₁, hu₂⟩ u' ⟨hu'₁, hu'₂⟩
      exact Prod.ext (hu₁.symm.trans hu'₁) (hu₂.trans hu'₂.symm)
    refine Or.inr ⟨a, ?_⟩
    rcases hcl with ⟨w, x, rfl⟩ | ⟨w, v, x, y, _, _, rfl⟩
    · exact (hfib w x).eq_singleton_of_mem ha
    · exact ((hfib w x).anti Set.inter_subset_left).eq_singleton_of_mem ha
  converse := by
    intro s d s'
    constructor
    · rintro ⟨h₁, h₂⟩
      exact ⟨h₁.symm, by rw [h₂]; abel⟩
    · rintro ⟨h₁, h₂⟩
      exact ⟨h₁.symm, by rw [h₂]; abel⟩

@[simp]
theorem regionFrame_taskRel (W ι D : Type) [AddCommGroup D] [LinearOrder D]
    [IsOrderedAddMonoid D] [Nontrivial D] (s : W × D) (d : D) (s' : W × D) :
    (regionFrame W ι D).TaskRel s d s' ↔ (s.1 = s'.1 ∧ s'.2 = s.2 + d) := Iff.rfl

/-! ### `regionFrame` discharges `def:frame`'s four axioms

The clock relation `s.1 = s'.1 ∧ s'.2 = s.2 + d` makes the duration of a transition recoverable
from its endpoints, via the position function `Prod.snd`. That is exactly the deterministic-shift
contract `TaskFrame.limit_of_shift` consumes, so *Limit* holds over **any** nontrivial duration
type — dense included — and every fiber is a singleton, which discharges *Spherical*.

This supersedes an earlier record flagging this frame as failing dense-polymorphically. That flag
was accurate against the frame's **former** relation, the maximally-permissive
`TaskRel s d s' := d = 0 → s = s'` described in `regionFrame`'s docstring above: above zero that
relation related every pair, so over a dense `D` every state sat in every cone of every other and
*Limit* collapsed. The relation is no longer that one. The four lemmas below elaborate at
polymorphic `D` under `[Nontrivial D]` alone, with **no** discreteness hypothesis — which is the
falsification test the flag needed, and it fails to falsify. -/

/-- Every fiber (`def:task-relation`, *Fiber* clause) of `regionFrame` is a subsingleton: the
clock is deterministic, so `Fib R s x ⊆ {(s.1, s.2 + x)}`. -/
theorem regionFrame_fib_subsingleton (W ι D : Type) [AddCommGroup D] [LinearOrder D]
    [IsOrderedAddMonoid D] [Nontrivial D] (s : W × D) (x : D) :
    (TaskFrame.Fib (regionFrame W ι D).TaskRel s x).Subsingleton := by
  rintro u ⟨hu₁, hu₂⟩ u' ⟨hu'₁, hu'₂⟩
  exact Prod.ext (hu₁.symm.trans hu'₁) (hu₂.trans hu'₂.symm)

/-- *Seriality* (`def:frame#Seriality`, verbatim: "$w \Rightarrow_x u$ and $v \Rightarrow_x w$
for some $u, v \in W$") for `regionFrame`: the clock supplies the successor `(s.1, s.2 + x)` and
the predecessor `(s.1, s.2 - x)`. -/
theorem regionFrame_serial (W ι D : Type) [AddCommGroup D] [LinearOrder D]
    [IsOrderedAddMonoid D] [Nontrivial D] : TaskFrame.Serial (regionFrame W ι D).TaskRel :=
  fun s x _ =>
    ⟨⟨(s.1, s.2 + x), rfl, rfl⟩,
     ⟨(s.1, s.2 - x), rfl, by show s.2 = s.2 - x + x; abel⟩⟩

/-- The interpolation half of *Compositionality* (`def:frame#Compositionality`, verbatim:
"$w \Rightarrow_{x + y} v$ if and only if $w \Rightarrow_x u$ and $u \Rightarrow_y v$ for some
$u \in W$") for `regionFrame`: interpolate at the unique intermediate `(s.1, s.2 + x)`. -/
theorem regionFrame_interpolates (W ι D : Type) [AddCommGroup D] [LinearOrder D]
    [IsOrderedAddMonoid D] [Nontrivial D] :
    TaskFrame.Interpolates (regionFrame W ι D).TaskRel := by
  rintro s v x y _ _ ⟨h₁, h₂⟩
  refine ⟨(s.1, s.2 + x), ⟨rfl, rfl⟩, h₁, ?_⟩
  show v.2 = s.2 + x + y
  rw [h₂]; abel

/-- *Limit* (`def:frame#Limit`, verbatim: "$\bigcap\limits_{x > 0} (w)_x = \set{w}$") for
`regionFrame`, in the literal transcribed shape, via `TaskFrame.limit_of_shift` with
`pos := Prod.snd`. `[Nontrivial D]` is the only hypothesis on `D` — the axiom holds over dense
duration types as well as discrete ones. -/
theorem regionFrame_limit (W ι D : Type) [AddCommGroup D] [LinearOrder D]
    [IsOrderedAddMonoid D] [Nontrivial D] :
    ∀ s u : W × D,
      (∀ x, 0 < x → ∃ y, |y| < x ∧ (regionFrame W ι D).TaskRel s y u) → u = s :=
  TaskFrame.limit_of_shift Prod.snd (fun _ _ _ h => h.2)
    (fun s u h => (((regionFrame W ι D).nullity_identity s u).mp h).symm)

/-- *Spherical* (`def:frame#Spherical`, verbatim: "$\bigcap \mathcal{S} \neq \emptyset$ for any
directed family $\mathcal{S}$ of nonempty fibers and segments") for `regionFrame`: every fiber is
a subsingleton and every segment is an intersection of fibers, so every nonempty member of a
directed family is a singleton and
`TaskFrame.sInter_nonempty_of_directed_of_univ_or_singleton` applies. -/
theorem regionFrame_spherical (W ι D : Type) [AddCommGroup D] [LinearOrder D]
    [IsOrderedAddMonoid D] [Nontrivial D] :
    TaskFrame.Spherical (regionFrame W ι D).TaskRel := by
  intro S hdir hmem
  refine TaskFrame.sInter_nonempty_of_directed_of_univ_or_singleton hdir
    (fun s hs => (hmem s hs).2) (fun s hs => ?_)
  obtain ⟨hcl, hne⟩ := hmem s hs
  obtain ⟨a, ha⟩ := hne
  refine Or.inr ⟨a, ?_⟩
  rcases hcl with ⟨w, x, rfl⟩ | ⟨w, v, x, y, _, _, rfl⟩
  · exact (regionFrame_fib_subsingleton W ι D w x).eq_singleton_of_mem ha
  · exact ((regionFrame_fib_subsingleton W ι D w x).anti
      Set.inter_subset_left).eq_singleton_of_mem ha

end Frame

/-! ## The histories -/

section Histories

variable {W ι D : Type} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]

set_option linter.unusedVariables false in
/--
The history of world `w` viewed with time offset `Δ`: total in time, assigning to `r` the state
"world `w`, at time `r + Δ`".

`Δ = 0` is the history the branch is really about; the nonzero offsets are the time-shifts of the
base histories (`timeShift_regionHistory`), and they are total exactly as the base histories
are.

The placement `f` is retained as a parameter — it no longer occurs in the states, since the
region code moved out of the frame's state space when the task relation became deterministic —
so that every declaration below keeps its shape. Regions re-enter through the valuation, which
reads `regionCode f` off the time component.
-/
def regionHistory (f : ι → D) (w : W) (Δ : D) : WorldHistory (regionFrame W ι D) where
  domain := fun _ => True
  nonempty_domain := ⟨0, trivial⟩
  convex := by intro _ _ _ _ _ _ _; trivial
  states := fun r _ => (w, r + Δ)
  respects_task := by
    intro s t _ _
    refine ⟨rfl, ?_⟩
    show t + Δ = s + Δ + (t - s)
    abel

@[simp]
theorem regionHistory_domain (f : ι → D) (w : W) (Δ : D) (r : D) :
    (regionHistory f w Δ).domain r := trivial

@[simp]
theorem regionHistory_states (f : ι → D) (w : W) (Δ : D) (r : D) (h : (regionHistory f w Δ).domain r) :
    (regionHistory f w Δ).states r h = (w, r + Δ) := rfl

/-- Time-shifting a region history is again a region history, with the offsets added. -/
theorem timeShift_regionHistory (f : ι → D) (w : W) (Δ Δ' : D) :
    WorldHistory.timeShift (regionHistory f w Δ) Δ' = regionHistory f w (Δ' + Δ) := by
  refine worldHistory_ext rfl ?_
  intro r _ _
  show ((w, r + Δ' + Δ) : W × D) = (w, r + (Δ' + Δ))
  rw [add_assoc]

/--
**Every region history is total**, at every offset — `regionHistory` carries
`domain := fun _ => True`, so totality is immediate.

Totality is what `def:BL-semantics`'s box clause quantifies over, so this is the fact that
puts a region history in range of `□`. It replaces the former membership lemma about a
designated admissible set: there is no such set here any more, and membership is no longer
what `□` instantiates against.
-/
theorem regionHistory_isTotal (f : ι → D) (w : W) (Δ : D) :
    (regionHistory f w Δ).IsTotal := fun _ => trivial

/-! ### Totality is now sufficient

The theorem that the deterministic re-host exists to make true. Under the previous
maximally-permissive task relation it was false: totality fixed the empty-history problem but
not the junk-history problem, so the region histories were a strict subset of `H_F`.
-/

/--
**Every total history of `regionFrame` is a region history.** The direct analogue of
`multiFamGen_total_eq` (`Metalogic/Algebraic/FlowFrame.lean`): the state at time `0` fixes the
world and the offset, and `respects_task` propagates the clock to every other time.
-/
theorem regionFrame_total_eq (f : ι → D) (σ : WorldHistory (regionFrame W ι D))
    (htot : ∀ r, σ.domain r) : ∃ (w : W) (Δ : D), σ = regionHistory f w Δ := by
  have key : ∀ (r : D) (hr : σ.domain r),
      σ.states r hr = ((σ.states 0 (htot 0)).1, r + (σ.states 0 (htot 0)).2) := by
    intro r hr
    obtain ⟨h₁, h₂⟩ := σ.respects_task 0 r (htot 0) hr
    refine Prod.ext h₁.symm ?_
    rw [h₂]
    abel_nf
  refine ⟨(σ.states 0 (htot 0)).1, (σ.states 0 (htot 0)).2, ?_⟩
  refine worldHistory_ext (funext fun r => propext ⟨fun _ => trivial, fun _ => htot r⟩) ?_
  intro r hr _
  exact key r hr

/--
**The frame's total-history set `H_F` is exactly the region histories.** `def:world-history`
fixes `H_F` as the totality-cut of the world histories: "A world history is *total* ---
equivalently, a *possible world* --- just in case $X = D$. ... The set of all total world
histories over $\F$ is denoted $H_{\F}$." Here the totality predicate `X = D` is spelled
`WorldHistory.IsTotal`, i.e. `∀ r, σ.domain r`.

The `←` direction is `regionHistory_isTotal`, definitional. The `→` direction is
`regionFrame_total_eq`. This is the characterization every downstream proof consumes: the
`def:BL-semantics` box clause ("for all $\sigma \in H_{\F}$") reduces on this carrier to a
quantifier over the region histories, with no designated admissible set in the statement.
-/
theorem isTotal_iff_regionHistory (f : ι → D) (σ : WorldHistory (regionFrame W ι D)) :
    σ.IsTotal ↔ ∃ (w : W) (Δ : D), σ = regionHistory f w Δ := by
  constructor
  · intro htot
    exact regionFrame_total_eq f σ htot
  · rintro ⟨w, Δ, rfl⟩
    exact regionHistory_isTotal f w Δ

end Histories

/-! ## `□` is the universal modality

The single semantic fact the region bridge rests on. `TruthAt`'s remaining set argument is inert
and is supplied as `Set.univ`; there is no shift-closure hypothesis, because the box clause
quantifies over totality and totality is preserved by `timeShift` outright.
-/

section BoxUniversal

variable {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] {F : TaskFrame D}

/--
**Box is evaluation-point independent.** `box φ` holds at one point iff `φ` holds at *every*
total history and *every* time.

The forward direction shifts an arbitrary `(σ, y)` back to `x` — legal because totality is
preserved by `timeShift` (`WorldHistory.isTotal_timeShift`), with no side condition on the
carrier — and reads the result off `time_shift_preserves_truth`. Shift-closure is no longer a
hypothesis anywhere: the box clause quantifies over totality, and totality is shift-stable
outright.
-/
theorem truthAt_box_iff (M : TaskModel F)
    (τ : WorldHistory F) (x : D) (φ : Formula) :
    TruthAt M τ x φ.box ↔
      ∀ σ : WorldHistory F, σ.IsTotal → ∀ y : D, TruthAt M σ y φ := by
  simp only [TruthAt]
  constructor
  · intro h σ hσ y
    exact (TimeShift.time_shift_preserves_truth M σ x y φ).mp
      (h _ (WorldHistory.isTotal_timeShift hσ (y - x)))
  · intro h σ hσ
    exact h σ hσ x

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

The nonzero offsets carry no independent semantic content: every total history is a time-shift of
a base history, so every truth value in the model is a truth value at some `regionHistory f w 0`. `truthAt_box_iff_base`
is the form the truth lemma's `box` case consumes.
-/

section BaseReduction

variable {W ι D : Type} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]

/-- Every region history is a time-shift of the base history of its world. -/
theorem regionHistory_eq_timeShift (f : ι → D) (w : W) (Δ : D) :
    regionHistory f w Δ = WorldHistory.timeShift (regionHistory f w (0 : D)) Δ := by
  rw [timeShift_regionHistory, add_zero]

/-- Truth at an offset history is truth at its base history, read at the offset time. -/
theorem truthAt_regionHistory_offset (M : TaskModel (regionFrame W ι D)) (f : ι → D)
    (w : W) (Δ r : D) (φ : Formula) :
    TruthAt M (regionHistory f w Δ) r φ ↔
      TruthAt M (regionHistory f w (0 : D)) (r + Δ) φ := by
  have h := TimeShift.time_shift_preserves_truth M
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
    -- A base history is total (`regionHistory_isTotal`), which is exactly what the box clause
    -- instantiates against now that it no longer mentions a designated admissible set.
    exact h _ (regionHistory_isTotal f w (0 : D)) y
  · intro h σ hσ y
    obtain ⟨w, Δ, rfl⟩ := (isTotal_iff_regionHistory f σ).mp hσ
    exact (truthAt_regionHistory_offset M f w Δ y φ).mpr (h w (y + Δ))

end BaseReduction

/-! ## Region-constancy: what holds, and what provably does not -/

section RegionConstancy

variable {W ι D : Type} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]

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
  have h : ((w, r + Δ) : W × D) = (w, r' + Δ) := hRC.states_congr hsame trivial trivial
  exact hne (add_right_cancel (congrArg Prod.snd h))

end RegionConstancy

/-! ## Sanity checks

Exercised by name so that a definition that stops elaborating fails here rather than downstream.
-/

section Checks

/--
**The translates are not region-constant** — the concrete refutation of the Phase 6 hypothesis
`∀ τ, τ.IsTotal → RegionConstant f τ` promised in the module docstring.

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
example : Nonempty (TaskFrame ℚ) := ⟨regionFrame Unit (Fin 1) ℚ⟩
example : Nonempty (TaskFrame ℝ) := ⟨regionFrame Unit (Fin 1) ℝ⟩
example : Nonempty (TaskFrame ℤ) := ⟨regionFrame Unit (Fin 1) ℤ⟩

/-- The base histories are total at a concrete carrier, and totality is all `□` now asks of
them. -/
example : (regionHistory (W := Unit) (fun _ : Fin 1 => (0 : ℚ)) () 1).IsTotal :=
  regionHistory_isTotal _ _ _

end Checks

end FormalSystem.Metalogic.Decidability.Verified.Bridge
