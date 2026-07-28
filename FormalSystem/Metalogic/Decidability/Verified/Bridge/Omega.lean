/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.Verified.Bridge.Interpolate
import FormalSystem.Semantics.Validity

/-!
# The countermodel's frame, histories, and admissible set

`Bridge/Interpolate.lean` ends with a total valuation on the carrier and the statement that truth
is constant on each region cut out by the placement. This file supplies the objects that
statement is about: a `TaskFrame`, a family of `WorldHistory`s, and the set `Ω` of admissible
histories that `valid` quantifies over.

## What `valid` demands, and the one constraint that is not negotiable

`FormalSystem.Semantics.valid` reads

```
∀ D, ∀ F : TaskFrame D, ∀ M, ∀ Ω, ShiftClosed Ω → ∀ τ ∈ Ω, ∀ t, TruthAt M Ω τ t φ
```

so refuting it means producing a **shift-closed** `Ω`. That is not a formality, and it decides
the shape of everything below.

### Consequence 1: `Ω = Set.univ` is unusable

`Set.univ` is shift-closed, and the plan named it as the fallback, but it cannot be used here.
`Set.univ` contains the empty history (`domain := fun _ => False`, all other fields vacuous), at
which every atom is false. `TruthAt … (box φ)` is a universal over `Ω` at a fixed time, so a
single such history falsifies `□p` outright and no branch carrying `T(□p)` could ever be
satisfied. `Ω` is therefore taken to be a *range*: exactly the histories the branch calls for,
and their time-translates.

### Consequence 2: `□` is the universal modality

For any shift-closed `Ω`, `time_shift_preserves_truth` turns the fixed-time universal into a
universal over times as well:

```
TruthAt M Ω τ x (box φ) ↔ ∀ σ ∈ Ω, ∀ y, TruthAt M Ω σ y φ
```

(`truthAt_box_iff` below). Truth of a boxed formula does not depend on where it is evaluated;
this is the semantic form of the perpetuity of `TM`, and it is what makes the `box` case of the
region-invariance induction *free* rather than an appeal to the induction hypothesis.

The engine agrees, which is worth recording because it is the load-bearing adequacy check for
this design: `□p → □Gp`, `□p → □□p`, `□p → G□p` and `□p → ¬◇F¬p` all close, and so do the
seriality rows `G p → F p`, `¬(Gp ∧ G¬p)`, `¬(Hp ∧ H¬p)`, `F ⊤`, `P ⊤`, while `F p → p` stays
open. See `Checks` at the bottom of this file for the two facts that are cheap to state in Lean;
the closure rows are `#eval` probes against `buildTableau`.

### Consequence 3: Phase 6's `∀ τ ∈ Ω, RegionConstant f τ` is NOT satisfiable here

`Interpolate.lean` hands `interpInvariant` over with the hypothesis `∀ τ ∈ Om, RegionConstant f τ`
— every history of the admissible set is constant on the regions of the *fixed* placement `f`.
For a shift-closed `Ω` that hypothesis forces the model to be trivial, and the argument is short
enough to state exactly:

Let `τ ∈ Ω` and `r ≠ r'`. `Ω` contains `timeShift τ Δ` for every `Δ`, whose state at `r` is
`τ.states (r + Δ)`. Region-constancy of *that* history at `r, r'` says: if `r` and `r'` are
region-mates then `τ.states (r + Δ) = τ.states (r' + Δ)`. Since `ι` is finite, only finitely many
`Δ` place a point of `f` between `r + Δ` and `r' + Δ`; choosing any other `Δ` makes the two
region-mates and forces `τ.states (r + Δ) = τ.states (r' + Δ)` for cofinitely many `Δ`, hence
`τ.states` constant. A history with constant states cannot separate two times, so no branch
asserting `T(p) @ t₁` and `F(p) @ t₂` in one world could be satisfied.

`regionConstant_regionHistory_zero` therefore proves region-constancy for the **base** history
only, and `not_regionConstant_regionHistory_one` exhibits a translate that is genuinely not
region-constant (`D = ℚ`, one placed point at `0`, `Δ = 1`, region-mates `-1/2` and `-2` whose
translates `1/2` and `-1` straddle the placed point). The truth induction Phase 7 runs is
consequently the **per-history** form `InterpInvariantAt` (`Bridge/TruthLemma.lean`), whose
`box` case is discharged by `truthAt_box_iff` instead of by an induction hypothesis at every
history. This is a correction to the Phase 6 → Phase 7 interface, not a re-opening of Phase 6:
every region lemma in `Interpolate.lean` is consumed unchanged.

## The frame

`regionFrame W ι D` has states `W × (Set ι × Set ι)` — a branch world paired with a region code
(`regionCode`, `Interpolate.lean`) — and the weakest task relation the `TaskFrame` axioms allow,
`TaskRel s d s' := d = 0 → s = s'`. `nullity_identity` forces at least this much, and asking for
no more keeps `respects_task` free for every history built below. A universal `TaskRel` is *not*
available: `nullity_identity` is an iff, so `TaskRel w 0 u` must imply `w = u`.

Pairing the world with a region *code* rather than with the raw time is what makes
`RegionConstant` provable at the base history: the code is by construction constant on regions.
-/

namespace FormalSystem.Metalogic.Decidability.Verified.Bridge

open FormalSystem.Syntax
open FormalSystem.Semantics
open FormalSystem.Metalogic.Decidability

/-! ## Extensionality for histories

`WorldHistory` carries two proof fields, so equality of two histories is decided by the domain
and the state assignment alone. Needed to identify a time-shifted history with another member of
the range that defines `Ω`.
-/

/-- Two histories with the same domain and the same states are equal. -/
theorem worldHistory_ext {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    {F : TaskFrame D} {σ τ : WorldHistory F} (hd : σ.domain = τ.domain)
    (hs : ∀ (r : D) (h : σ.domain r) (h' : τ.domain r), σ.states r h = τ.states r h') :
    σ = τ := by
  obtain ⟨d₁, c₁, s₁, t₁⟩ := σ
  obtain ⟨d₂, c₂, s₂, t₂⟩ := τ
  simp only at hd hs
  subst hd
  have : s₁ = s₂ := by
    funext r h
    exact hs r h h
  subst this
  rfl

/-! ## The frame -/

section Frame

variable (W ι D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]

/--
The countermodel's frame: a state is a branch world together with a region code, and the task
relation is the weakest one `nullity_identity` permits.

Weakest is deliberate. `respects_task` is the only constraint a history must satisfy, and with
this relation it reduces to "equal times carry equal states", which is free. Anything stronger
would restrict which region-code assignments are legal histories without buying anything: the
admissible set `Ω` is given as an explicit range, not carved out by the frame.
-/
def regionFrame : TaskFrame D where
  WorldState := W × (Set ι × Set ι)
  TaskRel := fun s d s' => d = 0 → s = s'
  nullity_identity := by
    intro w u
    exact ⟨fun h => h rfl, fun h _ => h⟩
  forward_comp := by
    intro w u v x y hx hy h₁ h₂ hxy
    have hx0 : x = 0 := by
      have : x ≤ x + y := le_add_of_nonneg_right hy
      rw [hxy] at this
      exact le_antisymm this hx
    have hy0 : y = 0 := by
      have : y ≤ x + y := le_add_of_nonneg_left hx
      rw [hxy] at this
      exact le_antisymm this hy
    exact (h₁ hx0).trans (h₂ hy0)
  converse := by
    intro w d u
    constructor
    · intro h hd
      exact (h (neg_eq_zero.mp hd)).symm
    · intro h hd
      exact (h (by rw [hd, neg_zero])).symm

@[simp]
theorem regionFrame_taskRel (s : W × (Set ι × Set ι)) (d : D) (s' : W × (Set ι × Set ι)) :
    (regionFrame W ι D).TaskRel s d s' ↔ (d = 0 → s = s') := Iff.rfl

end Frame

/-! ## The histories and the admissible set -/

section Histories

variable {W ι D : Type} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]

/--
The history of world `w` viewed with time offset `Δ`: total in time, assigning to `r` the state
"world `w`, in the region of `r + Δ`".

`Δ = 0` is the history the branch is really about; the nonzero offsets exist only because `Ω`
has to be shift-closed, and `timeShift_regionHistory` says they are exactly the time-shifts of
the base histories.
-/
def regionHistory (f : ι → D) (w : W) (Δ : D) : WorldHistory (regionFrame W ι D) where
  domain := fun _ => True
  convex := by intro _ _ _ _ _ _ _; trivial
  states := fun r _ => (w, regionCode f (r + Δ))
  respects_task := by
    intro s t _ _ _ hd
    have : t = s := by
      have := sub_eq_zero.mp hd
      exact this
    subst this
    rfl

@[simp]
theorem regionHistory_domain (f : ι → D) (w : W) (Δ : D) (r : D) :
    (regionHistory f w Δ).domain r := trivial

@[simp]
theorem regionHistory_states (f : ι → D) (w : W) (Δ : D) (r : D) (h : (regionHistory f w Δ).domain r) :
    (regionHistory f w Δ).states r h = (w, regionCode f (r + Δ)) := rfl

/-- Time-shifting a region history is again a region history, with the offsets added. -/
theorem timeShift_regionHistory (f : ι → D) (w : W) (Δ Δ' : D) :
    WorldHistory.timeShift (regionHistory f w Δ) Δ' = regionHistory f w (Δ' + Δ) := by
  refine worldHistory_ext rfl ?_
  intro r _ _
  show (w, regionCode f (r + Δ' + Δ)) = (w, regionCode f (r + (Δ' + Δ)))
  rw [add_assoc]

/--
The admissible set: the branch's worlds, at every time offset.

Shift-closed by `timeShift_regionHistory`, and containing no history whose domain is partial —
which is what keeps `□` satisfiable (see the module docstring, Consequence 1).
-/
def regionOmega (f : ι → D) : Set (WorldHistory (regionFrame W ι D)) :=
  Set.range fun p : W × D => regionHistory f p.1 p.2

theorem regionHistory_mem_regionOmega (f : ι → D) (w : W) (Δ : D) :
    regionHistory f w Δ ∈ regionOmega f :=
  ⟨(w, Δ), rfl⟩

theorem mem_regionOmega_iff (f : ι → D) (σ : WorldHistory (regionFrame W ι D)) :
    σ ∈ regionOmega f ↔ ∃ (w : W) (Δ : D), σ = regionHistory f w Δ := by
  constructor
  · rintro ⟨⟨w, Δ⟩, rfl⟩
    exact ⟨w, Δ, rfl⟩
  · rintro ⟨w, Δ, rfl⟩
    exact regionHistory_mem_regionOmega f w Δ

/-- **The shift-closure obligation, discharged.** -/
theorem shiftClosed_regionOmega (f : ι → D) : ShiftClosed (regionOmega (W := W) f) := by
  rintro σ ⟨⟨w, Δ⟩, rfl⟩ Δ'
  exact ⟨(w, Δ' + Δ), (timeShift_regionHistory f w Δ Δ').symm⟩

/-- Every region history has total domain, so every point of the carrier carries a state. -/
theorem regionOmega_total (f : ι → D) (σ : WorldHistory (regionFrame W ι D))
    (hσ : σ ∈ regionOmega f) (r : D) : σ.domain r := by
  obtain ⟨w, Δ, rfl⟩ := (mem_regionOmega_iff f σ).mp hσ
  trivial

end Histories

/-! ## `□` is the universal modality

The single semantic fact that makes a shift-closed `Ω` workable at all. Stated for an arbitrary
shift-closed `Ω`, because nothing about `regionOmega` is used.
-/

section BoxUniversal

variable {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] {F : TaskFrame D}

/--
**Box is evaluation-point independent.** For a shift-closed `Ω`, `box φ` holds at one point iff
`φ` holds at *every* history of `Ω` and *every* time.

The forward direction shifts an arbitrary `(σ, y)` back to `x` — legal precisely because `Ω` is
shift-closed — and reads the result off `time_shift_preserves_truth`.
-/
theorem truthAt_box_iff (M : TaskModel F) {Om : Set (WorldHistory F)} (hsc : ShiftClosed Om)
    (τ : WorldHistory F) (x : D) (φ : Formula) :
    TruthAt M Om τ x φ.box ↔ ∀ σ ∈ Om, ∀ y : D, TruthAt M Om σ y φ := by
  simp only [TruthAt]
  constructor
  · intro h σ hσ y
    exact (TimeShift.time_shift_preserves_truth M Om hsc σ x y φ).mp (h _ (hsc σ hσ (y - x)))
  · intro h σ hσ
    exact h σ hσ x

/-- Truth of a boxed formula does not depend on the time it is evaluated at. -/
theorem truthAt_box_congr (M : TaskModel F) {Om : Set (WorldHistory F)} (hsc : ShiftClosed Om)
    (τ : WorldHistory F) (x y : D) (φ : Formula) :
    TruthAt M Om τ x φ.box ↔ TruthAt M Om τ y φ.box := by
  rw [truthAt_box_iff M hsc τ x φ, truthAt_box_iff M hsc τ y φ]

/-- Nor on the history it is evaluated in. -/
theorem truthAt_box_congr_history (M : TaskModel F) {Om : Set (WorldHistory F)}
    (hsc : ShiftClosed Om) (τ σ : WorldHistory F) (x y : D) (φ : Formula) :
    TruthAt M Om τ x φ.box ↔ TruthAt M Om σ y φ.box := by
  rw [truthAt_box_iff M hsc τ x φ, truthAt_box_iff M hsc σ y φ]

end BoxUniversal

/-! ## Region-constancy: what holds, and what provably does not -/

section RegionConstancy

variable {W ι D : Type} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]

/--
**The base history is region-constant.** Its state at `r` is the region code of `r` itself, and
`SameRegion` is equality of codes.
-/
theorem regionConstant_regionHistory_zero (f : ι → D) (w : W) :
    RegionConstant f (regionHistory f w (0 : D)) where
  domain_congr := fun _ => Iff.rfl
  states_congr := by
    intro r r' h _ _
    show (w, regionCode f (r + 0)) = (w, regionCode f (r' + 0))
    rw [add_zero, add_zero, sameRegion_iff_regionCode_eq.mp h]

end RegionConstancy

/-! ## Sanity checks

Exercised by name so that a definition that stops elaborating fails here rather than downstream.
-/

section Checks

/--
**The translates are not region-constant** — the concrete refutation of the Phase 6 hypothesis
`∀ τ ∈ Ω, RegionConstant f τ` promised in the module docstring.

One placed point at `0 : ℚ`; `-1/2` and `-2` are region-mates (both strictly below the only
placed point), but the `Δ = 1` history reads their states off `1/2` and `-1`, which straddle it.
-/
theorem not_regionConstant_regionHistory_one :
    ¬ RegionConstant (fun _ : Fin 1 => (0 : ℚ)) (regionHistory (W := Unit) (fun _ : Fin 1 => (0 : ℚ)) () 1) := by
  intro hRC
  have hsame : SameRegion (fun _ : Fin 1 => (0 : ℚ)) (-1/2) (-2) := by
    intro i
    constructor
    · constructor <;> intro h <;> norm_num at h
    · constructor <;> intro _ <;> norm_num
  have := hRC.states_congr hsame trivial trivial
  have hcode : regionCode (fun _ : Fin 1 => (0 : ℚ)) (-1/2 + 1) =
      regionCode (fun _ : Fin 1 => (0 : ℚ)) (-2 + 1) := congrArg Prod.snd this
  have hmem : (0 : Fin 1) ∈ (regionCode (fun _ : Fin 1 => (0 : ℚ)) (-1/2 + 1)).1 := by
    simp only [regionCode, Set.mem_setOf_eq]
    norm_num
  rw [hcode] at hmem
  simp only [regionCode, Set.mem_setOf_eq] at hmem
  norm_num at hmem

/-- The frame elaborates at each of the three dense carriers and at `ℤ`. -/
example : Nonempty (TaskFrame ℚ) := ⟨regionFrame Unit (Fin 1) ℚ⟩
example : Nonempty (TaskFrame ℝ) := ⟨regionFrame Unit (Fin 1) ℝ⟩
example : Nonempty (TaskFrame ℤ) := ⟨regionFrame Unit (Fin 1) ℤ⟩

/-- The admissible set is shift-closed at a concrete carrier. -/
example : ShiftClosed (regionOmega (W := Unit) (fun _ : Fin 1 => (0 : ℚ))) :=
  shiftClosed_regionOmega _

end Checks

end FormalSystem.Metalogic.Decidability.Verified.Bridge
