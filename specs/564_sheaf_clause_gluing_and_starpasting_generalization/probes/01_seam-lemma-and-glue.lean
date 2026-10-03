/-
Research probe for the Sheaf clause: (A) the shared seam-composition lemma stated OFF totality,
(B) both call sites derived from it, (C) the glued section and the two restriction identities,
(D) uniqueness.
-/
import FormalSystem.Semantics.Presheaf.Behavior
import FormalSystem.PlusLanguage.PlusPasting

open FormalSystem.Semantics
open FormalSystem.Semantics.Presheaf

namespace Probe564

variable {F : TaskFrame}

/-! ## (A0) Choice-free reflection off zero, at `F.TaskRel`. -/

theorem taskRel_reflection_of_ne (F : TaskFrame) {w u : F.WorldState} {d : F.Duration}
    (hd : d ≠ 0) : F.TaskRel w d u ↔ F.TaskRel u (-d) w :=
  TaskFrame.reflect_reflection_of_ne hd

/-! ## (A) The shared argument, at `PartialHistory`, with two independent seam coordinates. -/

theorem rel_across_seam {F : TaskFrame} (hcomp : TaskFrame.Compositional F.TaskRel)
    {σ τ : PartialHistory F}
    {m m' : F.Duration} (hσm : σ.domain m) (hτm' : τ.domain m')
    (hmatch : σ.states m hσm = τ.states m' hτm')
    {s s' d : F.Duration} (hs : σ.domain s) (hs' : τ.domain s')
    (hsm : s ≤ m) (hm's' : m' ≤ s')
    (hd : d = (m - s) + (s' - m')) :
    F.TaskRel (σ.states s hs) d (τ.states s' hs') := by
  have h1 : F.TaskRel (σ.states s hs) (m - s) (σ.states m hσm) := σ.respects_task s m hs hσm
  have h2 : F.TaskRel (τ.states m' hτm') (s' - m') (τ.states s' hs') :=
    τ.respects_task m' s' hτm' hs'
  rw [hmatch] at h1
  rw [hd]
  exact TaskFrame.forward_of_comp hcomp _ _ _ _ _ (sub_nonneg.mpr hsm) (sub_nonneg.mpr hm's') h1 h2

/-! ## (B1) `paste_rel_le_lt` as a consumer: the total-history instance. -/

theorem paste_rel_le_lt' [F.IsRegular] (ρ σ : WorldHistory F) (t : F.Duration)
    (hsame : ρ.state t = σ.state t) {s s' : F.Duration} (hs : s ≤ t) (hs' : ¬ s' ≤ t) :
    F.TaskRel (ρ.state s) (s' - s) (σ.state s') :=
  rel_across_seam F.comp (σ := ρ.val) (τ := σ.val) (ρ.property t) (σ.property t) hsame
    (ρ.property s) (σ.property s') hs (le_of_lt (not_le.mp hs'))
    (by rw [add_comm]; exact (sub_add_sub_cancel s' t s).symm)

/-! ## (B2) `glue_seam` as a consumer: the interval-site instance. -/

theorem glue_seam' [F.IsRegular] {l₁ l₂ : F.Duration} (h₁ : 0 ≤ l₁) (h₂ : 0 ≤ l₂)
    (τ₁ : Beh F l₁) (τ₂ : Beh F l₂)
    (hmatch : τ₁.val.states l₁ (Beh.mem_dom τ₁ h₁ (le_refl l₁))
      = τ₂.val.states 0 (Beh.mem_dom τ₂ (le_refl 0) h₂))
    (s t : F.Duration) (hs : 0 ≤ s) (hsl : s ≤ l₁)
    (ht : 0 ≤ t - l₁) (htl : t - l₁ ≤ l₂) :
    F.TaskRel (τ₁.val.states s (Beh.mem_dom τ₁ hs hsl)) (t - s)
      (τ₂.val.states (t - l₁) (Beh.mem_dom τ₂ ht htl)) :=
  rel_across_seam F.comp (Beh.mem_dom τ₁ h₁ (le_refl l₁)) (Beh.mem_dom τ₂ (le_refl 0) h₂) hmatch
    (Beh.mem_dom τ₁ hs hsl) (Beh.mem_dom τ₂ ht htl) hsl ht
    (by rw [sub_zero, add_comm]; exact (sub_add_sub_cancel t l₁ s).symm)


/-! ## (C) The glued section, in CUT form: sections over `p` and `l - p` glue to one over `l`. -/

def glue (hcomp : TaskFrame.Compositional F.TaskRel) {l p : F.Duration} (hp : 0 ≤ p) (hpl : p ≤ l)
    (τ₁ : Beh F p) (τ₂ : Beh F (l - p))
    (hmatch : τ₁.val.states p (Beh.mem_dom τ₁ hp le_rfl)
      = τ₂.val.states 0 (Beh.mem_dom τ₂ le_rfl (sub_nonneg.mpr hpl))) : Beh F l :=
  ⟨{ domain := fun z => 0 ≤ z ∧ z ≤ l
     nonempty_domain := ⟨0, le_refl 0, le_trans hp hpl⟩
     states := fun z hz =>
       if hzp : z ≤ p then τ₁.val.states z (Beh.mem_dom τ₁ hz.1 hzp)
       else τ₂.val.states (z - p)
         (Beh.mem_dom τ₂ (sub_nonneg.mpr (le_of_lt (not_le.mp hzp))) (sub_le_sub_right hz.2 p))
     respects_task := by
       intro s t hs ht
       by_cases hsp : s ≤ p <;> by_cases htp : t ≤ p
       · rw [dif_pos hsp, dif_pos htp]
         exact τ₁.val.respects_task s t _ _
       · rw [dif_pos hsp, dif_neg htp]
         exact rel_across_seam hcomp (Beh.mem_dom τ₁ hp le_rfl)
           (Beh.mem_dom τ₂ le_rfl (sub_nonneg.mpr hpl)) hmatch _ _ hsp
           (sub_nonneg.mpr (le_of_lt (not_le.mp htp)))
           (by rw [sub_zero, add_comm]; exact (sub_add_sub_cancel t p s).symm)
       · have hts : t < s := lt_of_le_of_lt htp (not_le.mp hsp)
         rw [dif_neg hsp, dif_pos htp,
           taskRel_reflection_of_ne F (sub_ne_zero_of_ne (ne_of_lt hts)), neg_sub]
         exact rel_across_seam hcomp (Beh.mem_dom τ₁ hp le_rfl)
           (Beh.mem_dom τ₂ le_rfl (sub_nonneg.mpr hpl)) hmatch _ _ htp
           (sub_nonneg.mpr (le_of_lt (not_le.mp hsp)))
           (by rw [sub_zero, add_comm]; exact (sub_add_sub_cancel s p t).symm)
       · rw [dif_neg hsp, dif_neg htp]
         have h := τ₂.val.respects_task (s - p) (t - p)
           (Beh.mem_dom τ₂ (sub_nonneg.mpr (le_of_lt (not_le.mp hsp))) (sub_le_sub_right hs.2 p))
           (Beh.mem_dom τ₂ (sub_nonneg.mpr (le_of_lt (not_le.mp htp))) (sub_le_sub_right ht.2 p))
         rwa [sub_sub_sub_cancel_right] at h },
   fun _ => Iff.rfl⟩

/-! ### The two reading equations of `glue` -/

theorem glue_states_le (hcomp : TaskFrame.Compositional F.TaskRel) {l p : F.Duration} (hp : 0 ≤ p) (hpl : p ≤ l)
    (τ₁ : Beh F p) (τ₂ : Beh F (l - p)) (hmatch : _) (z : F.Duration)
    (hz : (glue hcomp hp hpl τ₁ τ₂ hmatch).val.domain z) (hzp : z ≤ p) :
    (glue hcomp hp hpl τ₁ τ₂ hmatch).val.states z hz = τ₁.val.states z (Beh.mem_dom τ₁ hz.1 hzp) :=
  dif_pos hzp

theorem glue_states_not_le (hcomp : TaskFrame.Compositional F.TaskRel) {l p : F.Duration} (hp : 0 ≤ p) (hpl : p ≤ l)
    (τ₁ : Beh F p) (τ₂ : Beh F (l - p)) (hmatch : _) (z : F.Duration)
    (hz : (glue hcomp hp hpl τ₁ τ₂ hmatch).val.domain z) (hzp : ¬ z ≤ p)
    (h2 : τ₂.val.domain (z - p)) :
    (glue hcomp hp hpl τ₁ τ₂ hmatch).val.states z hz = τ₂.val.states (z - p) h2 :=
  dif_neg hzp

/-! ### Restriction identity, left -/

theorem restrict_glue_left (hcomp : TaskFrame.Compositional F.TaskRel) {l p : F.Duration} (hp : 0 ≤ p) (hpl : p ≤ l)
    (τ₁ : Beh F p) (τ₂ : Beh F (l - p)) (hmatch : _) :
    Beh.restrict 0 p le_rfl hp (by rw [zero_add]; exact hpl) (glue hcomp hp hpl τ₁ τ₂ hmatch) = τ₁ := by
  refine Beh.ext (partialHistory_ext ?_ ?_)
  · funext z
    change (0 ≤ z ∧ z ≤ p) = τ₁.val.domain z
    exact propext (τ₁.property z).symm
  · intro r hr h'
    have hdomr : (glue hcomp hp hpl τ₁ τ₂ hmatch).val.domain r :=
      ⟨hr.1, le_trans hr.2 hpl⟩
    have hdom0 : (glue hcomp hp hpl τ₁ τ₂ hmatch).val.domain (0 + r) := by
      rw [zero_add]; exact hdomr
    rw [Beh.restrict_states 0 p le_rfl hp (by rw [zero_add]; exact hpl) _ r hr hdom0,
      PartialHistory.states_eq_of_time_eq _ (0 + r) r (zero_add r) hdom0 hdomr,
      glue_states_le hcomp hp hpl τ₁ τ₂ hmatch r hdomr hr.2]

/-! ### Restriction identity, right -/

theorem restrict_glue_right (hcomp : TaskFrame.Compositional F.TaskRel) {l p : F.Duration} (hp : 0 ≤ p) (hpl : p ≤ l)
    (τ₁ : Beh F p) (τ₂ : Beh F (l - p)) (hmatch : _) :
    Beh.restrict p (l - p) hp (sub_nonneg.mpr hpl) (by rw [add_sub_cancel])
      (glue hcomp hp hpl τ₁ τ₂ hmatch) = τ₂ := by
  refine Beh.ext (partialHistory_ext ?_ ?_)
  · funext z
    change (0 ≤ z ∧ z ≤ l - p) = τ₂.val.domain z
    exact propext (τ₂.property z).symm
  · intro r hr h'
    have hdom : (glue hcomp hp hpl τ₁ τ₂ hmatch).val.domain (p + r) :=
      ⟨add_nonneg hp hr.1, by
        have := add_le_add (le_refl p) hr.2
        rwa [add_sub_cancel] at this⟩
    rw [Beh.restrict_states p (l - p) hp (sub_nonneg.mpr hpl) (by rw [add_sub_cancel]) _ r hr hdom]
    by_cases hr0 : p + r ≤ p
    · have hle : p + r - p ≤ 0 := sub_nonpos.mpr hr0
      rw [add_sub_cancel_left] at hle
      have hr00 : r = 0 := le_antisymm hle hr.1
      subst hr00
      rw [glue_states_le hcomp hp hpl τ₁ τ₂ hmatch (p + 0) hdom hr0]
      rw [PartialHistory.states_eq_of_time_eq τ₁.val (p + 0) p (add_zero p) _
        (Beh.mem_dom τ₁ hp le_rfl), hmatch]
    · rw [glue_states_not_le hcomp hp hpl τ₁ τ₂ hmatch (p + r) hdom hr0
        (by rw [add_sub_cancel_left]; exact h')]
      exact PartialHistory.states_eq_of_time_eq τ₂.val (p + r - p) r (add_sub_cancel_left p r) _ h'

/-! ### Reading states out of an equality of sections -/

theorem states_eq_of_eq {l : F.Duration} {σ τ : Beh F l} (h : σ = τ) (r : F.Duration)
    (hσ : σ.val.domain r) (hτ : τ.val.domain r) : σ.val.states r hσ = τ.val.states r hτ := by
  subst h; rfl

/-! ### Uniqueness -/

theorem glue_unique (hcomp : TaskFrame.Compositional F.TaskRel) {l p : F.Duration} (hp : 0 ≤ p) (hpl : p ≤ l)
    (τ₁ : Beh F p) (τ₂ : Beh F (l - p)) (hmatch : _) (υ : Beh F l)
    (hL : Beh.restrict 0 p le_rfl hp (by rw [zero_add]; exact hpl) υ = τ₁)
    (hR : Beh.restrict p (l - p) hp (sub_nonneg.mpr hpl) (by rw [add_sub_cancel]) υ = τ₂) :
    υ = glue hcomp hp hpl τ₁ τ₂ hmatch := by
  refine Beh.ext (partialHistory_ext ?_ ?_)
  · funext z
    change υ.val.domain z = (0 ≤ z ∧ z ≤ l)
    exact propext (υ.property z)
  · intro r hr hr'
    have hr0 : 0 ≤ r := ((υ.property r).mp hr).1
    have hrl : r ≤ l := ((υ.property r).mp hr).2
    by_cases hrp : r ≤ p
    · rw [glue_states_le hcomp hp hpl τ₁ τ₂ hmatch r hr' hrp]
      have hd1 : (Beh.restrict 0 p le_rfl hp (by rw [zero_add]; exact hpl) υ).val.domain r :=
        ⟨hr0, hrp⟩
      have h0r : υ.val.domain (0 + r) := by rw [zero_add]; exact hr
      have h1 := states_eq_of_eq hL r hd1 (Beh.mem_dom τ₁ hr0 hrp)
      rw [Beh.restrict_states 0 p le_rfl hp (by rw [zero_add]; exact hpl) υ r hd1 h0r,
        PartialHistory.states_eq_of_time_eq υ.val (0 + r) r (zero_add r) h0r hr] at h1
      exact h1
    · have hrp' : 0 ≤ r - p := sub_nonneg.mpr (le_of_lt (not_le.mp hrp))
      have hrpl : r - p ≤ l - p := sub_le_sub_right hrl p
      rw [glue_states_not_le hcomp hp hpl τ₁ τ₂ hmatch r hr' hrp (Beh.mem_dom τ₂ hrp' hrpl)]
      have hd2 : (Beh.restrict p (l - p) hp (sub_nonneg.mpr hpl)
          (by rw [add_sub_cancel]) υ).val.domain (r - p) := ⟨hrp', hrpl⟩
      have hpr : υ.val.domain (p + (r - p)) := by rw [add_sub_cancel]; exact hr
      have h1 := states_eq_of_eq hR (r - p) hd2 (Beh.mem_dom τ₂ hrp' hrpl)
      rw [Beh.restrict_states p (l - p) hp (sub_nonneg.mpr hpl) (by rw [add_sub_cancel]) υ
          (r - p) hd2 hpr,
        PartialHistory.states_eq_of_time_eq υ.val (p + (r - p)) r (add_sub_cancel p r) hpr hr] at h1
      exact h1

/-! ### The Sheaf clause, packaged -/

theorem sheaf_clause (hcomp : TaskFrame.Compositional F.TaskRel) {l p : F.Duration} (hp : 0 ≤ p) (hpl : p ≤ l)
    (τ₁ : Beh F p) (τ₂ : Beh F (l - p))
    (hmatch : τ₁.val.states p (Beh.mem_dom τ₁ hp le_rfl)
      = τ₂.val.states 0 (Beh.mem_dom τ₂ le_rfl (sub_nonneg.mpr hpl))) :
    ∃! υ : Beh F l,
      Beh.restrict 0 p le_rfl hp (by rw [zero_add]; exact hpl) υ = τ₁ ∧
      Beh.restrict p (l - p) hp (sub_nonneg.mpr hpl) (by rw [add_sub_cancel]) υ = τ₂ :=
  ⟨glue hcomp hp hpl τ₁ τ₂ hmatch,
   ⟨restrict_glue_left hcomp hp hpl τ₁ τ₂ hmatch, restrict_glue_right hcomp hp hpl τ₁ τ₂ hmatch⟩,
   fun _ h => glue_unique hcomp hp hpl τ₁ τ₂ hmatch _ h.1 h.2⟩


end Probe564

#print axioms Probe564.rel_across_seam
#print axioms Probe564.paste_rel_le_lt'
#print axioms Probe564.glue_seam'
#print axioms Probe564.restrict_glue_left
#print axioms Probe564.restrict_glue_right
#print axioms Probe564.glue_unique
#print axioms Probe564.taskRel_reflection_of_ne
#print axioms Probe564.glue
#print axioms Probe564.sheaf_clause
#print axioms FormalSystem.Semantics.Presheaf.Beh.germEquiv
#print axioms FormalSystem.PlusLanguage.paste
