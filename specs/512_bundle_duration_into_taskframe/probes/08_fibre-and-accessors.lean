/-
Probe 08 (plan v02, Phase 0, concerns (b), (d), (e), (f)):

  (b) STOP GATE — `omega` and `Int` arithmetic at `FrameOver intOrder`.
  (d) STOP     — the `@[reducible]` flat accessors preserve the surface v01's 86 landed files
                 depend on (`F.WorldState`, `F.TaskRel w d u`, `(d : F.Duration)` in binder
                 position, `F.spherical` consumed *definitionally*).
  (e)          — the fibre inclusion is the constructor, and the Σ-identity holds by `rfl`.
  (f)          — a `@[reducible] def ParamTaskFrame` alias holds unmigrated code green.

Run with:  lake env lean specs/512_bundle_duration_into_taskframe/probes/08_fibre-and-accessors.lean
-/
import FormalSystem.Semantics.TaskFrame
import Mathlib.Algebra.Order.Group.Int

namespace FibreProbe
open FormalSystem.Semantics

/-! ## The target shape, declared locally -/

structure TemporalOrder where
  carrier : Type
  [addCommGroup       : AddCommGroup carrier]
  [linearOrder        : LinearOrder carrier]
  [isOrderedAddMonoid : IsOrderedAddMonoid carrier]
  [nontrivial         : Nontrivial carrier]

instance : CoeSort TemporalOrder Type := ⟨TemporalOrder.carrier⟩

attribute [instance] TemporalOrder.addCommGroup TemporalOrder.linearOrder
  TemporalOrder.isOrderedAddMonoid TemporalOrder.nontrivial

@[reducible] def TemporalOrder.of (D : Type) [AddCommGroup D] [LinearOrder D]
    [IsOrderedAddMonoid D] [Nontrivial D] : TemporalOrder := ⟨D⟩

@[reducible] def intOrder : TemporalOrder := ⟨ℤ⟩

/-- The fibre: frames over a fixed temporal order. The six axioms live here, stated once. -/
structure FrameOver (D : TemporalOrder) where
  WorldState : Type
  [worldNonempty : Nonempty WorldState]
  TaskRel : WorldState → D → WorldState → Prop
  nullity_identity : ∀ w u, TaskRel w 0 u ↔ w = u
  comp      : ParamTaskFrame.Compositional TaskRel
  converse  : ∀ w d u, TaskRel w d u ↔ TaskRel u (-d) w
  serial    : ParamTaskFrame.Serial TaskRel
  limit     : ∀ w u, (∀ x, 0 < x → ∃ y, |y| < x ∧ TaskRel w y u) → u = w
  spherical : ParamTaskFrame.Spherical TaskRel

attribute [instance] FrameOver.worldNonempty

/-- The total space, `≅ Σ (D : TemporalOrder), FrameOver D` by structure eta. -/
structure TF where
  Duration : TemporalOrder
  toFibre  : FrameOver Duration

namespace TF
@[reducible] def WorldState (F : TF) : Type := F.toFibre.WorldState
instance worldNonempty (F : TF) : Nonempty F.WorldState := F.toFibre.worldNonempty
@[reducible] def TaskRel (F : TF) : F.WorldState → F.Duration → F.WorldState → Prop :=
  F.toFibre.TaskRel
theorem nullity_identity (F : TF) : ∀ w u, F.TaskRel w 0 u ↔ w = u :=
  F.toFibre.nullity_identity
theorem comp (F : TF) : ParamTaskFrame.Compositional F.TaskRel := F.toFibre.comp
theorem converse (F : TF) : ∀ w d u, F.TaskRel w d u ↔ F.TaskRel u (-d) w :=
  F.toFibre.converse
theorem serial (F : TF) : ParamTaskFrame.Serial F.TaskRel := F.toFibre.serial
theorem limit (F : TF) :
    ∀ w u, (∀ x, 0 < x → ∃ y, |y| < x ∧ F.TaskRel w y u) → u = w := F.toFibre.limit
theorem spherical (F : TF) : ParamTaskFrame.Spherical F.TaskRel := F.toFibre.spherical
end TF

/-! ## (e) The fibre inclusion is the constructor -/

@[reducible] def FrameOver.toTF {D : TemporalOrder} (F : FrameOver D) : TF := ⟨D, F⟩

example {D : TemporalOrder} (F : FrameOver D) : (F.toTF).Duration = D := rfl
example {D : TemporalOrder} (F : FrameOver D) : (F.toTF).toFibre = F := rfl
example (G : TF) : (⟨G.Duration, G.toFibre⟩ : TF) = G := rfl
example {D : TemporalOrder} (F : FrameOver D) : (F.toTF).WorldState = F.WorldState := rfl
example {D : TemporalOrder} (F : FrameOver D) : (F.toTF).TaskRel = F.TaskRel := rfl
example {D : TemporalOrder} (F : FrameOver D) : (F.toTF).spherical = F.spherical := rfl

/-! ## (d) The flat accessors preserve the landed surface -/

section Accessors
variable (F : TF)

-- `F.WorldState` and `F.TaskRel w d u` with `(d : F.Duration)` via `CoeSort` in binder position.
example (w u : F.WorldState) (d : F.Duration) : Prop := F.TaskRel w d u
example (w : F.WorldState) : Prop := F.TaskRel w 0 w
example : Nonempty F.WorldState := inferInstance
example (x y : F.Duration) : x + y = y + x := add_comm x y
example (x y : F.Duration) : x ≤ y ∨ y ≤ x := le_total x y
example : ∃ x y : F.Duration, x ≠ y := exists_pair_ne _

-- The axiom fields, consumed DEFINITIONALLY (this is the Step Lemma's requirement).
example : ParamTaskFrame.Spherical F.TaskRel := F.spherical
example : ParamTaskFrame.Serial F.TaskRel := F.serial
example : ParamTaskFrame.Compositional F.TaskRel := F.comp
end Accessors

-- `PartialHistory`'s shape, taken verbatim from `Semantics/PartialHistory.lean:91`.
structure PartialHistory' (F : TF) where
  domain : F.Duration → Prop
  nonempty_domain : ∃ t, domain t
  states : (t : F.Duration) → domain t → F.WorldState
  respects_task : ∀ (s t : F.Duration) (hs : domain s) (ht : domain t),
    F.TaskRel (states s hs) (t - s) (states t ht)

-- `WorldHistory`'s shape (`Semantics/WorldHistory.lean:100`), including `extends`.
structure WorldHistory' (F : TF) extends PartialHistory' F where
  convex : ∀ (x z : F.Duration), domain x → domain z → ∀ (y : F.Duration), x ≤ y → y ≤ z → domain y

-- The derived-API shape (`TaskFrame.forward_comp`), proved over the accessors.
theorem TF.forward_comp (F : TF) (w u v : F.WorldState) (x y : F.Duration)
    (hx : 0 ≤ x) (hy : 0 ≤ y) (h1 : F.TaskRel w x u) (h2 : F.TaskRel u y v) :
    F.TaskRel w (x + y) v :=
  ParamTaskFrame.forward_of_comp F.comp w u v x y hx hy h1 h2

-- Generalized field notation on the derived member.
example (F : TF) (w u v : F.WorldState) (x y : F.Duration)
    (hx : 0 ≤ x) (hy : 0 ≤ y) (h1 : F.TaskRel w x u) (h2 : F.TaskRel u y v) :
    F.TaskRel w (x + y) v := F.forward_comp w u v x y hx hy h1 h2

-- A `stateAt`-shaped def over a history (`WorldHistory.lean:234`).
def stateAt' {F : TF} (τ : WorldHistory' F) (t : F.Duration) (h : τ.domain t) : F.WorldState :=
  τ.states t h

/-! ## (b) `omega` and `Int` arithmetic at `FrameOver intOrder` — STOP GATE -/

section IntFibre
open ParamTaskFrame

-- The exact site the v01 blocker reproduced.
def step (F : FrameOver intOrder) : F.WorldState → F.WorldState → Prop :=
  fun w u => F.TaskRel w 1 u

theorem step_def (F : FrameOver intOrder) (w u : F.WorldState) :
    step F w u ↔ F.TaskRel w 1 u := Iff.rfl

def iter {W : Type} (R : W → W → Prop) : ℕ → W → W → Prop
  | 0 => Eq
  | n + 1 => fun w u => ∃ v, iter R n w v ∧ R v u

@[simp]
theorem iter_zero {W : Type} (R : W → W → Prop) (w u : W) : iter R 0 w u ↔ w = u := Iff.rfl

@[simp]
theorem iter_succ {W : Type} (R : W → W → Prop) (n : ℕ) (w u : W) :
    iter R (n + 1) w u ↔ ∃ v, iter R n w v ∧ R v u := Iff.rfl

-- `(n : ℤ)` fed straight into `F.TaskRel`, whose duration argument is `↑intOrder`.
theorem taskRel_natCast_iff_iter (F : FrameOver intOrder) (n : ℕ) (w u : F.WorldState) :
    F.TaskRel w (n : ℤ) u ↔ iter (step F) n w u := by
  induction n generalizing u with
  | zero => simpa using F.nullity_identity w u
  | succ n ih =>
    have hcast : ((n + 1 : ℕ) : ℤ) = (n : ℤ) + 1 := by push_cast; rfl
    rw [hcast, iter_succ]
    have hcomp := F.comp w u (n : ℤ) 1 (Int.natCast_nonneg n) zero_le_one
    rw [hcomp]
    exact ⟨fun ⟨v, h1, h2⟩ => ⟨v, (ih v).mp h1, h2⟩,
           fun ⟨v, h1, h2⟩ => ⟨v, (ih v).mpr h1, h2⟩⟩

-- The full two-sided characterization, with `omega` discharging the sign arithmetic.
theorem taskRel_eq_iter (F : FrameOver intOrder) (w u : F.WorldState) (d : ℤ) :
    F.TaskRel w d u ↔
      (0 ≤ d → iter (step F) d.natAbs w u) ∧ (d ≤ 0 → iter (step F) d.natAbs u w) := by
  constructor
  · intro h
    refine ⟨fun hd => ?_, fun hd => ?_⟩
    · have : ((d.natAbs : ℤ)) = d := Int.natAbs_of_nonneg hd
      exact (taskRel_natCast_iff_iter F d.natAbs w u).mp (by rwa [this])
    · have hconv : F.TaskRel u (-d) w := (F.converse w d u).mp h
      have hnat : (((-d).natAbs : ℤ)) = -d := Int.natAbs_of_nonneg (by omega)
      have := (taskRel_natCast_iff_iter F (-d).natAbs u w).mp (by rwa [hnat])
      rwa [Int.natAbs_neg] at this
  · rintro ⟨hpos, hneg⟩
    rcases le_or_gt 0 d with hd | hd
    · have hnat : ((d.natAbs : ℤ)) = d := Int.natAbs_of_nonneg hd
      exact hnat ▸ (taskRel_natCast_iff_iter F d.natAbs w u).mpr (hpos hd)
    · have hd' : d ≤ 0 := le_of_lt hd
      have hnat : (((-d).natAbs : ℤ)) = -d := Int.natAbs_of_nonneg (by omega)
      have hiter : iter (step F) (-d).natAbs u w := by
        rw [Int.natAbs_neg]; exact hneg hd'
      have : F.TaskRel u (-d) w :=
        hnat ▸ (taskRel_natCast_iff_iter F (-d).natAbs u w).mpr hiter
      exact (F.converse w d u).mpr this

-- (b)(i): does `omega` close a goal whose hypotheses are `↑intOrder`-typed?
-- FAIL, recorded verbatim:
--   example (x y : ↑intOrder) (h : x < y) : x + 1 ≤ y := by omega
--   error: omega could not prove the goal: No usable constraints found. You may need to unfold
--   definitions so `omega` can see linear arithmetic facts about `Nat` and `Int` [...]
-- Recovery attempt 1: re-ascribe with `show` on the goal and a `have` on the hypothesis.
-- FAIL, recorded verbatim — the ascription is a no-op (v01 finding 3), so `omega` still sees
-- no `Int`-typed hypothesis:
--   example (x y : ↑intOrder) (h : x < y) : x + 1 ≤ y := by
--     show (x : ℤ) + 1 ≤ (y : ℤ)
--     have h' : (x : ℤ) < (y : ℤ) := h
--     omega
--   error: omega could not prove the goal: No usable constraints found. [...]

-- Recovery attempt 2: `change` the HYPOTHESIS's type (not an ascription), then `omega`. PASS.
example (x : ↑intOrder) (h : 0 < x) : 1 ≤ x := by
  change (0 : ℤ) < x at h
  change (1 : ℤ) ≤ x
  omega

-- Recovery attempt 3: state the binders at `ℤ` in the first place — the working form.
example (x y : ℤ) (h : x < y) : x + 1 ≤ y := by omega

-- Order relations written plainly at the fibre, with a `ℤ`-typed duration binder.
example (F : FrameOver intOrder) (w u : F.WorldState) (d : ℤ) (_h : 0 < d) : Prop :=
  F.TaskRel w (d - 1) u

-- and with an `↑intOrder`-typed one
example (F : FrameOver intOrder) (w u : F.WorldState) (d : ↑intOrder) (_h : 0 < d) : Prop :=
  F.TaskRel w (d - 1) u

-- A step-path shape, with `omega` on the ℤ arithmetic (`IntNormalForm.lean:280`).
def IsStepPath (F : FrameOver intOrder) (f : ℤ → F.WorldState) : Prop :=
  ∀ n : ℤ, step F (f n) (f (n + 1))

theorem iter_of_isStepPath {F : FrameOver intOrder} {f : ℤ → F.WorldState}
    (h : IsStepPath F f) (n : ℕ) (s : ℤ) : iter (step F) n (f s) (f (s + n)) := by
  induction n with
  | zero => simp [iter]
  | succ n ih =>
    refine ⟨f (s + n), ih, ?_⟩
    have hs : s + ((n : ℤ) + 1) = (s + n) + 1 := by omega
    have := h (s + n)
    rwa [show ((n + 1 : ℕ) : ℤ) = (n : ℤ) + 1 by push_cast; rfl, hs]

theorem respects_of_isStepPath {F : FrameOver intOrder} {f : ℤ → F.WorldState}
    (h : IsStepPath F f) (s t : ℤ) : F.TaskRel (f s) (t - s) (f t) := by
  refine (taskRel_eq_iter F (f s) (f t) (t - s)).mpr ⟨fun hd => ?_, fun hd => ?_⟩
  · have hst : t = s + ((t - s).natAbs : ℤ) := by omega
    have hgo := iter_of_isStepPath h (t - s).natAbs s
    rwa [← hst] at hgo
  · have hst : s = t + ((t - s).natAbs : ℤ) := by omega
    have hgo := iter_of_isStepPath h (t - s).natAbs t
    rwa [← hst] at hgo

end IntFibre

/-! ## (f) The transitional alias holds unmigrated code green -/

section Alias
@[reducible] def PTF (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    [Nontrivial D] : Type 1 := FrameOver (TemporalOrder.of D)

variable {D : Type} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]

-- Generalized field notation through the reducible alias.
example (F : PTF D) : Type := F.WorldState
example (F : PTF D) (w u : F.WorldState) (d : D) : Prop := F.TaskRel w d u
example (F : PTF D) : ParamTaskFrame.Spherical F.TaskRel := F.spherical
example (F : PTF D) : ParamTaskFrame.Compositional F.TaskRel := F.comp
example (F : PTF D) : ParamTaskFrame.Serial F.TaskRel := F.serial
example (F : PTF D) : Nonempty F.WorldState := inferInstance

-- A structure parameterized by the alias.
structure Bar {D : Type} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]
    (F : PTF D) where
  w : F.WorldState
  d : D
  rel : F.TaskRel w d w

-- A `PTF ℤ` value is a `FrameOver intOrder` value, definitionally.
example : PTF ℤ = FrameOver intOrder := rfl
example (F : PTF ℤ) (w u : F.WorldState) : Prop := F.TaskRel w 1 u
example (F : FrameOver intOrder) : PTF ℤ := F

-- And the alias's frames include into the total space by the constructor.
example (F : PTF D) : TF := F.toTF
end Alias

end FibreProbe
