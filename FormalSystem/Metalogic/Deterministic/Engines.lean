/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Deterministic.Validity
import FormalSystem.Metalogic.BXCanonical.Completeness
import FormalSystem.Metalogic.BXCanonical.CompletenessDedekind

/-!
# The completeness engines with the validity hypothesis narrowed to the deterministic frames

The four TM completeness engines — `completeness`, `derivable_of_validDense`,
`derivable_of_validZTime` and `completeness_rtime_engine` — restated with `ValidIn fc` replaced by
`ValidDetIn fc` (`Metalogic/Deterministic/Validity.lean`), i.e. with validity demanded only over
the **deterministic** frames of the class.

## Why this is free

Each engine's proof ends in a single application of the validity hypothesis to a *concrete*
constructed countermodel frame, and every one of those frames is deterministic: they are all
specializations of `Algebraic.multiFamTaskFrameGen`, whose determinism is
`multiFamTaskFrameGen_deterministic`. The four countermodel producers expose that fact as an
extra existential component, so the narrowed hypothesis applies at exactly
the same point the unnarrowed one did, and each proof below is the parent engine's script with
that one component fed in.

## What the narrowing does and does not say

It says: *the engines' own countermodels are deterministic*, so a formula that survives every
deterministic countermodel is already derivable. It does **not** say that TM is complete over
some new class — the conclusion is the same `Derivable fc [] φ` as before, and the class tag `fc`
is unchanged. `ValidDetIn fc` is a strictly weaker hypothesis than `ValidIn fc`
(`ValidIn.toDet`), so each theorem here is strictly stronger than its parent, and the parent is
recovered by composing with `ValidIn.toDet`.

## Main Results

- `derivable_of_validDetBase`, `derivable_of_validDetDense`, `derivable_of_validDetZTime`,
  `derivable_of_validDetRTime`

## References

* `FormalSystem/Metalogic/BXCanonical/Completeness.lean` — the parent engines at `.Base`,
  `.Dense`, `.ZTime`
* `FormalSystem/Metalogic/BXCanonical/CompletenessDedekind.lean` — the parent engine at `.RTime`

## Tags

completeness · determinism · frame-class · cor:tm-completeness
-/

namespace FormalSystem.Metalogic.Deterministic

open FormalSystem.Syntax
open FormalSystem.ProofSystem
open FormalSystem.Semantics
open FormalSystem.Metalogic.Core
open FormalSystem.Metalogic.BXCanonical

/--
**Completeness at `.Base` from deterministic validity.** A formula valid on every *deterministic*
task frame is a TM theorem at `.Base`.

The script is `completeness`'s: contrapositive, Lindenbaum, the three-way split on the MCS's
temporal character. Both surviving branches now feed the countermodel frame's determinism
component into the narrowed hypothesis.
-/
theorem derivable_of_validDetBase (φ : Formula) (h_valid : ValidDetIn FrameClass.Base φ) :
    Derivable FrameClass.Base [] φ := by
  by_contra h_not_deriv
  have h_cons := neg_consistent_of_not_derivable (fc := FrameClass.Base) φ h_not_deriv
  obtain ⟨M, hM_sup, hM_mcs⟩ := set_lindenbaum {Formula.neg φ} h_cons
  have h_neg_in : Formula.neg φ ∈ M := hM_sup (Set.mem_singleton _)
  rcases SetMaximalConsistent.negation_complete hM_mcs
    (Formula.box Chronicle.nextTop.neg) with h_box_dense | h_not_box_dense
  · obtain ⟨F, hdet, TM, τ, t, h_not_true⟩ :=
      countermodel_dense_enriched M hM_mcs φ h_neg_in h_box_dense
    exact h_not_true (ValidDetIn.apply h_valid F.toTaskFrame trivial hdet TM τ t)
  · rcases SetMaximalConsistent.negation_complete hM_mcs
      (Formula.box Chronicle.nextTop) with h_box_discrete | h_not_box_discrete
    · obtain ⟨F, hdet, TM, τ, t, h_not_true⟩ :=
        WeakCanonical.countermodel_discrete M hM_mcs φ h_neg_in h_box_discrete
      exact h_not_true (ValidDetIn.apply h_valid F trivial hdet TM τ t)
    · exact False.elim (Chronicle.mcs_mixed_case_absurd FrameClass.Base M hM_mcs
        h_not_box_dense h_not_box_discrete)

/--
**Completeness at `.Dense` from deterministic validity.** `derivable_of_validDense`'s script; the
countermodel is the bundle flow frame on `ℚ`, which is dense and deterministic.
-/
theorem derivable_of_validDetDense (φ : Formula) (h_valid : ValidDetIn FrameClass.Dense φ) :
    Derivable FrameClass.Dense [] φ := by
  by_contra h_not_deriv
  have h_cons := neg_consistent_of_not_derivable (fc := FrameClass.Dense) φ h_not_deriv
  obtain ⟨M, hM_sup, hM_mcs⟩ := set_lindenbaum {Formula.neg φ} h_cons
  have h_neg_in : Formula.neg φ ∈ M := hM_sup (Set.mem_singleton _)
  rcases SetMaximalConsistent.negation_complete hM_mcs
    (Formula.box Chronicle.nextTop.neg) with h_box_dense | h_not_box_dense
  · obtain ⟨F, hdet, TM, τ, t, h_not_true⟩ :=
      countermodel_dense_enriched M hM_mcs φ h_neg_in h_box_dense
    exact h_not_true
      (ValidDetIn.apply h_valid F.toTaskFrame inferInstance hdet TM τ t)
  · have h_ax : DerivationTree FrameClass.Dense [] Chronicle.nextTop.neg :=
      DerivationTree.axiom [] _ Axiom.dense_indicator (by trivial)
    have h_box : DerivationTree FrameClass.Dense [] Chronicle.nextTop.neg.box :=
      DerivationTree.necessitation _ h_ax
    have h_in : Chronicle.nextTop.neg.box ∈ M := theorem_in_mcs hM_mcs h_box
    exact set_consistent_not_both hM_mcs.1 (Chronicle.nextTop.neg.box) h_in h_not_box_dense

/--
**Completeness at `.ZTime` from deterministic validity.** `derivable_of_validZTime`'s script; the
countermodel is `multiFamTaskFrame` over `ℤ`, whose task relation is the deterministic clock.

The four carrier side conditions (`SuccOrder`, `PredOrder`, and the two Archimedean instances)
are passed positionally inside the anonymous constructor, for the reason recorded on the parent:
`IsSuccArchimedean` is indexed by its `SuccOrder` argument, so a `haveI`-introduced copy is a
fresh fvar the second hypothesis's type does not mention.
-/
theorem derivable_of_validDetZTime (φ : Formula) (h_valid : ValidDetIn FrameClass.ZTime φ) :
    Derivable FrameClass.ZTime [] φ := by
  by_contra h_not_deriv
  have h_cons := neg_consistent_of_not_derivable (fc := FrameClass.ZTime) φ h_not_deriv
  obtain ⟨M, hM_sup, hM_mcs⟩ := set_lindenbaum {Formula.neg φ} h_cons
  have h_neg_in : Formula.neg φ ∈ M := hM_sup (Set.mem_singleton _)
  rcases SetMaximalConsistent.negation_complete hM_mcs
    (Formula.box Chronicle.nextTop.neg) with h_box_dense | h_not_box_dense
  · -- Dense branch: `U(⊤,⊥)` is a `.ZTime` theorem (`ztimeNextTop`), so `nextTop ∈ M`; and
    -- `□¬nextTop ∈ M` gives `¬nextTop ∈ M` by Modal T. Contradiction.
    have h_in_next : Chronicle.nextTop ∈ M := theorem_in_mcs hM_mcs ztimeNextTop
    have h_modal_t : ⊢[FrameClass.ZTime]
        (Chronicle.nextTop.neg.box.imp Chronicle.nextTop.neg) :=
      DerivationTree.axiom [] _ (Axiom.modal_t Chronicle.nextTop.neg) (FrameClass.base_le _)
    have h_in_neg_next : Chronicle.nextTop.neg ∈ M :=
      SetMaximalConsistent.mp_of_theorem hM_mcs h_modal_t h_box_dense
    exact set_consistent_not_both hM_mcs.1 Chronicle.nextTop h_in_next h_in_neg_next
  · rcases SetMaximalConsistent.negation_complete hM_mcs
      (Formula.box Chronicle.nextTop) with h_box_discrete | h_not_box_discrete
    · obtain ⟨F, hsucc, hpred, hsuccArch, hpredArch, hdet, TM, τ, t, h_not_true⟩ :=
        WeakCanonical.countermodel_discrete_reynolds_v2 M hM_mcs φ h_neg_in h_box_discrete
      exact h_not_true (ValidDetIn.apply h_valid F
        ⟨hsucc, hpred, hsuccArch, hpredArch⟩ hdet TM τ t)
    · exact False.elim (Chronicle.mcs_mixed_case_absurd FrameClass.ZTime M hM_mcs
        h_not_box_dense h_not_box_discrete)

/--
**Completeness at `.RTime` from deterministic validity.** `completeness_rtime_engine`'s script;
the countermodel is `multiFamTaskFrameGen` over `ℝ`, dense, Dedekind-complete and deterministic.
-/
theorem derivable_of_validDetRTime (φ : Formula) (h_valid : ValidDetIn FrameClass.RTime φ) :
    Derivable FrameClass.RTime [] φ := by
  by_contra h_not_deriv
  have h_cons := neg_consistent_of_not_derivable (fc := FrameClass.RTime) φ h_not_deriv
  obtain ⟨M, hM_sup, hM_mcs⟩ := set_lindenbaum {Formula.neg φ} h_cons
  have h_neg_in : Formula.neg φ ∈ M := hM_sup (Set.mem_singleton _)
  have h_box_dense : Formula.box Chronicle.nextTop.neg ∈ M := dedekind_box_dense_mem hM_mcs
  obtain ⟨F, hdet, TM, τ, t, h_not_true⟩ :=
    countermodel_dedekind_dense (by decide) M hM_mcs φ h_neg_in h_box_dense
  exact h_not_true (ValidDetIn.apply h_valid F.toTaskFrame
    ⟨inferInstance, real_lub_of_bddAbove⟩ hdet TM τ t)

/-- The four rows as one statement, by cases on the frame-class tag: `FrameClass` has exactly the
four constructors, so no class is left out. -/
theorem derivable_of_validDet (fc : FrameClass) (φ : Formula) (h : ValidDetIn fc φ) :
    Derivable fc [] φ := by
  cases fc with
  | Base => exact derivable_of_validDetBase φ h
  | Dense => exact derivable_of_validDetDense φ h
  | ZTime => exact derivable_of_validDetZTime φ h
  | RTime => exact derivable_of_validDetRTime φ h

end FormalSystem.Metalogic.Deterministic
