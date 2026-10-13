/-
Probe 02: stage-by-stage wall-clock timing of the liveness fixpoint at certA, logged by
append to a file so a hang still leaves the completed stages on disk.
-/
import FormalSystem
open FormalSystem.Syntax FormalSystem.PlusLanguage
open FormalSystem.Metalogic.Decidability
open FormalSystem.Metalogic.Decidability.PlusSharingWitnessFamily

namespace Probe716J

def logPath : System.FilePath := "/tmp/claude-1000/-home-benjamin-Projects-BimodalLogic/50171684-9032-4844-ac9a-025805cf09a7/scratchpad/probe10.out"

def say (s : String) : IO Unit := do
  let h ← IO.FS.Handle.mk logPath IO.FS.Mode.append
  h.putStrLn s
  h.flush

def timeIt {α : Type} [ToString α] (name : String) (f : Unit → α) : IO Unit := do
  say s!"START {name}"
  let t0 ← IO.monoMsNow
  -- force the value through an IO side effect BEFORE reading the clock again,
  -- so the optimizer cannot float the pure computation past `t1`
  say s!"  {name} = {toString (f ())}"
  let t1 ← IO.monoMsNow
  say s!"    [{t1 - t0} ms]"

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
  say "=== probe 10: corrected timing harness ==="
  timeIt "closure.card" (fun _ => (plusClosureOf (([] : PlusContext) ++ [targetA pA])).card)
  timeIt "Fintype.card Pos" (fun _ => Fintype.card certA.Pos)
  timeIt "posAt 0" (fun _ => (certA.posAt 0).card)
  timeIt "verts" (fun _ => certA.verts.card)
  timeIt "sum predT cards over verts"
    (fun _ => Finset.sum certA.verts (fun v => (certA.predT v).card))
  timeIt "EUFix step at empty"
    (fun _ => (EUFix.step certA.verts certA.predT
      (Fair.inSet certA.verts (certA.atPosT (PlusFormula.atom pA)))
      (certA.atPosT PlusFormula.top) (∅ : Finset certA.TPos)).card)
  timeIt "EUFix iter 2"
    (fun _ => (EUFix.iter certA.verts certA.predT
      (Fair.inSet certA.verts (certA.atPosT (PlusFormula.atom pA)))
      (certA.atPosT PlusFormula.top) 2).card)
  timeIt "EUFix iter 3"
    (fun _ => (EUFix.iter certA.verts certA.predT
      (Fair.inSet certA.verts (certA.atPosT (PlusFormula.atom pA)))
      (certA.atPosT PlusFormula.top) 3).card)
  say "=== done ==="

end Probe716J
