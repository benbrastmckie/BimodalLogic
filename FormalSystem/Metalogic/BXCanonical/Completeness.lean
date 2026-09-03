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
import FormalSystem.Metalogic.Algebraic.FlowFrame
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

`completeness`, `completeness_dense` and `completeness_discrete` are all sorryAx-free (see
the Axiom Audit section at the end of this file; axioms: exactly `propext`,
`Classical.choice`, `Quot.sound` — the former `native_decide` dependency was eliminated by
swapping the Syntax-layer sites to `rfl`/`decide`). The general Base-frame `completeness` was
the last to close: its discrete branch calls `WeakCanonical.countermodel_discrete`
(WeakCanonical/GroupModel/CountermodelBase.lean), which builds the countermodel at the
non-Archimedean discrete carrier `ℚ ×ₗ ℤ` off `companionChronicle` rather than reusing the
Reynolds pipeline — a Base-MCS is not automatically Discrete-consistent, so the `ℤ` pipeline
is unavailable there. Its dense branch (`countermodel_dense_enriched`, on ℚ) and mixed branch
(`mcs_mixed_case_absurd`) are sorryAx-free as well.

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
      derivationExchange d (fun x => (cons_filter_neq_perm h_in x).symm)
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
      deductionTheorem [] (Formula.neg φ) Formula.bot d_reord
    -- ¬¬φ → φ by double negation elimination
    have h_dne : DerivationTree fc [] ((Formula.neg (Formula.neg φ)).imp φ) :=
      FormalSystem.Theorems.Propositional.doubleNegation φ
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

open FormalSystem.Metalogic.Algebraic in
/--
Enriched dense countermodel: constructs the same countermodel as `countermodel_dense`
but with `Rat` explicit throughout, so `DenselyOrdered` is available for `ValidDense`.
This is the single canonical dense countermodel used by both `completeness` and
`completeness_dense`. The countermodel lives on the bundle flow frame
(`Metalogic/Algebraic/FlowFrame.lean`), and the witness history is exhibited by its
**totality** (`bundleFlowHistory_total`) — `def:world-history`'s `H_F` — matching the
`def:BL-semantics` box clause and the totality binder of `Valid`/`ValidDense` directly, with
no admissible-history set and no shift-closure side condition.
-/
theorem countermodel_dense_enriched {fc : FrameClass} (A : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := fc) A)
    (φ : Formula) (h_neg_in : φ.neg ∈ A)
    (h_box_dense : Formula.box Chronicle.nextTop.neg ∈ A) :
    ∃ (F : FrameOver (TemporalOrder.of Rat)) (TM : TaskModel F)
      (τ : WorldHistory F) (_ : τ.IsTotal) (t : Rat),
      ¬TruthAt TM τ t φ := by
  let bfmcs := Chronicle.cantorBfmcsDense fc A h_mcs h_box_dense
  let fam₀ := Chronicle.rootedCantorFmcsDense fc A h_mcs h_box_dense 0
  have hfam₀ : fam₀ ∈ bfmcs.families := ⟨A, h_mcs, h_box_dense, 0, fun _ => Iff.rfl, rfl⟩
  refine ⟨bundleFlowFrame bfmcs, bundleFlowModel bfmcs,
    bundleFlowHistory ⟨fam₀, hfam₀⟩ 0, bundleFlowHistory_total _ _,
    0, ?_⟩
  have h_neg_fam : φ.neg ∈ fam₀.mcs ((0 : Rat) + 0) := by
    rw [zero_add, Chronicle.rooted_cantor_fmcs_dense_at_s]; exact h_neg_in
  exact bundleFlow_completeness_from_neg_membership
    bfmcs φ
    (Chronicle.cantor_bfmcs_dense_restricted_tc fc A h_mcs h_box_dense φ
      (fun ψ hψ => Finset.mem_toList.mpr (deferralClosure_subset_extendedDeferralClosure φ hψ)))
    (Chronicle.cantor_bfmcs_dense_restricted_buc fc A h_mcs h_box_dense φ)
    (Chronicle.cantor_bfmcs_dense_restricted_fuc fc A h_mcs h_box_dense φ)
    φ (self_mem_subformulaClosure φ)
    ⟨fam₀, hfam₀⟩ 0 0 h_neg_fam

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
   - Purely discrete (□(U(⊤,⊥)) ∈ w₀): countermodel on `ℚ ×ₗ ℤ` via
     `WeakCanonical.countermodel_discrete`
   - Mixed (¬□(F'T) ∧ ¬□(U(⊤,⊥))): eliminated by `mcs_mixed_case_absurd`
     using the structural axiom `discrete_box_necessity`

**Sorry Status — sorryAx-free.** The Base-MCS discrete branch was the last debt and is
discharged. The case □(U(⊤,⊥)) ∈ w₀ requires a discrete countermodel built from a *Base*-MCS.
The Reynolds pipeline (`countermodel_discrete_reynolds_v2`) requires
`SetMaximalConsistent (fc := FrameClass.Discrete)`, and a Base-MCS is not automatically
Discrete-consistent, so it cannot be reused here; the earlier BX-pipeline route was
irreparably sorried (`succ_cofinal` is provably unfixable — ℤ+ℤ counterexample) and is
archived to `Boneyard/DeadChronicleGapElimination/`. The branch now calls
`WeakCanonical.countermodel_discrete` (WeakCanonical/GroupModel/CountermodelBase.lean), which
takes the third route: build the countermodel directly over the non-Archimedean discrete
carrier `ℚ ×ₗ ℤ`, off `companionChronicle` — `FrameClass.Base` imposes no Archimedean
condition, so that carrier is admissible. The dense and mixed branches are sorryAx-free too.
For the frame-class-specific results, see `completeness_dense` and `completeness_discrete`.

**Why `FrameClass.Base` is essential here**: completeness is a per-frame-class fact — it pairs a
validity notion with the axiom set that captures it. `Valid φ` (validity over *all* linear
temporal frames) is matched by the `Base` axiom set specifically; the dense and discrete
notions have their own statements (`completeness_dense`, `completeness_discrete`) against
`ValidDense` / `ValidDiscrete`. There is no `{fc}`-uniform statement to generalise to.
-/
theorem completeness (φ : Formula) :
    Valid φ → Derivable FrameClass.Base [] φ := by
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
  -- 2. Purely discrete case (□(U(T,bot)) ∈ M): WeakCanonical.countermodel_discrete,
  --    on the non-Archimedean discrete carrier Q x_l Z
  -- 3. Mixed case (¬□(F'T) ∧ ¬□(U(T,bot)) ∈ M): eliminated by the structural
  --    axiom discrete_box_necessity (mcs_mixed_case_absurd)
  rcases SetMaximalConsistent.negation_complete hM_mcs
    (Formula.box Chronicle.nextTop.neg) with h_box_dense | h_not_box_dense
  · -- Dense case: □(F'T) ∈ M — countermodel on Rat (countermodel_dense_enriched)
    obtain ⟨F, TM, τ, h_tot, t, h_not_true⟩ :=
      countermodel_dense_enriched M hM_mcs φ h_neg_in h_box_dense
    exact h_not_true (h_valid.apply F TM τ h_tot t)
  · -- Non-dense: ¬□(F'T) ∈ M. Sub-split on □(U(T,bot)).
    rcases SetMaximalConsistent.negation_complete hM_mcs
      (Formula.box Chronicle.nextTop) with h_box_discrete | h_not_box_discrete
    · -- Purely discrete case: □(U(T,bot)) ∈ M — all box-equivalent MCS's are discrete
      obtain ⟨F, TM, τ, h_tot, t, h_not_true⟩ :=
        WeakCanonical.countermodel_discrete M hM_mcs φ h_neg_in h_box_discrete
      exact h_not_true (h_valid.apply F TM τ h_tot t)
    · -- Mixed case: ¬□(F'T) ∧ ¬□(U(T,bot)) ∈ M — eliminated by structural axiom
      exact False.elim (Chronicle.mcs_mixed_case_absurd FrameClass.Base M hM_mcs
        h_not_box_dense h_not_box_discrete)

/-! ## Frame-Class-Specific Completeness Theorems -/

-- countermodel_discrete_enriched archived to
-- Boneyard/DeadChronicleGapElimination/TransferDead.lean

/--
Dense Completeness Theorem: If a formula is valid on all densely ordered models,
then it is derivable in the Dense proof system.

**Proof Strategy**: Same contrapositive + MCS construction as `completeness`,
but using Dense-derivability and Dense-MCS throughout.
- Dense case: `countermodel_dense_enriched` produces a countermodel on `Rat`
  (DenselyOrdered), directly contradicting `ValidDense`.
- Non-dense case: the `dense_indicator` axiom `¬U(⊤,⊥)` is a Dense
  theorem, so `□(¬U(⊤,⊥))` is in every Dense-MCS, contradicting `¬□(F'T) ∈ M`.

**Sorry Status**: sorryAx-free (machine-verified; axioms: exactly `propext`,
`Classical.choice`, `Quot.sound`). The
non-dense branch closes via the `dense_indicator` axiom: `¬U(⊤,⊥)` is a Dense theorem,
so `□(¬U(⊤,⊥))` is in every Dense-MCS, contradicting `¬□(F'T) ∈ M`.
-/
theorem completeness_dense (φ : Formula) :
    ValidDense φ → Derivable FrameClass.Dense [] φ := by
  intro h_valid_dense
  by_contra h_not_deriv
  have h_cons := neg_consistent_of_not_derivable (fc := FrameClass.Dense) φ h_not_deriv
  obtain ⟨M, hM_sup, hM_mcs⟩ := set_lindenbaum {Formula.neg φ} h_cons
  have h_neg_in : Formula.neg φ ∈ M := hM_sup (Set.mem_singleton _)
  rcases SetMaximalConsistent.negation_complete hM_mcs
    (Formula.box Chronicle.nextTop.neg) with h_box_dense | h_not_box_dense
  · -- Dense case: □(F'T) ∈ M — countermodel on Rat (DenselyOrdered)
    obtain ⟨F, TM, τ, h_tot, t, h_not_true⟩ :=
      countermodel_dense_enriched M hM_mcs φ h_neg_in h_box_dense
    exact h_not_true (ValidIn.apply_total h_valid_dense F inferInstance TM τ h_tot t)
  · -- Non-dense case: ¬□(F'T) ∈ M. But the dense_indicator axiom ¬U(⊤,⊥)
    -- is a Dense theorem, so □(¬U(⊤,⊥)) = □(F'T) is in every Dense-MCS.
    -- Contradiction with h_not_box_dense : ¬□(F'T) ∈ M.
    have h_ax : DerivationTree FrameClass.Dense [] Chronicle.nextTop.neg :=
      DerivationTree.axiom [] _ Axiom.dense_indicator (by trivial)
    have h_box : DerivationTree FrameClass.Dense [] Chronicle.nextTop.neg.box :=
      DerivationTree.necessitation _ h_ax
    have h_in : Chronicle.nextTop.neg.box ∈ M := theorem_in_mcs hM_mcs h_box
    exact set_consistent_not_both hM_mcs.1 (Chronicle.nextTop.neg.box) h_in h_not_box_dense

/--
Discrete Completeness Theorem: If a formula is valid on all discretely ordered models,
then it is derivable in the Discrete proof system.

**Proof Strategy**: Same contrapositive + MCS construction as `completeness`,
but using Discrete-derivability and Discrete-MCS throughout.
- Discrete case (□(U(⊤,⊥)) ∈ M): `countermodel_discrete_reynolds_v2` produces a
  countermodel on `ℤ` (SuccOrder, PredOrder), contradicting `ValidDiscrete`.
- Dense case (□(F'⊤) ∈ M): `U(⊤,⊥)` is a Discrete theorem,
  so `nextTop ∈ M`. From `□(¬U(⊤,⊥)) ∈ M` and Modal T, `¬U(⊤,⊥) ∈ M`,
  contradiction.
- Mixed case: eliminated by `mcs_mixed_case_absurd`.

**Sorry Status**: sorryAx-free (machine-verified; axioms: exactly `propext`,
`Classical.choice`, `Quot.sound` — see the
Axiom Audit section below). The dense-case branch closes by deriving `U(⊤,⊥)` as a
Discrete theorem; the mixed case is eliminated by `mcs_mixed_case_absurd`.
-/
theorem completeness_discrete (φ : Formula) :
    ValidDiscrete φ → Derivable FrameClass.Discrete [] φ := by
  intro h_valid_discrete
  by_contra h_not_deriv
  have h_cons := neg_consistent_of_not_derivable (fc := FrameClass.Discrete) φ h_not_deriv
  obtain ⟨M, hM_sup, hM_mcs⟩ := set_lindenbaum {Formula.neg φ} h_cons
  have h_neg_in : Formula.neg φ ∈ M := hM_sup (Set.mem_singleton _)
  rcases SetMaximalConsistent.negation_complete hM_mcs
    (Formula.box Chronicle.nextTop.neg) with h_box_dense | h_not_box_dense
  · -- Dense case: □(F'T) ∈ M — but U(T,bot) is a Discrete theorem.
    -- Derive nextTop (= U(T,bot)) in the Discrete system, then from
    -- □(neg(nextTop)) ∈ M extract neg(nextTop) ∈ M via Modal T, contradiction.
    -- Step 1: T = bot → bot
    have h_top : ⊢[FrameClass.Discrete] Chronicle.topFormula :=
      FormalSystem.Theorems.Combinators.identity Formula.bot
    -- Steps 2-3: F(T) from seriality + MP
    have h_ft : ⊢[FrameClass.Discrete] Chronicle.topFormula.someFuture :=
      DerivationTree.modus_ponens [] _ _
        (DerivationTree.axiom [] _ Axiom.serial_future (FrameClass.base_le _)) h_top
    -- Steps 4-5: U(T, ¬T) from prior_UZ + MP
    have h_ut_negT : ⊢[FrameClass.Discrete]
        (Formula.untl Chronicle.topFormula.neg Chronicle.topFormula) :=
      DerivationTree.modus_ponens [] _ _
        (DerivationTree.axiom [] _ (Axiom.prior_UZ Chronicle.topFormula) (by trivial)) h_ft
    -- Step 6: ¬T → ⊥ via deduction theorem (assume T→⊥, derive T from identity, MP gives ⊥)
    have h_negT_bot : ⊢[FrameClass.Discrete] (Chronicle.topFormula.neg.imp Formula.bot) := by
      change ⊢[FrameClass.Discrete] ((Chronicle.topFormula.imp Formula.bot).imp Formula.bot)
      exact deductionTheorem [] (Chronicle.topFormula.imp Formula.bot) Formula.bot
        (DerivationTree.modus_ponens [Chronicle.topFormula.imp Formula.bot] Chronicle.topFormula
            Formula.bot
          (DerivationTree.assumption _ _ (by simp))
          (DerivationTree.weakening [] [Chronicle.topFormula.imp Formula.bot] _ h_top (by simp)))
    -- Step 7: G(¬T → ⊥) via temporal necessitation
    have h_G_negT_bot : ⊢[FrameClass.Discrete]
        (Chronicle.topFormula.neg.imp Formula.bot).allFuture :=
      DerivationTree.temporal_necessitation _ h_negT_bot
    -- Step 8: left_mono_until_G: G(¬T→⊥) → (U(T,¬T) → U(T,⊥))
    have h_mono : ⊢[FrameClass.Discrete]
        ((Chronicle.topFormula.neg.imp Formula.bot).allFuture.imp
          ((Formula.untl Chronicle.topFormula.neg Chronicle.topFormula).imp
            (Formula.untl Formula.bot Chronicle.topFormula))) :=
      DerivationTree.axiom [] _ (Axiom.left_mono_until_G Chronicle.topFormula.neg Formula.bot
          Chronicle.topFormula) (FrameClass.base_le _)
    -- Step 9: U(T,¬T) → U(T,⊥)
    have h_imp_next : ⊢[FrameClass.Discrete]
        ((Formula.untl Chronicle.topFormula.neg Chronicle.topFormula).imp Chronicle.nextTop) :=
      DerivationTree.modus_ponens [] _ _ h_mono h_G_negT_bot
    -- Step 10: U(T,⊥) = nextTop
    have h_next_top : ⊢[FrameClass.Discrete] Chronicle.nextTop :=
      DerivationTree.modus_ponens [] _ _ h_imp_next h_ut_negT
    -- Place nextTop in M
    have h_in_next : Chronicle.nextTop ∈ M := theorem_in_mcs hM_mcs h_next_top
    -- Extract ¬(nextTop) from □(¬(nextTop)) via Modal T
    have h_modal_t : ⊢[FrameClass.Discrete]
        (Chronicle.nextTop.neg.box.imp Chronicle.nextTop.neg) :=
      DerivationTree.axiom [] _ (Axiom.modal_t Chronicle.nextTop.neg) (FrameClass.base_le _)
    have h_in_neg_next : Chronicle.nextTop.neg ∈ M :=
      SetMaximalConsistent.mp_of_theorem hM_mcs h_modal_t h_box_dense
    -- Contradiction: nextTop ∈ M and ¬(nextTop) ∈ M
    exact set_consistent_not_both hM_mcs.1 Chronicle.nextTop h_in_next h_in_neg_next
  · -- Non-dense: ¬□(F'T) ∈ M. Sub-split on □(U(T,bot)).
    rcases SetMaximalConsistent.negation_complete hM_mcs
      (Formula.box Chronicle.nextTop) with h_box_discrete | h_not_box_discrete
    · -- Discrete case: □(U(T,bot)) ∈ M — countermodel on ℤ via Reynolds pipeline
      obtain ⟨F, hsucc, hpred, hsuccArch, hpredArch, TM, τ, h_tot, t, h_not_true⟩ :=
        FormalSystem.Metalogic.WeakCanonical.countermodel_discrete_reynolds_v2
          M hM_mcs φ h_neg_in h_box_discrete
      -- The four CARRIER side conditions arrive as ordinary hypotheses out of the existential;
      -- `ValidIn.apply_total` takes the frame condition as the single `Sat .Discrete F` slot, so
      -- the four are packaged back into the existential they came from. The four ALGEBRA binders
      -- the tuple used to carry are gone -- they are the `TemporalOrder` the frame now has as its
      -- `Duration` field.
      --
      -- The witnesses are passed positionally inside the anonymous constructor rather than
      -- through `haveI`: `IsSuccArchimedean` is indexed by its `SuccOrder` argument, so a
      -- `haveI`-introduced *copy* of `hsucc` is a fresh opaque fvar that `hsuccArch`'s type does
      -- not mention, and synthesis then fails to match the two.
      exact h_not_true
        (ValidIn.apply_total h_valid_discrete F ⟨hsucc, hpred, hsuccArch, hpredArch⟩ TM τ h_tot t)
    · -- Mixed case: ¬□(F'T) ∧ ¬□(U(T,bot)) ∈ M — eliminated by structural axiom
      exact False.elim (Chronicle.mcs_mixed_case_absurd FrameClass.Discrete M hM_mcs
          h_not_box_dense h_not_box_discrete)

#print axioms FormalSystem.Metalogic.BXCanonical.completeness
#print axioms FormalSystem.Metalogic.BXCanonical.completeness_dense
#print axioms FormalSystem.Metalogic.BXCanonical.completeness_discrete

/-! ## Axiom Audit

### completeness

```
#print axioms completeness
-- depends on: [propext, Classical.choice, Quot.sound]
```

**`sorryAx`-free.** Its three branches are the dense one (`countermodel_dense_enriched`, on ℚ),
the mixed one (`mcs_mixed_case_absurd`, vacuous), and the discrete one
(`WeakCanonical.countermodel_discrete` → `companionChronicle` → `companionGeneral`, on
`ℚ ×ₗ ℤ`). The discrete branch was the last debt in the tree; with it discharged,
`FormalSystem/` outside `Boneyard/` contains no structural `sorry` at all — asserted by check
C3 of `scripts/check-module-invariants.sh`, and pinned for this theorem by check C2.

### completeness_discrete

```
#print axioms completeness_discrete
-- depends on: [propext, Classical.choice, Quot.sound]
```

**`sorryAx`-free.** The Reynolds pipeline
(`countermodel_discrete_reynolds_v2` → `limitdom_is_good` → `no_gaps_discrete_model_surgery`
→ `uSExpressivelyCompleteOverPrior` → `kampPriorExpressiveCompleteness`
→ `nfCharacterizableTemporalPrior` → `nf_nvar_exist_all_depths`, KampPrior.lean) is fully
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
  this is the COMPLETE axiom set of `completeness`, `completeness_dense` and
  `completeness_discrete` alike (kernel-verified via `#print axioms` against fresh oleans)
- `Lean.ofReduceBool`/`Lean.trustCompiler` — NO LONGER PRESENT. Adjudication outcome: all
  7 in-cone `native_decide` sites were swapped (`Syntax/Formula.lean` `beq_refl` bot arm
  → `rfl`; four `le_max_of_le_right` bounds in
  `Syntax/SubformulaClosure/TemporalFormulas.lean` → `decide`; the two
  `fNestingDepth fTop`/`pNestingDepth pTop` calc steps there → `rfl`). No per-site
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
