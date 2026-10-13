import FormalSystem
open FormalSystem.Syntax FormalSystem.PlusLanguage
open FormalSystem.Metalogic.Decidability
open FormalSystem.Metalogic.Decidability.PlusSharingWitnessFamily

namespace Probe716P
def pA : Atom := Atom.mkBase "p"
abbrev ClB : Finset PlusFormula := closB pA

theorem atomB_sub : ({PlusFormula.atom pA} : Finset PlusFormula) ⊆ ClB := by
  intro ψ h; rw [mem_closB]; simp only [Finset.mem_singleton] at h; tauto

def sliceB : PlusSlice 2 ClB where
  edge := fun _ _ => true
  lab := fun w => if w = 1 then {PlusFormula.atom pA} else ∅
  lab_sub := by
    intro w
    split_ifs
    · exact atomB_sub
    · exact Finset.empty_subset _

def labBb : Finset PlusFormula := {PlusFormula.top, untlP pA, notP pA}
def labBf : Finset PlusFormula :=
  {PlusFormula.atom pA, PlusFormula.top, untlP pA, innerB pA, targetB pA}

theorem labBb_sub : labBb ⊆ ClB := by
  intro ψ h; rw [mem_closB]; simp only [labBb, Finset.mem_insert, Finset.mem_singleton] at h; tauto
theorem labBf_sub : labBf ⊆ ClB := by
  intro ψ h; rw [mem_closB]; simp only [labBf, Finset.mem_insert, Finset.mem_singleton] at h; tauto

def tgtB : PlusGraphPath 2 ClB where
  back := [(labBb, 0)]
  mid := [(labBb, 0)]
  fwd := [(labBf, 1)]
  back_ne := List.cons_ne_nil _ _
  fwd_ne := List.cons_ne_nil _ _
  label_sub := by
    intro X hX
    simp only [List.cons_append, List.nil_append, List.mem_cons, List.not_mem_nil, or_false] at hX
    rcases hX with rfl | rfl | rfl
    · exact labBb_sub
    · exact labBb_sub
    · exact labBf_sub

def certB : PlusSlicedCertificate ([] : PlusContext) [targetB pA] where
  n := 2
  n_pos := by norm_num
  back := [sliceB]
  mid := []
  fwd := [sliceB]
  back_ne := List.cons_ne_nil _ _
  fwd_ne := List.cons_ne_nil _ _
  bx := fun _ => false
  target := tgtB
  targetTime := 0

set_option maxRecDepth 1000000
set_option maxHeartbeats 0

example : certB.Certifies := by decide

end Probe716P
