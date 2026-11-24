import FormalSystem

open FormalSystem.Syntax FormalSystem.ProofSystem FormalSystem.Semantics
open FormalSystem.PlusLanguage FormalSystem.Metalogic.Decidability

namespace BimodalLib

/-- The premise-bearing consequence relation over `PointTruth`. -/
def GenericConsequenceIn {L : Type} [PointTruth L]
    (fc : FrameClass) (Γ : List L) (φ : L) : Prop := sorry

theorem genericConsequenceIn_nil {L : Type} [PointTruth L] (fc : FrameClass) (φ : L) :
    GenericConsequenceIn fc ([] : List L) φ ↔ GenericValidIn fc φ := sorry

theorem not_genericConsequenceIn_of_le {L : Type} [PointTruth L] {fc₁ fc₂ : FrameClass}
    (h : fc₁ ≤ fc₂) {Γ : List L} {φ : L}
    (hr : ¬ GenericConsequenceIn fc₂ Γ φ) : ¬ GenericConsequenceIn fc₁ Γ φ := sorry

theorem not_genericConsequenceIn_ofFormula {fc : FrameClass} {Γ : List Formula} {φ : Formula}
    (hr : ¬ GenericConsequenceIn fc Γ φ) :
    ¬ GenericConsequenceIn fc (Γ.map ofFormula) (ofFormula φ) := sorry

def gatesOK (φ : Formula) (fc : FrameClass) (b : Branch) (ord : TimeOrdering) : Bool := sorry

theorem not_genericConsequenceIn_of_gatesOK {φ : Formula} {fc : FrameClass}
    {b : Branch} {ord : TimeOrdering} (h : gatesOK φ fc b ord = true) :
    ¬ GenericConsequenceIn FrameClass.Base ([] : List Formula) φ := sorry

