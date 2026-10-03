/-
Research probe: `paste` generalized OFF its totality hypothesis.

`pasteAt` pastes two ARBITRARY partial histories sharing a state at `t` -- domain the union of
`σ`'s `≤ t` part and `τ`'s `> t` part -- using the same `rel_across_seam` argument probe 01 shares
with the interval-site gluing step. `isTotal_pasteAt` and `paste_eq_pasteAt` recover the existing
total-history `paste` as a corollary, with `paste`'s own definition and signature untouched.

All three are sorry-free. `pasteAt` is choice-free ([propext, Quot.sound]); `paste_eq_pasteAt`
inherits `Classical.choice` only through the EXISTING `paste`, whose `paste_rel` still routes the
mixed-orientation case through `F.reflection` rather than the choice-free off-zero reflection.
-/
import FormalSystem.PlusLanguage.PlusPasting
open FormalSystem.Semantics
namespace Probe564Paste
variable {F : TaskFrame}

theorem taskRel_reflection_of_ne (F : TaskFrame) {w u : F.WorldState} {d : F.Duration}
    (hd : d ≠ 0) : F.TaskRel w d u ↔ F.TaskRel u (-d) w :=
  TaskFrame.reflect_reflection_of_ne hd

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

/-- `paste` generalized OFF totality: two partial histories sharing a state at `t` paste to a
partial history on the union of `σ`'s past-of-`t` part and `τ`'s future-of-`t` part. -/
def pasteAt (hcomp : TaskFrame.Compositional F.TaskRel) (σ τ : PartialHistory F) (t : F.Duration)
    (hσt : σ.domain t) (hτt : τ.domain t) (hmatch : σ.states t hσt = τ.states t hτt) :
    PartialHistory F where
  domain := fun z => (z ≤ t ∧ σ.domain z) ∨ (¬ z ≤ t ∧ τ.domain z)
  nonempty_domain := ⟨t, Or.inl ⟨le_rfl, hσt⟩⟩
  states := fun z hz =>
    if hzt : z ≤ t then σ.states z (hz.resolve_right (fun h => h.1 hzt)).2
    else τ.states z (hz.resolve_left (fun h => hzt h.1)).2
  respects_task := by
    intro s s' hs hs'
    by_cases hst : s ≤ t <;> by_cases hs't : s' ≤ t
    · rw [dif_pos hst, dif_pos hs't]; exact σ.respects_task s s' _ _
    · rw [dif_pos hst, dif_neg hs't]
      exact rel_across_seam hcomp hσt hτt hmatch _ _ hst (le_of_lt (not_le.mp hs't))
        (by rw [add_comm]; exact (sub_add_sub_cancel s' t s).symm)
    · have hne : s' - s ≠ 0 :=
        sub_ne_zero_of_ne (ne_of_lt (lt_of_le_of_lt hs't (not_le.mp hst)))
      rw [dif_neg hst, dif_pos hs't, taskRel_reflection_of_ne F hne, neg_sub]
      exact rel_across_seam hcomp hσt hτt hmatch _ _ hs't (le_of_lt (not_le.mp hst))
        (by rw [add_comm]; exact (sub_add_sub_cancel s t s').symm)
    · rw [dif_neg hst, dif_neg hs't]; exact τ.respects_task s s' _ _


/-- Reading the pasted states on the `σ` side. -/
theorem pasteAt_states_le (hcomp : TaskFrame.Compositional F.TaskRel) (σ τ : PartialHistory F)
    (t : F.Duration) (hσt : σ.domain t) (hτt : τ.domain t)
    (hmatch : σ.states t hσt = τ.states t hτt) (z : F.Duration)
    (hz : (pasteAt hcomp σ τ t hσt hτt hmatch).domain z) (hzt : z ≤ t) (hσz : σ.domain z) :
    (pasteAt hcomp σ τ t hσt hτt hmatch).states z hz = σ.states z hσz := dif_pos hzt

/-- Reading the pasted states on the `τ` side. -/
theorem pasteAt_states_not_le (hcomp : TaskFrame.Compositional F.TaskRel) (σ τ : PartialHistory F)
    (t : F.Duration) (hσt : σ.domain t) (hτt : τ.domain t)
    (hmatch : σ.states t hσt = τ.states t hτt) (z : F.Duration)
    (hz : (pasteAt hcomp σ τ t hσt hτt hmatch).domain z) (hzt : ¬ z ≤ t) (hτz : τ.domain z) :
    (pasteAt hcomp σ τ t hσt hτt hmatch).states z hz = τ.states z hτz := dif_neg hzt

/-- At two TOTAL histories the generalized paste is total. -/
theorem isTotal_pasteAt (hcomp : TaskFrame.Compositional F.TaskRel) (ρ σ : WorldHistory F)
    (t : F.Duration) (hmatch : ρ.val.states t (ρ.property t) = σ.val.states t (σ.property t)) :
    (pasteAt hcomp ρ.val σ.val t (ρ.property t) (σ.property t) hmatch).IsTotal := by
  intro z
  by_cases h : z ≤ t
  · exact Or.inl ⟨h, ρ.property z⟩
  · exact Or.inr ⟨h, σ.property z⟩


open FormalSystem.PlusLanguage in
/-- The total-history `paste` IS the generalized `pasteAt` at two total histories: the existing
construction is recovered as a corollary, with its definition and signature untouched. -/
theorem paste_eq_pasteAt [F.IsRegular] (ρ σ : WorldHistory F) (t : F.Duration)
    (hsame : ρ.state t = σ.state t) :
    paste ρ σ t hsame
      = ⟨pasteAt F.comp ρ.val σ.val t (ρ.property t) (σ.property t) hsame,
         isTotal_pasteAt F.comp ρ σ t hsame⟩ := by
  refine WorldHistory.ext_state ?_
  intro z
  show pasteFun ρ σ t z
      = (pasteAt F.comp ρ.val σ.val t (ρ.property t) (σ.property t) hsame).states z
          (isTotal_pasteAt F.comp ρ σ t hsame z)
  unfold pasteFun
  by_cases h : z ≤ t
  · rw [if_pos h,
      pasteAt_states_le F.comp ρ.val σ.val t (ρ.property t) (σ.property t) hsame z _ h
        (ρ.property z)]
    exact (WorldHistory.states_eq_state ρ z (ρ.property z)).symm
  · rw [if_neg h,
      pasteAt_states_not_le F.comp ρ.val σ.val t (ρ.property t) (σ.property t) hsame z _ h
        (σ.property z)]
    exact (WorldHistory.states_eq_state σ z (σ.property z)).symm

end Probe564Paste
#print axioms Probe564Paste.pasteAt
#print axioms Probe564Paste.paste_eq_pasteAt
