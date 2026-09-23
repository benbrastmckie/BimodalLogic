/-
Probe: the `class FrameOver.IsRegular` architecture, in miniature, mirroring the real
`FormalSystem/Semantics/TaskFrame.lean` shapes exactly (fibre `PreFrame`, total space `PreTask`).
Question answered: does stripping the four axiom fields into a `Prop`-valued class keep
(i) `F.comp` textually unchanged at use sites, (ii) `Valid`-style quantification meaningful,
(iii) construction sites splittable, (iv) instance synthesis at concrete frames?
-/
import FormalSystem.Semantics.TaskFrame
import Mathlib.Data.Rat.Defs
import Mathlib.Data.Finite.Prod
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Positivity

namespace Probe656

open FormalSystem.Semantics
open FormalSystem.Semantics.TaskFrame

variable {D : TemporalOrder}

/-- The GENERAL fibre: exactly `WorldState`, its nonemptiness, and `PosRel`. -/
structure PreFrame (D : TemporalOrder) where
  WorldState : Type
  [worldNonempty : Nonempty WorldState]
  PosRel : WorldState → D.PositiveCone → WorldState → Prop

attribute [instance] PreFrame.worldNonempty

namespace PreFrame

def TaskRel (F : PreFrame D) : F.WorldState → ↑D → F.WorldState → Prop :=
  TaskFrame.reflect F.PosRel

/-- `Limit`, NAMED, definitionally the literal transcribed shape. -/
def _root_.Probe656.Limit {W : Type} {D : Type} [AddCommGroup D] [LinearOrder D]
    [IsOrderedAddMonoid D] (R : W → D → W → Prop) : Prop :=
  ∀ w u, (∀ x, 0 < x → ∃ y, |y| < x ∧ R w y u) → u = w

/-- The CONSTRAINED class. -/
class IsRegular (F : PreFrame D) : Prop where
  comp : TaskFrame.Compositional F.TaskRel
  serial : TaskFrame.Serial F.TaskRel
  limit : Probe656.Limit F.TaskRel
  saturation : TaskFrame.Saturation F.TaskRel

/-- Re-export: `F.comp` reads EXACTLY as it does today at every use site. -/
theorem comp (F : PreFrame D) [h : F.IsRegular] : TaskFrame.Compositional F.TaskRel := h.comp
theorem serial (F : PreFrame D) [h : F.IsRegular] : TaskFrame.Serial F.TaskRel := h.serial
theorem limit (F : PreFrame D) [h : F.IsRegular] : Probe656.Limit F.TaskRel := h.limit
theorem saturation (F : PreFrame D) [h : F.IsRegular] : TaskFrame.Saturation F.TaskRel :=
  h.saturation

/-- A DERIVED theorem that needs only two of the four constraints: nullity. -/
theorem nullity (F : PreFrame D) [F.IsRegular] (w : F.WorldState) : F.TaskRel w 0 w :=
  TaskFrame.nullity_of_serial_limit (F.serial) (F.limit) w

end PreFrame

/-- The GENERAL total space. -/
structure PreTask where
  Duration : TemporalOrder
  toFibre : PreFrame Duration

namespace PreTask

@[reducible] def WorldState (G : PreTask) : Type := G.toFibre.WorldState
@[reducible] def TaskRel (G : PreTask) : G.WorldState → ↑G.Duration → G.WorldState → Prop :=
  G.toFibre.TaskRel

/-- The total-space constrained class, by delegation. -/
abbrev IsRegular (G : PreTask) : Prop := G.toFibre.IsRegular

instance instIsRegular (G : PreTask) [h : G.toFibre.IsRegular] : G.IsRegular := h

theorem comp (G : PreTask) [G.IsRegular] : TaskFrame.Compositional G.TaskRel :=
  G.toFibre.comp

/-- Structure eta survives the field strip. -/
example (G : PreTask) : (⟨G.Duration, G.toFibre⟩ : PreTask) = G := rfl
example (F : PreFrame D) : (PreTask.mk D F).toFibre = F := rfl

end PreTask

/-! ### A construction site, split into `def` + `instance` -/

section Concrete

abbrev intOrd : TemporalOrder := TemporalOrder.of ℤ

/-- The static frame over `Bool`, as a GENERAL frame: two fields only. -/
def staticBool : PreFrame intOrd where
  WorldState := Bool
  PosRel := fun w _ u => w = u

theorem staticBool_taskRel (w u : staticBool.WorldState) (d : ↑intOrd) :
    staticBool.TaskRel w d u ↔ w = u := by
  constructor
  · intro h
    rcases lt_or_ge d 0 with hd | hd
    · exact ((TaskFrame.reflect_of_neg (P := staticBool.PosRel) hd).mp h).symm
    · exact (TaskFrame.reflect_of_nonneg (P := staticBool.PosRel) hd).mp h
  · intro h
    rcases lt_or_ge d 0 with hd | hd
    · exact (TaskFrame.reflect_of_neg (P := staticBool.PosRel) hd).mpr h.symm
    · exact (TaskFrame.reflect_of_nonneg (P := staticBool.PosRel) hd).mpr h

/-- The four constraints, proved SEPARATELY of the frame -- requirement (1)/(6). -/
theorem staticBool_serial : TaskFrame.Serial staticBool.TaskRel := by
  intro w x _
  exact ⟨⟨w, (staticBool_taskRel w w x).mpr rfl⟩, ⟨w, (staticBool_taskRel w w x).mpr rfl⟩⟩

theorem staticBool_limit : Limit staticBool.TaskRel := by
  intro w u h
  obtain ⟨y, _, hy⟩ := h 1 one_pos
  exact ((staticBool_taskRel w u y).mp hy).symm

/-- Registering the class at the construction site. -/
instance : staticBool.IsRegular where
  comp := by
    intro w v x y _ _
    constructor
    · intro h; exact ⟨w, (staticBool_taskRel w w x).mpr rfl,
        (staticBool_taskRel w v y).mpr ((staticBool_taskRel w v (x + y)).mp h)⟩
    · rintro ⟨u, hu, hv⟩
      exact (staticBool_taskRel w v (x + y)).mpr
        (((staticBool_taskRel w u x).mp hu).trans ((staticBool_taskRel u v y).mp hv))
  serial := staticBool_serial
  limit := staticBool_limit
  saturation := TaskFrame.saturation_of_finite (W := Bool) _

/-- Synthesis finds the instance: `F.comp` at a concrete frame, textually unchanged. -/
example : TaskFrame.Compositional staticBool.TaskRel := staticBool.comp
example : staticBool.TaskRel true 0 true := staticBool.nullity true

end Concrete

/-! ### `Valid`-style quantification over the constrained class -/

def ValidLike (P : ∀ G : PreTask, G.WorldState → Prop) : Prop :=
  ∀ (G : PreTask) [G.IsRegular] (w : G.WorldState), P G w

theorem ValidLike.apply {P} (h : ValidLike P) (G : PreTask) [G.IsRegular] (w : G.WorldState) :
    P G w := h G w

/-- A general (NON-regular) frame is now a first-class citizen: the four-state funnel. -/
inductive Four | a | b | c | d
deriving DecidableEq

instance : Nonempty Four := ⟨Four.a⟩

abbrev ratOrd : TemporalOrder := TemporalOrder.of Rat

def funnel : PreFrame ratOrd where
  WorldState := Four
  PosRel := fun w x u =>
    (x : Rat) = 0 ∧ w = u ∨
      0 < (x : Rat) ∧ (w = u ∨ (w = Four.a ∨ w = Four.b) ∧ (u = Four.c ∨ u = Four.d))

/-- The point of the refactor: a frame that is NOT regular is still a frame. -/
theorem funnel_not_limit : ¬ Limit funnel.TaskRel := by
  intro h
  have : Four.c = Four.a := by
    refine h Four.a Four.c ?_
    intro x hx
    have hhalf : (0 : Rat) < x / 2 := by positivity
    refine ⟨x / 2, ?_, ?_⟩
    · rw [abs_of_pos hhalf]; linarith
    · exact (TaskFrame.reflect_of_nonneg (P := funnel.PosRel) hhalf.le).mpr
        (Or.inr ⟨hhalf, Or.inr ⟨Or.inl rfl, Or.inl rfl⟩⟩)
  exact Four.noConfusion this

/-! ### `ofReflective`: general constructor + regular constructor with an AUTO-INSTANCE -/

section OfReflective

variable {D : TemporalOrder}

/-- GENERAL `ofReflective`: three arguments, no axioms. -/
def PreFrame.ofReflective (W : Type) [Nonempty W] (R : W → ↑D → W → Prop)
    (_hR : ∀ w d u, R w d u ↔ R u (-d) w) : PreFrame D where
  WorldState := W
  PosRel w x u := R w (x : ↑D) u

/-- REGULAR `ofReflective`: the existing seven-argument signature, unchanged. -/
def PreFrame.ofReflectiveRegular (W : Type) [Nonempty W] (R : W → ↑D → W → Prop)
    (hR : ∀ w d u, R w d u ↔ R u (-d) w) (_hcomp : TaskFrame.Compositional R)
    (_hser : TaskFrame.Serial R)
    (_hlim : ∀ w u, (∀ x, 0 < x → ∃ y, |y| < x ∧ R w y u) → u = w)
    (_hsat : TaskFrame.Saturation R) : PreFrame D :=
  PreFrame.ofReflective W R hR

/-- **The auto-instance**: every frame built by the regular constructor carries its class
instance, found by synthesis. A call site migrates by ONE token
(`ofReflective` -> `ofReflectiveRegular`); nothing else at the site changes. -/
instance PreFrame.instIsRegularOfReflective (W : Type) [Nonempty W] (R : W → ↑D → W → Prop)
    (hR : ∀ w d u, R w d u ↔ R u (-d) w) (hcomp : TaskFrame.Compositional R)
    (hser : TaskFrame.Serial R)
    (hlim : ∀ w u, (∀ x, 0 < x → ∃ y, |y| < x ∧ R w y u) → u = w)
    (hsat : TaskFrame.Saturation R) :
    (PreFrame.ofReflectiveRegular W R hR hcomp hser hlim hsat).IsRegular where
  comp := TaskFrame.compositional_reflect_of_reflective hR hcomp
  serial := TaskFrame.serial_reflect_of_reflective hR hser
  limit := TaskFrame.limit_reflect_of_reflective hR hlim
  saturation := TaskFrame.saturation_reflect_of_reflective hR hsat

end OfReflective

/-! ### Deprecation aliases survive a rename -/

theorem regular_alias_target {D : TemporalOrder} (F : PreFrame D) [F.IsRegular] :
    TaskFrame.Serial F.TaskRel := F.serial

@[deprecated regular_alias_target (since := "2026-09-22")]
alias old_name_for_serial := regular_alias_target

/-! ### The `FrameClass.Sat` lever: `Sat .Base F := F.IsRegular` -/

section SatLever

/-- Mirrors `FormalSystem.Semantics.FrameClass.Sat`, which is `@[reducible]` by design so that
`intro h` registers the frame condition in the LOCAL INSTANCE CACHE (the mechanism the `.Dense`
tag already relies on). -/
inductive Tag | Base | Dense

@[reducible]
def Sat : Tag → PreTask → Prop
  | .Base, G => G.IsRegular
  | .Dense, G => G.IsRegular

/-- `GenericValidOnFrames` is UNCHANGED: `∀ G, P G → ...`. -/
def ValidOnFrames (P : PreTask → Prop) (Q : ∀ G : PreTask, G.WorldState → Prop) : Prop :=
  ∀ G : PreTask, P G → ∀ w : G.WorldState, Q G w

def Valid' (Q : ∀ G : PreTask, G.WorldState → Prop) : Prop := ValidOnFrames (Sat .Base) Q

/-- **The load-bearing check**: plain `intro h` on a `Sat .Base G` hypothesis puts
`G.IsRegular` in the instance cache, so `G.comp` elaborates with NO explicit application --
exactly as `sat_intro` already achieves for `.Dense`. -/
example (Q : ∀ G : PreTask, G.WorldState → Prop)
    (hyp : ∀ (G : PreTask) [G.IsRegular] (w : G.WorldState), Q G w) : Valid' Q := by
  intro G h w
  have : TaskFrame.Compositional G.TaskRel := G.comp
  exact hyp G w

/-- The auto-instance on the regular `ofReflective` is found by synthesis. -/
example (W : Type) [Nonempty W] {D : TemporalOrder} (R : W → ↑D → W → Prop)
    (hR : ∀ w d u, R w d u ↔ R u (-d) w) (hcomp : TaskFrame.Compositional R)
    (hser : TaskFrame.Serial R)
    (hlim : ∀ w u, (∀ x, 0 < x → ∃ y, |y| < x ∧ R w y u) → u = w)
    (hsat : TaskFrame.Saturation R) :
    TaskFrame.Serial (PreFrame.ofReflectiveRegular W R hR hcomp hser hlim hsat).TaskRel :=
  (PreFrame.ofReflectiveRegular W R hR hcomp hser hlim hsat).serial

end SatLever

#print axioms PreFrame.nullity
#print axioms funnel_not_limit

end Probe656
