/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Syntax.MinusLanguage.Derivation
import FormalSystem.Syntax.PlusLanguage.Derivation
import FormalSystem.Syntax.StarLanguage.Derivation

/-!
# Language Derivation Tests

Worked derivations in the three extended proof systems TM⁻, TM⁺ and TM⋆: each checks that an axiom
instance, a lift between frame classes or a rule application elaborates as stated.
-/

namespace BimodalTest.Syntax.LanguageDerivationTest

/-! ## TM⁻ (`Syntax/MinusLanguage/Derivation.lean`) -/

section MinusLanguage

open FormalSystem.MinusLanguage
open FormalSystem.ProofSystem (FrameClass)

/-- Identity is a TM⁻ theorem, by the propositional basis alone. -/
example (φ : MinusFormula) : ⊢⁻[FrameClass.Base] φ.imp φ :=
  let k : ⊢⁻[FrameClass.Base]
      ((φ.imp ((φ.imp φ).imp φ)).imp ((φ.imp (φ.imp φ)).imp (φ.imp φ))) :=
    .axiom [] _ (Axiom.prop_k φ (φ.imp φ) φ) (FrameClass.base_le _)
  let s1 : ⊢⁻[FrameClass.Base] (φ.imp ((φ.imp φ).imp φ)) :=
    .axiom [] _ (Axiom.prop_s φ (φ.imp φ)) (FrameClass.base_le _)
  let s2 : ⊢⁻[FrameClass.Base] (φ.imp (φ.imp φ)) :=
    .axiom [] _ (Axiom.prop_s φ φ) (FrameClass.base_le _)
  .modus_ponens [] _ _ (.modus_ponens [] _ _ k s1) s2

/-- `DF` is available at `.ZTime` and its `minFrameClass` side condition discharges by
`decide` once the frame class is concrete. -/
example (φ : MinusFormula) :
    ⊢⁻[FrameClass.ZTime]
      (((φ.allPast.and φ).and MinusFormula.top.someFuture).imp φ.allPast.someFuture) :=
  .axiom [] _ (Axiom.df φ) (show FrameClass.ZTime ≤ FrameClass.ZTime by decide)

/-- Lifting a `Base` theorem into `TM⁻_z`. -/
example (φ : MinusFormula) : ⊢⁻[FrameClass.ZTime] φ.box.imp φ :=
  DerivationTree.lift (fc₁ := FrameClass.Base) (by decide)
    (.axiom [] _ (Axiom.modal_t φ) (FrameClass.base_le _))

end MinusLanguage

/-! ## TM⁺ (`Syntax/PlusLanguage/Derivation.lean`) -/

section PlusLanguage

open FormalSystem.Syntax
open FormalSystem.PlusLanguage
open FormalSystem.ProofSystem (FrameClass)

/-- MF at a `⊡`-formula is an axiom instance of TM⁺ — the instance `ofTM` alone could not
supply. -/
example (p : Atom) :
    ⊢⁺[FrameClass.Base] (PlusFormula.box (PlusFormula.stab (PlusFormula.atom p))).imp
      (PlusFormula.box (PlusFormula.allFuture (PlusFormula.stab (PlusFormula.atom p)))) :=
  .axiom [] _ (PlusAxiom.modal_future _) (FrameClass.base_le _)

/-- The `⊡` T-axiom is a theorem at every class. -/
example (fc : FrameClass) (φ : PlusFormula) : ⊢⁺[fc] (PlusFormula.stab φ).imp φ :=
  .axiom [] _ (PlusAxiom.stab_t φ) (FrameClass.base_le fc)

end PlusLanguage

/-! ## TM⋆ (`Syntax/StarLanguage/Derivation.lean`) -/

section StarLanguage

open FormalSystem.Syntax
open FormalSystem.StarLanguage
open FormalSystem.PlusLanguage
open FormalSystem.ProofSystem (FrameClass)

/-- A register schema is a theorem at every class: `↑ⁱ□φ ↔ □↑ⁱφ`. -/
example (fc : FrameClass) (i : ℕ) (φ : StarFormula) :
    ⊢⋆[fc] (StarFormula.timeStore i (.box φ)).iff (StarFormula.box (.timeStore i φ)) :=
  .axiom [] _ (StarAxiom.store_box i φ) (FrameClass.base_le fc)

/-- MF reaches TM⋆ at every `↓ⁱ`-free formula, not only at embedded ones. The witness is
`□↑¹p → □G↑¹p`: `↑¹p` is `RecallFree` and, by `ofPlus_ne_timeStore`, is **not** an `ofPlus`
image, so this instance is outside the reach of any embedding-only route. -/
example (fc : FrameClass) (p : Atom) :
    ⊢⋆[fc] (StarFormula.box (StarFormula.timeStore 1 (.atom p))).imp
      (StarFormula.box (StarFormula.allFuture (StarFormula.timeStore 1 (.atom p)))) :=
  .axiom [] _ (StarAxiom.modal_future _ (RecallFree.timeStore 1 (RecallFree.atom p)))
    (FrameClass.base_le fc)

/-- Temporal duality applies to a register formula: the dual of forward rigidity is backward
rigidity, and it is reached by the rule rather than by a second axiom. -/
example (fc : FrameClass) (i : ℕ) (φ : StarFormula) :
    ⊢⋆[fc] ((StarFormula.timeRecall i φ).imp
      (StarFormula.allFuture (.timeRecall i φ))).swapTemporal :=
  .temporal_duality _ (.axiom [] _ (StarAxiom.recall_rigid_future i φ) (FrameClass.base_le fc))

end StarLanguage

end BimodalTest.Syntax.LanguageDerivationTest
