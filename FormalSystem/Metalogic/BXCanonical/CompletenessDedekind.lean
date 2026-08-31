/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.BXCanonical.Completeness
import FormalSystem.Metalogic.WeakCanonical.RealModel.ChronicleRealFlow
import Mathlib.Algebra.Order.Archimedean.Real.Basic

/-!
# Dedekind Completeness: carrier probe and the box-dense branch

This module hosts the `FrameClass.Dedekind` completeness branch. It is the Dedekind analogue
of the `completeness_dense` material in the sibling module `Completeness.lean`, built on the
real line rather than on `Rat`.

## Scope of the Dedekind axioms

Reynolds 1992 (printed p.169) is explicit that the Prior axioms enforce only a *definably*
Dedekind complete model: "there may be gaps in the order but ... you wouldn't know that just
looking at the behaviour of temporal formulas." Nothing in this file — and nothing downstream
of it — may claim order-theoretic gap-freeness of the canonical carrier. The gap-freeness that
is available is definable gap-freeness, a consequence of Prior-U, and it is used only where a
temporal formula is at stake.

The Dedekind-completeness side condition that the *semantic* target needs is supplied instead
by the carrier: `ValidDedekindDense` (see `FormalSystem/Semantics/Validity.lean`) carries the
least-upper-bound property as an explicit `Prop` hypothesis, and `real_lub_of_bddAbove` below
discharges it for `ℝ` from Mathlib's conditionally complete linear order instance. There is
therefore no order-theoretic bridge to build.

## Contents

* `real_lub_of_bddAbove` — `ℝ` discharges the lub hypothesis of `ValidDedekindDense`.
* `dedekind_box_dense_mem` — every `FrameClass.Dedekind`-MCS contains `□(¬U(⊤,⊥))`.
* `chronicle_eval_family_zero_eq_root` — the root placement: the chronicle bundle's evaluation
  family takes the value `A` at time `0`.
* `countermodel_dedekind_dense` — Reynolds §9 Theorem 7's countermodel, on `ℝ`.
* `completeness_dedekind_engine` — the single-formula completeness engine for
  `ValidDedekindDense`, which `StrongCompleteness.lean` instantiates into the unconditional
  terminus.

The `example`s in the "Carrier probe" section are compile-time checks, not exports: they record
that the `D`-generic bundle flow machinery accepts `D := ℝ` unchanged, which is the
hypothesis the whole Dedekind route rests on.

## References

- Reynolds 1992, §1, printed p.169 (definably-Dedekind-complete scoping).
- Reynolds 1992, printed p.168 (US/R's density axioms, this tree's `Axiom.dense_indicator`).
-/

namespace FormalSystem.Metalogic.BXCanonical

open FormalSystem.Syntax
open FormalSystem.ProofSystem
open FormalSystem.Metalogic.Core
open FormalSystem.Metalogic.Bundle
open FormalSystem.Semantics

/-! ## Carrier probe: the `D`-generic machinery at `D := ℝ`

These `example`s exist to fail loudly if the bundle flow machinery
(`Metalogic/Algebraic/FlowFrame.lean`) ever acquires a binder that `ℝ` cannot discharge (a
`Countable`, an `Encodable`, a `SuccOrder`, ...). They are the compile-time form of the claim
"only the layer beneath the chronicle moves to `ℝ`". -/

section CarrierProbe

open FormalSystem.Metalogic.Algebraic

variable {fc : FrameClass}

/-- The bundle flow frame elaborates at `D := ℝ`. -/
noncomputable example (B : BFMCS (fc := fc) ℝ) : ParamTaskFrame ℝ := bundleFlowFrame B

/-- The bundle flow model elaborates at `D := ℝ`. -/
noncomputable example (B : BFMCS (fc := fc) ℝ) : TaskModel (bundleFlowFrame B) :=
  bundleFlowModel B

/-- The flow-line history space — the frame's total-history set `H_F`
(`def:world-history`) — elaborates at `D := ℝ`. -/
noncomputable example (B : BFMCS (fc := fc) ℝ) :
    Set (WorldHistory (bundleFlowFrame B)) :=
  {σ | ∀ t, σ.domain t}

/--
The re-hosted completeness engine typechecks at `D := ℝ` against a hypothesised real-carrier
bundle. This is the load-bearing probe: it is the single declaration the Dedekind countermodel
will be assembled from, and its binder list is `{fc} {D} [AddCommGroup D] [LinearOrder D]
[IsOrderedAddMonoid D] [Nontrivial D]` — no `DenselyOrdered`, no `Countable`, no `Rat`.
-/
noncomputable example (B : BFMCS (fc := fc) ℝ) (root : Formula)
    (h_rtc : B.RestrictedTemporallyCoherent root)
    (h_buc : B.RestrictedBackwardUntilSinceCoherent root)
    (h_fuc : B.RestrictedForwardUntilSinceCoherent root)
    (φ : Formula) (h_sub : φ ∈ subformulaClosure root)
    (fam : FMCS (fc := fc) ℝ) (hfam : fam ∈ B.families)
    (w₀ t : ℝ) (h_neg_in : φ.neg ∈ fam.mcs (w₀ + t)) :
    ¬TruthAt (bundleFlowModel B) (bundleFlowHistory ⟨fam, hfam⟩ w₀) t φ :=
  bundleFlow_completeness_from_neg_membership B root h_rtc h_buc h_fuc φ h_sub
    ⟨fam, hfam⟩ w₀ t h_neg_in

end CarrierProbe

/-! ## `ℝ` discharges the `ValidDedekindDense` binders

`AddCommGroup`, `LinearOrder`, `IsOrderedAddMonoid`, `DenselyOrdered` and `Nontrivial` are all
found by instance search. The remaining binder of `ValidDedekindDense`
(`FormalSystem/Semantics/Validity.lean`) is an explicit `Prop`, so it needs a named lemma. -/

/-- Instance-search check for the five class binders of `ValidDedekindDense` at `D := ℝ`. -/
noncomputable example : AddCommGroup ℝ := inferInstance

noncomputable example : LinearOrder ℝ := inferInstance

noncomputable example : IsOrderedAddMonoid ℝ := inferInstance

noncomputable example : DenselyOrdered ℝ := inferInstance

noncomputable example : Nontrivial ℝ := inferInstance

/--
The least-upper-bound hypothesis of `ValidDedekindDense` holds on `ℝ`.

This is the explicit `Prop` binder at the head of `ValidDedekindDense`; every application of a
`ValidDedekindDense` hypothesis at the real carrier discharges it with this lemma. The content
is Mathlib's `ConditionallyCompleteLinearOrder ℝ` instance: `sSup s` is a least upper bound of
any nonempty bounded-above `s`.
-/
theorem real_lub_of_bddAbove :
    ∀ s : Set ℝ, s.Nonempty → BddAbove s → ∃ x, IsLUB s x :=
  fun _ hne hbd => ⟨_, isLUB_csSup hne hbd⟩

/-! ## The box-dense branch at `FrameClass.Dedekind` -/

/--
Every `FrameClass.Dedekind`-MCS contains `□(¬U(⊤,⊥))`.

This is the Dedekind analogue of the non-dense branch of `completeness_dense`
(sibling module `Completeness.lean`): `Axiom.dense_indicator` states `¬U(⊤,⊥)`, whose
`minFrameClass` is `.Dense`, and `FrameClass.Dense ≤ FrameClass.Dedekind`, so the axiom is
admissible in a `.Dedekind` derivation. Necessitation then puts the box in every Dedekind-MCS
via `theorem_in_mcs`.

Consequence: the case split that `completeness_dense` performs on `□(¬U(⊤,⊥)) ∈ M` collapses at
`.Dedekind` — there is no non-dense branch to discharge, and the countermodel construction may
assume the box-dense hypothesis unconditionally.

The placement of `Dedekind` above `Dense` is primary-source: Reynolds 1992 (printed p.168)
includes density axioms in US/R, and `K⁺⊤` normalises to this tree's `Axiom.dense_indicator`.
-/
theorem dedekind_box_dense_mem {A : Set Formula}
    (h_mcs : SetMaximalConsistent (fc := FrameClass.Dedekind) A) :
    Formula.box Chronicle.nextTop.neg ∈ A := by
  have h_ax : DerivationTree FrameClass.Dedekind [] Chronicle.nextTop.neg :=
    DerivationTree.axiom [] _ Axiom.dense_indicator (by trivial)
  have h_box : DerivationTree FrameClass.Dedekind [] Chronicle.nextTop.neg.box :=
    DerivationTree.necessitation _ h_ax
  exact theorem_in_mcs h_mcs h_box

/-! ## Reynolds §9 Theorem 7: the countermodel on `ℝ`

Reynolds 1992, §9 Theorem 7, printed p.189. The five steps of the printed proof, and where
each lives:

1. *"First use Burgess--Xu Corollary 1 to furnish us with a structure `M₀` … the flow of time
   of `M₀` is the rationals"* — `Chronicle.cantorBfmcsDense`
   (`Chronicle/ChronicleToCountermodelBasic.lean`).
2. *"By ignoring all the atoms which don't appear in `A₀` we have a temporal structure `M`
   from a finite language"* — `Chronicle.chronicleMonadicStructure`
   (`Chronicle/ChronicleMonadicBridge.lean`), over the finite signature `mkSigFrom φ`.
3. *"The flow of time of `M` is countable, dense and without end points and D1 and D2 follow
   from the theorems 4 and 5"* — `Chronicle.chronicleMonadic_doetsD1` /
   `chronicleMonadic_doetsD2` (`WeakCanonical/RealModel/ChronicleRealFlow.lean`).
4. *"there is a structure with flow of time `ℝ` satisfying the same monadic first-order
   sentences of quantifier depth at most `k`"* — `Chronicle.chronicleRealFlow` and
   `chronicleRealFlow_kEquiv`, Doets' theorem (§8 Theorem 6) at the chronicle bridge.
5. The table transfer `R ⊨ ∃t α(t)` from `M ⊨ ∃t α(t)`, and the read-back of the `ℝ`-flowed
   monadic structure as a `ParamTaskFrame ℝ` — this section.

**On the table `α(t)`.** Step 5's *"table"* of a formula and its quantifier depth is **not**
introduced here: the tree already has it, as `table` / `table_correctness` /
`table_depth_bound` (`WeakCanonical/Table.lean`) — `table sig atomMap ψ` is the monadic
first-order transcription of `ψ` with one free variable, `table_correctness` is `M ⊨ α(t) ↔
TemporalTruth M t ψ`, and `table_depth_bound` is `(table … ψ).quantifierDepth ≤
operatorDepth ψ`. The quantifier depth is set to `k := operatorDepth φ + 2`, *"one greater
than the depth"* with a further `+1` so that `2 ≤ k` holds unconditionally, which is Doets'
theorem's own standing hypothesis. `staviFoDepth`/`tableMu`
(`WeakCanonical/EFGames/StaviCompleteness.lean`) is the μ-relativized variant used by the
Stavi development and is **not** what §9 needs; the plain `table` layer is.

**ADAPTED-FROM**: `countermodel_discrete_reynolds_v2`
(`WeakCanonical/IntegerModel/ReynoldsBridge.lean:739`), statement-for-statement with
`ℤ → ℝ`. The `ℤ` original is untouched and still consumed by `completeness_discrete`. Three
things change beyond the carrier: the per-family monadic structure is the chronicle bridge
rather than the limit-domain structure, so the truth correspondence is
`Chronicle.chronicleMonadic_truth_correspondence_eval` rather than the
`limitdomEffectiveFormula` route; the interval-carrier bookkeeping collapses, because
`IsRealFlow` says the carrier set is *all* of `ℝ` and there are no `lo`/`hi` bounds to
eliminate; and the induction carries `subformulaClosure` membership rather than a
`predFormulas` inclusion, which is what the chronicle correspondence is stated against. -/

open FormalSystem.Metalogic.WeakCanonical in
/--
The point of an `ℝ`-flowed interval structure at a given real.

`IsRealFlow` is `carrierSet = Set.univ` (`RealModel/DoetsTheorem.lean`), so every real is in
the carrier and this is total. It is the dense analogue of `toCarrier`
(`ReynoldsBridge.lean:663`), which needs `lo = none` and `hi = none` separately because a
`ZIntervalStructure` records its bounds.

No source: bookkeeping, original work.
-/
def realFlowPoint {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    {R : RIntervalStructure sig} (h : R.IsRealFlow) (x : ℝ) : R.intervalCarrier :=
  ⟨x, by
    have h' : R.carrierSet = Set.univ := h
    rw [h']; exact Set.mem_univ x⟩

open FormalSystem.Metalogic.WeakCanonical in
@[simp] theorem realFlowPoint_val {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] {R : RIntervalStructure sig} (h : R.IsRealFlow) (x : ℝ) :
    (realFlowPoint h x).val = x := rfl

/-! ### The root placement

Reynolds' step 1 delivers `M₀ ⊨ A₀(0)`: the root MCS sits at time `0`. In this tree that is
`cantorBfmcsDense`'s `evalFamily` field being `rootedCantorFmcsDense … 0`, whose value at `0`
is the root by `rooted_cantor_fmcs_dense_at_s`. The composition is recorded as a named lemma
rather than as an inline `have` because a mismatch here is silent: the countermodel would be
built at the wrong MCS and still typecheck. -/

/--
**Root placement.** The chronicle bundle's evaluation family takes the value `A` at time `0`.

`Chronicle.rooted_cantor_fmcs_dense_at_s` (`ChronicleToCountermodelBasic.lean:513`) at `s = 0`,
composed with `cantorBfmcsDense`'s `evalFamily := rootedCantorFmcsDense fc A h_mcs h_box 0`
(`:612`). Reynolds 1992, §9, printed p.189, *"`M₀ ⊨ A₀(0)`"*.
-/
theorem chronicle_eval_family_zero_eq_root {fc : FrameClass} (A : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := fc) A)
    (h_box_dense : Formula.box Chronicle.nextTop.neg ∈ A) :
    (Chronicle.cantorBfmcsDense fc A h_mcs h_box_dense).evalFamily.mcs 0 = A :=
  Chronicle.rooted_cantor_fmcs_dense_at_s fc A h_mcs h_box_dense 0

open FormalSystem.Metalogic.WeakCanonical in
open FormalSystem.Metalogic.BXCanonical.Chronicle in
/--
**The box predicate on the chronicle bridge is the box content of the root MCS**, at every
point of the rational flow.

`chronicleMonadicStructureOf`'s `interp p q` is `p.val ∈ fam.mcs q`, `mkAtomMapFwd` is the
identity on `predFormulas`, and `box_stable_in_rooted_cantor_fmcs_dense`
(`ChronicleToCountermodelBasic.lean:531`) makes the box content constant along the flow. This
is the dense counterpart of `box_stable_in_limit_f`'s role in
`countermodel_discrete_reynolds_v2`.

No source: bookkeeping over the chronicle's own box stability, original work.
-/
theorem chronicleMonadic_box_interp_iff {fc : FrameClass} (N : Set Formula)
    (hN : SetMaximalConsistent (fc := fc) N) (hbox : Formula.box Chronicle.nextTop.neg ∈ N)
    (root ψ : Formula) (h_pred : Formula.box ψ ∈ root.predFormulas) (q : Rat) :
    (Chronicle.chronicleMonadicStructure fc N hN hbox root).interp
        (mkAtomMapFwd root (Formula.box ψ)) q ↔ Formula.box ψ ∈ N := by
  show (mkAtomMapFwd root (Formula.box ψ)).val ∈
    (Chronicle.cantorBfmcsDense fc N hN hbox).evalFamily.mcs q ↔ _
  rw [mkAtomMapFwd_on_predFormulas root (Formula.box ψ) h_pred]
  exact Chronicle.box_stable_in_rooted_cantor_fmcs_dense fc N hN hbox ψ 0 q

/--
**Modal T along the chronicle flow**: if `□ψ` is in the root MCS then `ψ` is in the chronicle's
evaluation-family MCS at every rational point.

Box stability puts `□ψ` in every `mcs q`; `Axiom.modal_t` — a Base axiom, hence admissible at
every frame class via `FrameClass.base_le` — then puts `ψ` there too.

No source: routine, original work.
-/
theorem chronicle_mem_of_box_mem {fc : FrameClass} (N : Set Formula)
    (hN : SetMaximalConsistent (fc := fc) N) (hbox : Formula.box Chronicle.nextTop.neg ∈ N)
    (ψ : Formula) (h_box_N : Formula.box ψ ∈ N) (q : Rat) :
    ψ ∈ (Chronicle.cantorBfmcsDense fc N hN hbox).evalFamily.mcs q := by
  have h_box_q : Formula.box ψ ∈
      (Chronicle.cantorBfmcsDense fc N hN hbox).evalFamily.mcs q :=
    (Chronicle.box_stable_in_rooted_cantor_fmcs_dense fc N hN hbox ψ 0 q).mpr h_box_N
  have h_mcs_q := (Chronicle.cantorBfmcsDense fc N hN hbox).evalFamily.is_mcs q
  exact SetMaximalConsistent.implication_property h_mcs_q
    (theorem_in_mcs h_mcs_q
      (DerivationTree.axiom [] _ (Axiom.modal_t ψ) (FrameClass.base_le _))) h_box_q

open FormalSystem.Metalogic.WeakCanonical in
open FormalSystem.Metalogic.BXCanonical.Chronicle in
open FormalSystem.Metalogic.Algebraic in
/--
**Reynolds §9 Theorem 7, the countermodel half** (printed p.189).

For any frame class `fc` above `FrameClass.Dedekind` and any `fc`-MCS `A` containing `¬φ` and
the box-dense indicator `□(¬U(⊤,⊥))`, there is a task model **over the real line** in which
`φ` fails.

The construction is the dense mirror of `countermodel_discrete_reynolds_v2`: one `ℝ`-flowed
monadic structure per box-equivalence class of MCSs, assembled into the single task frame
`multiFamTaskFrameGen ℝ FamIdx` whose world states are `FamIdx × ℝ`. Box quantification over
the frame's total histories `H_F` — which comprises every family at every offset
(`multiFamGen_total_eq_range`) — is what makes the modal dimension come
out right, exactly as in the `ℤ` original: the monadic language never unfolds `□`, it reads it
as an opaque unary predicate, and the S5 content is carried by the chronicle's box-equivalence
instead.

Note the hypothesis list: `hfc` and the chronicle's own three. No Dedekind-completeness side
condition appears, because none is needed — the carrier is `ℝ`, and the lub property that
`ValidDedekindDense` demands of the *semantic* side is discharged separately by
`real_lub_of_bddAbove`.
-/
theorem countermodel_dedekind_dense {fc : FrameClass} (hfc : FrameClass.Dedekind ≤ fc)
    (A : Set Formula) (h_mcs : SetMaximalConsistent (fc := fc) A)
    (φ : Formula) (h_neg_in : φ.neg ∈ A)
    (h_box_dense : Formula.box Chronicle.nextTop.neg ∈ A) :
    ∃ (F : ParamTaskFrame ℝ) (TM : TaskModel F)
      (τ : WorldHistory F) (_ : τ.IsTotal) (t : ℝ),
      ¬TruthAt TM τ t φ := by
  classical
  -- The finite monadic language and the depth Reynolds sets "one greater than the depth".
  let sig := mkSigFrom φ
  let k := operatorDepth φ + 2
  have hk : 2 ≤ k := Nat.le_add_left 2 _
  -- One family per box-equivalence class of MCSs, as in the `ℤ` original.
  let FamIdx := {N : Set Formula // SetMaximalConsistent (fc := fc) N ∧
    Formula.box Chronicle.nextTop.neg ∈ N ∧ (∀ ψ, Formula.box ψ ∈ A ↔ Formula.box ψ ∈ N)}
  let f₀ : FamIdx := ⟨A, h_mcs, h_box_dense, fun _ => Iff.rfl⟩
  -- The root family inhabits the index, discharging the flow frame's carrier nonemptiness.
  haveI : Nonempty FamIdx := ⟨f₀⟩
  -- Step 2: the chronicle bridge at each family, over `ℚ`.
  let Mst : FamIdx → OrderedMonadicStructure sig := fun f =>
    chronicleMonadicStructure fc f.val f.property.1 f.property.2.1 φ
  -- Steps 3-4: Doets' theorem at each family, giving the `ℝ`-flowed `≡ₖ`-equivalent.
  let Rf : FamIdx → RIntervalStructure sig := fun f =>
    chronicleRealFlow hfc f.val f.property.1 f.property.2.1 φ k hk
  have hR : ∀ f : FamIdx, (Rf f).IsRealFlow := fun f =>
    chronicleRealFlow_isRealFlow hfc f.val f.property.1 f.property.2.1 φ k hk
  have h_k_equiv : ∀ f : FamIdx, KEquiv sig k (Mst f) ((Rf f).toOrdered sig) := fun f =>
    chronicleRealFlow_kEquiv hfc f.val f.property.1 f.property.2.1 φ k hk
  -- The task model: the valuation at `(f, x)` reads `R_f`'s atom predicate at `x`.
  let TM : TaskModel (multiFamTaskFrameGen ℝ FamIdx) :=
    { valuation := fun w a => (Rf w.1).interp (mkAtomMapFwd φ (.atom a)) w.2 }
  -- Step 1 + root placement: `¬φ` is true at `0` in the chronicle bridge.
  have h_not_phi : ¬TemporalTruth (Mst f₀) (mkAtomMapFwd φ) (0 : Rat) φ := by
    intro h_true
    have h_mem := (chronicleMonadic_truth_correspondence_eval fc A h_mcs h_box_dense φ φ
      (self_mem_subformulaClosure φ) 0).mp h_true
    rw [chronicle_eval_family_zero_eq_root A h_mcs h_box_dense] at h_mem
    exact set_consistent_not_both h_mcs.1 φ h_mem h_neg_in
  have h_root_neg : TemporalTruth (Mst f₀) (mkAtomMapFwd φ) (0 : Rat) φ.neg := by
    simp only [Formula.neg, TemporalTruth]
    exact fun h => absurd h h_not_phi
  -- Step 5, first half: transfer `∃t α(t)` across `≡ₖ` and extract the witness in `R_{f₀}`.
  have h_k_bound : operatorDepth φ.neg + 1 ≤ k := by
    simp only [k, Formula.neg, operatorDepth]; omega
  obtain ⟨s₀, h_neg_s₀⟩ := truth_transfer (mkAtomMapFwd φ) (h_k_equiv f₀) φ.neg h_k_bound
    (0 : Rat) h_root_neg
  -- Step 5, second half: the `ℝ`-flowed structure read back as a task model.
  suffices h_truth_corr : ∀ ψ : Formula, ψ ∈ subformulaClosure φ →
      ∀ (f : FamIdx) (w₀ t : ℝ),
      TruthAt TM (multiFamHistoryGen f w₀) t ψ ↔
        TemporalTruth ((Rf f).toOrdered sig) (mkAtomMapFwd φ) (realFlowPoint (hR f) (w₀ + t))
          ψ by
    refine ⟨multiFamTaskFrameGen ℝ FamIdx, TM, multiFamHistoryGen f₀ 0,
      multiFamHistoryGen_total f₀ 0, s₀.val, ?_⟩
    intro h_truth_phi
    have h_corr := (h_truth_corr φ (self_mem_subformulaClosure φ) f₀ 0 s₀.val).mp h_truth_phi
    have h_eq : realFlowPoint (hR f₀) (0 + s₀.val) = s₀ :=
      Subtype.ext (show (0 : ℝ) + s₀.val = s₀.val by ring)
    rw [h_eq] at h_corr
    exact h_neg_s₀ h_corr
  intro ψ h_sub f w₀ t
  induction ψ generalizing f w₀ t with
  | atom a =>
    simp only [TruthAt, TemporalTruth, multiFamHistoryGen, TM]
    exact ⟨fun ⟨_, h⟩ => h, fun h => ⟨trivial, h⟩⟩
  | bot => simp only [TruthAt, TemporalTruth]
  | imp ψ₁ ψ₂ ih₁ ih₂ =>
    simp only [TruthAt, TemporalTruth]
    exact Iff.imp (ih₁ (closure_imp_left φ ψ₁ ψ₂ h_sub) f w₀ t)
      (ih₂ (closure_imp_right φ ψ₁ ψ₂ h_sub) f w₀ t)
  | box ψ ih =>
    have h_sub_ψ : ψ ∈ subformulaClosure φ := closure_box φ ψ h_sub
    have h_box_pred_mem : Formula.box ψ ∈ φ.predFormulas :=
      box_mem_predFormulas_of_mem_closure ψ φ h_sub
    have h_box_depth : operatorDepth (.box ψ) ≤ operatorDepth φ :=
      predFormulas_operator_depth_le φ (.box ψ) h_box_pred_mem
    have h_depth_all : (MonadicFormula.all (table sig (mkAtomMapFwd φ) ψ)).quantifierDepth ≤ k := by
      simp only [MonadicFormula.quantifierDepth, k, operatorDepth] at h_box_depth ⊢
      exact Nat.succ_le_of_lt (Nat.lt_of_le_of_lt (table_depth_bound sig (mkAtomMapFwd φ) ψ)
        (by omega))
    -- The `∀`-sentence `∀x α(x)` transfers across `≡ₖ` in both directions.
    have h_transfer : ∀ f' : FamIdx,
        (∀ x : ((Rf f').toOrdered sig).carrier,
            TemporalTruth ((Rf f').toOrdered sig) (mkAtomMapFwd φ) x ψ) ↔
          ∀ x : (Mst f').carrier, TemporalTruth (Mst f') (mkAtomMapFwd φ) x ψ := by
      intro f'
      have h_sent := k_equiv_preserves_sentence (h_k_equiv f')
        (MonadicFormula.all (table sig (mkAtomMapFwd φ) ψ)) h_depth_all
      simp only [eval] at h_sent
      constructor
      · intro h_all x
        have h_env : Fin.cons x Fin.elim0 = (fun (_ : Fin 1) => x) := by
          funext i; fin_cases i; rfl
        have h_ev := h_sent.mpr (fun y => by
          have h_envy : Fin.cons y Fin.elim0 = (fun (_ : Fin 1) => y) := by
            funext i; fin_cases i; rfl
          exact h_envy ▸ (table_correctness ((Rf f').toOrdered sig) (mkAtomMapFwd φ) y ψ).mpr
            (h_all y)) x
        replace h_ev := h_env ▸ h_ev
        exact (table_correctness (Mst f') (mkAtomMapFwd φ) x ψ).mp h_ev
      · intro h_all x
        have h_env : Fin.cons x Fin.elim0 = (fun (_ : Fin 1) => x) := by
          funext i; fin_cases i; rfl
        have h_ev := h_sent.mp (fun y => by
          have h_envy : Fin.cons y Fin.elim0 = (fun (_ : Fin 1) => y) := by
            funext i; fin_cases i; rfl
          exact h_envy ▸ (table_correctness (Mst f') (mkAtomMapFwd φ) y ψ).mpr (h_all y)) x
        replace h_ev := h_env ▸ h_ev
        exact (table_correctness ((Rf f').toOrdered sig) (mkAtomMapFwd φ) x ψ).mp h_ev
    -- `□ψ ∈ N_{f'}` makes the box predicate true everywhere on `R_{f'}` (`∀x P(x)` transfers),
    -- and, via Modal T, makes `ψ` true everywhere on `R_{f'}` as well.
    let p : sig.preds := mkAtomMapFwd φ (Formula.box ψ)
    have h_pred_transfer : ∀ f' : FamIdx, Formula.box ψ ∈ f'.val →
        ∀ x : ((Rf f').toOrdered sig).carrier, ((Rf f').toOrdered sig).interp p x := by
      intro f' h_box_N'
      have h_depth : (MonadicFormula.all (.atom p ⟨0, by omega⟩) :
          MonadicSentence sig).quantifierDepth ≤ k := by
        simp only [MonadicFormula.quantifierDepth, k]; omega
      have h_eval_M : eval (Mst f') Fin.elim0 (MonadicFormula.all (.atom p ⟨0, by omega⟩)) := by
        simp only [eval]
        intro x
        exact (chronicleMonadic_box_interp_iff f'.val f'.property.1 f'.property.2.1 φ ψ
          h_box_pred_mem x).mpr h_box_N'
      have h_eval_R := (k_equiv_preserves_sentence (h_k_equiv f') _ h_depth).mp h_eval_M
      simp only [eval] at h_eval_R
      exact fun x => h_eval_R x
    have h_psi_all : ∀ f' : FamIdx, Formula.box ψ ∈ f'.val →
        ∀ x : ((Rf f').toOrdered sig).carrier,
          TemporalTruth ((Rf f').toOrdered sig) (mkAtomMapFwd φ) x ψ := by
      intro f' h_box_N'
      refine (h_transfer f').mpr (fun x => ?_)
      exact (chronicleMonadic_truth_correspondence_eval fc f'.val f'.property.1
        f'.property.2.1 φ ψ h_sub_ψ x).mpr
        (chronicle_mem_of_box_mem f'.val f'.property.1 f'.property.2.1 ψ h_box_N' x)
    simp only [TruthAt]
    constructor
    · -- Forward: `ψ` true on every family at every offset forces `□ψ ∈ A`, hence the box
      -- predicate at `f`.
      intro h_all
      have h_psi_in_all : ∀ f' : FamIdx, ψ ∈ f'.val := by
        intro f'
        have h_pt : ∀ x : ((Rf f').toOrdered sig).carrier,
            TemporalTruth ((Rf f').toOrdered sig) (mkAtomMapFwd φ) x ψ := by
          intro x
          have h_tot := multiFamHistoryGen_total (D := ℝ) f' (x.val - t)
          have h_ta := h_all _ h_tot
          rw [ih h_sub_ψ f' (x.val - t) t] at h_ta
          have h_eq : realFlowPoint (hR f') (x.val - t + t) = x :=
            Subtype.ext (show x.val - t + t = x.val by ring)
          rwa [h_eq] at h_ta
        have h_mem := (chronicleMonadic_truth_correspondence_eval fc f'.val f'.property.1
          f'.property.2.1 φ ψ h_sub_ψ 0).mp ((h_transfer f').mp h_pt (0 : Rat))
        rwa [chronicle_eval_family_zero_eq_root f'.val f'.property.1 f'.property.2.1] at h_mem
      have h_box_A : Formula.box ψ ∈ A := by
        by_contra h_not_box
        have h_neg_box : (Formula.box ψ).neg ∈ A :=
          (SetMaximalConsistent.negation_complete h_mcs (Formula.box ψ)).resolve_left h_not_box
        have h_diamond_neg : (Formula.neg ψ).diamond ∈ A :=
          SetMaximalConsistent.contrapositive h_mcs
            (liftBase fc (FormalSystem.Metalogic.Bundle.boxDneTheorem ψ)) h_neg_box
        obtain ⟨v, h_v_mcs, h_v_equiv, h_neg_ψ_v⟩ :=
          bx_modal_witness_fc h_mcs (Formula.neg ψ) h_diamond_neg
        have h_box_dense_v : Formula.box Chronicle.nextTop.neg ∈ v :=
          (h_v_equiv Chronicle.nextTop.neg).mp h_box_dense
        exact set_consistent_not_both h_v_mcs.1 ψ
          (h_psi_in_all ⟨v, h_v_mcs, h_box_dense_v, h_v_equiv⟩) h_neg_ψ_v
      exact h_pred_transfer f ((f.property.2.2 ψ).mp h_box_A) _
    · -- Backward: the box predicate at `f` forces `□ψ ∈ A`, hence `ψ` everywhere on every
      -- family.
      intro h_box σ h_mem
      obtain ⟨f', w₀', h_eq⟩ := multiFamGen_total_eq σ h_mem
      rw [h_eq, ih h_sub_ψ f' w₀' t]
      have h_ex_depth : (MonadicFormula.ex (.atom p ⟨0, by omega⟩) :
          MonadicSentence sig).quantifierDepth ≤ k := by
        simp only [MonadicFormula.quantifierDepth, k]; omega
      have h_ex_R : eval ((Rf f).toOrdered sig) Fin.elim0
          (MonadicFormula.ex (.atom p ⟨0, by omega⟩)) := by
        simp only [eval]
        exact ⟨realFlowPoint (hR f) (w₀ + t), h_box⟩
      have h_ex_M := ((k_equiv_preserves_sentence (h_k_equiv f) _ h_ex_depth).symm).mp h_ex_R
      simp only [eval] at h_ex_M
      obtain ⟨q, h_pred_q⟩ := h_ex_M
      have h_box_N : Formula.box ψ ∈ f.val :=
        (chronicleMonadic_box_interp_iff f.val f.property.1 f.property.2.1 φ ψ
          h_box_pred_mem q).mp h_pred_q
      have h_box_A : Formula.box ψ ∈ A := (f.property.2.2 ψ).mpr h_box_N
      exact h_psi_all f' ((f'.property.2.2 ψ).mp h_box_A) _
  | untl ψ₂ ψ₁ ih₂ ih₁ =>
    have h_sub₁ : ψ₁ ∈ subformulaClosure φ := closure_untl_left φ ψ₁ ψ₂ h_sub
    have h_sub₂ : ψ₂ ∈ subformulaClosure φ := closure_untl_right φ ψ₁ ψ₂ h_sub
    simp only [TruthAt, TemporalTruth]
    constructor
    · rintro ⟨s, hts, hψ₁, hguard⟩
      refine ⟨realFlowPoint (hR f) (w₀ + s), ?_, ?_, ?_⟩
      · show (w₀ + t : ℝ) < w₀ + s
        linarith
      · exact (ih₁ h_sub₁ f w₀ s).mp hψ₁
      · intro rc h_lt_rc h_rc_lt
        have h_lt1 : (w₀ + t : ℝ) < rc.val := h_lt_rc
        have h_lt2 : (rc.val : ℝ) < w₀ + s := h_rc_lt
        have h_eq : realFlowPoint (hR f) (w₀ + (rc.val - w₀)) = rc :=
          Subtype.ext (show w₀ + (rc.val - w₀) = rc.val by ring)
        rw [← h_eq]
        exact (ih₂ h_sub₂ f w₀ (rc.val - w₀)).mp (hguard _ (by linarith) (by linarith))
    · rintro ⟨sc, h_lt_sc, hψ₁, hguard⟩
      have h_lt : (w₀ + t : ℝ) < sc.val := h_lt_sc
      have h_eq_sc : realFlowPoint (hR f) (w₀ + (sc.val - w₀)) = sc :=
        Subtype.ext (show w₀ + (sc.val - w₀) = sc.val by ring)
      refine ⟨sc.val - w₀, by linarith, ?_, ?_⟩
      · rw [ih₁ h_sub₁ f w₀ (sc.val - w₀), h_eq_sc]; exact hψ₁
      · intro r htr hrs
        rw [ih₂ h_sub₂ f w₀ r]
        refine hguard _ (show (w₀ + t : ℝ) < w₀ + r by linarith) ?_
        show (w₀ + r : ℝ) < sc.val
        linarith
  | snce ψ₂ ψ₁ ih₂ ih₁ =>
    have h_sub₁ : ψ₁ ∈ subformulaClosure φ := closure_snce_left φ ψ₁ ψ₂ h_sub
    have h_sub₂ : ψ₂ ∈ subformulaClosure φ := closure_snce_right φ ψ₁ ψ₂ h_sub
    simp only [TruthAt, TemporalTruth]
    constructor
    · rintro ⟨s, hst, hψ₁, hguard⟩
      refine ⟨realFlowPoint (hR f) (w₀ + s), ?_, ?_, ?_⟩
      · show (w₀ + s : ℝ) < w₀ + t
        linarith
      · exact (ih₁ h_sub₁ f w₀ s).mp hψ₁
      · intro rc h_lt_rc h_rc_lt
        have h_lt1 : (w₀ + s : ℝ) < rc.val := h_lt_rc
        have h_lt2 : (rc.val : ℝ) < w₀ + t := h_rc_lt
        have h_eq : realFlowPoint (hR f) (w₀ + (rc.val - w₀)) = rc :=
          Subtype.ext (show w₀ + (rc.val - w₀) = rc.val by ring)
        rw [← h_eq]
        exact (ih₂ h_sub₂ f w₀ (rc.val - w₀)).mp (hguard _ (by linarith) (by linarith))
    · rintro ⟨sc, h_sc_lt, hψ₁, hguard⟩
      have h_lt : (sc.val : ℝ) < w₀ + t := h_sc_lt
      have h_eq_sc : realFlowPoint (hR f) (w₀ + (sc.val - w₀)) = sc :=
        Subtype.ext (show w₀ + (sc.val - w₀) = sc.val by ring)
      refine ⟨sc.val - w₀, by linarith, ?_, ?_⟩
      · rw [ih₁ h_sub₁ f w₀ (sc.val - w₀), h_eq_sc]; exact hψ₁
      · intro r hsr hrt
        rw [ih₂ h_sub₂ f w₀ r]
        refine hguard _ ?_ (show (w₀ + r : ℝ) < w₀ + t by linarith)
        show (sc.val : ℝ) < w₀ + r
        linarith

/-! ## The completeness engine for `FrameClass.Dedekind`

Reynolds 1992, §2, printed p.169, fixes the notion of completeness this discharges: a formula
valid over the class is derivable in the system for that class — the *single-formula* (weak)
statement. `StrongCompleteness.lean`'s `consequence_completeness_dedekind_of_engine` is stated
against exactly this interface, one formula in and one derivation from the empty context out,
and it is the deduction theorem that makes the finite-context form fall out of it without a
second construction. -/

/--
**The single-formula completeness engine for `ValidDedekindDense`** — Reynolds §9 Theorem 7.

Contrapositive, four steps, no case split:

1. `neg_consistent_of_not_derivable` (`Completeness.lean:72`) makes `{¬ψ}` `.Dedekind`-consistent.
2. `set_lindenbaum` extends it to a `.Dedekind`-MCS `M` with `¬ψ ∈ M`.
3. `dedekind_box_dense_mem` supplies `□(¬U(⊤,⊥)) ∈ M` *unconditionally* — this is where the
   Dedekind route is simpler than the Base and Discrete ones: `FrameClass.Dense ≤
   FrameClass.Dedekind`, so `Axiom.dense_indicator` is admissible and the non-dense branch that
   `completeness` and `completeness_discrete` must discharge does not exist here.
4. `countermodel_dedekind_dense` at `ℝ` produces the countermodel, with `by decide` discharging
   `FrameClass.Dedekind ≤ FrameClass.Dedekind` and `real_lub_of_bddAbove` discharging the
   least-upper-bound binder of `ValidDedekindDense`.
-/
theorem completeness_dedekind_engine (ψ : Formula) :
    ValidDedekindDense ψ → Derivable FrameClass.Dedekind [] ψ := by
  intro h_valid
  by_contra h_not_deriv
  have h_cons := neg_consistent_of_not_derivable (fc := FrameClass.Dedekind) ψ h_not_deriv
  obtain ⟨M, hM_sup, hM_mcs⟩ := set_lindenbaum {Formula.neg ψ} h_cons
  have h_neg_in : Formula.neg ψ ∈ M := hM_sup (Set.mem_singleton _)
  have h_box_dense : Formula.box Chronicle.nextTop.neg ∈ M := dedekind_box_dense_mem hM_mcs
  obtain ⟨F, TM, τ, h_tot, t, h_not_true⟩ :=
    countermodel_dedekind_dense (by decide) M hM_mcs ψ h_neg_in h_box_dense
  exact h_not_true (h_valid ℝ real_lub_of_bddAbove F TM τ h_tot t)

/-! ## Axiom Audit

Mirrors the audit section of the sibling module `Completeness.lean`. All four declarations must
report exactly `[propext, Classical.choice, Quot.sound]` — no `sorryAx`. -/

#print axioms real_lub_of_bddAbove
#print axioms dedekind_box_dense_mem
#print axioms countermodel_dedekind_dense
#print axioms completeness_dedekind_engine

end FormalSystem.Metalogic.BXCanonical
