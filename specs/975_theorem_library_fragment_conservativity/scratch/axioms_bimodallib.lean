import BimodalLib
open BimodalLib FormalSystem.Syntax FormalSystem.ProofSystem FormalSystem.PlusLanguage
#print axioms conservativeEdge_boolean
#print axioms derivableIn_boolean_of_box
#print axioms derivableIn_boolean_of_temporal
#print axioms conservativeEdge_box
#print axioms derivableIn_box_of_derivableInP
#print axioms not_conservativeEdge_temporal_base
example (fc : FrameClass) : ConservativeEdge {} fc := conservativeEdge_boolean fc
example (fc : FrameClass) (φ : Formula) (hφ : profileF φ ≤ {})
    (h : DerivableIn { box := true } fc φ) : DerivableIn {} fc φ := derivableIn_boolean_of_box fc φ hφ h
example (fc : FrameClass) (φ : Formula) (hφ : profileF φ ≤ {})
    (h : DerivableIn { temporal := true } fc φ) : DerivableIn {} fc φ := derivableIn_boolean_of_temporal fc φ hφ h
example (fc : FrameClass) : ConservativeEdge { box := true } fc := conservativeEdge_box fc
example (fc : FrameClass) (φ : Formula)
    (hφ : profileF φ ≤ { box := true })
    (h : DerivableInP { box := true, stab := true } fc (ofFormula φ)) :
    DerivableIn { box := true } fc φ := derivableIn_box_of_derivableInP fc φ hφ h
example : ¬ ConservativeEdge { temporal := true } FrameClass.Base := not_conservativeEdge_temporal_base
