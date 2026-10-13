/-
Probe 02: stage-by-stage wall-clock timing of the liveness fixpoint at certA, logged by
append to a file so a hang still leaves the completed stages on disk.
-/
import FormalSystem
open FormalSystem.Syntax FormalSystem.PlusLanguage
open FormalSystem.Metalogic.Decidability
open FormalSystem.Metalogic.Decidability.PlusSharingWitnessFamily

namespace Probe716K

def logPath : System.FilePath := "/tmp/claude-1000/-home-benjamin-Projects-BimodalLogic/50171684-9032-4844-ac9a-025805cf09a7/scratchpad/probe11.out"

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

/-! ## A hoisted / memoized mirror of the same stack -/

def closC : Finset PlusFormula := plusClosureOf (([] : PlusContext) ++ [targetA pA])

/-- `posAt` precomputed at every time the window and its one-step neighbours can reach. -/
def posTable : List (ℤ × Finset certA.Pos) :=
  ([-5, -4, -3, -2, -1, 0, 1, 2, 3, 4] : List ℤ).map (fun t => (t, certA.posAt t))

def posAtC (t : ℤ) : Finset certA.Pos :=
  match posTable.find? (fun p => decide (p.1 = t)) with
  | some p => p.2
  | none => certA.posAt t

def vertsC : Finset certA.TPos :=
  (Finset.univ ×ˢ certA.winTimes).filter (fun v => v.1 ∈ posAtC v.2)

def predPC (t : ℤ) (q : certA.Pos) : Finset certA.Pos :=
  (posAtC (t - 1)).filter (fun p => certA.edge (t - 1) p.1 q.1 = true ∧
    PlusSlicedCertificate.StepClause ([] : PlusContext) [targetA pA] p.2.1 q.2.1)

def predTC (v : certA.TPos) : Finset certA.TPos :=
  let P := predPC v.2 v.1
  let u := certA.prevTime v.2
  vertsC.filter (fun w => w.2 = u ∧ w.1 ∈ P)

def snceLiveC (X : Finset certA.TPos) (g e : PlusFormula) : Finset certA.TPos :=
  EUFix.lfp X predTC (Fair.inSet X (certA.atPosT e)) (certA.atPosT g)

def snceLiveAtC (X : Finset certA.TPos) (v : certA.TPos) : PlusFormula → Bool
  | .snce g e => decide (PlusFormula.snce g e ∈ v.1.2.1 → v ∈ snceLiveC X g e)
  | _ => true

def bwdLiveStepC (X : Finset certA.TPos) : Finset certA.TPos :=
  X.filter (fun v => (∃ w ∈ predTC v, w ∈ X) ∧ ∀ ψ ∈ closC, snceLiveAtC X v ψ = true)

def bwdLiveTC : Finset certA.TPos := Nu.gfp vertsC bwdLiveStepC

#eval show IO Unit from do
  say "=== probe 11 ==="
  say "--- landed self-loop embedded witness (library code, unmemoized) ---"
  timeIt "EC verts" (fun _ => EC.verts.card)
  timeIt "EC fwdLiveT" (fun _ => EC.fwdLiveT.card)
  timeIt "EC bwdLiveT" (fun _ => EC.bwdLiveT.card)
  timeIt "EC liveAt -1" (fun _ => (EC.liveAt (-1)).card)
  say "--- certA, hoisted mirror ---"
  timeIt "posTable build" (fun _ => posTable.length)
  timeIt "vertsC" (fun _ => vertsC.card)
  timeIt "vertsC again" (fun _ => vertsC.card)
  timeIt "sum predTC cards" (fun _ => Finset.sum vertsC (fun v => (predTC v).card))
  timeIt "snceLiveC at vertsC"
    (fun _ => (snceLiveC vertsC PlusFormula.top (PlusFormula.atom pA)).card)
  timeIt "bwdLiveStepC vertsC" (fun _ => (bwdLiveStepC vertsC).card)
  timeIt "bwdLiveTC" (fun _ => bwdLiveTC.card)
  say "=== done ==="

end Probe716K
