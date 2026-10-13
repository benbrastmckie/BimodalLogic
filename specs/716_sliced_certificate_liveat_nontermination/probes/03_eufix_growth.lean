/-
Probe 02: stage-by-stage wall-clock timing of the liveness fixpoint at certA, logged by
append to a file so a hang still leaves the completed stages on disk.
-/
import FormalSystem
open FormalSystem.Syntax FormalSystem.PlusLanguage
open FormalSystem.Metalogic.Decidability
open FormalSystem.Metalogic.Decidability.PlusSharingWitnessFamily

namespace Probe716C

def logPath : System.FilePath := "/tmp/claude-1000/-home-benjamin-Projects-BimodalLogic/50171684-9032-4844-ac9a-025805cf09a7/scratchpad/probe03.out"

def say (s : String) : IO Unit := do
  let h ← IO.FS.Handle.mk logPath IO.FS.Mode.append
  h.putStrLn s
  h.flush

def timeIt {α : Type} [ToString α] (name : String) (f : Unit → α) : IO Unit := do
  say s!"START {name}"
  let t0 ← IO.monoMsNow
  let s := toString (f ())
  let t1 ← IO.monoMsNow
  say s!"  {name} = {s}   [{t1 - t0} ms]"

def pA : Atom := Atom.mkBase "p"
abbrev ClA : Finset PlusFormula := closA pA

theorem atomA_sub : ({PlusFormula.atom pA} : Finset PlusFormula) ⊆ ClA := by
  intro ψ h; rw [mem_closA]; simp only [Finset.mem_singleton] at h; tauto

def sliceA : PlusSlice 2 ClA where
  edge := fun _ _ => true
  lab := fun w => if w = 1 then {PlusFormula.atom pA} else ∅
  lab_sub := by
    intro w
    split_ifs
    · exact atomA_sub
    · exact Finset.empty_subset _

def labAb : Finset PlusFormula := {PlusFormula.atom pA, PlusFormula.top, snceP pA}
def labAf : Finset PlusFormula := {PlusFormula.top, snceP pA}

theorem labAb_sub : labAb ⊆ ClA := by
  intro ψ h; rw [mem_closA]; simp only [labAb, Finset.mem_insert, Finset.mem_singleton] at h; tauto
theorem labAf_sub : labAf ⊆ ClA := by
  intro ψ h; rw [mem_closA]; simp only [labAf, Finset.mem_insert, Finset.mem_singleton] at h; tauto

def tgtA : PlusGraphPath 2 ClA where
  back := [(labAb, 1)]
  mid := []
  fwd := [(labAf, 0)]
  back_ne := List.cons_ne_nil _ _
  fwd_ne := List.cons_ne_nil _ _
  label_sub := by
    intro X hX
    simp only [List.cons_append, List.nil_append, List.mem_cons, List.not_mem_nil, or_false] at hX
    rcases hX with rfl | rfl
    · exact labAb_sub
    · exact labAf_sub

def certA : PlusSlicedCertificate ([] : PlusContext) [targetA pA] where
  n := 2
  n_pos := by norm_num
  back := [sliceA]
  mid := []
  fwd := [sliceA]
  back_ne := List.cons_ne_nil _ _
  fwd_ne := List.cons_ne_nil _ _
  bx := fun _ => false
  target := tgtA
  targetTime := 0

abbrev EC := (WitnessFamily.Embedded.liveFamily.sliced (-1))

#eval show IO Unit from do
  say "=== probe 03: EUFix.iter growth on the backward graph ==="
  let V := certA.verts
  let isE := Fair.inSet V (certA.atPosT (PlusFormula.atom pA))
  let isG := certA.atPosT PlusFormula.top
  timeIt "V.card" (fun _ => V.card)
  timeIt "iter 1" (fun _ => (EUFix.iter V certA.predT isE isG 1).card)
  timeIt "iter 2" (fun _ => (EUFix.iter V certA.predT isE isG 2).card)
  timeIt "iter 3" (fun _ => (EUFix.iter V certA.predT isE isG 3).card)
  timeIt "iter 4" (fun _ => (EUFix.iter V certA.predT isE isG 4).card)
  timeIt "iter 5" (fun _ => (EUFix.iter V certA.predT isE isG 5).card)
  timeIt "iter 6" (fun _ => (EUFix.iter V certA.predT isE isG 6).card)
  timeIt "iter 7" (fun _ => (EUFix.iter V certA.predT isE isG 7).card)
  timeIt "iter 8" (fun _ => (EUFix.iter V certA.predT isE isG 8).card)
  timeIt "iter 9" (fun _ => (EUFix.iter V certA.predT isE isG 9).card)
  timeIt "iter 10" (fun _ => (EUFix.iter V certA.predT isE isG 10).card)
  say "=== done ==="

end Probe716C
