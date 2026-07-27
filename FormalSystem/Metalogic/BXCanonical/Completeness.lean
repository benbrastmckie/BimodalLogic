/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

-- Archived to Boneyard/ScheduleBasedBFMCS/: schedule-based BFMCS
-- construction. 3 sorry sites (restricted_tc/buc/fuc) bypassed by Chronicle
-- approach. See Boneyard/ScheduleBasedBFMCS/README.md.
import FormalSystem.Metalogic.BXCanonical.Chronicle.ChronicleToCountermodel
import FormalSystem.Metalogic.BXCanonical.Chronicle.MCSMixedCase
import FormalSystem.Metalogic.WeakCanonical
import FormalSystem.Semantics.Validity
import Mathlib.Data.Int.SuccPred

/-!
# BX Completeness

The completeness theorem for bimodal logic TM with BX axioms:
if a formula is valid (true in all models), then it is derivable.

## Statement

```
theorem completeness (φ : Formula) :
    valid φ → Derivable FrameClass.Base [] φ
```

## Proof Sketch (Contrapositive)

1. Assume φ is not derivable: ¬Derivable FrameClass.Base [] φ
2. Then {¬φ} is consistent (otherwise we could derive φ)
3. By Lindenbaum: extend {¬φ} to MCS w₀ containing ¬φ
4. Build canonical TaskModel with BXPoints as world states
5. By truth lemma: ¬φ holds at w₀ in the canonical model
6. Therefore φ is not valid (countermodel exists)

## Status

`completeness_dense` and `completeness_discrete` are sorryAx-free (see the Axiom Audit
section at the end of this file; axioms: exactly `propext`, `Classical.choice`,
`Quot.sound` — the former `native_decide` dependency was eliminated by swapping the
Syntax-layer sites to `rfl`/`decide`). The general Base-frame
`completeness` still carries sorryAx, with a single source: the deprecated
`WeakCanonical.countermodel_discrete` (dead BX pipeline, WeakCanonical/Transfer.lean) used
in its discrete branch — the sole remaining completeness debt (a Base-MCS is not
automatically Discrete-consistent, so the sorry-free Reynolds pipeline cannot be reused
there). Its dense branch (`countermodel_dense_enriched`, on ℚ) and mixed branch
(`mcs_mixed_case_absurd`) are sorryAx-free.

## References

- Burgess 1984, Goldblatt 1992 (completeness for tense logics)
-/

namespace FormalSystem.Metalogic.BXCanonical

open FormalSystem.Syntax
open FormalSystem.ProofSystem
open FormalSystem.Metalogic.Core
open FormalSystem.Semantics

/-! ## Consistency of {¬φ} When φ Is Not Derivable -/

/--
If φ is not derivable from the empty context, then {¬φ} is set-consistent.

Proof: Suppose {¬φ} is inconsistent. Then some finite L ⊆ {¬φ} with L ⊢ ⊥.
Either L = [] (then [] ⊢ ⊥, contradicting consistency of TM) or L = [¬φ]
(then [¬φ] ⊢ ⊥, so [] ⊢ ¬¬φ by deduction, so [] ⊢ φ by double negation elimination).
-/
theorem neg_consistent_of_not_derivable {fc : FrameClass} (φ : Formula)
    (h_not_deriv : ¬Derivable fc [] φ) :
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
    -- Actually L_filt may still contain ¬φ if there are duplicates... no, the filter removes ALL
    -- ¬φ.
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
      FormalSystem.Theorems.Propositional.double_negation φ
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

-- The two witnesses used below have fully-qualified names 97 and 118 characters long, so
-- they cannot be written out inside this proof and stay under the 100-column limit.
open FormalSystem.Metalogic.Algebraic.ParametricHistory in
open FormalSystem.Metalogic.Algebraic.RestrictedParametricTruthLemma in
/--
Enriched dense countermodel: constructs the same countermodel as `countermodel_dense`
but with `Rat` explicit throughout, so `DenselyOrdered` is available for `valid_dense`.
This is the single canonical dense countermodel used by both `completeness` and
`completeness_dense`.
-/
theorem countermodel_dense_enriched {fc : FrameClass} (A : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := fc) A)
    (φ : Formula) (h_neg_in : φ.neg ∈ A)
    (h_box_dense : Formula.box Chronicle.next_top.neg ∈ A) :
    ∃ (F : TaskFrame Rat) (TM : TaskModel F)
      (Omega : Set (WorldHistory F)) (_ : ShiftClosed Omega)
      (τ : WorldHistory F) (_ : τ ∈ Omega) (t : Rat),
      ¬truth_at TM Omega τ t φ := by
  let bfmcs := Chronicle.cantor_bfmcs_dense fc A h_mcs h_box_dense
  let fam₀ := Chronicle.rooted_cantor_fmcs_dense fc A h_mcs h_box_dense 0
  refine ⟨FormalSystem.Metalogic.Algebraic.ParametricCanonical.ParametricCanonicalTaskFrame Rat,
    FormalSystem.Metalogic.Algebraic.ParametricTruthLemma.ParametricCanonicalTaskModel Rat,
    FormalSystem.Metalogic.Algebraic.ParametricHistory.ShiftClosedParametricCanonicalOmega bfmcs,
    shiftClosedParametricCanonicalOmega_is_shift_closed bfmcs,
    FormalSystem.Metalogic.Algebraic.ParametricHistory.parametric_to_history fam₀,
    FormalSystem.Metalogic.Algebraic.ParametricHistory.parametricCanonicalOmega_subset_shiftClosed bfmcs
      ⟨fam₀, ⟨A, h_mcs, h_box_dense, 0, fun _ => Iff.rfl, rfl⟩, rfl⟩,
    0, ?_⟩
  have h_neg_fam : φ.neg ∈ fam₀.mcs 0 := by
    rw [Chronicle.rooted_cantor_fmcs_dense_at_s]; exact h_neg_in
  exact
      fully_restricted_parametric_completeness_from_neg_membership
    bfmcs φ
    (Chronicle.cantor_bfmcs_dense_restricted_tc fc A h_mcs h_box_dense φ
      (fun ψ hψ => Finset.mem_toList.mpr (deferralClosure_subset_extendedDeferralClosure φ hψ)))
    (Chronicle.cantor_bfmcs_dense_restricted_buc fc A h_mcs h_box_dense φ)
    (Chronicle.cantor_bfmcs_dense_restricted_fuc fc A h_mcs h_box_dense φ)
    φ (self_mem_subformulaClosure φ)
    fam₀ ⟨A, h_mcs, h_box_dense, 0, fun _ => Iff.rfl, rfl⟩ 0 h_neg_fam

/-! ## BX Completeness Theorem -/

/--
Completeness Theorem: If a formula is valid, then it is derivable.

The contrapositive: if φ is not derivable, then φ is not valid.

**Proof Strategy**:
1. Assume φ is not derivable
2. By `neg_consistent_of_not_derivable`: {¬φ} is consistent
3. By Lindenbaum: extend to MCS w₀ with ¬φ ∈ w₀
4. Three-way case split on w₀'s temporal character:
   - Dense (□(F'T) ∈ w₀): countermodel on ℚ via `countermodel_dense_enriched`
   - Purely discrete (□(U(⊤,⊥)) ∈ w₀): countermodel via the deprecated
     `WeakCanonical.countermodel_discrete` — SOLE remaining sorryAx source
   - Mixed (¬□(F'T) ∧ ¬□(U(⊤,⊥))): eliminated by `mcs_mixed_case_absurd`
     using the structural axiom `discrete_box_necessity`

**Sorry Status — sole remaining completeness debt (the Base-MCS discrete branch)**:
carries `sorryAx` with exactly one source. The case □(U(⊤,⊥)) ∈ w₀ requires a discrete
countermodel built from a *Base*-MCS. The sorry-free Reynolds pipeline
(`countermodel_discrete_reynolds_v2`) requires
`SetMaximalConsistent (fc := FrameClass.Discrete)`, and a Base-MCS is not automatically
Discrete-consistent, so it cannot be reused here. The branch instead calls the deprecated
`WeakCanonical.countermodel_discrete` (WeakCanonical/Transfer.lean), whose former BX-pipeline
proof was irreparably sorried (`succ_cofinal` is provably unfixable — ℤ+ℤ counterexample) and
is now archived to `Boneyard/DeadChronicleGapElimination/`; the theorem carries a direct
terminal sorry. Discharging this branch is a genuine open construction
(e.g., a Base-to-Discrete MCS transfer or a Henkin-style discrete model), not a
re-wiring task. The dense and mixed branches are sorryAx-free. For the sorry-free
frame-class-specific results, see `completeness_dense` and `completeness_discrete`.
-/
theorem completeness (φ : Formula) :
    valid φ → Derivable FrameClass.Base [] φ := by
  -- Contrapositive: assume not derivable, show not valid
  by_contra h
  push Not at h
  obtain ⟨h_valid, h_not_deriv⟩ := h
  have h_not_deriv' : ¬Derivable FrameClass.Base [] φ := h_not_deriv
  -- {¬φ} is consistent
  have h_cons := neg_consistent_of_not_derivable φ h_not_deriv'
  -- Extend to MCS
  obtain ⟨M, hM_sup, hM_mcs⟩ := set_lindenbaum {Formula.neg φ} h_cons
  -- ¬φ ∈ M
  have h_neg_in : Formula.neg φ ∈ M := hM_sup (Set.mem_singleton _)
  -- φ ∉ M (since ¬φ ∈ M and M is MCS)
  have h_not_in : φ ∉ M := SetMaximalConsistent.neg_excludes hM_mcs φ h_neg_in
  -- Build canonical model and derive contradiction via three-way case split:
  -- 1. Dense case (□(F'T) ∈ M): countermodel on Rat via countermodel_dense_enriched
  -- 2. Purely discrete case (□(U(T,bot)) ∈ M): deprecated
  --    WeakCanonical.countermodel_discrete — sole remaining sorryAx source
  -- 3. Mixed case (¬□(F'T) ∧ ¬□(U(T,bot)) ∈ M): eliminated by the structural
  --    axiom discrete_box_necessity (mcs_mixed_case_absurd)
  rcases SetMaximalConsistent.negation_complete hM_mcs
    (Formula.box Chronicle.next_top.neg) with h_box_dense | h_not_box_dense
  · -- Dense case: □(F'T) ∈ M — countermodel on Rat (countermodel_dense_enriched)
    obtain ⟨F, TM, Omega, h_sc, τ, h_mem, t, h_not_true⟩ :=
      countermodel_dense_enriched M hM_mcs φ h_neg_in h_box_dense
    exact h_not_true (h_valid Rat F TM Omega h_sc τ h_mem t)
  · -- Non-dense: ¬□(F'T) ∈ M. Sub-split on □(U(T,bot)).
    rcases SetMaximalConsistent.negation_complete hM_mcs
      (Formula.box Chronicle.next_top) with h_box_discrete | h_not_box_discrete
    · -- Purely discrete case: □(U(T,bot)) ∈ M — all box-equivalent MCS's are discrete
      obtain ⟨D, _, _, _, _, F, TM, Omega, h_sc, τ, h_mem, t, h_not_true⟩ :=
        WeakCanonical.countermodel_discrete M hM_mcs φ h_neg_in h_box_discrete
      exact h_not_true (h_valid D F TM Omega h_sc τ h_mem t)
    · -- Mixed case: ¬□(F'T) ∧ ¬□(U(T,bot)) ∈ M — eliminated by structural axiom
      exact False.elim (Chronicle.mcs_mixed_case_absurd FrameClass.Base M hM_mcs
        h_not_box_dense h_not_box_discrete)

/--
Completeness (alternate form): valid → derivable.
-/
theorem completeness' (φ : Formula) (h : valid φ) :
    Derivable FrameClass.Base [] φ :=
  completeness φ h

/-! ## Frame-Class-Specific Completeness Theorems -/

-- countermodel_discrete_enriched archived to
-- Boneyard/DeadChronicleGapElimination/TransferDead.lean

/--
Dense Completeness Theorem: If a formula is valid on all densely ordered models,
then it is derivable in the Dense proof system.

**Proof Strategy**: Same contrapositive + MCS construction as `completeness`,
but using Dense-derivability and Dense-MCS throughout.
- Dense case: `countermodel_dense_enriched` produces a countermodel on `Rat`
  (DenselyOrdered), directly contradicting `valid_dense`.
- Non-dense case: the `dense_indicator` axiom `¬U(⊤,⊥)` is a Dense
  theorem, so `□(¬U(⊤,⊥))` is in every Dense-MCS, contradicting `¬□(F'T) ∈ M`.

**Sorry Status**: sorryAx-free (machine-verified; axioms: exactly `propext`,
`Classical.choice`, `Quot.sound`). The
non-dense branch closes via the `dense_indicator` axiom: `¬U(⊤,⊥)` is a Dense theorem,
so `□(¬U(⊤,⊥))` is in every Dense-MCS, contradicting `¬□(F'T) ∈ M`.
-/
theorem completeness_dense (φ : Formula) :
    valid_dense φ → Derivable FrameClass.Dense [] φ := by
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
- Discrete case (□(U(⊤,⊥)) ∈ M): `countermodel_discrete_reynolds_v2` produces a
  countermodel on `ℤ` (SuccOrder, PredOrder), contradicting `valid_discrete`.
- Dense case (□(F'⊤) ∈ M): `U(⊤,⊥)` is a Discrete theorem,
  so `next_top ∈ M`. From `□(¬U(⊤,⊥)) ∈ M` and Modal T, `¬U(⊤,⊥) ∈ M`,
  contradiction.
- Mixed case: eliminated by `mcs_mixed_case_absurd`.

**Sorry Status**: sorryAx-free (machine-verified; axioms: exactly `propext`,
`Classical.choice`, `Quot.sound` — see the
Axiom Audit section below). The dense-case branch closes by deriving `U(⊤,⊥)` as a
Discrete theorem; the mixed case is eliminated by `mcs_mixed_case_absurd`.
-/
theorem completeness_discrete (φ : Formula) :
    valid_discrete φ → Derivable FrameClass.Discrete [] φ := by
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
      FormalSystem.Theorems.Combinators.identity Formula.bot
    -- Steps 2-3: F(T) from seriality + MP
    have h_ft : ⊢[FrameClass.Discrete] Chronicle.top_formula.some_future :=
      DerivationTree.modus_ponens [] _ _
        (DerivationTree.axiom [] _ Axiom.serial_future (FrameClass.base_le _)) h_top
    -- Steps 4-5: U(T, ¬T) from prior_UZ + MP
    have h_ut_negT : ⊢[FrameClass.Discrete]
        (Formula.untl Chronicle.top_formula Chronicle.top_formula.neg) :=
      DerivationTree.modus_ponens [] _ _
        (DerivationTree.axiom [] _ (Axiom.prior_UZ Chronicle.top_formula) (by trivial)) h_ft
    -- Step 6: ¬T → ⊥ via deduction theorem (assume T→⊥, derive T from identity, MP gives ⊥)
    have h_negT_bot : ⊢[FrameClass.Discrete] (Chronicle.top_formula.neg.imp Formula.bot) := by
      change ⊢[FrameClass.Discrete] ((Chronicle.top_formula.imp Formula.bot).imp Formula.bot)
      exact deduction_theorem [] (Chronicle.top_formula.imp Formula.bot) Formula.bot
        (DerivationTree.modus_ponens [Chronicle.top_formula.imp Formula.bot] Chronicle.top_formula
            Formula.bot
          (DerivationTree.assumption _ _ (by simp))
          (DerivationTree.weakening [] [Chronicle.top_formula.imp Formula.bot] _ h_top (by simp)))
    -- Step 7: G(¬T → ⊥) via temporal necessitation
    have h_G_negT_bot : ⊢[FrameClass.Discrete]
        (Chronicle.top_formula.neg.imp Formula.bot).all_future :=
      DerivationTree.temporal_necessitation _ h_negT_bot
    -- Step 8: left_mono_until_G: G(¬T→⊥) → (U(T,¬T) → U(T,⊥))
    have h_mono : ⊢[FrameClass.Discrete]
        ((Chronicle.top_formula.neg.imp Formula.bot).all_future.imp
          ((Formula.untl Chronicle.top_formula Chronicle.top_formula.neg).imp
            (Formula.untl Chronicle.top_formula Formula.bot))) :=
      DerivationTree.axiom [] _ (Axiom.left_mono_until_G Chronicle.top_formula.neg Formula.bot
          Chronicle.top_formula) (FrameClass.base_le _)
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
    have h_modal_t : ⊢[FrameClass.Discrete]
        (Chronicle.next_top.neg.box.imp Chronicle.next_top.neg) :=
      DerivationTree.axiom [] _ (Axiom.modal_t Chronicle.next_top.neg) (FrameClass.base_le _)
    have h_in_neg_next : Chronicle.next_top.neg ∈ M :=
      SetMaximalConsistent.implication_property hM_mcs (theorem_in_mcs hM_mcs h_modal_t) h_box_dense
    -- Contradiction: next_top ∈ M and ¬(next_top) ∈ M
    exact set_consistent_not_both hM_mcs.1 Chronicle.next_top h_in_next h_in_neg_next
  · -- Non-dense: ¬□(F'T) ∈ M. Sub-split on □(U(T,bot)).
    rcases SetMaximalConsistent.negation_complete hM_mcs
      (Formula.box Chronicle.next_top) with h_box_discrete | h_not_box_discrete
    · -- Discrete case: □(U(T,bot)) ∈ M — countermodel on ℤ via Reynolds pipeline
      obtain ⟨D, _, _, _, _, _, _, _, _, F, TM, Omega, h_sc, τ, h_mem, t, h_not_true⟩ :=
        FormalSystem.Metalogic.WeakCanonical.countermodel_discrete_reynolds_v2
          M hM_mcs φ h_neg_in h_box_discrete
      exact h_not_true (h_valid_discrete D F TM Omega h_sc τ h_mem t)
    · -- Mixed case: ¬□(F'T) ∧ ¬□(U(T,bot)) ∈ M — eliminated by structural axiom
      exact False.elim (Chronicle.mcs_mixed_case_absurd FrameClass.Discrete M hM_mcs
          h_not_box_dense h_not_box_discrete)

#print axioms FormalSystem.Metalogic.BXCanonical.completeness_dense
#print axioms FormalSystem.Metalogic.BXCanonical.completeness_discrete

/-! ## Axiom Audit

### completeness_discrete

```
#print axioms completeness_discrete
-- depends on: [propext, Classical.choice, Quot.sound]
```

**`sorryAx`-free.** The Reynolds pipeline
(`countermodel_discrete_reynolds_v2` → `limitdom_is_good` → `no_gaps_discrete_model_surgery`
→ `US_expressively_complete_over_prior` → `kamp_prior_expressive_completeness`
→ `nf_characterizable_temporal_prior` → `nf_nvar_exist_all_depths`, KampPrior.lean) is fully
discharged: the formerly-sorry `| _k + 2` arm of `nf_nvar_exist_all_depths` is RETIRED by the
ζ wire `kampArm_zeta` (ZetaUniformExtract.lean) — the unary E[Σ]-atom re-architecture of
Rabinovich Def 4.1 / Prop 4.3 / Thm 4.4 (PDF pp.5-6), general in the depth. The k=0 and k=1
arms retain their per-depth route (`kampPrior_case1_arm_k0` / `kampPrior_case1_arm_k1`); the
arity-(n≥2) arm is excluded by the domain restriction `hn : n ≤ 1`.

The `chronicle_gap_contradiction` sorry was dead code — not on any live call path — and has
since been archived out of live code entirely, together with its whole closure, to
`Boneyard/DeadChronicleGapElimination/ChronicleGapChainExcision.lean`. It no longer resides in
`ChronicleToCountermodel.lean`. `mcs_mixed_case_absurd` (sorry-free, moved to MCSMixedCase.lean)
is the only Chronicle symbol used by `completeness_discrete`.

### Axiom Classification

- `propext`, `Classical.choice`, `Quot.sound` — standard Lean 4 axioms (acceptable);
  this is the COMPLETE axiom set of both `completeness_dense` and `completeness_discrete`
  (kernel-verified via `#print axioms` against fresh oleans)
- `Lean.ofReduceBool`/`Lean.trustCompiler` — NO LONGER PRESENT. Adjudication outcome: all
  7 in-cone `native_decide` sites were swapped (`Syntax/Formula.lean` `beq_refl` bot arm
  → `rfl`; four `le_max_of_le_right` bounds in
  `Syntax/SubformulaClosure/TemporalFormulas.lean` → `decide`; the two
  `f_nesting_depth F_top`/`p_nesting_depth P_top` calc steps there → `rfl`). No per-site
  fallback was needed (empty retention ledger); the 4 `native_decide` sites in
  `Metalogic/Decidability/SignedFormula.lean` are outside this import cone and untouched.
- no `sorryAx`
-/

#print axioms FormalSystem.Metalogic.BXCanonical.completeness
-- dd_countermodel archived to Boneyard/ScheduleBasedBFMCS/ (see its README.md)
-- Chronicle.countermodel_dense is no longer consumed by `completeness` (its dense branch
-- now uses `countermodel_dense_enriched`); audit retained pending archival.
#print axioms FormalSystem.Metalogic.BXCanonical.Chronicle.countermodel_dense

end FormalSystem.Metalogic.BXCanonical
