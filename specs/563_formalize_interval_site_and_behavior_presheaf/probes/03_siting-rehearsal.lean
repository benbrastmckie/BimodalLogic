/-
Siting rehearsal: both intended modules in their real namespaces, with the layering guard, in
one file (a probe cannot be imported, so the two-module split is rehearsed here as two
namespace blocks).
-/
import FormalSystem.Init
import FormalSystem.Semantics.PartialHistory

namespace FormalSystem.Semantics.Presheaf

/-! ### Site.lean rehearsal -/

variable {D : TemporalOrder}

/-- `def:interval-site`, *Interval*. -/
def Interval (p q : ↑D) : ↑D → Prop := fun z => p ≤ z ∧ z ≤ q

/-- Objects of `Int(D)`. -/
abbrev Obj (D : TemporalOrder) : Type := TemporalOrder.PositiveCone D

/-- `def:interval-site`, *Interval Category*: `Tr p : l' → l`. -/
structure Tr (l' l : Obj D) where
  shift : ↑D
  shift_nonneg : 0 ≤ shift
  shift_add_le : shift + l'.val ≤ l.val

namespace Tr

@[ext] theorem ext {l' l : Obj D} {f g : Tr l' l} (h : f.shift = g.shift) : f = g := by
  cases f; cases g; simp_all

/-- `Tr 0`, the identity. -/
def id (l : Obj D) : Tr l l := ⟨0, le_refl 0, by rw [zero_add]⟩

/-- `Tr p ∘ Tr p' = Tr (p + p')`. -/
def comp {l'' l' l : Obj D} (f : Tr l' l) (g : Tr l'' l') : Tr l'' l :=
  ⟨f.shift + g.shift, add_nonneg f.shift_nonneg g.shift_nonneg, by
    calc f.shift + g.shift + l''.val = f.shift + (g.shift + l''.val) := by rw [add_assoc]
      _ ≤ f.shift + l'.val := add_le_add (le_refl _) g.shift_add_le
      _ ≤ l.val := f.shift_add_le⟩

@[simp] theorem comp_shift {l'' l' l : Obj D} (f : Tr l' l) (g : Tr l'' l') :
    (comp f g).shift = f.shift + g.shift := rfl

@[simp] theorem id_shift (l : Obj D) : (id l).shift = 0 := rfl

theorem id_comp {l' l : Obj D} (f : Tr l' l) : comp (id l) f = f := by ext; simp

theorem comp_id {l' l : Obj D} (f : Tr l' l) : comp f (id l') = f := by ext; simp

theorem comp_assoc {l₃ l₂ l₁ l : Obj D} (f : Tr l₁ l) (g : Tr l₂ l₁) (h : Tr l₃ l₂) :
    comp (comp f g) h = comp f (comp g h) := by ext; simp [add_assoc]

theorem le_of_hom {l' l : Obj D} (f : Tr l' l) : l'.val ≤ l.val :=
  le_trans (le_add_of_nonneg_left f.shift_nonneg) f.shift_add_le

end Tr

/-- Left restriction, along `Tr 0 : l' → l`. -/
def lres {l l' : Obj D} (h : l'.val ≤ l.val) : Tr l' l :=
  ⟨0, le_refl 0, by rw [zero_add]; exact h⟩

/-- Right restriction, along `Tr (l - l') : l' → l`. -/
def rres {l l' : Obj D} (h : l'.val ≤ l.val) : Tr l' l :=
  ⟨l.val - l'.val, sub_nonneg.mpr h, by rw [sub_add_cancel]⟩

/-! ### Behavior.lean rehearsal -/

variable {F : TaskFrame}

/-- Extensionality for partial histories, replacing the deleted `ShiftSet.wh_ext`. -/
theorem partialHistory_ext {σ τ : PartialHistory F} (hd : σ.domain = τ.domain)
    (hs : ∀ (r : F.Duration) (h : σ.domain r) (h' : τ.domain r), σ.states r h = τ.states r h') :
    σ = τ := by
  obtain ⟨d₁, n₁, s₁, t₁⟩ := σ
  obtain ⟨d₂, n₂, s₂, t₂⟩ := τ
  simp only at hd hs
  subst hd
  have : s₁ = s₂ := by funext r h; exact hs r h h
  subst this
  rfl

/-- `def:behavior-presheaf`: `Beh(F)(l)`. -/
def Beh (F : TaskFrame) (l : F.Duration) : Type :=
  { τ : PartialHistory F // ∀ t, τ.domain t ↔ (0 ≤ t ∧ t ≤ l) }

namespace Beh

theorem mem_dom {l : F.Duration} (τ : Beh F l) {t : F.Duration} (h0 : 0 ≤ t) (hl : t ≤ l) :
    τ.val.domain t := (τ.property t).mpr ⟨h0, hl⟩

theorem isConvex {l : F.Duration} (τ : Beh F l) : τ.val.IsConvex := by
  intro x z hx hz y hxy hyz
  exact (τ.property y).mpr
    ⟨le_trans ((τ.property x).mp hx).1 hxy, le_trans hyz ((τ.property z).mp hz).2⟩

/-- The domain of a section is the interval `[0, l]` of `def:interval-site`. -/
theorem domain_eq_interval {l : F.Duration} (τ : Beh F l) : τ.val.domain = Interval 0 l := by
  funext t; exact propext (τ.property t)

/-- Restriction along `Tr p : l' → l`. -/
def restrict {l : F.Duration} (p l' : F.Duration) (hp : 0 ≤ p) (hl' : 0 ≤ l')
    (hple : p + l' ≤ l) (τ : Beh F l) : Beh F l' :=
  ⟨{ domain := fun z => 0 ≤ z ∧ z ≤ l'
     nonempty_domain := ⟨0, le_refl 0, hl'⟩
     states := fun z hz =>
       τ.val.states (p + z) (mem_dom τ (add_nonneg hp hz.1)
         (le_trans (add_le_add (le_refl p) hz.2) hple))
     respects_task := by
       intro s t hs ht
       have h := τ.val.respects_task (p + s) (p + t)
         (mem_dom τ (add_nonneg hp hs.1) (le_trans (add_le_add (le_refl p) hs.2) hple))
         (mem_dom τ (add_nonneg hp ht.1) (le_trans (add_le_add (le_refl p) ht.2) hple))
       rwa [add_sub_add_left_eq_sub] at h },
   fun _ => Iff.rfl⟩

theorem restrict_domain {l : F.Duration} (p l' : F.Duration) (hp : 0 ≤ p) (hl' : 0 ≤ l')
    (hple : p + l' ≤ l) (τ : Beh F l) (z : F.Duration) :
    (restrict p l' hp hl' hple τ).val.domain z = (0 ≤ z ∧ z ≤ l') := rfl

theorem restrict_states {l : F.Duration} (p l' : F.Duration) (hp : 0 ≤ p) (hl' : 0 ≤ l')
    (hple : p + l' ≤ l) (τ : Beh F l) (z : F.Duration)
    (hz : (restrict p l' hp hl' hple τ).val.domain z) (hpz : τ.val.domain (p + z)) :
    (restrict p l' hp hl' hple τ).val.states z hz = τ.val.states (p + z) hpz := rfl

theorem ext {l : F.Duration} {σ τ : Beh F l} (h : σ.val = τ.val) : σ = τ := Subtype.ext h

/-- Functoriality, identity half: `Tr 0` acts trivially. -/
theorem restrict_id {l : F.Duration} (hl : 0 ≤ l) (τ : Beh F l) :
    restrict 0 l (le_refl 0) hl (by rw [zero_add]) τ = τ := by
  refine ext (partialHistory_ext ?_ ?_)
  · funext z
    show (0 ≤ z ∧ z ≤ l) = τ.val.domain z
    exact propext ((τ.property z).symm)
  · intro r hr h'
    have h0r : τ.val.domain (0 + r) := by rw [zero_add]; exact h'
    rw [restrict_states 0 l (le_refl 0) hl (by rw [zero_add]) τ r hr h0r]
    exact PartialHistory.states_eq_of_time_eq τ.val (0 + r) r (zero_add r) h0r h'

/-- Functoriality, composition half. -/
theorem restrict_comp {l : F.Duration} (p l' p' l'' : F.Duration)
    (hp : 0 ≤ p) (hl' : 0 ≤ l') (hple : p + l' ≤ l)
    (hp' : 0 ≤ p') (hl'' : 0 ≤ l'') (hple' : p' + l'' ≤ l')
    (τ : Beh F l) :
    restrict p' l'' hp' hl'' hple' (restrict p l' hp hl' hple τ)
      = restrict (p + p') l'' (add_nonneg hp hp') hl''
          (by
            rw [add_assoc]
            exact le_trans (add_le_add (le_refl p) hple') hple) τ := by
  refine ext (partialHistory_ext rfl ?_)
  intro r hr hr'
  have hin : τ.val.domain (p + (p' + r)) :=
    mem_dom τ (add_nonneg hp (add_nonneg hp' hr.1))
      (le_trans (add_le_add (le_refl p) (le_trans (add_le_add (le_refl p') hr.2) hple')) hple)
  have hin' : τ.val.domain (p + p' + r) := by rw [← add_assoc] at hin; exact hin
  rw [restrict_states p' l'' hp' hl'' hple' _ r hr (by
        rw [restrict_domain]
        exact ⟨add_nonneg hp' hr.1, le_trans (add_le_add (le_refl p') hr.2) hple'⟩),
      restrict_states p l' hp hl' hple τ (p' + r) _ hin,
      restrict_states (p + p') l'' (add_nonneg hp hp') hl'' _ τ r hr' hin']
  exact PartialHistory.states_eq_of_time_eq τ.val (p + (p' + r)) (p + p' + r)
    (add_assoc p p' r).symm hin hin'

/-! #### Restriction indexed by a site morphism: `Beh(F)` as a genuine presheaf -/

/-- Restriction along a morphism `f : Tr l' l` of `Int(D)`, rather than along raw data. This is
the presheaf action of `def:behavior-presheaf` indexed by `def:interval-site`'s morphisms. -/
def restrictTr {l' l : Obj F.Duration} (f : Tr l' l) (τ : Beh F l.val) : Beh F l'.val :=
  restrict f.shift l'.val f.shift_nonneg l'.property f.shift_add_le τ

/-- Functoriality at the identity, stated at the site. -/
theorem restrictTr_id {l : Obj F.Duration} (τ : Beh F l.val) :
    restrictTr (Tr.id l) τ = τ :=
  restrict_id l.property τ

/-- Functoriality at a composite, stated at the site: `Beh(F)` is CONTRAVARIANT. -/
theorem restrictTr_comp {l'' l' l : Obj F.Duration} (f : Tr l' l) (g : Tr l'' l')
    (τ : Beh F l.val) :
    restrictTr (Tr.comp f g) τ = restrictTr g (restrictTr f τ) :=
  (restrict_comp f.shift l'.val g.shift l''.val f.shift_nonneg l'.property f.shift_add_le
    g.shift_nonneg l''.property g.shift_add_le τ).symm

/-! #### Germs -/

/-- The germ of a section over `0`. -/
def germ (τ : Beh F 0) : F.WorldState :=
  τ.val.states 0 (mem_dom τ (le_refl 0) (le_refl 0))

/-- Every world state is a germ. -/
def ofGerm (F : TaskFrame) [F.IsRegular] (w : F.WorldState) : Beh F 0 :=
  ⟨{ domain := fun t => 0 ≤ t ∧ t ≤ 0
     nonempty_domain := ⟨0, le_refl 0, le_refl 0⟩
     states := fun _ _ => w
     respects_task := by
       intro s t hs ht
       have hs0 : s = 0 := le_antisymm hs.2 hs.1
       have ht0 : t = 0 := le_antisymm ht.2 ht.1
       subst hs0; subst ht0
       simpa [sub_self] using (F.nullity_identity w w).mpr rfl },
   fun _ => Iff.rfl⟩

theorem germ_ofGerm (F : TaskFrame) [F.IsRegular] (w : F.WorldState) :
    germ (ofGerm F w) = w := rfl

theorem ofGerm_germ [F.IsRegular] (τ : Beh F 0) : ofGerm F (germ τ) = τ := by
  refine ext (partialHistory_ext ?_ ?_)
  · funext z
    show (0 ≤ z ∧ z ≤ 0) = τ.val.domain z
    exact propext ((τ.property z).symm)
  · intro r _ h'
    have hr0 : r = 0 := le_antisymm ((τ.property r).mp h').2 ((τ.property r).mp h').1
    subst hr0
    rfl

/-- `Beh(F)(0) ≃ W`, the *Germs* clause, as an `Equiv`. -/
def germEquiv (F : TaskFrame) [F.IsRegular] : Beh F 0 ≃ F.WorldState where
  toFun := germ
  invFun := ofGerm F
  left_inv := ofGerm_germ
  right_inv := germ_ofGerm F

end Beh

end FormalSystem.Semantics.Presheaf

assert_not_exists FormalSystem.ProofSystem.Axiom FormalSystem.ProofSystem.DerivationTree
