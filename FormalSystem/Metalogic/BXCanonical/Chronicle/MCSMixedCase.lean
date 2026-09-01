/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.BXCanonical.Chronicle.ChronicleToCountermodelBasic

/-!
# MCS Mixed Case Elimination

The mixed case (¬□(F'T) ∧ ¬□(U(⊤,⊥)) in an MCS) is impossible due to the
structural axiom `discrete_box_necessity`. This fact is used by `completeness_discrete`
in `Completeness.lean`.

Separated from `ChronicleToCountermodel.lean` to decouple the sorry-free mixed-case
elimination from the dead-code sorry chain (`chronicle_gap_contradiction`). That chain has
since been archived to `Boneyard/DeadChronicleGapElimination/ChronicleGapChainExcision.lean`
and no longer exists in live code.
-/

namespace FormalSystem.Metalogic.BXCanonical.Chronicle

open FormalSystem.Syntax
open FormalSystem.ProofSystem
open FormalSystem.Metalogic.Core
open FormalSystem.Metalogic.Bundle
open FormalSystem.Semantics
open FormalSystem.Theorems.Propositional

/--
The mixed case (¬□(F'T) ∧ ¬□(U(⊤,⊥)) in an MCS) is impossible.

From the structural axiom `discrete_box_necessity` (U(T,bot) → □(U(T,bot))):
1. `¬□(U(T,bot)) ∈ A` (h_not_box_discrete)
2. By S5 negative introspection: `□(¬□(U(T,bot))) ∈ A`
3. Contrapositive of the axiom: `¬□(U(T,bot)) → ¬U(T,bot)` is a theorem
4. By necessitation + K-distribution: `□(¬□(U(T,bot))) → □(¬U(T,bot))` is a theorem
5. From steps 2, 4: `□(¬U(T,bot)) ∈ A`, i.e., `□(F'T) ∈ A`
6. But `¬□(F'T) ∈ A` (h_not_box_dense) — contradiction with MCS consistency
-/
theorem mcs_mixed_case_absurd (fc : FrameClass) (A : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := fc) A)
    (h_not_box_dense : (Formula.box nextTop.neg).neg ∈ A)
    (h_not_box_discrete : (Formula.box nextTop).neg ∈ A) : False := by
  have h_axiom : [] ⊢ nextTop.imp (Formula.box nextTop) :=
    DerivationTree.axiom [] _ Axiom.discrete_box_necessity trivial
  have h_contra : [] ⊢ (Formula.box nextTop).neg.imp nextTop.neg :=
    FormalSystem.Theorems.Propositional.contraposition h_axiom
  have h_nec : [] ⊢ Formula.box ((Formula.box nextTop).neg.imp nextTop.neg) :=
    DerivationTree.necessitation _ h_contra
  have h_k_dist : [] ⊢ (Formula.box ((Formula.box nextTop).neg.imp nextTop.neg)).imp
      ((Formula.box (Formula.box nextTop).neg).imp (Formula.box nextTop.neg)) :=
    DerivationTree.axiom [] _ (Axiom.modal_k_dist (Formula.box nextTop).neg nextTop.neg) trivial
  have h_box_chain : [] ⊢ (Formula.box (Formula.box nextTop).neg).imp (Formula.box nextTop.neg) :=
    DerivationTree.modus_ponens [] _ _ h_k_dist h_nec
  have h_box_neg_box : Formula.box (Formula.box nextTop).neg ∈ A :=
    SetMaximalConsistent.neg_box_implies_box_neg_box h_mcs nextTop h_not_box_discrete
  have h_box_dense : Formula.box nextTop.neg ∈ A :=
    SetMaximalConsistent.implication_property h_mcs
      (theorem_in_mcs h_mcs (liftBase fc h_box_chain)) h_box_neg_box
  exact set_consistent_not_both h_mcs.1 (Formula.box nextTop.neg) h_box_dense h_not_box_dense

/--
Mixed-case countermodel: proved vacuously via `False.elim` since the mixed case
is impossible (every MCS has either □(F'T) or □(U(T,bot))).
-/
theorem countermodelChronicleMixed (fc : FrameClass) (A : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := fc) A)
    (φ : Formula) (_h_neg_in : φ.neg ∈ A)
    (h_not_box_dense : (Formula.box nextTop.neg).neg ∈ A)
    (h_not_box_discrete : (Formula.box nextTop).neg ∈ A) :
    ∃ (F : TaskFrame) (TM : TaskModel F)
      (τ : WorldHistory F) (_ : τ.IsTotal) (t : ↑F.Duration),
      ¬TruthAt TM τ t φ := by
  exact False.elim (mcs_mixed_case_absurd fc A h_mcs h_not_box_dense h_not_box_discrete)

end FormalSystem.Metalogic.BXCanonical.Chronicle
