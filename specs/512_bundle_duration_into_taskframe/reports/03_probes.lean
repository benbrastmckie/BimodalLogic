/-
Third probe file: pinning down EXACTLY when a concrete bundled frame's `Duration`
carrier is transparent to typeclass synthesis, and what the working idiom is for the
`ℤ`-specific machinery (IntNormalForm / IntPresentation / Decidability).

Run with:
  lake env lean specs/512_bundle_duration_into_taskframe/reports/03_probes.lean
-/

import FormalSystem.Semantics.TaskFrame
import Mathlib.Algebra.Order.Group.Int
import Mathlib.Tactic.NormNum

namespace Probe3

open FormalSystem.Semantics

structure BFrame where
  Duration : Type
  [addCommGroup : AddCommGroup Duration]
  [linearOrder : LinearOrder Duration]
  [orderedAddMonoid : IsOrderedAddMonoid Duration]
  [nontrivial : Nontrivial Duration]
  WorldState : Type
  [worldNonempty : Nonempty WorldState]
  TaskRel : WorldState → Duration → WorldState → Prop
  nullity_identity : ∀ w u, TaskRel w 0 u ↔ w = u
  comp : TaskFrame.Compositional TaskRel
  converse : ∀ w d u, TaskRel w d u ↔ TaskRel u (-d) w
  serial : TaskFrame.Serial TaskRel
  limit : ∀ w u, (∀ x, 0 < x → ∃ y, |y| < x ∧ TaskRel w y u) → u = w
  spherical : TaskFrame.Spherical TaskRel

attribute [instance] BFrame.addCommGroup BFrame.linearOrder BFrame.orderedAddMonoid
  BFrame.nontrivial BFrame.worldNonempty

/-! ## R1. Direct `abbrev` with literal field syntax — carrier is a `mk` application -/

abbrev directInt : BFrame where
  Duration := Int
  WorldState := Bool
  TaskRel w _ u := w = u
  nullity_identity _ _ := Iff.rfl
  comp := by
    intro w v x y _ _
    constructor
    · intro h; exact ⟨w, rfl, h⟩
    · rintro ⟨u, rfl, h⟩; exact h
  converse w _ u := ⟨fun h => h.symm, fun h => h.symm⟩
  serial := fun w _ _ => ⟨⟨w, rfl⟩, ⟨w, rfl⟩⟩
  limit w u h := by
    obtain ⟨y, _, hy⟩ := h 1 Int.one_pos
    exact hy.symm
  spherical := TaskFrame.spherical_of_eq (D := Int) (fun _ _ _ => Iff.rfl)

-- R1a. Does typeclass synthesis now see `Int`?
example (x : directInt.Duration) : x + 1 = 1 + x := add_comm x 1
-- `omega` needs the type to be SYNTACTICALLY `Int`. Neither `abbrev` nor an
-- ascription-`show` (which inserts no cast, since the types are already defeq) helps.
example (x y : directInt.Duration) (h : x < y) : x + 1 ≤ y := by
  fail_if_success omega
  exact Int.add_one_le_iff.mpr h
example (x : directInt.Duration) : Decidable (x = 0) := inferInstance

/-! ## R2. Same body, but as a plain `def` -/

def defInt : BFrame where
  Duration := Int
  WorldState := Bool
  TaskRel w _ u := w = u
  nullity_identity _ _ := Iff.rfl
  comp := by
    intro w v x y _ _
    constructor
    · intro h; exact ⟨w, rfl, h⟩
    · rintro ⟨u, rfl, h⟩; exact h
  converse w _ u := ⟨fun h => h.symm, fun h => h.symm⟩
  serial := fun w _ _ => ⟨⟨w, rfl⟩, ⟨w, rfl⟩⟩
  limit w u h := by
    obtain ⟨y, _, hy⟩ := h 1 Int.one_pos
    exact hy.symm
  spherical := TaskFrame.spherical_of_eq (D := Int) (fun _ _ _ => Iff.rfl)

-- R2a. Does synthesis see `Int` through a plain `def`?  **NO.** Uncommenting the line
-- below reproduces, verbatim:
--   failed to synthesize instance of type class
--     OfNat defInt.Duration 1
--   numerals are polymorphic in Lean, but the numeral `1` cannot be used in a context
--   where the expected type is defInt.Duration
-- Typeclass synthesis runs at REDUCIBLE transparency; a plain `def` does not unfold there.
-- example (x : defInt.Duration) : x + 1 = 1 + x := add_comm x 1

/-! ## R3. `@[reducible]` on the plain `def` -/

attribute [reducible] defInt

example (x : defInt.Duration) : x + 1 = 1 + x := add_comm x 1
example (x y : defInt.Duration) (h : x < y) : x + 1 ≤ y :=
  Int.add_one_le_iff.mpr h

/-! ## R4. The IDIOM that works regardless of reducibility:
     state everything at `ℤ`, let unification (default transparency) do the work. -/

def opaqueInt : BFrame := defInt

-- R4a. Can an `ℤ`-typed variable be fed to `F.TaskRel`?
example (w u : opaqueInt.WorldState) (d : Int) : Prop := opaqueInt.TaskRel w d u

-- R4b. Can an `ℤ` numeral literal be fed directly?
example (w u : opaqueInt.WorldState) : Prop := opaqueInt.TaskRel w (3 : Int) u

-- R4c. Does an `ℤ`-stated theorem about the frame elaborate and prove?
theorem opaqueInt_rel (w u : opaqueInt.WorldState) (d : Int) :
    opaqueInt.TaskRel w d u ↔ w = u := Iff.rfl

-- R4d. And `omega` inside such a statement, with the arithmetic at `ℤ`?
example (w u : opaqueInt.WorldState) (d : Int) (h : 0 < d) :
    opaqueInt.TaskRel w ((d + 1 : Int)) u ↔ w = u := by
  have : (0 : Int) < d + 1 := by omega
  exact Iff.rfl

/-! ## R5. `Duration`-equation rewriting for an opaque frame -/

theorem opaqueInt_Duration : opaqueInt.Duration = Int := rfl

example (_x : opaqueInt.Duration) : True := trivial

-- The working route for `omega` at a concrete frame: restate the goal with the
-- variables genuinely re-typed at `Int` via a generalizing helper lemma.
theorem opaqueInt_int_lemma (x y : Int) (h : x < y) : x + 1 ≤ y := by omega

-- Same negative at the opaque frame: the numeral `1` cannot be elaborated at
-- `opaqueInt.Duration`. The goal must be stated at `Int` in the first place.
-- example (x y : opaqueInt.Duration) (h : x < y) : x + 1 ≤ y :=
--   opaqueInt_int_lemma x y h
example (x y : Int) (h : x < y) : x + 1 ≤ y := opaqueInt_int_lemma x y h

/-! ## R6. Does the transparency problem reach ABSTRACT frames?  (expected: no) -/

example (F : BFrame) (x y : F.Duration) : x + y = y + x := add_comm x y
example (F : BFrame) (x : F.Duration) : x - x = 0 := sub_self x
example (F : BFrame) (x y : F.Duration) : x ≤ y ∨ y ≤ x := le_total x y
example (F : BFrame) (x : F.Duration) (h : 0 < x) : ∃ y : F.Duration, 0 < y ∧ y ≤ x :=
  ⟨x, h, le_refl x⟩
example (F : BFrame) [DenselyOrdered F.Duration] (x y : F.Duration) (h : x < y) :
    ∃ z, x < z ∧ z < y := exists_between h

/-! ## R7. Instance-binder side conditions ON a bundled frame -/

example (F : BFrame) (hd : DenselyOrdered F.Duration) (x y : F.Duration) (h : x < y) :
    ∃ z, x < z ∧ z < y := @exists_between _ _ hd _ _ h

-- R7a. `haveI` is the idiom for a Prop-valued frame-class hypothesis.
example (F : BFrame) (hd : DenselyOrdered F.Duration) (x y : F.Duration) (h : x < y) :
    ∃ z, x < z ∧ z < y := by
  haveI := hd
  exact exists_between h

/-! ## R8. Universe check: can `WorldState : Type` stay at `Type 0`
     while `Duration : Type` also stays at `Type 0`?  Already answered: `BFrame : Type 1`.
     Confirm the parameterized structure's current universe for comparison. -/

#check fun (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D] =>
  (TaskFrame D : Type 1)

/-! ## R9. The prescribed idiom for the concrete-ℤ machinery, end to end. -/

/-- Carrier equation, `rfl`, available as a `simp` lemma and as a `show` target. -/
@[simp] theorem opaqueInt_Duration' : opaqueInt.Duration = Int := rfl

/-- Frame lemmas take an explicit `(d : Int)` binder; unification places it. -/
theorem opaqueInt_rel_add (w u : opaqueInt.WorldState) (d e : Int) :
    opaqueInt.TaskRel w ((d + e : Int)) u ↔ opaqueInt.TaskRel w ((e + d : Int)) u := by
  rw [Int.add_comm]

/-- Arithmetic side conditions are discharged at `Int`, outside the frame application. -/
theorem opaqueInt_pos (w u : opaqueInt.WorldState) (d : Int) (h : 0 < d) :
    opaqueInt.TaskRel w ((d + 1 : Int)) u ↔ w = u := by
  have : (0 : Int) < d + 1 := by omega
  exact Iff.rfl

end Probe3
