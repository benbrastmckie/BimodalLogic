/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.WeakCanonical.GroupModel.GroupableCompanion
import FormalSystem.Metalogic.Algebraic.FlowFrame
import Mathlib.Algebra.Order.Monoid.Prod

/-!
# The Base-MCS discrete countermodel at `ℚ ×ₗ ℤ`

This module hosts `countermodel_discrete`: from a **Base** MCS `A` containing `¬φ` and
`□(nextTop)`, it builds a countermodel to `φ` on the non-Archimedean discrete carrier
`ℚ ×ₗ ℤ`. It is the Base analogue of `countermodel_discrete_reynolds_v2`
(`IntegerModel/ReynoldsBridge.lean`), which needs a *Discrete* MCS and lands on `ℤ`.

## Why this module exists rather than `Transfer.lean`

The construction consumes `companionChronicle`
(`GroupModel/GroupableCompanion.lean`), and the import chain runs

```
Transfer.lean  ←  IntegerModel/ReynoldsBridge.lean  ←  GroupModel/GroupableCompanion.lean
```

so `Transfer.lean` is strictly *upstream* of the companion lemma and cannot import it. The
theorem is therefore declared here, under `namespace FormalSystem.Metalogic.WeakCanonical`,
which preserves the fully-qualified name
`FormalSystem.Metalogic.WeakCanonical.countermodel_discrete` verbatim — so the sole consumer,
`BXCanonical/Completeness.lean`, needs no edit at all. Moving `truth_transfer` out of
`Transfer.lean` to break the cycle upstream was rejected: it has many consumers and the churn
is unbounded.

## What changes relative to the `ℤ` blueprint

Three substitutions carry the `ℤ` body to `ℚ ×ₗ ℤ`:

* `limitdom_is_good` → `companionChronicle`. The latter carries **no** `Discrete ≤ fc`
  hypothesis (discreteness of the flow comes from `□(nextTop)` alone), so the `(le_refl _)`
  argument disappears, and it delivers `goodGroupable` rather than `good`.
* `multiFamTaskFrame` / `multiFamHistory` / `multiFam_total_eq` →
  `multiFamTaskFrameGen (ℚ ×ₗ ℤ)` / `multiFamHistoryGen` / `multiFamGen_total_eq`
  (`Algebraic/FlowFrame.lean`).
* `FrameClass.Discrete` → `FrameClass.Base` throughout. Every remaining step is already
  `{fc : FrameClass}`-generic; in particular `Axiom.modal_t` is a `.Base` axiom, so its
  `trivial` membership proof survives.

Two consequences of the carrier change are worth naming. First, `QZStructure.toOrdered_carrier`
is `rfl`, so the target carrier *is* `ℚ ×ₗ ℤ` — there is no `lo`/`hi`-carved interval subtype,
and the bounds/`toCarrier` bookkeeping that the `ℤ` blueprint needs simply has no analogue
here. Second, `omega` does not run at `ℚ ×ₗ ℤ`; the three ordered-group facts it was doing are
isolated below as `qz_add_lt_add_iff`, `qz_add_sub_cancel` and `qz_zero_add`, so the proof body
cites a proved name instead of a decision procedure.

## References

- Doets 1987, ch. 7 (pp. 89-93); Reynolds 1992, §8 (printed p. 185) — as transposed by
  `GroupModel/GoodGroupable.lean` and `GroupModel/GroupableCompanion.lean`.
-/

namespace FormalSystem.Metalogic.WeakCanonical

open FormalSystem.Syntax
open FormalSystem.ProofSystem
open FormalSystem.Metalogic.Core
open FormalSystem.Metalogic.BXCanonical.Chronicle
open FormalSystem.Semantics
open FormalSystem.Metalogic.Algebraic

/-! ## Carrier gate

The four instances `valid` (`Semantics/Validity.lean`) binds its duration type under, plus the
elaboration of the generic flow frame at this carrier. Mirrors the gates at
`GroupModel/GoodGroupable.lean` and `BXCanonical/DiscreteCarrierProbe.lean`; these lines make
*"`ℚ ×ₗ ℤ` is an admissible duration type for the flow-frame construction"* a compile-time
invariant of this module. -/

example : AddCommGroup (ℚ ×ₗ ℤ) := inferInstance
example : LinearOrder (ℚ ×ₗ ℤ) := inferInstance
example : IsOrderedAddMonoid (ℚ ×ₗ ℤ) := inferInstance
example : Nontrivial (ℚ ×ₗ ℤ) := inferInstance

noncomputable example : TaskFrame (ℚ ×ₗ ℤ) := multiFamTaskFrameGen (ℚ ×ₗ ℤ) Unit

/-! ## Carrier arithmetic

The three ordered-group facts that replace `omega` in the `untl`/`snce` cases of the ported
body. At `ℤ` these are decided; at `ℚ ×ₗ ℤ` they are instances of the ordered abelian group
laws, and naming them keeps the proof body free of ad hoc tactic guessing. -/

/-- Shift-monotonicity: translation by `w` is strictly order-preserving. This is what the `ℤ`
blueprint's `change (w₀ + t : ℤ) < w₀ + s; omega` steps become. -/
private theorem qz_add_lt_add_iff (w t s : ℚ ×ₗ ℤ) : w + t < w + s ↔ t < s :=
  add_lt_add_iff_left w

/-- Shift-cancellation: `w + (s - w) = s`, the fact that makes `s - w` the offset witnessing a
carrier point `s` as a translate of the base point `w`. Replaces the `ℤ` blueprint's
`Subtype.ext (by simp only [toCarrier]; omega)`. -/
private theorem qz_add_sub_cancel (w s : ℚ ×ₗ ℤ) : w + (s - w) = s := by abel

/-- Zero-shift: the root history's base point is `0`, so the target point `0 + s` is `s`.
Replaces the `ℤ` blueprint's `omega` at the existential-packaging step. -/
private theorem qz_zero_add (s : ℚ ×ₗ ℤ) : (0 : ℚ ×ₗ ℤ) + s = s := zero_add s

/-- Segment-offset cancellation: `z - t + t = z`. The box case's forward direction shifts the
base point of a flow line to land its clock reading on an arbitrary carrier point; at `ℤ` that
step was `omega`. -/
private theorem qz_sub_add_cancel (z t : ℚ ×ₗ ℤ) : z - t + t = z := by abel

/-- Surjectivity of the shift `x ↦ w + x` in offset form: every carrier point `r` is
`w + x` for some offset `x`. Packaging `qz_add_sub_cancel` as an existential is what lets the
`untl`/`snce` cases name the offset without ever writing a subtraction against a point whose
type is only `rfl`-equal to `ℚ ×ₗ ℤ` — the `-` elaborator compares operand types
syntactically and would not see through `((getQ f).toOrdered sig).carrier`. -/
private theorem qz_exists_shift (w r : ℚ ×ₗ ℤ) : ∃ x : ℚ ×ₗ ℤ, w + x = r :=
  ⟨r - w, qz_add_sub_cancel w r⟩

/-! ## The countermodel -/

/--
The Base-MCS discrete countermodel, at the non-Archimedean discrete carrier `ℚ ×ₗ ℤ`.

For any **Base** MCS `A` containing `¬φ` and `□(nextTop)`, constructs a countermodel to `φ`
on `ℚ ×ₗ ℤ`: `φ` fails at a point of a total history of `multiFamTaskFrameGen (ℚ ×ₗ ℤ) FamIdx`.

The construction is the multi-family flow-line model, one companion structure per
box-equivalent MCS family, with `WorldState = FamIdx × (ℚ ×ₗ ℤ)`. Box quantification ranges
over all families, via `H_F` comprising exactly the family×offset flow lines
(`multiFamGen_total_eq`), which resolves the single-structure box-semantics mismatch: by the
S5 box-equivalence structure `□ψ ∈ A` iff `□ψ ∈ N` for every box-equivalent `N`, and the box
predicate on each companion is constant, inherited from the chronicle's S5 structure across
`k`-equivalence.

The Base analogue of `countermodel_discrete_reynolds_v2` (`IntegerModel/ReynoldsBridge.lean`),
which requires a *Discrete* MCS and lands on `ℤ`. The two differences that matter: the
companion structure comes from `companionChronicle` (no `Discrete ≤ fc` hypothesis, so a
Base MCS suffices), and its carrier is the whole of `ℚ ×ₗ ℤ` rather than a `ℤ`-interval, so
no bounds bookkeeping is needed.
-/
theorem countermodel_discrete_base_port (A : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := FrameClass.Base) A)
    (φ : Formula) (h_neg_in : φ.neg ∈ A)
    (h_box_discrete : Formula.box nextTop ∈ A) :
    ∃ (D : Type) (_ : AddCommGroup D) (_ : LinearOrder D) (_ : IsOrderedAddMonoid D)
      (_ : Nontrivial D) (F : TaskFrame D) (TM : TaskModel F)
      (τ : WorldHistory F) (_ : τ.IsTotal) (t : D),
      ¬TruthAt TM τ t φ := by
  -- FamIdx: type of box-equivalent Base MCSes (one per S5 accessibility class)
  let FamIdx := {N : Set Formula // SetMaximalConsistent (fc := FrameClass.Base) N ∧
    Formula.box nextTop ∈ N ∧ (∀ ψ, Formula.box ψ ∈ A ↔ Formula.box ψ ∈ N)}
  -- Root family: A itself
  let f₀ : FamIdx := ⟨A, h_mcs, h_box_discrete, fun _ => Iff.rfl⟩
  -- The root family inhabits the index, discharging the frame's carrier nonemptiness.
  haveI : Nonempty FamIdx := ⟨f₀⟩
  -- Signature and depth
  let sig := mkSigFrom φ
  let k := operatorDepth φ + 2
  -- For each family f, build a limitdom and extract a `ℚ ×ₗ ℤ` companion via
  -- `companionChronicle` — the Base analogue of `limitdom_is_good`, carrying no `h_fc` slot.
  have h_fam_good : ∀ (f : FamIdx), goodGroupable sig k
      (limitdomMonadicStructure f.val f.property.1 φ) := by
    intro ⟨N, hN_mcs, hN_box, _⟩
    exact companionChronicle N hN_mcs hN_box φ k
  -- Extract companions via Classical.choice
  let getQ : FamIdx → QZStructure sig := fun f => (h_fam_good f).choose
  have h_k_equiv : ∀ f, KEquiv sig k (limitdomMonadicStructure f.val f.property.1 φ)
      ((getQ f).toOrdered sig) :=
    fun f => (h_fam_good f).choose_spec
  -- Build TaskModel: valuation at (f, x) evaluates Q_f's atom predicate at x.
  -- `QZStructure.interp` is stated at `ℚ ×ₗ ℤ`, so `w.2` types directly.
  let TM : TaskModel (multiFamTaskFrameGen (ℚ ×ₗ ℤ) FamIdx) :=
    { valuation := fun w atom =>
        (getQ w.1).interp (mkAtomMapFwd φ (.atom atom)) w.2 }
  -- Get TemporalTruth(φ.neg) at root on limitdom, then transfer to the companion
  have h_root_neg : TemporalTruth (limitdomMonadicStructure A h_mcs φ) (mkAtomMapFwd φ)
      ⟨0, zero_mem_limit_dom FrameClass.Base A h_mcs⟩ φ.neg :=
    limitdom_root_neg_truth A h_mcs φ h_neg_in
  have h_k_bound : operatorDepth φ.neg + 1 ≤ k := by
    simp only [k, Formula.neg, operatorDepth]; omega
  obtain ⟨s₀, h_neg_s₀⟩ := truth_transfer (mkAtomMapFwd φ) (h_k_equiv f₀) φ.neg
    h_k_bound ⟨0, zero_mem_limit_dom FrameClass.Base A h_mcs⟩ h_root_neg
  -- Truth correspondence: TruthAt on the multi-family flow frame ↔ TemporalTruth on Q_f,
  -- along the order-isomorphism `r ↦ w₀ + r`. Proved by structural induction on the formula,
  -- restricted to formulas whose predFormulas are contained in φ.predFormulas (needed for
  -- the box case).
  suffices h_truth_corr : ∀ (ψ : Formula) (_ : ψ.predFormulas ⊆ φ.predFormulas)
      (f : FamIdx) (w₀ : ℚ ×ₗ ℤ) (t : ℚ ×ₗ ℤ),
      TruthAt TM (multiFamHistoryGen f w₀) t ψ ↔
        TemporalTruth ((getQ f).toOrdered sig) (mkAtomMapFwd φ) (w₀ + t) ψ by
    -- Package the existential (four fewer instance slots than the Discrete original: no
    -- `SuccOrder`/`PredOrder`/`IsSuccArchimedean`/`IsPredArchimedean`).
    refine ⟨ℚ ×ₗ ℤ, inferInstance, inferInstance, inferInstance, inferInstance,
      multiFamTaskFrameGen (ℚ ×ₗ ℤ) FamIdx, TM,
      multiFamHistoryGen f₀ 0, multiFamHistoryGen_total f₀ 0,
      s₀, ?_⟩
    intro h_truth_phi
    have h_corr := (h_truth_corr φ (Finset.Subset.refl _) f₀ 0 s₀).mp h_truth_phi
    -- Transport along `0 + s₀ = s₀`. Done by an explicit congruence rather than `rw`: the
    -- point argument's type is `((getQ f₀).toOrdered sig).carrier`, only `rfl`-equal to
    -- `ℚ ×ₗ ℤ`, so `rw`'s syntactic matcher does not see the pattern.
    have h_point : ∀ (x y : ℚ ×ₗ ℤ), x = y →
        TemporalTruth ((getQ f₀).toOrdered sig) (mkAtomMapFwd φ) x φ →
        TemporalTruth ((getQ f₀).toOrdered sig) (mkAtomMapFwd φ) y φ := by
      intro x y h hx; exact h ▸ hx
    exact h_neg_s₀ (h_point _ _ (qz_zero_add s₀) h_corr)
  -- Prove truth correspondence by structural induction
  intro ψ h_sub f w₀ t
  induction ψ generalizing f w₀ t with
  | atom a =>
    -- Both sides reduce to Q_f.interp (atomMap (.atom a)) (w₀ + t)
    simp only [TruthAt, TemporalTruth, multiFamHistoryGen, TM]
    exact ⟨fun ⟨_, h⟩ => h, fun h => ⟨trivial, h⟩⟩
  | bot =>
    simp only [TruthAt, TemporalTruth]
  | imp ψ₁ ψ₂ ih₁ ih₂ =>
    simp only [TruthAt, TemporalTruth]
    exact Iff.imp
      (ih₁ (Finset.Subset.trans Finset.subset_union_left h_sub) f w₀ t)
      (ih₂ (Finset.Subset.trans Finset.subset_union_right h_sub) f w₀ t)
  | box ψ ih =>
    -- Box case: TruthAt(.box ψ) = ∀ σ, σ.IsTotal → TruthAt σ t ψ
    have h_sub_ψ : ψ.predFormulas ⊆ φ.predFormulas :=
      Finset.Subset.trans Finset.subset_union_right h_sub
    simp only [TruthAt]
    constructor
    · -- Forward: (∀ σ, σ.IsTotal → TruthAt σ t ψ) → TemporalTruth (.box ψ)
      intro h_all
      -- Convert to: ∀ f' x, TemporalTruth Q_{f'} atomMap x ψ
      have h_univ : ∀ (f' : FamIdx) (x : ℚ ×ₗ ℤ),
          TemporalTruth ((getQ f').toOrdered sig) (mkAtomMapFwd φ) x ψ := by
        intro f' x
        have h_tot : (multiFamHistoryGen f' (x - t)).IsTotal :=
          multiFamHistoryGen_total f' (x - t)
        have h_ta := h_all (multiFamHistoryGen f' (x - t)) h_tot
        rw [ih h_sub_ψ f' (x - t) t] at h_ta
        rw [qz_sub_add_cancel] at h_ta
        exact h_ta
      -- Step A: Transfer TemporalTruth on each Q_{f'} back to MCS membership
      have h_ψ_in_all : ∀ (f' : FamIdx), ψ ∈ f'.val := by
        intro f'
        -- Step A1: ∀x.table(ψ)(x) on Q_{f'}
        have h_all_table_Z : eval ((getQ f').toOrdered sig) Fin.elim0
            (MonadicFormula.all (table sig (mkAtomMapFwd φ) ψ)) := by
          simp only [eval]
          intro x
          have h_env : Fin.cons x Fin.elim0 = (fun (_ : Fin 1) => x) := by
            funext i; fin_cases i; rfl
          rw [h_env]
          exact (table_correctness ((getQ f').toOrdered sig) (mkAtomMapFwd φ) x ψ).mpr
            (h_univ f' x)
        -- Step A2: k-equiv reverse transfer to limitdom_{f'}
        have h_box_depth : operatorDepth (.box ψ) ≤ operatorDepth φ :=
          predFormulas_operator_depth_le φ (.box ψ)
            (h_sub (Finset.mem_union.mpr (Or.inl (Finset.mem_singleton.mpr rfl))))
        have h_depth_all : (MonadicFormula.all (table sig (mkAtomMapFwd φ) ψ)).quantifierDepth ≤
            k := by
          simp only [MonadicFormula.quantifierDepth, k, operatorDepth] at h_box_depth ⊢
          exact Nat.succ_le_of_lt (Nat.lt_of_le_of_lt (table_depth_bound sig (mkAtomMapFwd φ) ψ)
            (by omega))
        have h_all_table_lim : eval (limitdomMonadicStructure f'.val f'.property.1 φ) Fin.elim0
            (MonadicFormula.all (table sig (mkAtomMapFwd φ) ψ)) :=
          ((k_equiv_preserves_sentence (h_k_equiv f') _ h_depth_all).symm).mp h_all_table_Z
        -- Step A3: Unpack → ∀ x, TemporalTruth on limitdom
        simp only [eval] at h_all_table_lim
        -- Step A4: At the root point 0, get ψ ∈ LimitF(0) = N_{f'}
        have h_tt_root : TemporalTruth (limitdomMonadicStructure f'.val f'.property.1 φ)
            (mkAtomMapFwd φ) ⟨0, zero_mem_limit_dom FrameClass.Base f'.val f'.property.1⟩
                ψ := by
          have h_eval := h_all_table_lim ⟨0, zero_mem_limit_dom FrameClass.Base f'.val
              f'.property.1⟩
          have h_env : Fin.cons ⟨0, zero_mem_limit_dom FrameClass.Base f'.val f'.property.1⟩
              Fin.elim0 =
              (fun (_ : Fin 1) => (⟨0, zero_mem_limit_dom FrameClass.Base f'.val
                  f'.property.1⟩ :
                (limitdomMonadicStructure f'.val f'.property.1 φ).carrier)) := by
            funext i; fin_cases i; rfl
          -- `rw … at` no longer matches the `Fin.cons` application: its implicit motive
          -- in `h_env` (inferred from the `fun _ => x` right-hand side) differs from the
          -- one `eval` produced, and the two are only definitionally equal. `▸` transports
          -- at `default` transparency and is unaffected. (Lean 4.31.)
          replace h_eval := h_env ▸ h_eval
          exact (table_correctness (limitdomMonadicStructure f'.val f'.property.1 φ)
            (mkAtomMapFwd φ) _ ψ).mp h_eval
        -- Step A5: By limitdom_temporal_truth_effective + effectiveFormula_id
        have h_eff_mem : limitdomEffectiveFormula φ ψ ∈
            LimitF FrameClass.Base f'.val f'.property.1 0 :=
          (limitdom_temporal_truth_effective f'.val f'.property.1 φ ψ _).mp h_tt_root
        simp only [limitdomEffectiveFormula] at h_eff_mem
        rw [effectiveFormula_id_of_sub h_sub_ψ, limit_f_zero] at h_eff_mem
        exact h_eff_mem
      -- Step B: ψ ∈ all N_{f'} → .box ψ ∈ A (contrapositive via bx_modal_witness_fc)
      have h_box_in_A : Formula.box ψ ∈ A := by
        by_contra h_not_box
        have h_neg_box : (Formula.box ψ).neg ∈ A :=
          (SetMaximalConsistent.negation_complete h_mcs (Formula.box ψ)).resolve_left h_not_box
        have h_diamond_neg : (Formula.neg ψ).diamond ∈ A :=
          FormalSystem.Metalogic.Bundle.SetMaximalConsistent.contrapositive h_mcs
            (liftBase FrameClass.Base (FormalSystem.Metalogic.Bundle.boxDneTheorem ψ)) h_neg_box
        obtain ⟨v, h_v_mcs, h_v_equiv, h_neg_ψ_v⟩ :=
          bx_modal_witness_fc h_mcs (Formula.neg ψ) h_diamond_neg
        -- v is box-equiv to A, so □(nextTop) ∈ v
        have h_box_disc_v : Formula.box nextTop ∈ v :=
          (h_v_equiv nextTop).mp h_box_discrete
        -- v is a FamIdx element
        let fv : FamIdx := ⟨v, h_v_mcs, h_box_disc_v, h_v_equiv⟩
        -- h_ψ_in_all gives ψ ∈ v
        have h_ψ_v : ψ ∈ v := h_ψ_in_all fv
        -- Contradiction: ψ and ψ.neg both in v
        exact set_consistent_not_both h_v_mcs.1 ψ h_ψ_v h_neg_ψ_v
      -- Step C: .box ψ ∈ A → box pred True on Q_f
      have h_box_in_N : Formula.box ψ ∈ f.val := (f.property.2.2 ψ).mp h_box_in_A
      change TemporalTruth ((getQ f).toOrdered sig) (mkAtomMapFwd φ) (w₀ + t) (.box ψ)
      simp only [TemporalTruth]
      have h_all_pred_lim : ∀ (x : (limitdomMonadicStructure f.val f.property.1 φ).carrier),
          (limitdomMonadicStructure f.val f.property.1 φ).interp
            (mkAtomMapFwd φ (.box ψ)) x := by
        intro ⟨q, hq⟩
        change (mkAtomMap φ (mkAtomMapFwd φ (.box ψ))) ∈ LimitF FrameClass.Base f.val
            f.property.1 q
        have h_box_pred_mem : Formula.box ψ ∈ φ.predFormulas :=
          h_sub (Finset.mem_union.mpr (Or.inl (Finset.mem_singleton.mpr rfl)))
        rw [mkAtomMapFwd_section φ (.box ψ) h_box_pred_mem]
        exact (box_stable_in_limit_f FrameClass.Base f.val f.property.1 ψ q hq).mpr h_box_in_N
      -- Transfer ∀x.P_{.box ψ}(x) from limitdom to the companion via k-equiv
      have h_all_pred_Z : ∀ (x : ((getQ f).toOrdered sig).carrier),
          ((getQ f).toOrdered sig).interp (mkAtomMapFwd φ (.box ψ)) x := by
        let p := mkAtomMapFwd φ (.box ψ)
        let sent : MonadicSentence sig := .all (.atom p ⟨0, by omega⟩)
        have h_depth : sent.quantifierDepth ≤ k := by
          simp only [sent, MonadicFormula.quantifierDepth, k]; omega
        have h_eval_lim : eval (limitdomMonadicStructure f.val f.property.1 φ) Fin.elim0
            sent := by
          simp only [sent, eval]
          intro x
          exact h_all_pred_lim x
        have h_eval_Z : eval ((getQ f).toOrdered sig) Fin.elim0 sent :=
          (k_equiv_preserves_sentence (h_k_equiv f) sent h_depth).mp h_eval_lim
        simp only [sent, eval] at h_eval_Z
        exact fun x => h_eval_Z x
      exact h_all_pred_Z (w₀ + t)
    · -- Backward: TemporalTruth (.box ψ) → (∀ σ, σ.IsTotal → TruthAt σ t ψ)
      intro h_box σ h_mem
      obtain ⟨f', w₀', h_eq⟩ := multiFamGen_total_eq σ h_mem
      rw [h_eq, ih h_sub_ψ f' w₀' t]
      -- Step 1: h_box gives the predicate at one point → ∃x. P(x) on Q_f
      have h_box_pred_mem : Formula.box ψ ∈ φ.predFormulas :=
        h_sub (Finset.mem_union.mpr (Or.inl (Finset.mem_singleton.mpr rfl)))
      let p := mkAtomMapFwd φ (.box ψ)
      -- Step 2: existential transfer to limitdom_f → .box ψ ∈ some LimitF point
      have h_ex_Z : eval ((getQ f).toOrdered sig) Fin.elim0
          (MonadicFormula.ex (.atom p ⟨0, by omega⟩)) := by
        simp only [eval]
        exact ⟨w₀ + t, h_box⟩
      have h_ex_depth : (MonadicFormula.ex (.atom p ⟨0, by omega⟩) : MonadicSentence
          sig).quantifierDepth ≤ k := by
        simp only [MonadicFormula.quantifierDepth, k]; omega
      have h_ex_lim : eval (limitdomMonadicStructure f.val f.property.1 φ) Fin.elim0
          (MonadicFormula.ex (.atom p ⟨0, by omega⟩)) :=
        ((k_equiv_preserves_sentence (h_k_equiv f) _ h_ex_depth).symm).mp h_ex_Z
      simp only [eval] at h_ex_lim
      obtain ⟨⟨q, hq⟩, h_pred_q⟩ := h_ex_lim
      have h_box_q : Formula.box ψ ∈ LimitF FrameClass.Base f.val f.property.1 q := by
        have : (mkAtomMap φ (mkAtomMapFwd φ (.box ψ))) ∈
            LimitF FrameClass.Base f.val f.property.1 q := h_pred_q
        rwa [mkAtomMapFwd_section φ (.box ψ) h_box_pred_mem] at this
      -- Step 3: box_stable → .box ψ ∈ N_f
      have h_box_N : Formula.box ψ ∈ f.val :=
        (box_stable_in_limit_f FrameClass.Base f.val f.property.1 ψ q hq).mp h_box_q
      -- Step 4: Box-equiv → .box ψ ∈ A → .box ψ ∈ N_{f'}
      have h_box_A : Formula.box ψ ∈ A := (f.property.2.2 ψ).mpr h_box_N
      have h_box_N' : Formula.box ψ ∈ f'.val := (f'.property.2.2 ψ).mp h_box_A
      -- Steps 5-6: Box stability + Modal T → ψ ∈ limit_f_{f'}(x) for all x.
      -- `Axiom.modal_t` is a `.Base` axiom, so its membership proof stays `trivial`.
      have h_ψ_all_lim : ∀ (x : (limitdomMonadicStructure f'.val f'.property.1 φ).carrier),
          TemporalTruth (limitdomMonadicStructure f'.val f'.property.1 φ)
            (mkAtomMapFwd φ) x ψ := by
        intro ⟨q, hq⟩
        have h_box_q : Formula.box ψ ∈ LimitF FrameClass.Base f'.val f'.property.1 q :=
          (box_stable_in_limit_f FrameClass.Base f'.val f'.property.1 ψ q hq).mpr h_box_N'
        have h_ψ_q : ψ ∈ LimitF FrameClass.Base f'.val f'.property.1 q :=
          SetMaximalConsistent.implication_property
            (limit_c0 FrameClass.Base f'.val f'.property.1 q hq)
            (theorem_in_mcs (limit_c0 FrameClass.Base f'.val f'.property.1 q hq)
              (DerivationTree.axiom [] _ (Axiom.modal_t ψ) trivial)) h_box_q
        rw [← effectiveFormula_id_of_sub h_sub_ψ] at h_ψ_q
        exact (limitdom_temporal_truth_effective f'.val f'.property.1 φ ψ ⟨q, hq⟩).mpr h_ψ_q
      -- Step 7: Transfer TemporalTruth from limitdom_{f'} to Q_{f'}
      have h_all_table_lim : eval (limitdomMonadicStructure f'.val f'.property.1 φ) Fin.elim0
          (MonadicFormula.all (table sig (mkAtomMapFwd φ) ψ)) := by
        simp only [eval]
        intro x
        have h_env : Fin.cons x Fin.elim0 = (fun (_ : Fin 1) => x) := by
          funext i; fin_cases i; rfl
        rw [h_env]
        exact (table_correctness (limitdomMonadicStructure f'.val f'.property.1 φ)
          (mkAtomMapFwd φ) x ψ).mpr (h_ψ_all_lim x)
      have h_box_depth : operatorDepth (.box ψ) ≤ operatorDepth φ :=
        predFormulas_operator_depth_le φ (.box ψ)
          (h_sub (Finset.mem_union.mpr (Or.inl (Finset.mem_singleton.mpr rfl))))
      have h_depth_all : (MonadicFormula.all (table sig (mkAtomMapFwd φ) ψ)).quantifierDepth ≤
          k := by
        simp only [MonadicFormula.quantifierDepth, k, operatorDepth] at h_box_depth ⊢
        exact Nat.succ_le_of_lt (Nat.lt_of_le_of_lt (table_depth_bound sig (mkAtomMapFwd φ) ψ)
          (by omega))
      have h_all_table_Z : eval ((getQ f').toOrdered sig) Fin.elim0
          (MonadicFormula.all (table sig (mkAtomMapFwd φ) ψ)) :=
        (k_equiv_preserves_sentence (h_k_equiv f') _ h_depth_all).mp h_all_table_lim
      simp only [eval] at h_all_table_Z
      have h_eval := h_all_table_Z (w₀' + t)
      have h_env : Fin.cons ((w₀' + t : ℚ ×ₗ ℤ) : ((getQ f').toOrdered sig).carrier) Fin.elim0 =
          (fun (_ : Fin 1) => ((w₀' + t : ℚ ×ₗ ℤ) : ((getQ f').toOrdered sig).carrier)) := by
        funext i; fin_cases i; rfl
      -- Same `Fin.cons` motive mismatch as the `box` case above.
      replace h_eval := h_env ▸ h_eval
      exact (table_correctness ((getQ f').toOrdered sig) (mkAtomMapFwd φ) _ ψ).mp h_eval
  | untl ψ₂ ψ₁ ih₂ ih₁ =>
    have h_sub₁ : ψ₁.predFormulas ⊆ φ.predFormulas :=
      Finset.Subset.trans Finset.subset_union_left h_sub
    have h_sub₂ : ψ₂.predFormulas ⊆ φ.predFormulas :=
      Finset.Subset.trans Finset.subset_union_right h_sub
    simp only [TruthAt, TemporalTruth]
    constructor
    · -- Forward: offset witness → carrier witness, along `r ↦ w₀ + r`
      rintro ⟨s, hts, hψ₁, hguard⟩
      refine ⟨w₀ + s, ?_, ?_, ?_⟩
      · exact (qz_add_lt_add_iff w₀ t s).mpr hts
      · exact (ih₁ h_sub₁ f w₀ s).mp hψ₁
      · intro rc h_lt_rc h_rc_lt
        obtain ⟨r, h_eq⟩ := qz_exists_shift w₀ rc
        have htr : t < r := by rw [← qz_add_lt_add_iff w₀, h_eq]; exact h_lt_rc
        have hrs : r < s := by rw [← qz_add_lt_add_iff w₀, h_eq]; exact h_rc_lt
        rw [← h_eq]
        exact (ih₂ h_sub₂ f w₀ r).mp (hguard r htr hrs)
    · -- Backward: carrier witness → offset witness, along `r ↦ r - w₀`
      rintro ⟨sc, h_lt_sc, hψ₁, hguard⟩
      obtain ⟨sd, h_sd⟩ := qz_exists_shift w₀ sc
      refine ⟨sd, ?_, ?_, ?_⟩
      · rw [← qz_add_lt_add_iff w₀, h_sd]; exact h_lt_sc
      · rw [ih₁ h_sub₁ f w₀ sd, h_sd]; exact hψ₁
      · intro r htr hrs
        rw [ih₂ h_sub₂ f w₀ r]
        refine hguard _ ((qz_add_lt_add_iff w₀ t r).mpr htr) ?_
        have h_lt2 := (qz_add_lt_add_iff w₀ r sd).mpr hrs
        rwa [h_sd] at h_lt2
  | snce ψ₂ ψ₁ ih₂ ih₁ =>
    -- Symmetric to the Until case
    have h_sub₁ : ψ₁.predFormulas ⊆ φ.predFormulas :=
      Finset.Subset.trans Finset.subset_union_left h_sub
    have h_sub₂ : ψ₂.predFormulas ⊆ φ.predFormulas :=
      Finset.Subset.trans Finset.subset_union_right h_sub
    simp only [TruthAt, TemporalTruth]
    constructor
    · -- Forward: offset witness → carrier witness
      rintro ⟨s, hst, hψ₁, hguard⟩
      refine ⟨w₀ + s, ?_, ?_, ?_⟩
      · exact (qz_add_lt_add_iff w₀ s t).mpr hst
      · exact (ih₁ h_sub₁ f w₀ s).mp hψ₁
      · intro rc h_lt_rc h_rc_lt
        obtain ⟨r, h_eq⟩ := qz_exists_shift w₀ rc
        have hsr : s < r := by rw [← qz_add_lt_add_iff w₀, h_eq]; exact h_lt_rc
        have hrt : r < t := by rw [← qz_add_lt_add_iff w₀, h_eq]; exact h_rc_lt
        rw [← h_eq]
        exact (ih₂ h_sub₂ f w₀ r).mp (hguard r hsr hrt)
    · -- Backward: carrier witness → offset witness
      rintro ⟨sc, h_sc_lt, hψ₁, hguard⟩
      obtain ⟨sd, h_sd⟩ := qz_exists_shift w₀ sc
      refine ⟨sd, ?_, ?_, ?_⟩
      · rw [← qz_add_lt_add_iff w₀, h_sd]; exact h_sc_lt
      · rw [ih₁ h_sub₁ f w₀ sd, h_sd]; exact hψ₁
      · intro r hsr hrt
        rw [ih₂ h_sub₂ f w₀ r]
        refine hguard _ ?_ ((qz_add_lt_add_iff w₀ r t).mpr hrt)
        have h_lt := (qz_add_lt_add_iff w₀ sd r).mpr hsr
        rwa [h_sd] at h_lt

end FormalSystem.Metalogic.WeakCanonical
