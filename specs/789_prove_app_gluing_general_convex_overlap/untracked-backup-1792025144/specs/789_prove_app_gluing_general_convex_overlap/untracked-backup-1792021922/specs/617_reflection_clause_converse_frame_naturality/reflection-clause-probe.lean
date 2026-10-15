import Mathlib.Tactic.Abel
import FormalSystem.Semantics.Presheaf.Behavior

/-! Simulates the PROMOTED frame-level reversal block sited at the Semantics/TaskFrame.lean
layer, then re-runs the whole Reflection clause on top of it with no OpenLanguage import. -/

namespace FormalSystem.Semantics

variable {D : TemporalOrder}

def FrameOver.rev (F : FrameOver D) : FrameOver D where
  WorldState := F.WorldState
  worldNonempty := F.worldNonempty
  PosRel := fun w x u => F.PosRel u x w

instance FrameOver.rev_isRegular (F : FrameOver D) [F.IsRegular] : F.rev.IsRegular where
  comp := by
    intro w v x y hx hy
    have h := F.comp v w y x hy hx
    rw [add_comm] at h
    change F.TaskRel v (x + y) w ↔ ∃ u, F.TaskRel u x w ∧ F.TaskRel v y u
    rw [h]
    constructor
    · rintro ⟨u, h1, h2⟩; exact ⟨u, h2, h1⟩
    · rintro ⟨u, h1, h2⟩; exact ⟨u, h2, h1⟩
  serial := by
    intro w x hx
    obtain ⟨⟨u, hu⟩, ⟨v, hv⟩⟩ := F.serial w x hx
    exact ⟨⟨v, hv⟩, ⟨u, hu⟩⟩
  limit := by
    intro w u h
    exact (F.limit u w h).symm
  saturation := by
    intro S hdir hmem
    refine F.saturation S hdir ?_
    intro s hs
    obtain ⟨hcls, hne⟩ := hmem s hs
    refine ⟨?_, hne⟩
    rcases hcls with ⟨w, x, rfl⟩ | ⟨w, v, x, y, hx, hy, rfl⟩
    · left
      refine ⟨w, -x, ?_⟩
      ext u
      change F.TaskRel u x w ↔ F.TaskRel w (-x) u
      exact F.reflection u x w
    · right
      refine ⟨v, w, y, x, hy, hx, ?_⟩
      ext u
      change F.TaskRel u x w ∧ F.TaskRel u (-y) v ↔ F.TaskRel v y u ∧ F.TaskRel w (-x) u
      rw [F.reflection u x w, F.reflection u (-y) v, neg_neg, and_comm]

theorem FrameOver.rev_taskRel (F : FrameOver D) (w : F.WorldState) (d : ↑D) (u : F.WorldState) :
    F.rev.TaskRel w d u ↔ F.TaskRel u d w := Iff.rfl

theorem FrameOver.rev_taskRel_neg (F : FrameOver D) [F.IsRegular] (w : F.WorldState) (d : ↑D)
    (u : F.WorldState) : F.rev.TaskRel w d u ↔ F.TaskRel w (-d) u :=
  F.reflection u d w

theorem FrameOver.rev_rev (F : FrameOver D) : F.rev.rev = F := rfl

@[reducible] def TaskFrame.rev (F : TaskFrame) : TaskFrame := ⟨F.Duration, F.toFibre.rev⟩

theorem TaskFrame.rev_rev (F : TaskFrame) : F.rev.rev = F := rfl

end FormalSystem.Semantics


namespace Probe3
open FormalSystem FormalSystem.Semantics FormalSystem.Semantics.Presheaf

variable {D : TemporalOrder}

/-! ### The reflection automorphism on morphisms -/

def Tr.ref {l' l : Obj D} (f : Tr l' l) : Tr l' l :=
  ⟨l.val - f.shift - l'.val,
   sub_nonneg.mpr (le_sub_iff_add_le.mpr (by rw [add_comm]; exact f.shift_add_le)),
   by rw [sub_add_cancel]; exact sub_le_self _ f.shift_nonneg⟩

@[simp] theorem Tr.ref_shift {l' l : Obj D} (f : Tr l' l) :
    (Tr.ref f).shift = l.val - f.shift - l'.val := rfl

theorem Tr.ref_ref {l' l : Obj D} (f : Tr l' l) : Tr.ref (Tr.ref f) = f := by
  ext; simp; abel

theorem Tr.ref_id (l : Obj D) : Tr.ref (Tr.id l) = Tr.id l := by
  ext; simp

theorem Tr.ref_comp {l'' l' l : Obj D} (f : Tr l' l) (g : Tr l'' l') :
    Tr.ref (Tr.comp f g) = Tr.comp (Tr.ref f) (Tr.ref g) := by
  ext; simp; abel

theorem Tr.ref_lres {l l' : Obj D} (h : l'.val ≤ l.val) :
    Tr.ref (lres h) = rres h := by
  ext; simp [lres, rres]

theorem Tr.ref_rres {l l' : Obj D} (h : l'.val ≤ l.val) :
    Tr.ref (rres h) = lres h := by
  ext; simp [lres, rres]

/-! ### The reflection of a section -/

def reflectSec {F : TaskFrame} (l : Obj F.Duration) (τ : Beh F l.val) : Beh F.rev l.val :=
  ⟨{ domain := fun z => 0 ≤ z ∧ z ≤ l.val
     nonempty_domain := ⟨0, le_refl 0, l.property⟩
     states := fun z hz =>
       τ.val.states (l.val - z)
         (Beh.mem_dom τ (sub_nonneg.mpr hz.2) (sub_le_self _ hz.1))
     respects_task := by
       intro s t hs ht
       refine (FrameOver.rev_taskRel F.toFibre _ (t - s) _).mpr ?_
       have h := τ.val.respects_task (l.val - t) (l.val - s)
         (Beh.mem_dom τ (sub_nonneg.mpr ht.2) (sub_le_self _ ht.1))
         (Beh.mem_dom τ (sub_nonneg.mpr hs.2) (sub_le_self _ hs.1))
       rwa [show (l.val - s) - (l.val - t) = t - s by abel] at h },
   fun _ => Iff.rfl⟩

theorem reflectSec_states {F : TaskFrame} (l : Obj F.Duration) (τ : Beh F l.val)
    (z : F.Duration) (hz : (reflectSec l τ).val.domain z) (h' : τ.val.domain (l.val - z)) :
    (reflectSec l τ).val.states z hz = τ.val.states (l.val - z) h' := rfl

/-! ### Naturality -/

theorem reflect_natural {F : TaskFrame} {l' l : Obj F.Duration} (f : Tr l' l)
    (τ : Beh F l.val) :
    reflectSec l' (Beh.restrictTr f τ)
      = Beh.restrictTr (F := F.rev) (Tr.ref f) (reflectSec l τ) := by
  refine Beh.ext (partialHistory_ext rfl ?_)
  intro r hr hr'
  show τ.val.states (f.shift + (l'.val - r)) _ = τ.val.states (l.val - ((l.val - f.shift - l'.val) + r)) _
  exact PartialHistory.states_eq_of_time_eq τ.val _ _ (by abel) _ _

/-! ### Each component is a bijection -/

theorem reflect_reflect {F : TaskFrame} (l : Obj F.Duration) (τ : Beh F l.val) :
    reflectSec (F := F.rev) l (reflectSec l τ) = τ := by
  refine Beh.ext (partialHistory_ext ?_ ?_)
  · funext z
    change (0 ≤ z ∧ z ≤ l.val) = τ.val.domain z
    exact propext ((τ.property z).symm)
  · intro r hr h'
    show τ.val.states (l.val - (l.val - r)) _ = τ.val.states r _
    exact PartialHistory.states_eq_of_time_eq τ.val _ _ (by abel) _ _

def reflectEquiv (F : TaskFrame) (l : Obj F.Duration) : Beh F l.val ≃ Beh F.rev l.val where
  toFun := reflectSec l
  invFun := reflectSec (F := F.rev) l
  left_inv := reflect_reflect l
  right_inv := reflect_reflect (F := F.rev) l

end Probe3

#print axioms Probe3.Tr.ref_ref
#print axioms Probe3.Tr.ref_comp
#print axioms Probe3.reflect_natural
#print axioms Probe3.reflect_reflect
#print axioms Probe3.reflectEquiv

assert_not_exists FormalSystem.ProofSystem.Axiom FormalSystem.ProofSystem.DerivationTree
