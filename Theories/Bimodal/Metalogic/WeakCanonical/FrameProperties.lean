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

/-- Z1 axiom instance (for a given psi) is in every MCS of the discrete system.
BLOCKED(task 168): z1 has minFrameClass = .Discrete, but ReflCanDomain uses fc := .Base.
The correct fix is to parameterize ReflCanDomain (and the underlying WeakCanonical
model construction) over fc, then instantiate with .Discrete for discrete completeness.
This requires a cascade through the entire WeakCanonical pipeline. -/
theorem z1_in_frame {fc : FrameClass} (h_fc : FrameClass.Discrete ≤ fc) (x : ReflCanDomain fc) (psi : Formula) :
    Formula.imp (Formula.all_future (Formula.imp (Formula.all_future psi) psi))
      (Formula.imp (Formula.some_future (Formula.all_future psi)) (Formula.all_future psi)) ∈ x.val :=
  theorem_in_mcs x.property (DerivationTree.axiom [] _ (Axiom.z1 psi) h_fc)

/-! ## Prior-UZ/SZ in the Canonical Frame -/

/-- Prior-UZ: F(psi) → U(psi, ¬psi) is in every MCS.
BLOCKED(task 168): Same issue — prior_UZ has minFrameClass = .Discrete but
ReflCanDomain uses fc := .Base. -/
theorem prior_UZ_in_frame {fc : FrameClass} (h_fc : FrameClass.Discrete ≤ fc) (x : ReflCanDomain fc) (psi : Formula) :
    Formula.imp (Formula.some_future psi) (Formula.untl psi psi.neg) ∈ x.val :=
  theorem_in_mcs x.property (DerivationTree.axiom [] _ (Axiom.prior_UZ psi) h_fc)

/-- Prior-SZ: P(psi) → S(psi, ¬psi) is in every MCS.
BLOCKED(task 168): Same issue — prior_SZ has minFrameClass = .Discrete but
ReflCanDomain uses fc := .Base. -/
theorem prior_SZ_in_frame {fc : FrameClass} (h_fc : FrameClass.Discrete ≤ fc) (x : ReflCanDomain fc) (psi : Formula) :
    Formula.imp (Formula.some_past psi) (Formula.snce psi psi.neg) ∈ x.val :=
  theorem_in_mcs x.property (DerivationTree.axiom [] _ (Axiom.prior_SZ psi) h_fc)

/-! ## Seriality (No Endpoints) -/

/-- BX1 serial_future: ⊤ → F(⊤) is a theorem. -/
theorem serial_future_in_frame (x : ReflCanDomain) :
    Formula.imp (Formula.bot.imp Formula.bot) (Formula.some_future (Formula.bot.imp Formula.bot)) ∈ x.val :=
  theorem_in_mcs x.property (DerivationTree.axiom [] _ Axiom.serial_future trivial)

/-- BX1' serial_past: ⊤ → P(⊤) is a theorem. -/
theorem serial_past_in_frame (x : ReflCanDomain) :
    Formula.imp (Formula.bot.imp Formula.bot) (Formula.some_past (Formula.bot.imp Formula.bot)) ∈ x.val :=
  theorem_in_mcs x.property (DerivationTree.axiom [] _ Axiom.serial_past trivial)

end Bimodal.Metalogic.WeakCanonical
