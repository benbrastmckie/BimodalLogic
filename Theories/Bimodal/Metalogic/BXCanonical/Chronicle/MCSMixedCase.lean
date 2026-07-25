/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import Bimodal.Metalogic.BXCanonical.Chronicle.ChronicleToCountermodelBasic

/-!
# MCS Mixed Case Elimination

The mixed case (¬□(F'T) ∧ ¬□(U(⊤,⊥)) in an MCS) is impossible due to the
structural axiom `discrete_box_necessity`. This fact is used by `completeness_discrete`
in `Completeness.lean`.

Separated from `ChronicleToCountermodel.lean` to decouple the sorry-free mixed-case
elimination from the dead-code sorry chain (`chronicle_gap_contradiction`).
-/

namespace Bimodal.Metalogic.BXCanonical.Chronicle

open Bimodal.Syntax
open Bimodal.ProofSystem
open Bimodal.Metalogic.Core
open Bimodal.Metalogic.Bundle
open Bimodal.Semantics
open Bimodal.Theorems.Propositional

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
theorem mcs_mixed_case_absurd (fc : FrameClass) (A : Set Formula) (h_mcs : SetMaximalConsistent (fc := fc) A)
    (h_not_box_dense : (Formula.box next_top.neg).neg ∈ A)
    (h_not_box_discrete : (Formula.box next_top).neg ∈ A) : False := by
  have h_axiom : [] ⊢ next_top.imp (Formula.box next_top) :=
    DerivationTree.axiom [] _ Axiom.discrete_box_necessity trivial
  have h_contra : [] ⊢ (Formula.box next_top).neg.imp next_top.neg :=
    Bimodal.Theorems.Propositional.contraposition h_axiom
  have h_nec : [] ⊢ Formula.box ((Formula.box next_top).neg.imp next_top.neg) :=
    DerivationTree.necessitation _ h_contra
  have h_k_dist : [] ⊢ (Formula.box ((Formula.box next_top).neg.imp next_top.neg)).imp
      ((Formula.box (Formula.box next_top).neg).imp (Formula.box next_top.neg)) :=
    DerivationTree.axiom [] _ (Axiom.modal_k_dist (Formula.box next_top).neg next_top.neg) trivial
  have h_box_chain : [] ⊢ (Formula.box (Formula.box next_top).neg).imp (Formula.box next_top.neg) :=
    DerivationTree.modus_ponens [] _ _ h_k_dist h_nec
  have h_box_neg_box : Formula.box (Formula.box next_top).neg ∈ A :=
    SetMaximalConsistent.neg_box_implies_box_neg_box h_mcs next_top h_not_box_discrete
  have h_box_dense : Formula.box next_top.neg ∈ A :=
    SetMaximalConsistent.implication_property h_mcs
      (theorem_in_mcs h_mcs (liftBase fc h_box_chain)) h_box_neg_box
  exact set_consistent_not_both h_mcs.1 (Formula.box next_top.neg) h_box_dense h_not_box_dense

/--
Mixed-case countermodel: proved vacuously via `False.elim` since the mixed case
is impossible (every MCS has either □(F'T) or □(U(T,bot))).
-/
theorem dd_countermodel_chronicle_mixed_sorry (fc : FrameClass) (A : Set Formula) (h_mcs : SetMaximalConsistent (fc := fc) A)
    (φ : Formula) (_h_neg_in : φ.neg ∈ A)
    (h_not_box_dense : (Formula.box next_top.neg).neg ∈ A)
    (h_not_box_discrete : (Formula.box next_top).neg ∈ A) :
    ∃ (D : Type) (_ : AddCommGroup D) (_ : LinearOrder D) (_ : IsOrderedAddMonoid D)
      (_ : Nontrivial D) (F : TaskFrame D) (TM : TaskModel F)
      (Omega : Set (WorldHistory F)) (_ : ShiftClosed Omega)
      (τ : WorldHistory F) (_ : τ ∈ Omega) (t : D),
      ¬truth_at TM Omega τ t φ := by
  exact False.elim (mcs_mixed_case_absurd fc A h_mcs h_not_box_dense h_not_box_discrete)

end Bimodal.Metalogic.BXCanonical.Chronicle
