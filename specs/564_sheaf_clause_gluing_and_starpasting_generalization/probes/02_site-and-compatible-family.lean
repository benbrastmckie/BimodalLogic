/-
Research probe: the cut-form Sheaf clause lifts to the interval SITE for free, and the
coverage's compatible-family condition is exactly the raw seam-agreement hypothesis.

(1) `restrictTr (coverLeft …)` and `restrictTr (coverRight …)` are DEFINITIONALLY the raw-data
    restrictions the clause is stated with (`rfl`), so no transport is needed.
(2) `restrictTr (rres …) τ₁ = restrictTr (lres …) τ₂` in `Beh F 0` -- the compatible-family
    condition over the germ that `cover_germ_composites` identifies -- is equivalent to
    `τ₁.states p = τ₂.states 0`.
-/
import FormalSystem.Semantics.Presheaf.Behavior
open FormalSystem.Semantics
open FormalSystem.Semantics.Presheaf
namespace Probe564Site
variable {F : TaskFrame}

/-- The site-indexed left restriction along `coverLeft` IS the raw-data restriction at offset 0. -/
example (l : Obj F.Duration) (p : ↑F.Duration) (hp : 0 ≤ p) (hpl : p ≤ l.val)
    (υ : Beh F l.val) :
    Beh.restrictTr (coverLeft l p hp hpl) υ
      = Beh.restrict 0 p le_rfl hp (by rw [zero_add]; exact hpl) υ := rfl

/-- The site-indexed right restriction along `coverRight` IS the raw-data restriction at offset
`p` onto length `l - p`. -/
example (l : Obj F.Duration) (p : ↑F.Duration) (hp : 0 ≤ p) (hpl : p ≤ l.val)
    (υ : Beh F l.val) :
    Beh.restrictTr (coverRight l p hp hpl) υ
      = Beh.restrict p (l.val - p) hp (sub_nonneg.mpr hpl) (by rw [add_sub_cancel]) υ := rfl


theorem states_eq_of_eq {l : F.Duration} {σ τ : Beh F l} (h : σ = τ) (r : F.Duration)
    (hσ : σ.val.domain r) (hτ : τ.val.domain r) : σ.val.states r hσ = τ.val.states r hτ := by
  subst h; rfl

/-- The coverage's compatible-family condition, as an equality of germ sections, IS the raw
seam-agreement hypothesis. -/
theorem compat_iff_match (l p : F.Duration) (hp : 0 ≤ p) (hpl : p ≤ l)
    (τ₁ : Beh F p) (τ₂ : Beh F (l - p)) :
    Beh.restrictTr (l' := (⟨0, le_refl 0⟩ : Obj F.Duration)) (l := ⟨p, hp⟩) (rres hp) τ₁
        = Beh.restrictTr (l' := (⟨0, le_refl 0⟩ : Obj F.Duration)) (l := ⟨l - p, sub_nonneg.mpr hpl⟩)
            (lres (sub_nonneg.mpr hpl)) τ₂
      ↔ τ₁.val.states p (Beh.mem_dom τ₁ hp le_rfl)
          = τ₂.val.states 0 (Beh.mem_dom τ₂ le_rfl (sub_nonneg.mpr hpl)) := by
  constructor
  · intro h
    have h0 := states_eq_of_eq h 0 (by exact ⟨le_rfl, le_rfl⟩) (by exact ⟨le_rfl, le_rfl⟩)
    simp only [Beh.restrictTr, rres, lres] at h0
    rw [Beh.restrict_states (p - 0) 0 _ _ _ τ₁ 0 _ (Beh.mem_dom τ₁ (by simpa using hp) (by simp)),
        Beh.restrict_states 0 0 _ _ _ τ₂ 0 _ (Beh.mem_dom τ₂ (by simp) (by simpa using sub_nonneg.mpr hpl))] at h0
    rw [PartialHistory.states_eq_of_time_eq τ₁.val (p - 0 + 0) p (by simp) _
          (Beh.mem_dom τ₁ hp le_rfl),
        PartialHistory.states_eq_of_time_eq τ₂.val (0 + 0) 0 (by simp) _
          (Beh.mem_dom τ₂ le_rfl (sub_nonneg.mpr hpl))] at h0
    exact h0
  · intro h
    refine Beh.ext (partialHistory_ext rfl ?_)

    intro r hr hr'
    have hr0 : r = 0 := le_antisymm hr.2 hr.1
    subst hr0
    simp only [Beh.restrictTr, rres, lres] at hr hr' ⊢
    rw [Beh.restrict_states (p - 0) 0 _ _ _ τ₁ 0 hr (Beh.mem_dom τ₁ (by simpa using hp) (by simp)),
        Beh.restrict_states 0 0 _ _ _ τ₂ 0 hr' (Beh.mem_dom τ₂ (by simp) (by simpa using sub_nonneg.mpr hpl))]
    rw [PartialHistory.states_eq_of_time_eq τ₁.val (p - 0 + 0) p (by simp) _
          (Beh.mem_dom τ₁ hp le_rfl),
        PartialHistory.states_eq_of_time_eq τ₂.val (0 + 0) 0 (by simp) _
          (Beh.mem_dom τ₂ le_rfl (sub_nonneg.mpr hpl))]
    exact h
end Probe564Site
