import Bimodal.Metalogic.Bundle.BMCS
import Bimodal.Metalogic.Bundle.BMCSTruth
import Bimodal.Metalogic.Bundle.BFMCS
import Bimodal.Metalogic.Bundle.TemporalCoherentConstruction
import Bimodal.Metalogic.Bundle.CoherentConstruction
import Bimodal.Metalogic.Core.MaximalConsistent
import Bimodal.Metalogic.Core.MCSProperties
import Bimodal.Metalogic.Core.DeductionTheorem
import Bimodal.Syntax.Formula
import Bimodal.Theorems.Propositional

/-!
# BMCS Truth Lemma

This module proves the **key theorem** of the BMCS completeness approach:
the truth lemma connecting MCS membership to BMCS truth.

## Proof Status

The main `bmcs_truth_lemma` is fully proven for temporally coherent BMCS.
All cases (atom, bot, imp, box, all_future, all_past) are sorry-free.

The temporal backward cases (G, H) use the `temporally_coherent` hypothesis
on the BMCS, which provides `forward_F` and `backward_P` properties needed
for the contraposition argument via `temporal_backward_G` and `temporal_backward_H`.

### Axiom Dependency

The truth lemma inherits the `temporally_saturated_mcs_exists` axiom from
TemporalCoherentConstruction.lean via the construction that provides temporally
coherent BMCS. This axiom asserts the existence of temporally saturated MCS,
which is a standard result from Henkin-style completeness proofs.

## Main Result

```
theorem bmcs_truth_lemma (B : BMCS D) (h_tc : B.temporally_coherent)
    (fam : BFMCS D) (hfam : fam ∈ B.families)
    (t : D) (φ : Formula) :
    φ ∈ fam.mcs t ↔ bmcs_truth_at B fam t φ
```

## Proof Status: ALL CASES PROVEN

All six cases of the truth lemma are proven without sorry:
- **Atom**: Trivial by definition
- **Bot**: By MCS consistency
- **Imp**: By MCS modus ponens and negation completeness
- **Box**: Uses `modal_forward` and `modal_backward` (THE CRUCIAL CASE)
- **G (all_future)**: Forward via forward_G; backward via temporal_backward_G
- **H (all_past)**: Forward via backward_H; backward via temporal_backward_H

The temporal backward cases use the `temporally_coherent` hypothesis on the BMCS,
which provides `forward_F` and `backward_P` for the contraposition argument
(via `temporal_backward_G` and `temporal_backward_H` from TemporalCoherentConstruction.lean).

## Axiom Dependency Chain

```
bmcs_truth_lemma (no sorry, no axiom)
  requires: B.temporally_coherent
    provided by: construction in Completeness.lean
      uses: temporal_eval_saturated_bundle_exists (no sorry)
        uses: temporally_saturated_mcs_exists (AXIOM)
```

The `temporally_saturated_mcs_exists` axiom asserts the existence of temporally
saturated MCS extending any consistent context. This is a standard result from
Henkin-style completeness proofs in temporal logic.

## References

- Research report: specs/862_divide_truthlemma_forward_backward/reports/research-002.md
- Research report: specs/843_remove_singleFamily_modal_backward_axiom/reports/research-005.md
- Research report: specs/857_add_temporal_backward_properties/reports/research-007.md
-/

namespace Bimodal.Metalogic.Bundle

open Bimodal.Syntax
open Bimodal.Metalogic.Core

variable {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]

/-!
## Helper Lemmas for Temporal Forward Direction

These lemmas handle the forward direction (MCS membership → truth) for temporal cases.
The forward direction uses the existing coherence conditions in BFMCS.
-/

/--
Helper: MCS all_future membership implies truth at all future times.

If `G φ ∈ fam.mcs t`, then for all `s ≥ t`, we have `φ ∈ fam.mcs s`.

**Proof Strategy**:
- For `s = t`: Use temporal T axiom (`G φ → φ`) via MCS closure
- For `s > t`: Use `forward_G` coherence condition
-/
lemma mcs_all_future_implies_phi_at_future (fam : BFMCS D) (t s : D) (φ : Formula)
    (hts : t ≤ s) (hG : Formula.all_future φ ∈ fam.mcs t) : φ ∈ fam.mcs s := by
  rcases hts.lt_or_eq with h_lt | h_eq
  · -- s > t: use forward_G
    exact fam.forward_G t s φ h_lt hG
  · -- s = t: use T axiom (G φ → φ)
    subst h_eq
    have h_mcs := fam.is_mcs t
    have h_t_axiom : [] ⊢ (Formula.all_future φ).imp φ :=
      Bimodal.ProofSystem.DerivationTree.axiom [] _ (Bimodal.ProofSystem.Axiom.temp_t_future φ)
    have h_t_in_mcs : (Formula.all_future φ).imp φ ∈ fam.mcs t :=
      theorem_in_mcs h_mcs h_t_axiom
    exact set_mcs_implication_property h_mcs h_t_in_mcs hG

/--
Helper: MCS all_past membership implies truth at all past times.

If `H φ ∈ fam.mcs t`, then for all `s ≤ t`, we have `φ ∈ fam.mcs s`.

**Proof Strategy**:
- For `s = t`: Use temporal T axiom (`H φ → φ`) via MCS closure
- For `s < t`: Use `backward_H` coherence condition
-/
lemma mcs_all_past_implies_phi_at_past (fam : BFMCS D) (t s : D) (φ : Formula)
    (hst : s ≤ t) (hH : Formula.all_past φ ∈ fam.mcs t) : φ ∈ fam.mcs s := by
  rcases hst.lt_or_eq with h_lt | h_eq
  · -- s < t: use backward_H
    exact fam.backward_H t s φ h_lt hH
  · -- s = t: use T axiom (H φ → φ)
    subst h_eq
    have h_mcs := fam.is_mcs s
    have h_t_axiom : [] ⊢ (Formula.all_past φ).imp φ :=
      Bimodal.ProofSystem.DerivationTree.axiom [] _ (Bimodal.ProofSystem.Axiom.temp_t_past φ)
    have h_t_in_mcs : (Formula.all_past φ).imp φ ∈ fam.mcs s :=
      theorem_in_mcs h_mcs h_t_axiom
    exact set_mcs_implication_property h_mcs h_t_in_mcs hH

/-!
## Note: Backward Direction for Temporal Operators

The backward direction (truth at all times -> MCS membership) for the temporal
operators G and H requires structural properties (temporal_backward_G/H) on
BFMCS. Once Task 857 adds these properties, the proofs use MCS
maximality by contraposition - the same pattern as modal_backward in BMCS.

The sorries in backward cases block this file from publication. See the module
docstring "Path to Resolution" for the mathematical path to eliminating them.
-/

/-!
## Helper Lemmas for Implication Case

These derive propositional tautologies needed for the implication case.
Note: DerivationTree is a Type, so these are definitions, not lemmas.
-/

/--
Classical tautology: ¬(ψ → χ) → ψ

Proof: ¬(ψ → χ) = (ψ → χ) → ⊥. Classically, this implies ψ.
-/
noncomputable def neg_imp_implies_antecedent (ψ χ : Formula) :
    Bimodal.ProofSystem.DerivationTree [] ((ψ.imp χ).neg.imp ψ) := by
  -- Strategy: Prove [¬ψ, ¬(ψ → χ)] ⊢ ⊥, then apply deduction theorem twice,
  -- then compose with double negation elimination.
  -- Note: deduction_theorem expects (A :: Γ) ⊢ B, so the formula to discharge must be first.

  -- Step 1: From [¬ψ, ¬(ψ → χ)], derive ⊥
  -- efq_neg : ⊢ ¬ψ → (ψ → χ)
  have h_efq : Bimodal.ProofSystem.DerivationTree [] (ψ.neg.imp (ψ.imp χ)) :=
    Bimodal.Theorems.Propositional.efq_neg ψ χ

  -- Weaken to context [¬ψ, ¬(ψ → χ)]
  have h_efq_ctx : [ψ.neg, (ψ.imp χ).neg] ⊢ ψ.neg.imp (ψ.imp χ) :=
    Bimodal.ProofSystem.DerivationTree.weakening [] [ψ.neg, (ψ.imp χ).neg] _ h_efq (by intro; simp)

  -- Get ¬ψ from context
  have h_neg_psi : [ψ.neg, (ψ.imp χ).neg] ⊢ ψ.neg :=
    Bimodal.ProofSystem.DerivationTree.assumption _ _ (by simp)

  -- Apply modus ponens: ¬ψ and (¬ψ → (ψ → χ)) gives (ψ → χ)
  have h_imp : [ψ.neg, (ψ.imp χ).neg] ⊢ ψ.imp χ :=
    Bimodal.ProofSystem.DerivationTree.modus_ponens _ _ _ h_efq_ctx h_neg_psi

  -- Get ¬(ψ → χ) from context
  have h_neg_imp : [ψ.neg, (ψ.imp χ).neg] ⊢ (ψ.imp χ).neg :=
    Bimodal.ProofSystem.DerivationTree.assumption _ _ (by simp)

  -- Apply modus ponens: (ψ → χ) and ¬(ψ → χ) gives ⊥
  -- Note: ¬(ψ → χ) = (ψ → χ) → ⊥
  have h_bot : [ψ.neg, (ψ.imp χ).neg] ⊢ Formula.bot :=
    Bimodal.ProofSystem.DerivationTree.modus_ponens _ _ _ h_neg_imp h_imp

  -- Step 2: Apply deduction theorem to get [¬(ψ → χ)] ⊢ ¬ψ → ⊥ = ¬¬ψ
  have h_neg_neg_psi : [(ψ.imp χ).neg] ⊢ ψ.neg.neg :=
    Bimodal.Metalogic.Core.deduction_theorem [(ψ.imp χ).neg] ψ.neg Formula.bot h_bot

  -- Step 3: Apply deduction theorem again to get ⊢ ¬(ψ → χ) → ¬¬ψ
  have h_deduct : [] ⊢ (ψ.imp χ).neg.imp ψ.neg.neg :=
    Bimodal.Metalogic.Core.deduction_theorem [] (ψ.imp χ).neg ψ.neg.neg h_neg_neg_psi

  -- Step 4: double_negation gives ⊢ ¬¬ψ → ψ
  have h_dne : [] ⊢ ψ.neg.neg.imp ψ :=
    Bimodal.Theorems.Propositional.double_negation ψ

  -- Step 5: Compose using b_combinator: (¬¬ψ → ψ) → ((¬(ψ → χ) → ¬¬ψ) → (¬(ψ → χ) → ψ))
  have h_b : [] ⊢ (ψ.neg.neg.imp ψ).imp (((ψ.imp χ).neg.imp ψ.neg.neg).imp ((ψ.imp χ).neg.imp ψ)) :=
    Bimodal.Theorems.Combinators.b_combinator

  -- Apply modus ponens twice
  have h_step1 : [] ⊢ ((ψ.imp χ).neg.imp ψ.neg.neg).imp ((ψ.imp χ).neg.imp ψ) :=
    Bimodal.ProofSystem.DerivationTree.modus_ponens _ _ _ h_b h_dne

  exact Bimodal.ProofSystem.DerivationTree.modus_ponens _ _ _ h_step1 h_deduct

/--
Classical tautology: ¬(ψ → χ) → ¬χ

Proof: ¬(ψ → χ) = (ψ → χ) → ⊥. Classically, this implies ¬χ.
-/
noncomputable def neg_imp_implies_neg_consequent (ψ χ : Formula) :
    Bimodal.ProofSystem.DerivationTree [] ((ψ.imp χ).neg.imp χ.neg) := by
  -- Strategy: Prove [χ, ¬(ψ → χ)] ⊢ ⊥, then apply deduction theorem twice.
  -- Note: deduction_theorem expects (A :: Γ) ⊢ B, so the formula to discharge must be first.

  -- Step 1: From [χ, ¬(ψ → χ)], derive ⊥
  -- prop_s : ⊢ χ → (ψ → χ)
  have h_prop_s : [] ⊢ χ.imp (ψ.imp χ) :=
    Bimodal.ProofSystem.DerivationTree.axiom [] _ (Bimodal.ProofSystem.Axiom.prop_s χ ψ)

  -- Weaken to context [χ, ¬(ψ → χ)]
  have h_prop_s_ctx : [χ, (ψ.imp χ).neg] ⊢ χ.imp (ψ.imp χ) :=
    Bimodal.ProofSystem.DerivationTree.weakening [] [χ, (ψ.imp χ).neg] _ h_prop_s (by intro; simp)

  -- Get χ from context
  have h_chi : [χ, (ψ.imp χ).neg] ⊢ χ :=
    Bimodal.ProofSystem.DerivationTree.assumption _ _ (by simp)

  -- Apply modus ponens: χ and (χ → (ψ → χ)) gives (ψ → χ)
  have h_imp : [χ, (ψ.imp χ).neg] ⊢ ψ.imp χ :=
    Bimodal.ProofSystem.DerivationTree.modus_ponens _ _ _ h_prop_s_ctx h_chi

  -- Get ¬(ψ → χ) from context
  have h_neg_imp : [χ, (ψ.imp χ).neg] ⊢ (ψ.imp χ).neg :=
    Bimodal.ProofSystem.DerivationTree.assumption _ _ (by simp)

  -- Apply modus ponens: (ψ → χ) and ¬(ψ → χ) gives ⊥
  have h_bot : [χ, (ψ.imp χ).neg] ⊢ Formula.bot :=
    Bimodal.ProofSystem.DerivationTree.modus_ponens _ _ _ h_neg_imp h_imp

  -- Step 2: Apply deduction theorem to get [¬(ψ → χ)] ⊢ χ → ⊥ = ¬χ
  have h_neg_chi : [(ψ.imp χ).neg] ⊢ χ.neg :=
    Bimodal.Metalogic.Core.deduction_theorem [(ψ.imp χ).neg] χ Formula.bot h_bot

  -- Step 3: Apply deduction theorem again to get ⊢ ¬(ψ → χ) → ¬χ
  exact Bimodal.Metalogic.Core.deduction_theorem [] (ψ.imp χ).neg χ.neg h_neg_chi

/-!
## Main Truth Lemma

The truth lemma is the key result connecting MCS membership to BMCS truth.
It is proven by structural induction on the formula.
-/

/--
**BMCS Truth Lemma**: For any family in a temporally coherent BMCS, formula membership
in the MCS corresponds exactly to truth in the BMCS.

This is THE KEY THEOREM of the BMCS completeness approach.

**Cases**:
- **Atom**: Trivial (definition)
- **Bot**: MCS is consistent, so ⊥ ∉ MCS, and False ↔ False
- **Imp**: Uses MCS modus ponens and negation completeness
- **Box**: Uses `modal_forward` and `modal_backward` (THE CRUCIAL CASE)
- **G (all_future)**: Uses `forward_G` coherence (forward); temporal_backward_G (backward)
- **H (all_past)**: Uses `backward_H` coherence (forward); temporal_backward_H (backward)

**Key Achievement**: ALL cases are proven. The BOX case uses the BMCS approach,
the temporal cases use the `temporal_backward_G` and `temporal_backward_H` theorems
via the `temporally_coherent` hypothesis on the BMCS.

**Axiom dependency**: Inherits `temporally_saturated_mcs_exists` from TemporalCoherentConstruction.lean
(via the construction that provides `temporally_coherent` BMCS).
-/
theorem bmcs_truth_lemma (B : BMCS D) (h_tc : B.temporally_coherent)
    (fam : BFMCS D) (hfam : fam ∈ B.families)
    (t : D) (φ : Formula) :
    φ ∈ fam.mcs t ↔ bmcs_truth_at B fam t φ := by
  induction φ generalizing fam t with
  | atom p =>
    -- Atom case: trivial by definition
    simp only [bmcs_truth_at]
  | bot =>
    -- Bot case: ⊥ ∉ MCS (by consistency) ↔ False
    simp only [bmcs_truth_at]
    constructor
    · intro h_bot
      have h_cons := (fam.is_mcs t).1
      have h_deriv : Bimodal.ProofSystem.DerivationTree [Formula.bot] Formula.bot :=
        Bimodal.ProofSystem.DerivationTree.assumption [Formula.bot] Formula.bot (by simp)
      exact h_cons [Formula.bot] (fun ψ hψ => by simp at hψ; rw [hψ]; exact h_bot) ⟨h_deriv⟩
    · intro h_false
      exact False.elim h_false
  | imp ψ χ ih_ψ ih_χ =>
    -- Implication case: uses MCS modus ponens and negation completeness.
    -- CROSS-DEPENDENCY: Forward uses `.mpr` (backward) on subformula ψ.
    -- This is why forward and backward cannot be separated.
    simp only [bmcs_truth_at]
    have h_mcs := fam.is_mcs t
    constructor
    · -- Forward: (ψ → χ) ∈ MCS → (bmcs_truth ψ → bmcs_truth χ)
      -- Note: uses ih_ψ.mpr (backward on ψ) to convert truth back to MCS membership
      intro h_imp h_ψ_true
      have h_ψ_mcs : ψ ∈ fam.mcs t := (ih_ψ fam hfam t).mpr h_ψ_true
      have h_χ_mcs : χ ∈ fam.mcs t := set_mcs_implication_property h_mcs h_imp h_ψ_mcs
      exact (ih_χ fam hfam t).mp h_χ_mcs
    · -- Backward: (bmcs_truth ψ → bmcs_truth χ) → (ψ → χ) ∈ MCS
      intro h_truth_imp
      rcases set_mcs_negation_complete h_mcs (ψ.imp χ) with h_imp | h_neg_imp
      · exact h_imp
      · -- ¬(ψ → χ) ∈ MCS - derive contradiction
        exfalso
        -- From ¬(ψ → χ), we get ψ ∈ MCS and ¬χ ∈ MCS (classically)
        have h_ψ_mcs : ψ ∈ fam.mcs t := by
          have h_taut := neg_imp_implies_antecedent ψ χ
          exact set_mcs_closed_under_derivation h_mcs [(ψ.imp χ).neg]
            (by simp [h_neg_imp])
            (Bimodal.ProofSystem.DerivationTree.modus_ponens _ _ _
              (Bimodal.ProofSystem.DerivationTree.weakening [] _ _ h_taut (by intro; simp))
              (Bimodal.ProofSystem.DerivationTree.assumption _ _ (by simp)))
        have h_neg_χ_mcs : χ.neg ∈ fam.mcs t := by
          have h_taut := neg_imp_implies_neg_consequent ψ χ
          exact set_mcs_closed_under_derivation h_mcs [(ψ.imp χ).neg]
            (by simp [h_neg_imp])
            (Bimodal.ProofSystem.DerivationTree.modus_ponens _ _ _
              (Bimodal.ProofSystem.DerivationTree.weakening [] _ _ h_taut (by intro; simp))
              (Bimodal.ProofSystem.DerivationTree.assumption _ _ (by simp)))
        -- By IH: ψ true
        have h_ψ_true : bmcs_truth_at B fam t ψ := (ih_ψ fam hfam t).mp h_ψ_mcs
        -- By h_truth_imp: χ true
        have h_χ_true : bmcs_truth_at B fam t χ := h_truth_imp h_ψ_true
        -- By IH: χ ∈ MCS
        have h_χ_mcs : χ ∈ fam.mcs t := (ih_χ fam hfam t).mpr h_χ_true
        -- But ¬χ ∈ MCS, contradiction
        exact set_consistent_not_both (fam.is_mcs t).1 χ h_χ_mcs h_neg_χ_mcs
  | box ψ ih =>
    /-
    BOX CASE: THE KEY TO THE ENTIRE APPROACH - FULLY PROVEN WITHOUT SORRY

    This is the case that was blocking traditional completeness proofs.
    The BMCS approach makes it work by:
    1. Truth of □ψ is defined as: ψ true at ALL families in the bundle
    2. MCS has □ψ iff ψ is in ALL families' MCSes (by modal coherence)
    3. These two conditions match exactly!
    -/
    simp only [bmcs_truth_at]
    constructor
    · -- Forward: □ψ ∈ MCS → ∀ fam' ∈ families, bmcs_truth ψ at fam'
      intro h_box fam' hfam'
      -- By modal_forward: ψ ∈ fam'.mcs t
      have h_ψ_mcs : ψ ∈ fam'.mcs t := B.modal_forward fam hfam ψ t h_box fam' hfam'
      -- By IH: bmcs_truth_at B fam' t ψ
      exact (ih fam' hfam' t).mp h_ψ_mcs
    · -- Backward: (∀ fam' ∈ families, bmcs_truth ψ at fam') → □ψ ∈ MCS
      intro h_all
      -- By IH: ψ ∈ fam'.mcs t for all fam' ∈ families
      have h_ψ_all_mcs : ∀ fam' ∈ B.families, ψ ∈ fam'.mcs t := by
        intro fam' hfam'
        exact (ih fam' hfam' t).mpr (h_all fam' hfam')
      -- By modal_backward: □ψ ∈ fam.mcs t
      exact B.modal_backward fam hfam ψ t h_ψ_all_mcs
  | all_future ψ ih =>
    -- G (all_future) case
    simp only [bmcs_truth_at]
    constructor
    · -- Forward: G ψ ∈ MCS → ∀ s ≥ t, bmcs_truth ψ at s (PROVEN)
      intro h_G s hts
      have h_ψ_mcs : ψ ∈ fam.mcs s := mcs_all_future_implies_phi_at_future fam t s ψ hts h_G
      exact (ih fam hfam s).mp h_ψ_mcs
    · -- Backward: (∀ s ≥ t, bmcs_truth ψ at s) → G ψ ∈ MCS
      -- Uses temporal_backward_G via the temporally_coherent hypothesis.
      -- The proof constructs a TemporalCoherentFamily from the family and its
      -- temporal coherence properties, then applies temporal_backward_G.
      intro h_all
      -- Extract forward_F and backward_P for this family from h_tc
      obtain ⟨h_forward_F, h_backward_P⟩ := h_tc fam hfam
      -- Build a TemporalCoherentFamily
      let tcf : TemporalCoherentFamily D := {
        toBFMCS := fam
        forward_F := h_forward_F
        backward_P := h_backward_P
      }
      -- By IH backward: convert truth to MCS membership at each time
      have h_all_mcs : ∀ s : D, t ≤ s → ψ ∈ fam.mcs s := by
        intro s hts
        exact (ih fam hfam s).mpr (h_all s hts)
      -- Apply temporal_backward_G
      exact temporal_backward_G tcf t ψ h_all_mcs
  | all_past ψ ih =>
    -- H (all_past) case - symmetric to all_future
    simp only [bmcs_truth_at]
    constructor
    · -- Forward: H ψ ∈ MCS → ∀ s ≤ t, bmcs_truth ψ at s (PROVEN)
      intro h_H s hst
      have h_ψ_mcs : ψ ∈ fam.mcs s := mcs_all_past_implies_phi_at_past fam t s ψ hst h_H
      exact (ih fam hfam s).mp h_ψ_mcs
    · -- Backward: (∀ s ≤ t, bmcs_truth ψ at s) → H ψ ∈ MCS
      -- Uses temporal_backward_H via the temporally_coherent hypothesis.
      intro h_all
      -- Extract forward_F and backward_P for this family from h_tc
      obtain ⟨h_forward_F, h_backward_P⟩ := h_tc fam hfam
      -- Build a TemporalCoherentFamily
      let tcf : TemporalCoherentFamily D := {
        toBFMCS := fam
        forward_F := h_forward_F
        backward_P := h_backward_P
      }
      -- By IH backward: convert truth to MCS membership at each time
      have h_all_mcs : ∀ s : D, s ≤ t → ψ ∈ fam.mcs s := by
        intro s hst
        exact (ih fam hfam s).mpr (h_all s hst)
      -- Apply temporal_backward_H
      exact temporal_backward_H tcf t ψ h_all_mcs

/-!
## Corollaries

These corollaries follow directly from the truth lemma and are useful
for the completeness proof.
-/

/--
If φ is in the MCS at the evaluation family and time 0, then φ is true there.
-/
theorem bmcs_eval_truth (B : BMCS D) (h_tc : B.temporally_coherent)
    (φ : Formula) (h : φ ∈ B.eval_family.mcs 0) :
    bmcs_truth_at B B.eval_family 0 φ :=
  (bmcs_truth_lemma B h_tc B.eval_family B.eval_family_mem 0 φ).mp h

/--
If φ is true at the evaluation family and time 0, then φ is in the MCS there.
-/
theorem bmcs_eval_mcs (B : BMCS D) (h_tc : B.temporally_coherent)
    (φ : Formula) (h : bmcs_truth_at B B.eval_family 0 φ) :
    φ ∈ B.eval_family.mcs 0 :=
  (bmcs_truth_lemma B h_tc B.eval_family B.eval_family_mem 0 φ).mpr h

/--
Box membership is equivalent to universal truth over bundle families.
This is a direct corollary combining the truth lemma with box semantics.
-/
theorem bmcs_box_iff_all_true (B : BMCS D) (h_tc : B.temporally_coherent)
    (fam : BFMCS D) (hfam : fam ∈ B.families)
    (t : D) (φ : Formula) :
    Formula.box φ ∈ fam.mcs t ↔ ∀ fam' ∈ B.families, bmcs_truth_at B fam' t φ := by
  rw [bmcs_truth_lemma B h_tc fam hfam t (Formula.box φ)]
  simp only [bmcs_truth_at]

/--
Truth of □φ at any family is the same (family-independent).
-/
theorem bmcs_box_truth_unique (B : BMCS D) (fam1 fam2 : BFMCS D)
    (_ : fam1 ∈ B.families) (_ : fam2 ∈ B.families) (t : D) (φ : Formula) :
    bmcs_truth_at B fam1 t (Formula.box φ) ↔ bmcs_truth_at B fam2 t (Formula.box φ) := by
  simp only [bmcs_truth_at]

/-!
## Summary of Proof Status

### ALL Cases Proven (for temporally coherent BMCS):
- **Atom**: Trivial by definition
- **Bot**: By MCS consistency
- **Imp**: By MCS modus ponens and negation completeness (note: forward uses backward on subformulas)
- **Box**: FULLY PROVEN using modal_forward and modal_backward
- **all_future (G)**: Forward via forward_G coherence; backward via temporal_backward_G
- **all_past (H)**: Forward via backward_H coherence; backward via temporal_backward_H

### Key Achievement

ALL cases of the truth lemma are now proven (no sorry in bmcs_truth_lemma).
- The BOX case uses the BMCS approach with modal_forward and modal_backward.
- The TEMPORAL cases use the temporally_coherent hypothesis, which provides
  forward_F and backward_P for the contraposition argument.

### Axiom Dependency

The truth lemma requires `B.temporally_coherent`, which is provided by the
construction in TemporalCoherentConstruction.lean. That construction depends on
the `temporally_saturated_mcs_exists` axiom, which asserts the existence of
temporally saturated MCS (standard Henkin construction result).

### EvalBMCS (Archived)

The EvalBMCS truth lemma was removed in task 912 (4 sorries eliminated).
Use `bmcs_truth_lemma` for the full truth lemma.
-/

/-!
## EvalBMCS Truth Lemma (ARCHIVED)

The `eval_bmcs_truth_lemma` and `eval_bmcs_eval_truth` were removed in task 912.
They had 4 sorries due to structural limitations of EvalBMCS (no full modal coherence).

The full BMCS approach (above) resolves all cases completely. Use `bmcs_truth_lemma` instead.

**Previous sorry locations** (for reference):
- Box forward: membership -> truth at non-eval families (EvalBMCS limitation)
- Box backward: truth -> membership at non-eval families (EvalBMCS limitation)
- all_future backward: temporal saturation needed
- all_past backward: temporal saturation needed
-/

end Bimodal.Metalogic.Bundle
