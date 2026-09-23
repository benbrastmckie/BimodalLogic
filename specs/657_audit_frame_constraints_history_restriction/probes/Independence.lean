import Mathlib.Data.Int.SuccPred
import FormalSystem.Semantics.TaskFrame

/-!
# Probe: closing the independence matrix for `def:frame`'s four constraints

Two of the four constraints already have compiled independence witnesses in the library:

* *Limit* — the four-state funnel: `StateTopology.funnel_serial`, `...funnel_compositional`,
  `...funnel_saturation`, `...funnel_not_limit`.
* *Saturation* — the rational two-origin frame: `StateTopology.RationalTwoOrigins.rel_serial`,
  `...rel_compositional`, `...rel_limit`, `...not_rel_saturation`.

The other two had none. This probe supplies them, over `ℤ`-time with a two-element carrier, so
that every one of `def:frame`'s constraints is certified **independent** of the other three.

* *Seriality* — the **void frame** `V`: the empty task relation. *Compositionality*, *Limit* and
  *Saturation* all hold vacuously; *Seriality* fails at `x = 0`, since no state has a successor.
* *Compositionality* — the **bump frame** `B`: identity at duration `0`, everything at duration
  `±1`, identity again at `|d| ≥ 2`. *Seriality*, *Limit* and *Saturation* hold; composition
  fails, because `ff ⇒₁ tt` and `tt ⇒₁ tt` while `ff ⇏₂ tt`.

Both are finite, so *Saturation* is free by `cor:saturation-finite`
(`TaskFrame.saturation_of_finite`), and both are over `ℤ`, so *Limit* is the one-step argument.
-/

namespace FormalSystem.Semantics

open TaskFrame

namespace ConstraintIndependence

/-! ## The void frame: *Seriality* is independent -/

/-- The empty task relation on `Bool` over `ℤ`-time. -/
def voidRel : Bool → ℤ → Bool → Prop := fun _ _ _ => False

/-- The void relation obeys the reflection law. -/
theorem voidRel_refl_law : ∀ w d u, voidRel w d u ↔ voidRel u (-d) w := by
  intro w d u; exact Iff.rfl

/-- **The void frame** `V`. -/
def voidFrame : FrameOver intOrder :=
  FrameOver.ofReflective Bool voidRel voidRel_refl_law

theorem voidFrame_taskRel : voidFrame.TaskRel = voidRel :=
  FrameOver.ofReflective_taskRel_eq

/-- *Compositionality* holds vacuously: both sides of the biconditional are false. -/
theorem voidFrame_compositional : TaskFrame.Compositional voidFrame.TaskRel := by
  rw [voidFrame_taskRel]
  intro w v x y _ _
  exact ⟨fun h => h.elim, fun ⟨_, h, _⟩ => h.elim⟩

/-- *Limit* holds vacuously: the cone hypothesis cannot be met. -/
theorem voidFrame_limit : TaskFrame.Limit voidFrame.TaskRel := by
  rw [voidFrame_taskRel]
  intro w u h
  obtain ⟨y, _, hy⟩ := h 1 (by norm_num)
  exact hy.elim

/-- *Saturation* holds, by `cor:saturation-finite` — the carrier is finite. -/
theorem voidFrame_saturation : TaskFrame.Saturation voidFrame.TaskRel := by
  rw [voidFrame_taskRel]
  exact TaskFrame.saturation_of_finite voidRel

/-- **The independence witness for *Seriality***: no state has a `0`-successor. -/
theorem voidFrame_not_serial : ¬ TaskFrame.Serial voidFrame.TaskRel := by
  rw [voidFrame_taskRel]
  intro h
  obtain ⟨⟨u, hu⟩, _⟩ := h false 0 le_rfl
  exact hu.elim

/-! ## The bump frame: *Compositionality* is independent -/

/--
The bump relation on `Bool` over `ℤ`-time: identity at duration `0`, the total relation at
duration `±1`, identity again from `|d| ≥ 2` outwards.
-/
def bumpRel : Bool → ℤ → Bool → Prop :=
  fun w d u => (d = 0 ∧ w = u) ∨ |d| = 1 ∨ (2 ≤ |d| ∧ w = u)

/-- The bump relation obeys the reflection law: every clause is symmetric under `d ↦ -d`,
`w ↔ u`. -/
theorem bumpRel_refl_law : ∀ w d u, bumpRel w d u ↔ bumpRel u (-d) w := by
  intro w d u
  simp only [bumpRel, abs_neg, neg_eq_zero]
  constructor
  · rintro (⟨h1, h2⟩ | h | ⟨h1, h2⟩)
    · exact Or.inl ⟨h1, h2.symm⟩
    · exact Or.inr (Or.inl h)
    · exact Or.inr (Or.inr ⟨h1, h2.symm⟩)
  · rintro (⟨h1, h2⟩ | h | ⟨h1, h2⟩)
    · exact Or.inl ⟨h1, h2.symm⟩
    · exact Or.inr (Or.inl h)
    · exact Or.inr (Or.inr ⟨h1, h2.symm⟩)

/-- **The bump frame** `B`. -/
def bumpFrame : FrameOver intOrder :=
  FrameOver.ofReflective Bool bumpRel bumpRel_refl_law

theorem bumpFrame_taskRel : bumpFrame.TaskRel = bumpRel :=
  FrameOver.ofReflective_taskRel_eq

/-- *Seriality* holds: every state is its own successor and predecessor at every `x ≥ 0`. -/
theorem bumpFrame_serial : TaskFrame.Serial bumpFrame.TaskRel := by
  rw [bumpFrame_taskRel]
  have key : ∀ (w : Bool) (x : ℤ), 0 ≤ x → bumpRel w x w := by
    intro w x hx
    by_cases h0 : x = 0
    · exact Or.inl ⟨h0, rfl⟩
    by_cases h1 : x = 1
    · exact Or.inr (Or.inl (by rw [h1]; norm_num))
    · refine Or.inr (Or.inr ⟨?_, rfl⟩)
      rw [abs_of_nonneg hx]
      omega
  intro w x hx
  exact ⟨⟨w, key w x hx⟩, ⟨w, key w x hx⟩⟩

/-- *Limit* holds: at radius `1` over `ℤ` the only available duration is `0`, where the relation
is the identity. -/
theorem bumpFrame_limit : TaskFrame.Limit bumpFrame.TaskRel := by
  rw [bumpFrame_taskRel]
  haveI : SuccOrder (intOrder.carrier) := (inferInstance : SuccOrder ℤ)
  haveI : NoMaxOrder (intOrder.carrier) := (inferInstance : NoMaxOrder ℤ)
  refine TaskFrame.limit_of_succOrder (fun w u hR => ?_)
  rcases hR with ⟨_, h2⟩ | h | ⟨h1, _⟩
  · exact h2.symm
  · norm_num at h
  · norm_num at h1

/-- *Saturation* holds, by `cor:saturation-finite`. -/
theorem bumpFrame_saturation : TaskFrame.Saturation bumpFrame.TaskRel := by
  rw [bumpFrame_taskRel]
  exact TaskFrame.saturation_of_finite bumpRel

/--
**The independence witness for *Compositionality***: `ff ⇒₁ tt` and `tt ⇒₁ tt`, yet `ff ⇏₂ tt`,
so the composition (`←`) half of the biconditional fails.
-/
theorem bumpFrame_not_compositional : ¬ TaskFrame.Compositional bumpFrame.TaskRel := by
  rw [bumpFrame_taskRel]
  intro h
  have hone : |(1 : ℤ)| = 1 := by norm_num
  have hrhs : ∃ u, bumpRel false 1 u ∧ bumpRel u 1 true :=
    ⟨true, Or.inr (Or.inl hone), Or.inr (Or.inl hone)⟩
  have hlhs := (h false true 1 1 (by norm_num) (by norm_num)).mpr hrhs
  rcases hlhs with ⟨h1, _⟩ | h1 | ⟨_, h2⟩
  · norm_num at h1
  · norm_num at h1
  · norm_num at h2

end ConstraintIndependence

end FormalSystem.Semantics

section AxiomCheck
open FormalSystem.Semantics.ConstraintIndependence
#print axioms voidFrame_compositional
#print axioms voidFrame_limit
#print axioms voidFrame_saturation
#print axioms voidFrame_not_serial
#print axioms bumpFrame_serial
#print axioms bumpFrame_limit
#print axioms bumpFrame_saturation
#print axioms bumpFrame_not_compositional
end AxiomCheck
