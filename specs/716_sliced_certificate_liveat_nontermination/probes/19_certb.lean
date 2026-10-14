/-
Probe 19 -- certB: the Scope-Hypothesis measurements, the interest expression, and the bounded
`decide`.

ORDER IS DELIBERATE. The interest expression and the two size figures are evaluated BEFORE any
`Certifies` attempt: a row that cannot be interesting is not worth a multi-hour `decide`, and the
phase's Scope Hypothesis names the "order of magnitude larger closure" as a carried hypothesis
rather than a fact, to be confirmed by `(plusClosureOf (Γ ++ Del)).card` and
`Fintype.card certB.Pos` here.

THE SLAB REPAIR. Probe 15's `sliceB` labels `w = 1` with `{atom p}` alone, so no slab of the
window carries a formula of the claimed `untl` kind and `c36Sliced [c36Untl]` cannot be
satisfied however well `Certifies` goes. The repair is the one the landed `certA` already
carries: put the claimed kind's own formula in the slab labelling and discharge the subset
obligation through `mem_closB`.

  lake env lean specs/716_sliced_certificate_liveat_nontermination/probes/19_certb.lean
-/
import FormalSystem
open FormalSystem.Syntax FormalSystem.PlusLanguage
open FormalSystem.Metalogic.Decidability
open FormalSystem.Metalogic.Decidability.PlusSharingWitnessFamily

namespace Probe716CertB

def pB : Atom := Atom.mkBase "p"
abbrev ClB : Finset PlusFormula := closB pB

/-! ## The slab repair: the claimed `untl` kind occupies the slab -/

def labSliceB : Finset PlusFormula := {PlusFormula.atom pB, untlP pB}

theorem labSliceB_sub : labSliceB ⊆ ClB := by
  intro ψ h
  rw [mem_closB]
  simp only [labSliceB, Finset.mem_insert, Finset.mem_singleton] at h
  tauto

def sliceB : PlusSlice 2 ClB where
  edge := fun _ _ => true
  lab := fun w => if w = 1 then labSliceB else ∅
  lab_sub := by
    intro w
    split_ifs
    · exact labSliceB_sub
    · exact Finset.empty_subset _

/-! ## The target path, carried from probe 15 unchanged -/

def labBb : Finset PlusFormula := {PlusFormula.top, untlP pB, notP pB}
def labBf : Finset PlusFormula :=
  {PlusFormula.atom pB, PlusFormula.top, untlP pB, innerB pB, targetB pB}

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

def certB : PlusSlicedCertificate ([] : PlusContext) [targetB pB] where
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

/-! ## The C36 interest-expression vocabulary, copied from `scripts/check-module-invariants.sh` -/

def c36Untl : PlusFormula → Bool | .untl _ _ => true | _ => false
def c36In (k : PlusFormula → Bool) (C : Finset PlusFormula) : Bool := decide (∃ φ ∈ C, k φ = true)
def c36Sliced {Γ Del : PlusContext} (ks : List (PlusFormula → Bool))
    (G : PlusSlicedCertificate Γ Del) : Bool :=
  ks.all fun k => c36In k (plusClosureOf (Γ ++ Del)) &&
    decide (∃ t ∈ G.winTimes, ∃ w : Fin G.n, ∃ χ ∈ G.slab t w, k χ = true)

/-! ## A. the Scope-Hypothesis figures, and the interest expression -/

#time #eval (plusClosureOf (([] : PlusContext) ++ [targetB pB])).card
#time #eval Fintype.card certB.Pos
#time #eval certB.winTimes.card
#time #eval (certB.posAt 0).card
#time #eval certB.verts.card
#time #eval c36Sliced [c36Untl] certB

end Probe716CertB
