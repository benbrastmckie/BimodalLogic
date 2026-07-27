/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.WeakCanonical.TruthLemma

/-!
# Frame Properties for the Reflexive Canonical Model

Proves key frame properties that hold in the canonical model.
All proofs rely on `theorem_in_mcs` — axiom instances are theorems, hence in every MCS.
-/
namespace FormalSystem.Metalogic.WeakCanonical

open FormalSystem.Syntax
open FormalSystem.ProofSystem
open FormalSystem.Metalogic.Core

/-! ## Z1 in the Canonical Frame -/

/-- Z1 axiom instance (for a given psi) is in every MCS of the discrete system.
BLOCKED: z1 has minFrameClass = .Discrete, but ReflCanDomain uses fc := .Base.
The correct fix is to parameterize ReflCanDomain (and the underlying WeakCanonical
model construction) over fc, then instantiate with .Discrete for discrete completeness.
This requires a cascade through the entire WeakCanonical pipeline. -/
theorem z1_in_frame {fc : FrameClass} (h_fc : FrameClass.Discrete ≤ fc) (x : ReflCanDomain fc)
    (psi : Formula) :
    Formula.imp (Formula.allFuture (Formula.imp (Formula.allFuture psi) psi))
      (Formula.imp (Formula.someFuture (Formula.allFuture psi)) (Formula.allFuture psi)) ∈
          x.val :=
  theorem_in_mcs x.property (DerivationTree.axiom [] _ (Axiom.z1 psi) h_fc)

/-! ## Prior-UZ/SZ in the Canonical Frame -/

/-- Prior-UZ: F(psi) → U(psi, ¬psi) is in every MCS.
BLOCKED: Same issue — prior_UZ has minFrameClass = .Discrete but
ReflCanDomain uses fc := .Base. -/
theorem prior_UZ_in_frame {fc : FrameClass} (h_fc : FrameClass.Discrete ≤ fc)
    (x : ReflCanDomain fc) (psi : Formula) :
    Formula.imp (Formula.someFuture psi) (Formula.untl psi psi.neg) ∈ x.val :=
  theorem_in_mcs x.property (DerivationTree.axiom [] _ (Axiom.prior_UZ psi) h_fc)

/-- Prior-SZ: P(psi) → S(psi, ¬psi) is in every MCS.
BLOCKED: Same issue — prior_SZ has minFrameClass = .Discrete but
ReflCanDomain uses fc := .Base. -/
theorem prior_SZ_in_frame {fc : FrameClass} (h_fc : FrameClass.Discrete ≤ fc)
    (x : ReflCanDomain fc) (psi : Formula) :
    Formula.imp (Formula.somePast psi) (Formula.snce psi psi.neg) ∈ x.val :=
  theorem_in_mcs x.property (DerivationTree.axiom [] _ (Axiom.prior_SZ psi) h_fc)

/-! ## Seriality (No Endpoints) -/

/-- BX1 serial_future: ⊤ → F(⊤) is a theorem. -/
theorem serial_future_in_frame (x : ReflCanDomain) :
    Formula.imp (Formula.bot.imp Formula.bot) (Formula.someFuture (Formula.bot.imp Formula.bot)) ∈
        x.val :=
  theorem_in_mcs x.property (DerivationTree.axiom [] _ Axiom.serial_future trivial)

/-- BX1' serial_past: ⊤ → P(⊤) is a theorem. -/
theorem serial_past_in_frame (x : ReflCanDomain) :
    Formula.imp (Formula.bot.imp Formula.bot) (Formula.somePast (Formula.bot.imp Formula.bot)) ∈
        x.val :=
  theorem_in_mcs x.property (DerivationTree.axiom [] _ Axiom.serial_past trivial)

end FormalSystem.Metalogic.WeakCanonical
