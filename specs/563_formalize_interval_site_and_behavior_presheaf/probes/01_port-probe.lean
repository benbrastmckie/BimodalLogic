/-
Port probe for the behavior presheaf: the task-553 probe `04_presheaf-skeleton.lean` re-expressed
against the CURRENT tree, in which `ConvexHistory` no longer exists.
-/
import FormalSystem.Init
import FormalSystem.Semantics.PartialHistory
import Mathlib.Algebra.Order.Group.Int

open FormalSystem.Semantics

namespace Probe563

variable {F : TaskFrame}

/-! ## Local extensionality for `PartialHistory` (replaces the deleted `ShiftSet.wh_ext`) -/

theorem ph_ext {σ τ : PartialHistory F} (hd : σ.domain = τ.domain)
    (hs : ∀ (r : F.Duration) (h : σ.domain r) (h' : τ.domain r), σ.states r h = τ.states r h') :
    σ = τ := by
  obtain ⟨d₁, n₁, s₁, t₁⟩ := σ
  obtain ⟨d₂, n₂, s₂, t₂⟩ := τ
  simp only at hd hs
  subst hd
  have : s₁ = s₂ := by funext r h; exact hs r h h
  subst this
  rfl

/-! ## Sections -/

def Beh (F : TaskFrame) (l : F.Duration) : Type :=
  { τ : PartialHistory F // ∀ t, τ.domain t ↔ (0 ≤ t ∧ t ≤ l) }

namespace Beh

theorem mem_dom {l : F.Duration} (τ : Beh F l) {t : F.Duration} (h0 : 0 ≤ t) (hl : t ≤ l) :
    τ.val.domain t := (τ.property t).mpr ⟨h0, hl⟩

/-- Convexity is DERIVABLE for a section: an interval domain is convex. -/
theorem isConvex {l : F.Duration} (τ : Beh F l) : τ.val.IsConvex := by
  intro x z hx hz y hxy hyz
  exact (τ.property y).mpr
    ⟨le_trans ((τ.property x).mp hx).1 hxy, le_trans hyz ((τ.property z).mp hz).2⟩

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

theorem restrict_id {l : F.Duration} (hl : 0 ≤ l) (τ : Beh F l) :
    restrict 0 l (le_refl 0) hl (by rw [zero_add]) τ = τ := by
  refine ext (ph_ext ?_ ?_)
  · funext z
    show (0 ≤ z ∧ z ≤ l) = τ.val.domain z
    exact propext ((τ.property z).symm)
  · intro r hr h'
    have h0r : τ.val.domain (0 + r) := by rw [zero_add]; exact h'
    rw [restrict_states 0 l (le_refl 0) hl (by rw [zero_add]) τ r hr h0r]
    exact PartialHistory.states_eq_of_time_eq τ.val (0 + r) r (zero_add r) h0r h'

theorem restrict_comp {l : F.Duration} (p l' p' l'' : F.Duration)
    (hp : 0 ≤ p) (hl' : 0 ≤ l') (hple : p + l' ≤ l)
    (hp' : 0 ≤ p') (hl'' : 0 ≤ l'') (hple' : p' + l'' ≤ l')
    (τ : Beh F l) :
    restrict p' l'' hp' hl'' hple' (restrict p l' hp hl' hple τ)
      = restrict (p + p') l'' (add_nonneg hp hp') hl''
          (by
            rw [add_assoc]
            exact le_trans (add_le_add (le_refl p) hple') hple) τ := by
  refine ext (ph_ext rfl ?_)
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

/-! ## Germs -/

def germ (τ : Beh F 0) : F.WorldState :=
  τ.val.states 0 (mem_dom τ (le_refl 0) (le_refl 0))

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
  refine ext (ph_ext ?_ ?_)
  · funext z
    show (0 ≤ z ∧ z ≤ 0) = τ.val.domain z
    exact propext ((τ.property z).symm)
  · intro r _ h'
    have hr0 : r = 0 := le_antisymm ((τ.property r).mp h').2 ((τ.property r).mp h').1
    subst hr0
    rfl

/-! ## The seam step -/

theorem glue_seam [F.IsRegular] {l₁ l₂ : F.Duration} (h₁ : 0 ≤ l₁) (h₂ : 0 ≤ l₂)
    (τ₁ : Beh F l₁) (τ₂ : Beh F l₂)
    (hmatch : τ₁.val.states l₁ (mem_dom τ₁ h₁ (le_refl l₁))
      = τ₂.val.states 0 (mem_dom τ₂ (le_refl 0) h₂))
    (s t : F.Duration) (hs : 0 ≤ s) (hsl : s ≤ l₁)
    (ht : 0 ≤ t - l₁) (htl : t - l₁ ≤ l₂) :
    F.TaskRel (τ₁.val.states s (mem_dom τ₁ hs hsl)) (t - s)
      (τ₂.val.states (t - l₁) (mem_dom τ₂ ht htl)) := by
  have hA : F.TaskRel (τ₁.val.states s (mem_dom τ₁ hs hsl)) (l₁ - s)
      (τ₁.val.states l₁ (mem_dom τ₁ h₁ (le_refl l₁))) :=
    τ₁.val.respects_task s l₁ _ _
  have hB : F.TaskRel (τ₂.val.states 0 (mem_dom τ₂ (le_refl 0) h₂)) ((t - l₁) - 0)
      (τ₂.val.states (t - l₁) (mem_dom τ₂ ht htl)) :=
    τ₂.val.respects_task 0 (t - l₁) _ _
  rw [hmatch] at hA
  rw [sub_zero] at hB
  have hsum : t - s = (l₁ - s) + (t - l₁) := by
    rw [add_comm]; exact (sub_add_sub_cancel t l₁ s).symm
  rw [hsum]
  exact (F.comp _ _ _ _ (sub_nonneg.mpr hsl) ht).mpr ⟨_, hA, hB⟩

end Beh

end Probe563
