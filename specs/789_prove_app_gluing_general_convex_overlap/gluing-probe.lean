/-
Probe for the general gluing lemma (paper anchor `app:gluing`).
Research artifact; not part of the library build.
-/
import FormalSystem.Semantics.PartialHistory
import FormalSystem.Semantics.Presheaf.Behavior

namespace FormalSystem.Semantics.GluingProbe

open FormalSystem.Semantics
open FormalSystem.Semantics.Presheaf (partialHistory_ext)

variable {F : TaskFrame}

/-! ### Step 1: convexity of the union domain (no decidability, no frame constraint) -/

theorem isConvex_union {τ₁ τ₂ : PartialHistory F} (h₁ : τ₁.IsConvex) (h₂ : τ₂.IsConvex)
    {z : F.Duration} (hz₁ : τ₁.domain z) (hz₂ : τ₂.domain z) :
    ∀ a c : F.Duration, (τ₁.domain a ∨ τ₂.domain a) → (τ₁.domain c ∨ τ₂.domain c) →
      ∀ b : F.Duration, a ≤ b → b ≤ c → (τ₁.domain b ∨ τ₂.domain b) := by
  intro a c ha hc b hab hbc
  rcases ha with ha | ha <;> rcases hc with hc | hc
  · exact Or.inl (h₁ a c ha hc b hab hbc)
  · rcases le_total b z with hbz | hzb
    · exact Or.inl (h₁ a z ha hz₁ b hab hbz)
    · exact Or.inr (h₂ z c hz₂ hc b hzb hbc)
  · rcases le_total b z with hbz | hzb
    · exact Or.inr (h₂ a z ha hz₂ b hab hbz)
    · exact Or.inl (h₁ z c hz₁ hc b hzb hbc)
  · exact Or.inr (h₂ a c ha hc b hab hbc)

/-! ### Step 2: the two mixed-pair seam steps -/

theorem rel_mixed_left {τ₁ τ₂ : PartialHistory F} (hcomp : TaskFrame.Compositional F.TaskRel)
    (h₁ : τ₁.IsConvex) (h₂ : τ₂.IsConvex)
    {z : F.Duration} (hz₁ : τ₁.domain z) (hz₂ : τ₂.domain z)
    (hagree : ∀ (t : F.Duration) (p : τ₁.domain t) (q : τ₂.domain t),
      τ₁.states t p = τ₂.states t q)
    {x y : F.Duration} (hx₁ : τ₁.domain x) (hy₂ : τ₂.domain y) (hy₁ : ¬ τ₁.domain y)
    (hxy : x ≤ y) :
    F.TaskRel (τ₁.states x hx₁) (y - x) (τ₂.states y hy₂) := by
  have hzy : z ≤ y := by
    by_contra hc
    exact hy₁ (h₁ x z hx₁ hz₁ y hxy (le_of_lt (not_le.mp hc)))
  rcases le_total x z with hxz | hzx
  · exact PartialHistory.rel_across_seam hcomp hz₁ hz₂ (hagree z hz₁ hz₂) hx₁ hy₂ hxz hzy
      (by rw [add_comm]; exact (sub_add_sub_cancel y z x).symm)
  · have hx₂ : τ₂.domain x := h₂ z y hz₂ hy₂ x hzx hxy
    rw [hagree x hx₁ hx₂]
    exact τ₂.respects_task x y hx₂ hy₂

theorem rel_mixed_right {τ₁ τ₂ : PartialHistory F} (hcomp : TaskFrame.Compositional F.TaskRel)
    (h₁ : τ₁.IsConvex) (h₂ : τ₂.IsConvex)
    {z : F.Duration} (hz₁ : τ₁.domain z) (hz₂ : τ₂.domain z)
    (hagree : ∀ (t : F.Duration) (p : τ₁.domain t) (q : τ₂.domain t),
      τ₁.states t p = τ₂.states t q)
    {x y : F.Duration} (hx₂ : τ₂.domain x) (hy₁ : τ₁.domain y) (hx₁ : ¬ τ₁.domain x)
    (hxy : x ≤ y) :
    F.TaskRel (τ₂.states x hx₂) (y - x) (τ₁.states y hy₁) := by
  have hxz : x ≤ z := by
    by_contra hc
    exact hx₁ (h₁ z y hz₁ hy₁ x (le_of_lt (not_le.mp hc)) hxy)
  rcases le_total z y with hzy | hyz
  · exact PartialHistory.rel_across_seam hcomp hz₂ hz₁ (hagree z hz₁ hz₂).symm hx₂ hy₁ hxz hzy
      (by rw [add_comm]; exact (sub_add_sub_cancel y z x).symm)
  · have hy₂ : τ₂.domain y := h₂ x z hx₂ hz₂ y hxy hyz
    rw [hagree y hy₁ hy₂]
    exact τ₂.respects_task x y hx₂ hy₂

/-! ### Step 3: the glued convex history -/

def glue (hcomp : TaskFrame.Compositional F.TaskRel) (τ₁ τ₂ : PartialHistory F)
    [DecidablePred τ₁.domain] (h₁ : τ₁.IsConvex) (h₂ : τ₂.IsConvex)
    {z : F.Duration} (hz₁ : τ₁.domain z) (hz₂ : τ₂.domain z)
    (hagree : ∀ (t : F.Duration) (p : τ₁.domain t) (q : τ₂.domain t),
      τ₁.states t p = τ₂.states t q) :
    PartialHistory F where
  domain := fun t => τ₁.domain t ∨ τ₂.domain t
  nonempty_domain := ⟨z, Or.inl hz₁⟩
  states := fun t ht =>
    if h : τ₁.domain t then τ₁.states t h else τ₂.states t (ht.resolve_left h)
  respects_task := by
    intro s t hs ht
    by_cases hs₁ : τ₁.domain s <;> by_cases ht₁ : τ₁.domain t
    · rw [dif_pos hs₁, dif_pos ht₁]; exact τ₁.respects_task s t hs₁ ht₁
    · have ht₂ : τ₂.domain t := ht.resolve_left ht₁
      rw [dif_pos hs₁, dif_neg ht₁]
      rcases le_total s t with hst | hts
      · exact rel_mixed_left hcomp h₁ h₂ hz₁ hz₂ hagree hs₁ ht₂ ht₁ hst
      · have hne : t - s ≠ 0 := sub_ne_zero_of_ne (fun h : t = s => ht₁ (h.symm ▸ hs₁))
        rw [TaskFrame.reflection_of_ne F hne, neg_sub]
        exact rel_mixed_right hcomp h₁ h₂ hz₁ hz₂ hagree ht₂ hs₁ ht₁ hts
    · have hs₂ : τ₂.domain s := hs.resolve_left hs₁
      rw [dif_neg hs₁, dif_pos ht₁]
      rcases le_total s t with hst | hts
      · exact rel_mixed_right hcomp h₁ h₂ hz₁ hz₂ hagree hs₂ ht₁ hs₁ hst
      · have hne : t - s ≠ 0 := sub_ne_zero_of_ne (fun h : t = s => hs₁ (h ▸ ht₁))
        rw [TaskFrame.reflection_of_ne F hne, neg_sub]
        exact rel_mixed_left hcomp h₁ h₂ hz₁ hz₂ hagree ht₁ hs₂ hs₁ hts
    · rw [dif_neg hs₁, dif_neg ht₁]
      exact τ₂.respects_task s t (hs.resolve_left hs₁) (ht.resolve_left ht₁)

/-! ### Step 4: reading equations, convexity, restriction identities, uniqueness -/

section Readings

variable {τ₁ τ₂ : PartialHistory F} (hcomp : TaskFrame.Compositional F.TaskRel)
  [DecidablePred τ₁.domain] (h₁ : τ₁.IsConvex) (h₂ : τ₂.IsConvex) {z : F.Duration}
  (hz₁ : τ₁.domain z) (hz₂ : τ₂.domain z)
  (hagree : ∀ (t : F.Duration) (p : τ₁.domain t) (q : τ₂.domain t),
    τ₁.states t p = τ₂.states t q)

theorem glue_domain (t : F.Duration) :
    (glue hcomp τ₁ τ₂ h₁ h₂ hz₁ hz₂ hagree).domain t ↔ (τ₁.domain t ∨ τ₂.domain t) := Iff.rfl

theorem glue_mem_left {t : F.Duration} (h : τ₁.domain t) :
    (glue hcomp τ₁ τ₂ h₁ h₂ hz₁ hz₂ hagree).domain t := Or.inl h

theorem glue_mem_right {t : F.Duration} (h : τ₂.domain t) :
    (glue hcomp τ₁ τ₂ h₁ h₂ hz₁ hz₂ hagree).domain t := Or.inr h

theorem glue_states_left {t : F.Duration}
    {ht : (glue hcomp τ₁ τ₂ h₁ h₂ hz₁ hz₂ hagree).domain t} (h : τ₁.domain t) :
    (glue hcomp τ₁ τ₂ h₁ h₂ hz₁ hz₂ hagree).states t ht = τ₁.states t h := dif_pos h

theorem glue_states_not_left {t : F.Duration}
    {ht : (glue hcomp τ₁ τ₂ h₁ h₂ hz₁ hz₂ hagree).domain t} (h : ¬ τ₁.domain t)
    (h' : τ₂.domain t) :
    (glue hcomp τ₁ τ₂ h₁ h₂ hz₁ hz₂ hagree).states t ht = τ₂.states t h' := dif_neg h

/-- The right-hand reading **where the seam hypothesis is consumed**: on the overlap the `dite`
lands in the left branch, and only `hagree` closes the gap to `τ₂`. -/
theorem glue_states_right {t : F.Duration}
    (ht : (glue hcomp τ₁ τ₂ h₁ h₂ hz₁ hz₂ hagree).domain t) (h' : τ₂.domain t) :
    (glue hcomp τ₁ τ₂ h₁ h₂ hz₁ hz₂ hagree).states t ht = τ₂.states t h' := by
  by_cases h : τ₁.domain t
  · rw [glue_states_left hcomp h₁ h₂ hz₁ hz₂ hagree h]; exact hagree t h h'
  · exact glue_states_not_left hcomp h₁ h₂ hz₁ hz₂ hagree h h'

theorem glue_isConvex : (glue hcomp τ₁ τ₂ h₁ h₂ hz₁ hz₂ hagree).IsConvex :=
  isConvex_union h₁ h₂ hz₁ hz₂

theorem glue_extends_left : (glue hcomp τ₁ τ₂ h₁ h₂ hz₁ hz₂ hagree).Extends τ₁ :=
  ⟨fun _ ht => Or.inl ht, fun _ ht => dif_pos ht⟩

theorem glue_extends_right : (glue hcomp τ₁ τ₂ h₁ h₂ hz₁ hz₂ hagree).Extends τ₂ :=
  { subset := fun _ ht => glue_mem_right hcomp h₁ h₂ hz₁ hz₂ hagree ht
    agree := fun _t ht => glue_states_right hcomp h₁ h₂ hz₁ hz₂ hagree _ ht }

/-- Uniqueness: **no frame constraint, no convexity, no overlap**. -/
theorem glue_unique (υ : PartialHistory F)
    (hdom : ∀ t, υ.domain t ↔ (τ₁.domain t ∨ τ₂.domain t))
    (he₁ : υ.Extends τ₁) (he₂ : υ.Extends τ₂) :
    υ = glue hcomp τ₁ τ₂ h₁ h₂ hz₁ hz₂ hagree := by
  refine partialHistory_ext (funext fun t => propext (hdom t)) ?_
  intro r hr hr'
  by_cases h : τ₁.domain r
  · rw [glue_states_left hcomp h₁ h₂ hz₁ hz₂ hagree h]
    exact he₁.agree r h
  · rw [glue_states_not_left hcomp h₁ h₂ hz₁ hz₂ hagree h (hr'.resolve_left h)]
    exact he₂.agree r (hr'.resolve_left h)

include hcomp h₁ h₂ hz₁ hz₂ hagree in
/-- `app:gluing` itself. -/
theorem gluing_clause :
    ∃! υ : PartialHistory F,
      (∀ t, υ.domain t ↔ (τ₁.domain t ∨ τ₂.domain t)) ∧ υ.IsConvex ∧
        υ.Extends τ₁ ∧ υ.Extends τ₂ :=
  ⟨glue hcomp τ₁ τ₂ h₁ h₂ hz₁ hz₂ hagree,
   ⟨glue_domain hcomp h₁ h₂ hz₁ hz₂ hagree,
    glue_isConvex hcomp h₁ h₂ hz₁ hz₂ hagree,
    glue_extends_left hcomp h₁ h₂ hz₁ hz₂ hagree,
    glue_extends_right hcomp h₁ h₂ hz₁ hz₂ hagree⟩,
   fun _ h => glue_unique hcomp h₁ h₂ hz₁ hz₂ hagree _ h.1 h.2.2.1 h.2.2.2⟩

end Readings

/-! ### Step 5b: the clause under the paper's own hypothesis `X₁ ∩ X₂ ≠ ∅`

The overlap witness must be an explicit parameter of the *construction* `glue` (extracting it
from an existential would need `Classical.choose`), but the **clause** is a `Prop`, so the
existential form is available choice-free by ordinary `Exists.elim`.
-/

theorem gluing_clause_of_overlap {τ₁ τ₂ : PartialHistory F}
    (hcomp : TaskFrame.Compositional F.TaskRel) [DecidablePred τ₁.domain]
    (h₁ : τ₁.IsConvex) (h₂ : τ₂.IsConvex)
    (hov : ∃ z : F.Duration, τ₁.domain z ∧ τ₂.domain z)
    (hagree : ∀ (t : F.Duration) (p : τ₁.domain t) (q : τ₂.domain t),
      τ₁.states t p = τ₂.states t q) :
    ∃! υ : PartialHistory F,
      (∀ t, υ.domain t ↔ (τ₁.domain t ∨ τ₂.domain t)) ∧ υ.IsConvex ∧
        υ.Extends τ₁ ∧ υ.Extends τ₂ := by
  obtain ⟨z, hz₁, hz₂⟩ := hov
  exact gluing_clause hcomp h₁ h₂ hz₁ hz₂ hagree

/-! ### Step 6: the paper's `rho ^ z sigma` as an instance (ray domains) -/

section RayInstance

variable (ρ σ : WorldHistory F) (z : F.Duration)

theorem pastRay_isConvex : (PartialHistory.restrict ρ (fun t => t ≤ z) ⟨z, le_rfl⟩).IsConvex :=
  fun _ _ _ hc _ _ hyc => le_trans hyc hc

theorem futRay_isConvex : (PartialHistory.restrict σ (fun t => z ≤ t) ⟨z, le_rfl⟩).IsConvex :=
  fun _ _ ha _ _ hay _ => le_trans ha hay

instance decPastRay : DecidablePred (PartialHistory.restrict ρ (fun t => t ≤ z) ⟨z, le_rfl⟩).domain :=
  fun t => inferInstanceAs (Decidable (t ≤ z))

/-- The seam gluing of the past ray of `ρ` and the future ray of `σ` is **total**: the paper's
`ρ ⌢_z σ` is the general gluing at two ray domains. -/
theorem seamGlue_isTotal (hcomp : TaskFrame.Compositional F.TaskRel)
    (hsame : ρ.state z = σ.state z) :
    (glue hcomp (PartialHistory.restrict ρ (fun t => t ≤ z) ⟨z, le_rfl⟩)
        (PartialHistory.restrict σ (fun t => z ≤ t) ⟨z, le_rfl⟩)
        (pastRay_isConvex ρ z) (futRay_isConvex σ z) le_rfl le_rfl
        (fun t p q => by obtain rfl := le_antisymm p q; exact hsame)).IsTotal :=
  fun t => le_total t z

theorem seamGlue_states_past (hcomp : TaskFrame.Compositional F.TaskRel)
    (hsame : ρ.state z = σ.state z) (t : F.Duration) (ht : t ≤ z)
    (hmem : (glue hcomp (PartialHistory.restrict ρ (fun t => t ≤ z) ⟨z, le_rfl⟩)
        (PartialHistory.restrict σ (fun t => z ≤ t) ⟨z, le_rfl⟩)
        (pastRay_isConvex ρ z) (futRay_isConvex σ z) le_rfl le_rfl
        (fun t p q => by obtain rfl := le_antisymm p q; exact hsame)).domain t) :
    (glue hcomp (PartialHistory.restrict ρ (fun t => t ≤ z) ⟨z, le_rfl⟩)
        (PartialHistory.restrict σ (fun t => z ≤ t) ⟨z, le_rfl⟩)
        (pastRay_isConvex ρ z) (futRay_isConvex σ z) le_rfl le_rfl
        (fun t p q => by obtain rfl := le_antisymm p q; exact hsame)).states t hmem
      = ρ.state t :=
  glue_states_left _ _ _ _ _ _ ht

end RayInstance

#print axioms isConvex_union
#print axioms rel_mixed_left
#print axioms rel_mixed_right
#print axioms glue
#print axioms glue_states_right
#print axioms glue_isConvex
#print axioms glue_extends_right
#print axioms glue_unique
#print axioms gluing_clause
#print axioms gluing_clause_of_overlap
#print axioms seamGlue_isTotal
#print axioms seamGlue_states_past

end FormalSystem.Semantics.GluingProbe
