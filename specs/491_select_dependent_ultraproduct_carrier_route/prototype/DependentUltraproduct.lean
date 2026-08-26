/-
Prototype: the DEPENDENT ultraproduct carrier, route (a).

Verifies that every instance binder `ShiftSet` / `SatisfiableBaseSet` demands
(`AddCommGroup`, `LinearOrder`, `IsOrderedAddMonoid`, `Nontrivial`), plus `DenselyOrdered`
for the Dense branch, can be supplied on the dependent ultraproduct
`(∀ i, D i) ⧸ evZero φ D`, with `AddCommGroup` obtained *for free* from `QuotientAddGroup`.

Also builds the dependent ultraproduct of the *carriers* `Ω i` and its shift action,
discharging `sh_zero` and `sh_add`.

Nothing here is the Łoś lemma.
-/
import FormalSystem.Semantics.ShiftSet
import Mathlib.Order.Filter.Ultrafilter.Basic

set_option linter.unusedSectionVars false

open Filter FormalSystem.Semantics FormalSystem.Syntax

namespace UProto

variable {I : Type} {φ : Ultrafilter I} {D : I → Type}
  [∀ i, AddCommGroup (D i)] [∀ i, LinearOrder (D i)] [∀ i, IsOrderedAddMonoid (D i)]

variable (φ D) in
/-- The eventually-zero subgroup of the Pi group. -/
def evZero : AddSubgroup (∀ i, D i) where
  carrier := {f | ∀ᶠ i in φ, f i = 0}
  zero_mem' := Eventually.of_forall fun _ => rfl
  add_mem' := by
    intro a b ha hb
    exact hb.mp (ha.mono (fun i hia hib => by simp [hia, hib]))
  neg_mem' := by
    intro a ha
    exact ha.mono (fun i hi => by simp [hi])

@[simp] theorem mem_evZero {f : ∀ i, D i} : f ∈ evZero φ D ↔ ∀ᶠ i in φ, f i = 0 := Iff.rfl

variable (φ D) in
/-- The dependent ultraproduct of the duration carriers. `AddCommGroup` is inherited. -/
abbrev UD := (∀ i, D i) ⧸ evZero φ D

/-- Coercion of a section to its class. -/
def mk (f : ∀ i, D i) : UD φ D := QuotientAddGroup.mk f

theorem mk_eq_mk {f g : ∀ i, D i} : mk (φ := φ) f = mk g ↔ ∀ᶠ i in φ, f i = g i := by
  rw [mk, mk, QuotientAddGroup.eq, mem_evZero]
  constructor
  · exact fun h => h.mono (fun i hi => by
      have : -f i + g i = 0 := hi
      exact neg_add_eq_zero.mp this)
  · exact fun h => h.mono (fun i hi => by simp [hi])

/-! ### The order — the only genuinely hand-supplied structure -/

instance : LE (UD φ D) :=
  ⟨fun a b => Quotient.liftOn₂' a b (fun f g => ∀ᶠ i in φ, f i ≤ g i) (by
    intro f g f' g' hf hg
    rw [QuotientAddGroup.leftRel_apply, mem_evZero] at hf hg
    have hf' : ∀ᶠ i in φ, f i = f' i := hf.mono (fun i hi => neg_add_eq_zero.mp hi)
    have hg' : ∀ᶠ i in φ, g i = g' i := hg.mono (fun i hi => neg_add_eq_zero.mp hi)
    exact propext ⟨fun h => (hf'.and hg').mp (h.mono (fun i h1 h2 => h2.1 ▸ h2.2 ▸ h1)),
      fun h => (hf'.and hg').mp (h.mono (fun i h1 h2 => h2.1 ▸ h2.2 ▸ h1))⟩)⟩

theorem mk_le_mk {f g : ∀ i, D i} : mk (φ := φ) f ≤ mk g ↔ ∀ᶠ i in φ, f i ≤ g i := Iff.rfl

open scoped Classical in
noncomputable instance : LinearOrder (UD φ D) where
  le_refl a := by
    induction a using QuotientAddGroup.induction_on with
    | H f => exact Eventually.of_forall fun _ => le_refl _
  le_trans a b c := by
    induction a using QuotientAddGroup.induction_on with
    | H f =>
      induction b using QuotientAddGroup.induction_on with
      | H g =>
        induction c using QuotientAddGroup.induction_on with
        | H h =>
          intro h1 h2
          exact (mk_le_mk.mpr ((mk_le_mk.mp h2).mp ((mk_le_mk.mp h1).mono
            (fun i hi hj => le_trans hi hj))) : _)
  le_antisymm a b := by
    induction a using QuotientAddGroup.induction_on with
    | H f =>
      induction b using QuotientAddGroup.induction_on with
      | H g =>
        intro h1 h2
        exact mk_eq_mk.mpr ((mk_le_mk.mp h2).mp ((mk_le_mk.mp h1).mono
          (fun i hi hj => le_antisymm hi hj)))
  le_total a b := by
    induction a using QuotientAddGroup.induction_on with
    | H f =>
      induction b using QuotientAddGroup.induction_on with
      | H g =>
        rcases φ.em (fun i => f i ≤ g i) with h | h
        · exact Or.inl h
        · exact Or.inr (h.mono (fun i hi => le_of_not_ge hi))
  toDecidableLE := Classical.decRel _

instance : IsOrderedAddMonoid (UD φ D) where
  add_le_add_left a b := by
    induction a using QuotientAddGroup.induction_on with
    | H f =>
      induction b using QuotientAddGroup.induction_on with
      | H g =>
        intro hab c
        induction c using QuotientAddGroup.induction_on with
        | H h => exact (mk_le_mk.mp hab).mono (fun i hi => by exact add_le_add_left hi _)

/-! ### Strict order, `Nontrivial`, and the Dense-branch binder -/

theorem not_eventually_false {p : I → Prop} (h : ∀ᶠ i in φ, p i) (h' : ∀ i, ¬ p i) : False := by
  obtain ⟨i, hi⟩ := h.exists
  exact h' i hi

theorem mk_lt_mk {f g : ∀ i, D i} : mk (φ := φ) f < mk g ↔ ∀ᶠ i in φ, f i < g i := by
  rw [lt_iff_le_not_ge]
  constructor
  · rintro ⟨_, h2⟩
    rcases φ.em (fun i => g i ≤ f i) with h | h
    · exact absurd (mk_le_mk.mpr h) h2
    · exact h.mono (fun i hi => lt_of_not_ge hi)
  · intro h
    refine ⟨mk_le_mk.mpr (h.mono (fun i hi => le_of_lt hi)), ?_⟩
    intro hle
    exact not_eventually_false (h.and (mk_le_mk.mp hle)) (fun i hi => absurd hi.1 (not_lt_of_ge hi.2))

instance [∀ i, Nontrivial (D i)] : Nontrivial (UD φ D) := by
  refine ⟨mk (fun i => (exists_ne (0 : D i)).choose), mk 0, ?_⟩
  intro h
  exact not_eventually_false (mk_eq_mk.mp h)
    (fun i => (exists_ne (0 : D i)).choose_spec)

open scoped Classical in
instance [∀ i, DenselyOrdered (D i)] : DenselyOrdered (UD φ D) := by
  constructor
  intro a b hab
  induction a using QuotientAddGroup.induction_on with
  | H f =>
    induction b using QuotientAddGroup.induction_on with
    | H g =>
      have h : ∀ᶠ i in φ, f i < g i := mk_lt_mk.mp hab
      refine ⟨mk (fun i => if hi : f i < g i then (exists_between hi).choose else f i), ?_, ?_⟩
      · exact mk_lt_mk.mpr (h.mono (fun i hi => by
          simp only [dif_pos hi]; exact (exists_between hi).choose_spec.1))
      · exact mk_lt_mk.mpr (h.mono (fun i hi => by
          simp only [dif_pos hi]; exact (exists_between hi).choose_spec.2))

/-! ### The carrier ultraproduct and its shift action -/

variable (φ) in
/-- Eventual-equality setoid on a dependent family of carriers. -/
def carrierSetoid (Ω : I → Type) : Setoid (∀ i, Ω i) where
  r f g := ∀ᶠ i in φ, f i = g i
  iseqv := ⟨fun _ => Eventually.of_forall fun _ => rfl, fun h => h.mono fun _ => Eq.symm,
    fun h1 h2 => h2.mp (h1.mono fun _ a b => a.trans b)⟩

variable (φ) in
/-- The dependent ultraproduct of the carriers. -/
def UOmega (Ω : I → Type) : Type := Quotient (carrierSetoid φ Ω)

variable {Ω : I → Type}

/-- Class of a section of the carrier family. -/
def omk (f : ∀ i, Ω i) : UOmega φ Ω := Quotient.mk (carrierSetoid φ Ω) f

theorem omk_eq_omk {f g : ∀ i, Ω i} : omk (φ := φ) f = omk g ↔ ∀ᶠ i in φ, f i = g i :=
  ⟨fun h => @Quotient.exact _ (carrierSetoid φ Ω) _ _ h,
   fun h => @Quotient.sound _ (carrierSetoid φ Ω) _ _ h⟩

theorem omk_surjective (w : UOmega φ Ω) : ∃ f, omk (φ := φ) f = w :=
  Quotient.exists_rep w

/-- The pointwise shift action, lifted to the two ultraproducts. -/
def shU (sh : ∀ i, Ω i → D i → Ω i) (w : UOmega φ Ω) (d : UD φ D) : UOmega φ Ω :=
  Quotient.liftOn₂' w d (fun f x => omk (φ := φ) (fun i => sh i (f i) (x i))) (by
    intro f x f' x' hf hx
    have hf' : ∀ᶠ i in φ, f i = f' i := hf
    rw [QuotientAddGroup.leftRel_apply, mem_evZero] at hx
    have hx' : ∀ᶠ i in φ, x i = x' i := hx.mono (fun i hi => neg_add_eq_zero.mp hi)
    exact omk_eq_omk.mpr ((hf'.and hx').mono (fun i hi => by rw [hi.1, hi.2])))

@[simp] theorem shU_mk (sh : ∀ i, Ω i → D i → Ω i) (f : ∀ i, Ω i) (x : ∀ i, D i) :
    shU (φ := φ) sh (omk f) (mk x) = omk (fun i => sh i (f i) (x i)) := rfl

theorem shU_zero (sh : ∀ i, Ω i → D i → Ω i) (hz : ∀ i w, sh i w 0 = w) (w : UOmega φ Ω) :
    shU (φ := φ) (D := D) sh w 0 = w := by
  obtain ⟨f, rfl⟩ := omk_surjective w
  show shU sh (omk f) (mk (0 : ∀ i, D i)) = omk f
  rw [shU_mk]
  exact omk_eq_omk.mpr (Eventually.of_forall fun i => hz i (f i))

theorem shU_add (sh : ∀ i, Ω i → D i → Ω i)
    (ha : ∀ i w a b, sh i (sh i w a) b = sh i w (a + b)) (w : UOmega φ Ω) (a b : UD φ D) :
    shU (φ := φ) sh (shU sh w a) b = shU sh w (a + b) := by
  obtain ⟨f, rfl⟩ := omk_surjective w
  induction a using QuotientAddGroup.induction_on with
  | H x =>
    induction b using QuotientAddGroup.induction_on with
    | H y =>
      show shU sh (shU sh (omk f) (mk x)) (mk y) = shU sh (omk f) (mk x + mk y)
      rw [shU_mk, shU_mk]
      exact omk_eq_omk.mpr (Eventually.of_forall fun i => ha i (f i) (x i) (y i))

/-! ### R3 and the binder-list check

`ShiftSet (UD φ D)` elaborates: every one of the four instance binders resolves, and the
quotient lands in `Type` (not `Type 1`), which is R3.
-/

/-- Packaging check: `ShiftSet` accepts `UD φ D` as its duration carrier. -/
def shiftSetOnUD [∀ i, Nontrivial (D i)] (Carrier : Type) (hne : Nonempty Carrier)
    (sh : Carrier → UD φ D → Carrier) (hz : ∀ w, sh w 0 = w)
    (hadd : ∀ w a b, sh (sh w a) b = sh w (a + b))
    (hsep : ∀ w u, (∀ x : UD φ D, 0 < x → ∃ y, |y| < x ∧ u = sh w y) → u = w)
    (A : Atom → Carrier → Prop) : ShiftSet (UD φ D) where
  Carrier := Carrier
  carrier_nonempty := hne
  sh := sh
  sh_zero := hz
  sh_add := hadd
  sep := hsep
  A := A

#print axioms shiftSetOnUD
#print axioms shU_add
#print axioms UProto.instDenselyOrderedUD

end UProto
