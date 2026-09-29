import FormalSystem

/-!
Probe (research round 2): the target `phi1 = □⟐Xp → (□⟐X¬p → ⊥)` that no hop-free family
certifies (see `HopFreeIncomplete.lean`) **is** certified by a four-lasso family with free
succession. So the obstruction in that probe is index-identity succession, not the certificate
class.

Five of the six conditions, (C0), (C1'), (C3), (C4) and (C5), are accepted by running the
landed `Decidable` instances (`#guard`), the same style of check
`PlusWitnessFamily/Examples.lean` makes. That is evidence by computation, not a kernel-checked
proof term. The sixth, (C2'), is proved from (C1') as `fam_fulfilling`, because the landed
fixpoint procedure for it is too slow to run inside a probe.
-/

open FormalSystem FormalSystem.PlusLanguage FormalSystem.Syntax
open FormalSystem.Metalogic.Decidability

namespace Probe703Hop

def pa : Atom := Atom.mkBase "p"
def p : PlusFormula := .atom pa
def np : PlusFormula := .imp p .bot
def Xp : PlusFormula := .untl .bot p
def Xnp : PlusFormula := .untl .bot np
def dXp : PlusFormula := .imp (.stab (.imp Xp .bot)) .bot
def dXnp : PlusFormula := .imp (.stab (.imp Xnp .bot)) .bot
def th1 : PlusFormula := .box dXp
def th2 : PlusFormula := .box dXnp
def phi1 : PlusFormula := .imp th1 (.imp th2 .bot)

abbrev Cl : Finset PlusFormula := plusClosureOf (([] : PlusContext) ++ [phi1])

/-- The value of an event one step ahead, given whether `p` holds there. -/
def valNext (pNext : Bool) : PlusFormula → Bool
  | .atom _ => pNext
  | .imp a b => !valNext pNext a || valNext pNext b
  | _ => false

/-- The intended truth value at a position where `p` is `pNow` and is `pNext` one step on. -/
def val (pNow pNext : Bool) : PlusFormula → Bool
  | .atom _ => pNow
  | .bot => false
  | .imp a b => !val pNow pNext a || val pNow pNext b
  | .box _ => true
  | .stab _ => false
  | .untl _ e => valNext pNext e
  | .snce _ _ => false

def lbl (pNow pNext : Bool) : Finset PlusFormula := Cl.filter (fun ψ => val pNow pNext ψ = true)

/-- A lasso of period two in both directions. -/
def row (e o : Finset PlusFormula) (he : e ⊆ Cl) (ho : o ⊆ Cl) : PlusLabelledLasso Cl where
  back := [e, o]
  mid := []
  fwd := [e, o]
  back_ne := by simp
  fwd_ne := by simp
  label_sub := by
    intro X hX
    simp only [List.append_nil, List.cons_append, List.nil_append, List.mem_cons,
      List.not_mem_nil, or_false] at hX
    rcases hX with rfl | rfl | rfl | rfl <;> assumption

/-- A lasso of period one in both directions. -/
def crow (e : Finset PlusFormula) (he : e ⊆ Cl) : PlusLabelledLasso Cl where
  back := [e]
  mid := []
  fwd := [e]
  back_ne := by simp
  fwd_ne := by simp
  label_sub := by
    intro X hX
    simp only [List.append_nil, List.cons_append, List.nil_append, List.mem_cons,
      List.not_mem_nil, or_false] at hX
    rcases hX with rfl | rfl <;> assumption

def rowC : PlusLabelledLasso Cl := crow (lbl true true) (Finset.filter_subset _ _)
def rowD : PlusLabelledLasso Cl := crow (lbl false false) (Finset.filter_subset _ _)
def rowA : PlusLabelledLasso Cl :=
  row (lbl true false) (lbl false true) (Finset.filter_subset _ _) (Finset.filter_subset _ _)
def rowB : PlusLabelledLasso Cl :=
  row (lbl false true) (lbl true false) (Finset.filter_subset _ _) (Finset.filter_subset _ _)

/-- Even times: `{C, A}` hold `p`, `{D, B}` do not. -/
def repE : Fin 4 → Fin 4 := fun i => if i.val = 0 ∨ i.val = 2 then 0 else 1
/-- Odd times: `{C, B}` hold `p`, `{D, A}` do not. -/
def repO : Fin 4 → Fin 4 := fun i => if i.val = 0 ∨ i.val = 3 then 0 else 1

def fam : PlusSharingWitnessFamily ([] : PlusContext) [phi1] where
  bx := fun _ => true
  lassos := [rowC, rowD, rowA, rowB]
  lassos_ne := by simp
  repBack := [repE, repO]
  repMid := []
  repFwd := [repE, repO]
  repBack_ne := by simp
  repFwd_ne := by simp
  rep_idem := by
    intro f hf i
    simp only [List.append_nil, List.cons_append, List.nil_append, List.mem_cons,
      List.not_mem_nil, or_false] at hf
    rcases hf with rfl | rfl | rfl | rfl <;> fin_cases i <;> rfl
  transBack := transFullOf _ [repE, repO]
  transMid := transFullOf _ []
  transFwd := transFullOf _ [repE, repO]
  transBack_len := transFullOf_length _ _
  transMid_len := transFullOf_length _ _
  transFwd_len := transFullOf_length _ _
  trans_refl := transFullOf_refl _ _ _ _
  lift := liftable_of_transFullOf _ _ _ _ (by simp) (by simp)

/-! ## Five of the six conditions, accepted by running the landed decision procedures -/

set_option linter.hashCommand false in
#guard @Decidable.decide _ (PlusSharingWitnessFamily.decidablePlusAtomCoherent fam)
set_option linter.hashCommand false in
#guard @Decidable.decide _ (PlusSharingWitnessFamily.decidablePlusLocalCoherentShare fam)
set_option linter.hashCommand false in
#guard @Decidable.decide _ (PlusWitnessFamily.decidablePlusBoxFaithful fam.toPlusWitnessFamily)
set_option linter.hashCommand false in
#guard @Decidable.decide _ (PlusWitnessFamily.decidablePlusTarget fam.toPlusWitnessFamily 0)
set_option linter.hashCommand false in
#guard @Decidable.decide _ (PlusSharingWitnessFamily.decidableStabFaithful fam)

/-! ## The sixth, (C2'), proved rather than run

The landed fixpoint procedure for (C2') is too slow to run on this family inside a probe. The
condition follows from (C1') here because every `untl` of the closure has guard `⊥` and the
closure has no `snce`: a one-step eventuality is discharged by the very next thread step. -/

/-- Shape check on one closure member. -/
def shapeOK : PlusFormula → Bool
  | .untl g _ => decide (g = .bot)
  | .snce _ _ => false
  | _ => true

theorem closure_shape : ∀ ψ ∈ Cl, shapeOK ψ = true := by decide

theorem fam_fulfilling (h : fam.PlusLocalCoherentShare) : fam.PlusThreadFulfilling := by
  refine ⟨fun i u g e hmem θ hθ => ?_, fun i u g e hmem θ hθ => ?_⟩
  · have hcl : PlusFormula.untl g e ∈ Cl := fam.subset_plusClosureOf i u hmem
    have hg : g = .bot := by
      have := closure_shape _ hcl
      simpa [shapeOK] using this
    subst hg
    have hstep : fam.trans u i (θ.idx (u + 1)) := by
      have := PlusSharingWitnessFamily.Thread.step θ u
      rwa [hθ] at this
    rcases ((h i u).2.2.2.1 _ hstep .bot e hcl).mp hmem with he | ⟨hb, -⟩
    · exact ⟨u + 1, by omega, he, fun r h1 h2 => by omega⟩
    · exact absurd hb (h _ _).1
  · have hcl : PlusFormula.snce g e ∈ Cl := fam.subset_plusClosureOf i u hmem
    have := closure_shape _ hcl
    simp [shapeOK] at this

#print axioms fam_fulfilling

end Probe703Hop
