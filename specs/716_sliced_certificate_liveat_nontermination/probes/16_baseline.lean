/-
Probe 16 -- the rerunnable baseline harness for this implementation round.

WHAT THIS MEASURES
  * At the pinned self-loop embedded witness `WitnessFamily.Embedded.liveFamily.sliced (-1)`:
    `verts.card`, `fwdLiveT.card`, `bwdLiveT.card`, `(liveAt (-1)).card`. These are the numbers
    the cost regression guard and every "after" figure are read against.
  * At the slab-carrying width-2 total-edge certificate (`certA` below, the construction the
    library lands): `Fintype.card Pos`, `verts.card`, `winTimes.card`, `(posAt 0).card`, and the
    `verts` / `predT` stage times.
  * The C36 interest expression `c36Sliced [c36Snce]` at `certA`.

HARNESS CONSTRAINT
  Probes 01-09 of this task bind the measured value to a pure `let` between two `IO.monoMsNow`
  reads. Lean floats that binding past the second read, so every stage reports 0 ms while the
  run never finishes -- their figures are NOT citable. The `timeIt` below forces the value
  through an `IO` write BEFORE the second clock read, as probes 10-15 do.
-/
import FormalSystem
open FormalSystem.Syntax FormalSystem.PlusLanguage
open FormalSystem.Metalogic.Decidability
open FormalSystem.Metalogic.Decidability.PlusSharingWitnessFamily

namespace Probe716Baseline

def logPath : System.FilePath :=
  "/tmp/claude-1000/-home-benjamin-Projects-BimodalLogic/cdc42a16-7328-4525-8f63-a2cd097dc642/scratchpad/probe16.out"

def say (s : String) : IO Unit := do
  let h ← IO.FS.Handle.mk logPath IO.FS.Mode.append
  h.putStrLn s
  h.flush

def timeIt {α : Type} [ToString α] (name : String) (f : Unit → α) : IO Unit := do
  say s!"START {name}"
  let t0 ← IO.monoMsNow
  say s!"  {name} = {toString (f ())}"
  let t1 ← IO.monoMsNow
  say s!"    [{t1 - t0} ms]"

/-! ## The slab-carrying width-2 total-edge certificate -/

def pA : Atom := Atom.mkBase "p"
abbrev ClA : Finset PlusFormula := closA pA

def labSlice : Finset PlusFormula := {PlusFormula.atom pA, snceP pA}

theorem labSlice_sub : labSlice ⊆ ClA := by
  intro ψ h
  rw [mem_closA]
  simp only [labSlice, Finset.mem_insert, Finset.mem_singleton] at h
  tauto

def sliceA : PlusSlice 2 ClA where
  edge := fun _ _ => true
  lab := fun w => if w = 1 then labSlice else ∅
  lab_sub := by
    intro w
    split_ifs
    · exact labSlice_sub
    · exact Finset.empty_subset _

def labAb : Finset PlusFormula := {PlusFormula.atom pA, PlusFormula.top, snceP pA}
def labAf : Finset PlusFormula := {PlusFormula.top, snceP pA}

theorem labAb_sub : labAb ⊆ ClA := by
  intro ψ h; rw [mem_closA]; simp only [labAb, Finset.mem_insert, Finset.mem_singleton] at h; tauto
theorem labAf_sub : labAf ⊆ ClA := by
  intro ψ h; rw [mem_closA]; simp only [labAf, Finset.mem_insert, Finset.mem_singleton] at h; tauto

def pathA : PlusGraphPath 2 ClA where
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
  target := pathA
  targetTime := 0

/-! ## The C36 interest-expression vocabulary, copied from `scripts/check-module-invariants.sh` -/

def c36Snce : PlusFormula → Bool | .snce _ _ => true | _ => false
def c36In (k : PlusFormula → Bool) (C : Finset PlusFormula) : Bool := decide (∃ φ ∈ C, k φ = true)
def c36Sliced {Γ Del : PlusContext} (ks : List (PlusFormula → Bool))
    (G : PlusSlicedCertificate Γ Del) : Bool :=
  ks.all fun k => c36In k (plusClosureOf (Γ ++ Del)) &&
    decide (∃ t ∈ G.winTimes, ∃ w : Fin G.n, ∃ χ ∈ G.slab t w, k χ = true)

abbrev EC := WitnessFamily.Embedded.liveFamily.sliced (-1)

#eval show IO Unit from do
  say "=== probe 16: baseline, corrected harness ==="
  say "--- A. the pinned self-loop embedded witness, liveFamily.sliced (-1) ---"
  timeIt "EC closure.card"
    (fun _ => (plusClosureOf (([] : PlusContext) ++ [ofFormula WitnessFamily.Embedded.evTarget])).card)
  timeIt "EC Fintype.card Pos" (fun _ => Fintype.card EC.Pos)
  timeIt "EC winTimes.card" (fun _ => EC.winTimes.card)
  timeIt "EC verts.card" (fun _ => EC.verts.card)
  timeIt "EC fwdLiveT.card" (fun _ => EC.fwdLiveT.card)
  timeIt "EC bwdLiveT.card" (fun _ => EC.bwdLiveT.card)
  timeIt "EC liveAt (-1) .card" (fun _ => (EC.liveAt (-1)).card)
  say "--- B. the slab-carrying width-2 total-edge certificate, certA ---"
  timeIt "certA closure.card"
    (fun _ => (plusClosureOf (([] : PlusContext) ++ [targetA pA])).card)
  timeIt "certA Fintype.card Pos" (fun _ => Fintype.card certA.Pos)
  timeIt "certA winTimes.card" (fun _ => certA.winTimes.card)
  timeIt "certA posAt 0 .card" (fun _ => (certA.posAt 0).card)
  timeIt "certA verts.card" (fun _ => certA.verts.card)
  timeIt "certA sum predT cards over verts"
    (fun _ => Finset.sum certA.verts (fun v => (certA.predT v).card))
  say "--- C. the C36 interest expression at certA ---"
  timeIt "certA c36Sliced [c36Snce]" (fun _ => c36Sliced [c36Snce] certA)
  say "=== probe 16 done ==="

end Probe716Baseline
