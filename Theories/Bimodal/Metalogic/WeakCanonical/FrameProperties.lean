import Bimodal.Metalogic.WeakCanonical.TruthLemma

/-!
# Frame Properties for the Reflexive Canonical Model

Proves key frame properties that hold in the canonical model.
All proofs rely on `theorem_in_mcs` — axiom instances are theorems, hence in every MCS.
-/
namespace Bimodal.Metalogic.WeakCanonical

open Bimodal.Syntax
open Bimodal.ProofSystem
open Bimodal.Metalogic.Core

/-! ## Z1 in the Canonical Frame -/

/-- Z1 axiom instance (for a given psi) is a theorem, hence in every MCS. -/
theorem z1_in_frame (x : ReflCanDomain) (psi : Formula) :
    Formula.imp (Formula.all_future (Formula.imp (Formula.all_future psi) psi))
      (Formula.imp (Formula.some_future (Formula.all_future psi)) (Formula.all_future psi)) ∈ x.val :=
  theorem_in_mcs x.property (DerivationTree.axiom [] _ (Axiom.z1 psi))

/-! ## Prior-UZ/SZ in the Canonical Frame -/

/-- Prior-UZ: F(psi) → U(psi, ¬psi) is a theorem. -/
theorem prior_UZ_in_frame (x : ReflCanDomain) (psi : Formula) :
    Formula.imp (Formula.some_future psi) (Formula.untl psi psi.neg) ∈ x.val :=
  theorem_in_mcs x.property (DerivationTree.axiom [] _ (Axiom.prior_UZ psi))

/-- Prior-SZ: P(psi) → S(psi, ¬psi) is a theorem. -/
theorem prior_SZ_in_frame (x : ReflCanDomain) (psi : Formula) :
    Formula.imp (Formula.some_past psi) (Formula.snce psi psi.neg) ∈ x.val :=
  theorem_in_mcs x.property (DerivationTree.axiom [] _ (Axiom.prior_SZ psi))

/-! ## Seriality (No Endpoints) -/

/-- BX1 serial_future: ⊤ → F(⊤) is a theorem. -/
theorem serial_future_in_frame (x : ReflCanDomain) :
    Formula.imp (Formula.bot.imp Formula.bot) (Formula.some_future (Formula.bot.imp Formula.bot)) ∈ x.val :=
  theorem_in_mcs x.property (DerivationTree.axiom [] _ Axiom.serial_future)

/-- BX1' serial_past: ⊤ → P(⊤) is a theorem. -/
theorem serial_past_in_frame (x : ReflCanDomain) :
    Formula.imp (Formula.bot.imp Formula.bot) (Formula.some_past (Formula.bot.imp Formula.bot)) ∈ x.val :=
  theorem_in_mcs x.property (DerivationTree.axiom [] _ Axiom.serial_past)

end Bimodal.Metalogic.WeakCanonical
