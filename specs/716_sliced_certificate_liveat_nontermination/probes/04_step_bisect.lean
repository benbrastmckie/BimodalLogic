/-
Probe 02: stage-by-stage wall-clock timing of the liveness fixpoint at certA, logged by
append to a file so a hang still leaves the completed stages on disk.
-/
import FormalSystem
open FormalSystem.Syntax FormalSystem.PlusLanguage
open FormalSystem.Metalogic.Decidability
open FormalSystem.Metalogic.Decidability.PlusSharingWitnessFamily

namespace Probe716D

def logPath : System.FilePath := "/tmp/claude-1000/-home-benjamin-Projects-BimodalLogic/50171684-9032-4844-ac9a-025805cf09a7/scratchpad/probe04.out"

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
  say "=== probe 04: bisecting EUFix.step ==="
  let V := certA.verts
  let isE := Fair.inSet V (certA.atPosT (PlusFormula.atom pA))
  let isG := certA.atPosT PlusFormula.top
  timeIt "V.card" (fun _ => V.card)
  -- (a) raw DecidableEq cost: 16x16 equality tests on TPos
  timeIt "pairwise eq count over VxV"
    (fun _ => Finset.sum V (fun v => (V.filter (fun w => w = v)).card))
  -- (b) predT cost again
  timeIt "sum predT cards" (fun _ => Finset.sum V (fun v => (certA.predT v).card))
  -- (c) isE / isG cost
  timeIt "count isE over V" (fun _ => (V.filter (fun w => isE w = true)).card)
  timeIt "count isG over V" (fun _ => (V.filter (fun w => isG w = true)).card)
  -- (d) step from empty
  let X1 := EUFix.step V certA.predT isE isG (∅ : Finset certA.TPos)
  timeIt "X1 = step at empty" (fun _ => X1.card)
  -- (e) hand-rolled membership of predT-successors in X1 (no step)
  timeIt "sum over V of |predT v cap X1|"
    (fun _ => Finset.sum V (fun v => ((certA.predT v).filter (fun w => w ∈ X1)).card))
  -- (f) hand-rolled step body, X1 forced and shared
  timeIt "handrolled step at X1"
    (fun _ => Finset.sum V (fun v =>
      if ((certA.predT v).filter
            (fun w => (isE w || (isG w && decide (w ∈ X1))) = true)).card = 0
      then 0 else 1))
  -- (g) library step at the SAME shared X1
  timeIt "library step at shared X1"
    (fun _ => (EUFix.step V certA.predT isE isG X1).card)
  -- (h) library step at V itself
  timeIt "library step at V" (fun _ => (EUFix.step V certA.predT isE isG V).card)
  -- (i) iter 2 (the one that hung)
  timeIt "EUFix.iter 2" (fun _ => (EUFix.iter V certA.predT isE isG 2).card)
  say "=== done ==="

end Probe716D
