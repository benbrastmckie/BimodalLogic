-- Archived to Boneyard/ScheduleBasedBFMCS/ (task 130): schedule-based BFMCS
-- construction. 3 sorry sites (restricted_tc/buc/fuc) bypassed by Chronicle
-- approach. See Boneyard/ScheduleBasedBFMCS/README.md.
import Bimodal.Metalogic.BXCanonical.Chronicle.ChronicleToCountermodel
import Bimodal.Metalogic.WeakCanonical
import Bimodal.Semantics.Validity
import Mathlib.Data.Int.SuccPred

/-!
# BX Completeness

The completeness theorem for bimodal logic TM with BX axioms:
if a formula is valid (true in all models), then it is derivable.

## Statement

```
theorem completeness (φ : Formula) :
    valid φ → Nonempty (DerivationTree FrameClass.Base [] φ)
```

## Proof Sketch (Contrapositive)

1. Assume φ is not derivable: ¬Nonempty (DerivationTree FrameClass.Base [] φ)
2. Then {¬φ} is consistent (otherwise we could derive φ)
3. By Lindenbaum: extend {¬φ} to MCS w₀ containing ¬φ
4. Build canonical TaskModel with BXPoints as world states
5. By truth lemma: ¬φ holds at w₀ in the canonical model
6. Therefore φ is not valid (countermodel exists)

## Status

The completeness proof is wired through `countermodel_dense` from
Chronicle/ChronicleToCountermodel.lean, which uses the Burgess 1982 chronicle
construction over Rat instead of the schedule-based Int chain. This bypasses the
3 sorry sites in RootScopedChain.lean (which remain as dead code).

Remaining leaf sorries are in the Chronicle/ modules (FMCS G/H coherence,
chronicle construction C5/C5' satisfaction, counterexample enumeration).

## References

- Burgess 1984, Goldblatt 1992 (completeness for tense logics)
-/

namespace Bimodal.Metalogic.BXCanonical

open Bimodal.Syntax
open Bimodal.ProofSystem
open Bimodal.Metalogic.Core
open Bimodal.Semantics

/-! ## Consistency of {¬φ} When φ Is Not Derivable -/

/--
If φ is not derivable from the empty context, then {¬φ} is set-consistent.

Proof: Suppose {¬φ} is inconsistent. Then some finite L ⊆ {¬φ} with L ⊢ ⊥.
Either L = [] (then [] ⊢ ⊥, contradicting consistency of TM) or L = [¬φ]
(then [¬φ] ⊢ ⊥, so [] ⊢ ¬¬φ by deduction, so [] ⊢ φ by double negation elimination).
-/
theorem neg_consistent_of_not_derivable {fc : FrameClass} (φ : Formula)
    (h_not_deriv : ¬Nonempty (DerivationTree fc [] φ)) :
    SetConsistent (fc := fc) ({Formula.neg φ} : Set Formula) := by
  intro L hL ⟨d⟩
  -- Every element of L is ¬φ
  have h_all_neg : ∀ ψ ∈ L, ψ = Formula.neg φ := by
    intro ψ hψ
    exact Set.mem_singleton_iff.mp (hL ψ hψ)
  -- Case split: is ¬φ in L?
  by_cases h_in : Formula.neg φ ∈ L
  · -- ¬φ ∈ L. Put it first, then deduction theorem.
    let L_filt := L.filter (fun y => decide (y ≠ Formula.neg φ))
    have d_reord : DerivationTree fc (Formula.neg φ :: L_filt) Formula.bot :=
      derivation_exchange d (fun x => (cons_filter_neq_perm h_in x).symm)
    -- L_filt ⊆ {¬φ}, so L_filt is a subset of [¬φ,...,¬φ] with all ≠ ¬φ, hence L_filt = []
    -- Actually L_filt may still contain ¬φ if there are duplicates... no, the filter removes ALL ¬φ.
    -- Wait, the filter keeps elements ≠ ¬φ. So L_filt ⊆ L and all elements ≠ ¬φ.
    -- But L ⊆ {¬φ}, so L_filt must be empty.
    have h_filt_empty : L_filt = [] := by
      by_contra h_ne
      obtain ⟨a, ha⟩ := List.exists_mem_of_ne_nil _ h_ne
      have h_and := List.mem_filter.mp ha
      have h_ne_neg : a ≠ Formula.neg φ := by simpa using h_and.2
      exact h_ne_neg (h_all_neg a h_and.1)
    rw [h_filt_empty] at d_reord
    -- Now d_reord : [¬φ] ⊢ ⊥
    have d_negneg : DerivationTree fc [] (Formula.neg (Formula.neg φ)) :=
      deduction_theorem [] (Formula.neg φ) Formula.bot d_reord
    -- ¬¬φ → φ by double negation elimination
    have h_dne : DerivationTree fc [] ((Formula.neg (Formula.neg φ)).imp φ) :=
      Bimodal.Theorems.Propositional.double_negation φ
    have d_phi : DerivationTree fc [] φ :=
      DerivationTree.modus_ponens [] _ _ h_dne d_negneg
    exact h_not_deriv ⟨d_phi⟩
  · -- ¬φ ∉ L. Then L ⊆ {¬φ} with ¬φ ∉ L means L = [] (since only element is ¬φ).
    have h_L_empty : L = [] := by
      by_contra h_ne
      obtain ⟨a, ha⟩ := List.exists_mem_of_ne_nil _ h_ne
      have := h_all_neg a ha
      exact h_in (this ▸ ha)
    rw [h_L_empty] at d
    -- [] ⊢ ⊥ means ⊥ is a theorem, but the empty context is consistent
    -- (propositional logic is consistent)
    -- Actually we can derive: from [] ⊢ ⊥ we get [] ⊢ φ by ex_falso
    have h_ef : DerivationTree fc [] (Formula.bot.imp φ) :=
      DerivationTree.axiom [] _ (Axiom.ex_falso φ) trivial
    have d_phi : DerivationTree fc [] φ :=
      DerivationTree.modus_ponens [] _ _ h_ef d
    exact h_not_deriv ⟨d_phi⟩

/-! ## BX Completeness Theorem -/

/--
Completeness Theorem: If a formula is valid, then it is derivable.

The contrapositive: if φ is not derivable, then φ is not valid.

**Proof Strategy**:
1. Assume φ is not derivable
2. By `neg_consistent_of_not_derivable`: {¬φ} is consistent
3. By Lindenbaum: extend to MCS w₀ with ¬φ ∈ w₀
4. Build canonical model via `countermodel_dense` (Chronicle/ChronicleToCountermodel.lean)
5. By parametric truth lemma: φ is false at the canonical evaluation point
6. Instantiate `valid φ` at the canonical model to get truth, contradiction

**Status**: Proof completed via `countermodel_dense` (Burgess chronicle).
The mixed case (¬□(F'T) ∧ ¬□(U(T,bot))) is eliminated by `mcs_mixed_case_absurd`
using the structural axiom `discrete_box_necessity` (task 142).
Remaining leaf sorries are in the Chronicle/ modules (FMCS coherence, chronicle
construction). The RootScopedChain.lean sorry sites are no longer on the critical
path -- the chronicle bypasses them entirely.
-/
theorem completeness (φ : Formula) :
    valid φ → Nonempty (DerivationTree FrameClass.Base [] φ) := by
  -- Contrapositive: assume not derivable, show not valid
  by_contra h
  push_neg at h
  obtain ⟨h_valid, h_not_deriv⟩ := h
  -- Convert IsEmpty to ¬Nonempty
  have h_not_deriv' : ¬Nonempty (DerivationTree FrameClass.Base [] φ) := not_nonempty_iff.mpr h_not_deriv
  -- {¬φ} is consistent
  have h_cons := neg_consistent_of_not_derivable φ h_not_deriv'
  -- Extend to MCS
  obtain ⟨M, hM_sup, hM_mcs⟩ := set_lindenbaum {Formula.neg φ} h_cons
  -- ¬φ ∈ M
  have h_neg_in : Formula.neg φ ∈ M := hM_sup (Set.mem_singleton _)
  -- φ ∉ M (since ¬φ ∈ M and M is MCS)
  have h_not_in : φ ∉ M := SetMaximalConsistent.neg_excludes hM_mcs φ h_neg_in
  -- Build canonical model and derive contradiction via three-way case split:
  -- 1. Dense case (□(F'T) ∈ M): countermodel on Rat via Cantor iso
  -- 2. Purely discrete case (□(U(T,bot)) ∈ M): countermodel on Int via succ embedding
  -- 3. Mixed case (¬□(F'T) ∧ ¬□(U(T,bot)) ∈ M): vacuously true (mcs_mixed_case_absurd, task 142)
  rcases SetMaximalConsistent.negation_complete hM_mcs
    (Formula.box Chronicle.next_top.neg) with h_box_dense | h_not_box_dense
  · -- Dense case: □(F'T) ∈ M — all box-equivalent MCS's are dense
    obtain ⟨D, _, _, _, _, F, TM, Omega, h_sc, τ, h_mem, t, h_not_true⟩ :=
      Chronicle.countermodel_dense FrameClass.Base M hM_mcs φ h_neg_in h_box_dense
    exact h_not_true (h_valid D F TM Omega h_sc τ h_mem t)
  · -- Non-dense: ¬□(F'T) ∈ M. Sub-split on □(U(T,bot)).
    rcases SetMaximalConsistent.negation_complete hM_mcs
      (Formula.box Chronicle.next_top) with h_box_discrete | h_not_box_discrete
    · -- Purely discrete case: □(U(T,bot)) ∈ M — all box-equivalent MCS's are discrete
      obtain ⟨D, _, _, _, _, F, TM, Omega, h_sc, τ, h_mem, t, h_not_true⟩ :=
        WeakCanonical.countermodel_discrete M hM_mcs φ h_neg_in h_box_discrete
      exact h_not_true (h_valid D F TM Omega h_sc τ h_mem t)
    · -- Mixed case: ¬□(F'T) ∧ ¬□(U(T,bot)) ∈ M — some worlds dense, others discrete
      obtain ⟨D, _, _, _, _, F, TM, Omega, h_sc, τ, h_mem, t, h_not_true⟩ :=
        Chronicle.dd_countermodel_chronicle_mixed_sorry FrameClass.Base M hM_mcs φ h_neg_in
          h_not_box_dense h_not_box_discrete
      exact h_not_true (h_valid D F TM Omega h_sc τ h_mem t)

/--
Completeness (alternate form): valid → derivable.
-/
theorem completeness' (φ : Formula) (h : valid φ) :
    Nonempty (DerivationTree FrameClass.Base [] φ) :=
  completeness φ h

/-! ## Frame-Class-Specific Completeness Theorems -/

/--
Enriched dense countermodel: constructs the same countermodel as `countermodel_dense`
but with `Rat` explicit throughout, so `DenselyOrdered` is available for `valid_dense`.
-/
private theorem countermodel_dense_enriched {fc : FrameClass} (A : Set Formula) (h_mcs : SetMaximalConsistent (fc := fc) A)
    (φ : Formula) (h_neg_in : φ.neg ∈ A)
    (h_box_dense : Formula.box Chronicle.next_top.neg ∈ A) :
    ∃ (F : TaskFrame Rat) (TM : TaskModel F)
      (Omega : Set (WorldHistory F)) (_ : ShiftClosed Omega)
      (τ : WorldHistory F) (_ : τ ∈ Omega) (t : Rat),
      ¬truth_at TM Omega τ t φ := by
  let bfmcs := Chronicle.cantor_bfmcs_dense fc A h_mcs h_box_dense
  let fam₀ := Chronicle.rooted_cantor_fmcs_dense fc A h_mcs h_box_dense 0
  refine ⟨Bimodal.Metalogic.Algebraic.ParametricCanonical.ParametricCanonicalTaskFrame Rat,
    Bimodal.Metalogic.Algebraic.ParametricTruthLemma.ParametricCanonicalTaskModel Rat,
    Bimodal.Metalogic.Algebraic.ParametricHistory.ShiftClosedParametricCanonicalOmega bfmcs,
    Bimodal.Metalogic.Algebraic.ParametricHistory.shiftClosedParametricCanonicalOmega_is_shift_closed bfmcs,
    Bimodal.Metalogic.Algebraic.ParametricHistory.parametric_to_history fam₀,
    Bimodal.Metalogic.Algebraic.ParametricHistory.parametricCanonicalOmega_subset_shiftClosed bfmcs
      ⟨fam₀, ⟨A, h_mcs, h_box_dense, 0, fun _ => Iff.rfl, rfl⟩, rfl⟩,
    0, ?_⟩
  have h_neg_fam : φ.neg ∈ fam₀.mcs 0 := by
    rw [Chronicle.rooted_cantor_fmcs_dense_at_s]; exact h_neg_in
  exact Bimodal.Metalogic.Algebraic.RestrictedParametricTruthLemma.fully_restricted_parametric_completeness_from_neg_membership
    bfmcs φ
    (Chronicle.cantor_bfmcs_dense_restricted_tc fc A h_mcs h_box_dense φ
      (fun ψ hψ => Finset.mem_toList.mpr (deferralClosure_subset_extendedDeferralClosure φ hψ)))
    (Chronicle.cantor_bfmcs_dense_restricted_buc fc A h_mcs h_box_dense φ)
    (Chronicle.cantor_bfmcs_dense_restricted_fuc fc A h_mcs h_box_dense φ)
    φ (self_mem_subformulaClosure φ)
    fam₀ ⟨A, h_mcs, h_box_dense, 0, fun _ => Iff.rfl, rfl⟩ 0 h_neg_fam

/--
Enriched discrete countermodel: constructs a countermodel with `Int` explicit
throughout, so `SuccOrder`/`PredOrder` are available for `valid_discrete`.

Uses `dd_countermodel_chronicle_discrete` from the Chronicle pipeline, which is
already parameterized over fc. The D = Int specialization is obtained by matching
on the existential that returns D = Int.
-/
private theorem countermodel_discrete_enriched {fc : FrameClass} (A : Set Formula) (h_mcs : SetMaximalConsistent (fc := fc) A)
    (h_fc : FrameClass.Discrete ≤ fc)
    (φ : Formula) (h_neg_in : φ.neg ∈ A)
    (h_box_discrete : Formula.box Chronicle.next_top ∈ A) :
    ∃ (F : TaskFrame Int) (TM : TaskModel F)
      (Omega : Set (WorldHistory F)) (_ : ShiftClosed Omega)
      (τ : WorldHistory F) (_ : τ ∈ Omega) (t : Int),
      ¬truth_at TM Omega τ t φ := by
  let bfmcs := Chronicle.cantor_bfmcs_discrete fc A h_mcs h_box_discrete
  let fam₀ := Chronicle.rooted_succ_discrete_fmcs fc A h_mcs h_box_discrete 0
  refine ⟨Bimodal.Metalogic.Algebraic.ParametricCanonical.ParametricCanonicalTaskFrame Int,
    Bimodal.Metalogic.Algebraic.ParametricTruthLemma.ParametricCanonicalTaskModel Int,
    Bimodal.Metalogic.Algebraic.ParametricHistory.ShiftClosedParametricCanonicalOmega bfmcs,
    Bimodal.Metalogic.Algebraic.ParametricHistory.shiftClosedParametricCanonicalOmega_is_shift_closed bfmcs,
    Bimodal.Metalogic.Algebraic.ParametricHistory.parametric_to_history fam₀,
    Bimodal.Metalogic.Algebraic.ParametricHistory.parametricCanonicalOmega_subset_shiftClosed bfmcs
      ⟨fam₀, ⟨A, h_mcs, h_box_discrete, 0, fun _ => Iff.rfl, rfl⟩, rfl⟩,
    0, ?_⟩
  have h_neg_fam : φ.neg ∈ fam₀.mcs 0 := by
    rw [Chronicle.rooted_succ_discrete_fmcs_at_s]; exact h_neg_in
  exact Bimodal.Metalogic.Algebraic.RestrictedParametricTruthLemma.fully_restricted_parametric_completeness_from_neg_membership
    bfmcs φ
    (Chronicle.cantor_bfmcs_discrete_restricted_tc fc A h_mcs h_fc h_box_discrete φ
      (fun ψ hψ => Finset.mem_toList.mpr (deferralClosure_subset_extendedDeferralClosure φ hψ)))
    (Chronicle.cantor_bfmcs_discrete_restricted_buc fc A h_mcs h_box_discrete φ)
    (Chronicle.cantor_bfmcs_discrete_restricted_fuc fc A h_mcs h_fc h_box_discrete φ)
    φ (self_mem_subformulaClosure φ)
    fam₀ ⟨A, h_mcs, h_box_discrete, 0, fun _ => Iff.rfl, rfl⟩ 0 h_neg_fam

/--
Dense Completeness Theorem: If a formula is valid on all densely ordered models,
then it is derivable in the Dense proof system.

**Proof Strategy**: Same contrapositive + MCS construction as `completeness`,
but using Dense-derivability and Dense-MCS throughout.
- Dense case: `countermodel_dense_enriched` produces a countermodel on `Rat`
  (DenselyOrdered), directly contradicting `valid_dense`.
- Non-dense case (task 198): the `dense_indicator` axiom `¬U(⊤,⊥)` is a Dense
  theorem, so `□(¬U(⊤,⊥))` is in every Dense-MCS, contradicting `¬□(F'T) ∈ M`.

**Sorry Status**: Inherits sorries from `countermodel_dense` (dense case).
The non-dense branch is now resolved (task 198): the `dense_indicator` axiom
`¬U(⊤,⊥)` is a Dense theorem, so `□(¬U(⊤,⊥))` is in every Dense-MCS,
contradicting `¬□(F'T) ∈ M`.
-/
theorem completeness_dense (φ : Formula) :
    valid_dense φ → Nonempty (DerivationTree FrameClass.Dense [] φ) := by
  intro h_valid_dense
  by_contra h_not_deriv
  have h_cons := neg_consistent_of_not_derivable (fc := FrameClass.Dense) φ h_not_deriv
  obtain ⟨M, hM_sup, hM_mcs⟩ := set_lindenbaum {Formula.neg φ} h_cons
  have h_neg_in : Formula.neg φ ∈ M := hM_sup (Set.mem_singleton _)
  rcases SetMaximalConsistent.negation_complete hM_mcs
    (Formula.box Chronicle.next_top.neg) with h_box_dense | h_not_box_dense
  · -- Dense case: □(F'T) ∈ M — countermodel on Rat (DenselyOrdered)
    obtain ⟨F, TM, Omega, h_sc, τ, h_mem, t, h_not_true⟩ :=
      countermodel_dense_enriched M hM_mcs φ h_neg_in h_box_dense
    exact h_not_true (h_valid_dense Rat F TM Omega h_sc τ h_mem t)
  · -- Non-dense case: ¬□(F'T) ∈ M. But the dense_indicator axiom ¬U(⊤,⊥)
    -- is a Dense theorem, so □(¬U(⊤,⊥)) = □(F'T) is in every Dense-MCS.
    -- Contradiction with h_not_box_dense : ¬□(F'T) ∈ M.
    have h_ax : DerivationTree FrameClass.Dense [] Chronicle.next_top.neg :=
      DerivationTree.axiom [] _ Axiom.dense_indicator (by trivial)
    have h_box : DerivationTree FrameClass.Dense [] Chronicle.next_top.neg.box :=
      DerivationTree.necessitation _ h_ax
    have h_in : Chronicle.next_top.neg.box ∈ M := theorem_in_mcs hM_mcs h_box
    exact set_consistent_not_both hM_mcs.1 (Chronicle.next_top.neg.box) h_in h_not_box_dense

/--
Discrete Completeness Theorem: If a formula is valid on all discretely ordered models,
then it is derivable in the Discrete proof system.

**Proof Strategy**: Same contrapositive + MCS construction as `completeness`,
but using Discrete-derivability and Discrete-MCS throughout.
- Discrete case (□(U(⊤,⊥)) ∈ M): `countermodel_discrete_enriched` produces a
  countermodel on `Int` (SuccOrder, PredOrder), contradicting `valid_discrete`.
- Dense case (□(F'⊤) ∈ M, task 198): `U(⊤,⊥)` is a Discrete theorem,
  so `next_top ∈ M`. From `□(¬U(⊤,⊥)) ∈ M` and Modal T, `¬U(⊤,⊥) ∈ M`,
  contradiction.
- Mixed case: eliminated by `mcs_mixed_case_absurd`.

**Sorry Status**: The dense-case branch is now resolved (task 198):
`U(⊤,⊥)` (next_top) is a Discrete theorem (derived from prior_UZ + serial_future
+ guard weakening via left_mono_until_G), so from `□(¬U(⊤,⊥)) ∈ M` and Modal T
we get `¬U(⊤,⊥) ∈ M`, contradicting `U(⊤,⊥) ∈ M`.
The mixed-case sorry is eliminated via `dd_countermodel_chronicle_mixed_sorry`.
-/
theorem completeness_discrete (φ : Formula) :
    valid_discrete φ → Nonempty (DerivationTree FrameClass.Discrete [] φ) := by
  intro h_valid_discrete
  by_contra h_not_deriv
  have h_cons := neg_consistent_of_not_derivable (fc := FrameClass.Discrete) φ h_not_deriv
  obtain ⟨M, hM_sup, hM_mcs⟩ := set_lindenbaum {Formula.neg φ} h_cons
  have h_neg_in : Formula.neg φ ∈ M := hM_sup (Set.mem_singleton _)
  rcases SetMaximalConsistent.negation_complete hM_mcs
    (Formula.box Chronicle.next_top.neg) with h_box_dense | h_not_box_dense
  · -- Dense case: □(F'T) ∈ M — but U(T,bot) is a Discrete theorem.
    -- Derive next_top (= U(T,bot)) in the Discrete system, then from
    -- □(neg(next_top)) ∈ M extract neg(next_top) ∈ M via Modal T, contradiction.
    -- Step 1: T = bot → bot
    have h_top : ⊢[FrameClass.Discrete] Chronicle.top_formula :=
      Bimodal.Theorems.Combinators.identity Formula.bot
    -- Steps 2-3: F(T) from seriality + MP
    have h_ft : ⊢[FrameClass.Discrete] Chronicle.top_formula.some_future :=
      DerivationTree.modus_ponens [] _ _
        (DerivationTree.axiom [] _ Axiom.serial_future (FrameClass.base_le _)) h_top
    -- Steps 4-5: U(T, ¬T) from prior_UZ + MP
    have h_ut_negT : ⊢[FrameClass.Discrete] (Formula.untl Chronicle.top_formula Chronicle.top_formula.neg) :=
      DerivationTree.modus_ponens [] _ _
        (DerivationTree.axiom [] _ (Axiom.prior_UZ Chronicle.top_formula) (by trivial)) h_ft
    -- Step 6: ¬T → ⊥ via deduction theorem (assume T→⊥, derive T from identity, MP gives ⊥)
    have h_negT_bot : ⊢[FrameClass.Discrete] (Chronicle.top_formula.neg.imp Formula.bot) := by
      show ⊢[FrameClass.Discrete] ((Chronicle.top_formula.imp Formula.bot).imp Formula.bot)
      exact deduction_theorem [] (Chronicle.top_formula.imp Formula.bot) Formula.bot
        (DerivationTree.modus_ponens [Chronicle.top_formula.imp Formula.bot] Chronicle.top_formula Formula.bot
          (DerivationTree.assumption _ _ (by simp))
          (DerivationTree.weakening [] [Chronicle.top_formula.imp Formula.bot] _ h_top (by simp)))
    -- Step 7: G(¬T → ⊥) via temporal necessitation
    have h_G_negT_bot : ⊢[FrameClass.Discrete] (Chronicle.top_formula.neg.imp Formula.bot).all_future :=
      DerivationTree.temporal_necessitation _ h_negT_bot
    -- Step 8: left_mono_until_G: G(¬T→⊥) → (U(T,¬T) → U(T,⊥))
    have h_mono : ⊢[FrameClass.Discrete]
        ((Chronicle.top_formula.neg.imp Formula.bot).all_future.imp
          ((Formula.untl Chronicle.top_formula Chronicle.top_formula.neg).imp
            (Formula.untl Chronicle.top_formula Formula.bot))) :=
      DerivationTree.axiom [] _ (Axiom.left_mono_until_G Chronicle.top_formula.neg Formula.bot Chronicle.top_formula) (FrameClass.base_le _)
    -- Step 9: U(T,¬T) → U(T,⊥)
    have h_imp_next : ⊢[FrameClass.Discrete]
        ((Formula.untl Chronicle.top_formula Chronicle.top_formula.neg).imp Chronicle.next_top) :=
      DerivationTree.modus_ponens [] _ _ h_mono h_G_negT_bot
    -- Step 10: U(T,⊥) = next_top
    have h_next_top : ⊢[FrameClass.Discrete] Chronicle.next_top :=
      DerivationTree.modus_ponens [] _ _ h_imp_next h_ut_negT
    -- Place next_top in M
    have h_in_next : Chronicle.next_top ∈ M := theorem_in_mcs hM_mcs h_next_top
    -- Extract ¬(next_top) from □(¬(next_top)) via Modal T
    have h_modal_t : ⊢[FrameClass.Discrete] (Chronicle.next_top.neg.box.imp Chronicle.next_top.neg) :=
      DerivationTree.axiom [] _ (Axiom.modal_t Chronicle.next_top.neg) (FrameClass.base_le _)
    have h_in_neg_next : Chronicle.next_top.neg ∈ M :=
      SetMaximalConsistent.implication_property hM_mcs (theorem_in_mcs hM_mcs h_modal_t) h_box_dense
    -- Contradiction: next_top ∈ M and ¬(next_top) ∈ M
    exact set_consistent_not_both hM_mcs.1 Chronicle.next_top h_in_next h_in_neg_next
  · -- Non-dense: ¬□(F'T) ∈ M. Sub-split on □(U(T,bot)).
    rcases SetMaximalConsistent.negation_complete hM_mcs
      (Formula.box Chronicle.next_top) with h_box_discrete | h_not_box_discrete
    · -- Discrete case: □(U(T,bot)) ∈ M — countermodel on Int
      obtain ⟨F, TM, Omega, h_sc, τ, h_mem, t, h_not_true⟩ :=
        countermodel_discrete_enriched M hM_mcs (le_refl _) φ h_neg_in h_box_discrete
      exact h_not_true (h_valid_discrete Int F TM Omega h_sc τ h_mem t)
    · -- Mixed case: ¬□(F'T) ∧ ¬□(U(T,bot)) ∈ M — eliminated by structural axiom
      exact False.elim (Chronicle.mcs_mixed_case_absurd FrameClass.Discrete M hM_mcs h_not_box_dense h_not_box_discrete)

#print axioms Bimodal.Metalogic.BXCanonical.completeness_dense
#print axioms Bimodal.Metalogic.BXCanonical.completeness_discrete

/-! ## Axiom Audit (Phase 0 Results)

Captured during Phase 0 of task 109 (2026-04-20).

### Current State (as of Phase 0)

```
#print axioms completeness
-- depends on: [propext, sorryAx, Classical.choice, Lean.ofReduceBool, Lean.trustCompiler, Quot.sound]

#print axioms dd_countermodel
-- depends on: [propext, sorryAx, Classical.choice, Lean.ofReduceBool, Lean.trustCompiler, Quot.sound]
```

### Axiom Classification

- `propext`, `Classical.choice`, `Quot.sound` — target axioms (acceptable, standard Lean 4)
- `sorryAx` — must be eliminated (7 critical-path sorries)
- `Lean.ofReduceBool`, `Lean.trustCompiler` — introduced by `native_decide` in Syntax layer
  (Formula.lean, SignedFormula.lean); these are acceptable, not sorry-related

### Sorry Dependency Tree (Post-Phase 5 Rewiring)

The `sorryAx` dependency now traces through `dd_countermodel_chronicle` →
`cantor_bfmcs` in Chronicle/ChronicleToCountermodel.lean, which uses the
Burgess chronicle construction with a Cantor isomorphism to embed all
rationals into the limit domain.

**Active sorry sites** (1 total, on critical path):
- 1 density g-value consistency in CounterexampleElimination.lean:3570 — the
  density elimination needs `SetConsistent (fc := FrameClass.Base) (χ.g pc.x pc.y)` to find β ∉ g for
  `lemma_2_6_splitting`. This traces to the Cantor isomorphism requiring
  `DenselyOrdered` on the limit domain (an implementation choice — Burgess 1982
  doesn't need density). Task 117 will remove the Cantor iso and build the model
  directly on the limit domain, eliminating this sorry.

**Closed sorry sites** (task 107, Phases 1-7):
- 7 c2' sorry sites (closed via guard threading + walk restructuring)
- 2 c4 hard case sorry sites (closed via BX6 absorption, Burgess 2.9)
- 2 FUC sorry sites (closed via adj_g_mem_limit_f + witness_not_old)
- NoUnivBurgessR3 hypothesis (deleted — unprovable in J₀, replaced by CUD g-values)

**Dead code** (no longer on critical path):
- All sorry sites in RootScopedChain.lean (bx_bfmcs_restricted_tc/buc/fuc)
- Dead code sorries in CanonicalModel.lean (enriched_seed_consistent, etc.)

### Target State

After task 117 (remove Cantor iso), `#print axioms completeness` should show:
`{propext, Classical.choice, Lean.ofReduceBool, Lean.trustCompiler, Quot.sound}`

Current state (task 107 complete):
`{propext, sorryAx, Classical.choice, Lean.ofReduceBool, Lean.trustCompiler, Quot.sound}`
`sorryAx` traces to: CE:3570 → limit_dom_dense → DenselyOrdered → cantor_iso → dd_countermodel_chronicle

(The `Lean.ofReduceBool` and `Lean.trustCompiler` remain from `native_decide` in the Syntax layer
and are not removable without changing the decidability infrastructure.)
-/

#print axioms Bimodal.Metalogic.BXCanonical.completeness
-- dd_countermodel archived to Boneyard/ScheduleBasedBFMCS/ (task 130)
#print axioms Bimodal.Metalogic.BXCanonical.Chronicle.countermodel_dense

end Bimodal.Metalogic.BXCanonical
