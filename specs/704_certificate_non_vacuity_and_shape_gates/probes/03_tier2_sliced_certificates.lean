/-
Probe 704 (implementation, Phase 5, Tier 2): hand-built width-2 time-sliced certificates for
`targetA = (⊤ S p) → ⊡(⊤ S p)` and `targetB = (⊤ U p) → (¬p → ⊡(⊤ U p))`, one total-edge
slice each (state 0: p false; state 1: p true), the target path leaving state 1 for state 0 at
time 0 (A) or state 0 for state 1 at time 1 (B), so that at the target position `⊡` of the
tense formula is refuted by a second live position at the same state that never sees `p`.
Compile from the repository root with: lake env lean <this file>
RESULT: `lake env lean` produced NO output within 560 s -- the compiled per-conjunct `#eval`s
did not return, so the obstacle is the cost of the decision procedure at width 2 over a
6-formula closure, not the construction. See the plan's Phase 5 Reasoned Exclusions.
-/
import FormalSystem
open FormalSystem.Syntax FormalSystem.PlusLanguage
open FormalSystem.Metalogic.Decidability
open FormalSystem.Metalogic.Decidability.PlusSharingWitnessFamily

namespace Tier2
def pA : Atom := Atom.mkBase "p"

/-! ### A: `(⊤ S p) → ⊡(⊤ S p)` -/
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

/-- state `1` (p true), on the negatives: `{p, ⊤, Pp}`. -/
def labAb : Finset PlusFormula := {PlusFormula.atom pA, PlusFormula.top, snceP pA}
/-- state `0` (p false), from time 0 on: `{⊤, Pp}` -- `⊡Pp` absent, so the target is refuted. -/
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

#eval s!"A BiSerial={decide certA.BiSerial} TailStable={decide certA.TailStable} BoxLabel={decide certA.BoxLabelFaithful} win={decide (certA.targetTime ∈ certA.winTimes)} path={decide certA.TargetPathPos} live={decide (certA.targetPos certA.targetTime ∈ certA.liveAt certA.targetTime)} stab={decide certA.StabFaithful} boxLive={decide certA.BoxLiveFaithful} target={decide certA.Target}"
#eval s!"A Certifies={decide certA.Certifies} winTimes={certA.winTimes.card} posAt0={(certA.posAt 0).card} liveAt0={(certA.liveAt 0).card}"

/-! ### B: `(⊤ U p) → (¬p → ⊡(⊤ U p))` -/
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

/-- state `0` up to time 0: `{⊤, Fp, ¬p}` -- `⊡Fp` absent, so `innerB` and the target are absent. -/
def labBb : Finset PlusFormula := {PlusFormula.top, untlP pA, notP pA}
/-- state `1` from time 1 on: `{p, ⊤, Fp, innerB, T}`. -/
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

#eval s!"B BiSerial={decide certB.BiSerial} TailStable={decide certB.TailStable} BoxLabel={decide certB.BoxLabelFaithful} win={decide (certB.targetTime ∈ certB.winTimes)} path={decide certB.TargetPathPos} live={decide (certB.targetPos certB.targetTime ∈ certB.liveAt certB.targetTime)} stab={decide certB.StabFaithful} boxLive={decide certB.BoxLiveFaithful} target={decide certB.Target}"
#eval s!"B Certifies={decide certB.Certifies} winTimes={certB.winTimes.card} posAt0={(certB.posAt 0).card} liveAt0={(certB.liveAt 0).card}"
end Tier2
