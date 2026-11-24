import BimodalLib.Conservativity

namespace BimodalLib

open FormalSystem.Syntax FormalSystem.ProofSystem FormalSystem.PlusLanguage

theorem conservativeEdge_boolean (fc : FrameClass) : ConservativeEdge {} fc := sorry


theorem derivableIn_boolean_of_box (fc : FrameClass) (φ : Formula) (hφ : profileF φ ≤ {})
    (h : DerivableIn { box := true } fc φ) : DerivableIn {} fc φ := sorry


theorem derivableIn_boolean_of_temporal (fc : FrameClass) (φ : Formula) (hφ : profileF φ ≤ {})
    (h : DerivableIn { temporal := true } fc φ) : DerivableIn {} fc φ := sorry


theorem conservativeEdge_box (fc : FrameClass) : ConservativeEdge { box := true } fc := sorry


theorem derivableIn_box_of_derivableInP (fc : FrameClass) (φ : Formula)
    (hφ : profileF φ ≤ { box := true })
    (h : DerivableInP { box := true, stab := true } fc (ofFormula φ)) :
    DerivableIn { box := true } fc φ := sorry


theorem not_conservativeEdge_temporal_base :
    ¬ ConservativeEdge { temporal := true } FrameClass.Base := sorry

