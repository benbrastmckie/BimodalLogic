/-!
# BONEYARD: MCS-Membership Completeness (BANNED)

**Status**: ARCHIVED - DO NOT REVIVE
**Archived by**: Task 931
**Date**: 2026-02-25
**Original locations**:
  - `Theories/Bimodal/Metalogic/Bundle/ChainBundleBFMCS.lean` (lines 350-691)
  - `Theories/Bimodal/Metalogic/Bundle/BFMCSTruth.lean` (lines 334-477)

## BAN NOTICE

This code is PERMANENTLY BANNED from the active codebase. It implements a
non-standard "MCS-membership" box semantics that departs from the standard
validity definition used in Kripke semantics.

### Why MCS-Membership Box Semantics Is Forbidden

The standard `bmcs_truth_at` defines Box using recursive truth:
  `Box phi TRUE := forall fam' in families, phi TRUE at fam'`

The non-standard `bmcs_truth_at_mcs` defines Box using MCS membership:
  `Box phi TRUE := forall fam' in families, phi IN fam'.mcs t`

**Problem**: The `_mcs` definition does NOT define a standard notion of validity.
It conflates semantic truth with syntactic membership, creating a completeness
theorem that is vacuously correct but semantically meaningless. The resulting
"completeness" does not establish the standard meta-theorem connecting provability
to truth in all models.

Research report: `specs/930_verify_correctness_mcs_membership_box_semantics/reports/research-001.md`

### Symbols Archived (from ChainBundleBFMCS.lean)

| Symbol | Kind | Description |
|--------|------|-------------|
| `bmcs_truth_at_mcs` | def | Non-standard truth definition |
| `bmcs_truth_mcs_neg` | theorem | Negation for non-standard truth |
| `bmcs_truth_lemma_mcs` | theorem | Truth lemma for non-standard semantics |
| `bmcs_valid_mcs` | def | Non-standard validity |
| `bmcs_consequence_mcs` | def | Non-standard consequence |
| `ContextDerivable_mcs` | def | Context derivability (duplicate) |
| `not_derivable_implies_neg_consistent_mcs` | lemma | Helper (duplicate) |
| `bmcs_not_valid_mcs_of_not_derivable` | theorem | Contrapositive weak completeness |
| `bmcs_weak_completeness_mcs` | theorem | Weak completeness (non-standard) |
| `context_not_derivable_implies_extended_consistent_mcs` | lemma | Helper (duplicate) |
| `bmcs_not_consequence_mcs_of_not_derivable` | theorem | Contrapositive strong completeness |
| `bmcs_strong_completeness_mcs` | theorem | Strong completeness (non-standard) |
| `bmcs_representation_mcs` | theorem | Representation (non-standard) |
| `bmcs_context_representation_mcs` | theorem | Context representation (non-standard) |

### Symbols Archived (from BFMCSTruth.lean)

| Symbol | Kind | Description |
|--------|------|-------------|
| `eval_bmcs_truth_at` | def | Truth for EvalBFMCS (dead code) |
| `eval_bmcs_satisfies_context` | def | Context satisfaction (dead code) |
| `eval_bmcs_truth_neg` | theorem | Negation truth (dead code) |
| `eval_bmcs_truth_and` | theorem | Conjunction truth (dead code) |
| `eval_bmcs_truth_or` | theorem | Disjunction truth (dead code) |
| `eval_bmcs_truth_diamond` | theorem | Diamond truth (dead code) |
| `eval_bmcs_truth_box_family_independent` | theorem | Box family independence (dead code) |
| `eval_bmcs_truth_box_reflexive` | theorem | Box reflexivity (dead code) |

The `eval_bmcs_*` code uses standard semantics but is dead code - never referenced
by any other module. It was created for a planned EvalBFMCS approach that was
superseded by the BFMCS construction in Completeness.lean.

## DO NOT REVIVE

Any future completeness work MUST use the standard `bmcs_truth_at` definition
from `BFMCSTruth.lean` (which defines Box via recursive truth, not MCS membership).
The sorry-free completeness chain is in `Bundle/Completeness.lean` using the
standard definition.
-/

/-
================================================================================
SECTION 1: Non-Standard MCS-Membership Completeness (from ChainBundleBFMCS.lean)
================================================================================

Original location: Theories/Bimodal/Metalogic/Bundle/ChainBundleBFMCS.lean
Original lines: 350-691
Reason for ban: Non-standard box semantics (MCS membership instead of recursive truth)
================================================================================
-/

-- All imports commented out to prevent build issues
-- import Bimodal.Metalogic.Bundle.BFMCS
-- import Bimodal.Metalogic.Bundle.CanonicalFMCS
-- import Bimodal.Metalogic.Bundle.ChainFMCS
-- import Bimodal.Metalogic.Bundle.ModalSaturation
-- import Bimodal.Metalogic.Bundle.Construction
-- import Bimodal.Metalogic.Bundle.TemporalCoherentConstruction
-- import Bimodal.Metalogic.Bundle.TruthLemma
-- import Bimodal.Theorems.Propositional

/-

namespace Bimodal.Metalogic.Bundle

open Bimodal.Syntax
open Bimodal.Metalogic.Core
open Bimodal.ProofSystem

/-!
## Modified Truth Definition
-/

/--
Modified BFMCS truth: Box uses MCS membership instead of recursive truth.
-/
def bmcs_truth_at_mcs {D : Type*} [Preorder D] (B : BFMCS D) (fam : FMCS D) (t : D) :
    Formula → Prop
  | Formula.atom p => Formula.atom p ∈ fam.mcs t
  | Formula.bot => False
  | Formula.imp φ ψ => bmcs_truth_at_mcs B fam t φ → bmcs_truth_at_mcs B fam t ψ
  | Formula.box φ => ∀ fam' ∈ B.families, φ ∈ fam'.mcs t
  | Formula.all_past φ => ∀ s, s ≤ t → bmcs_truth_at_mcs B fam s φ
  | Formula.all_future φ => ∀ s, t ≤ s → bmcs_truth_at_mcs B fam s φ

/--
Negation truth for modified semantics.
-/
theorem bmcs_truth_mcs_neg {D : Type*} [Preorder D]
    (B : BFMCS D) (fam : FMCS D) (t : D) (φ : Formula) :
    bmcs_truth_at_mcs B fam t (Formula.neg φ) ↔ ¬bmcs_truth_at_mcs B fam t φ := by
  unfold Formula.neg; simp only [bmcs_truth_at_mcs]

/-!
## Truth Lemma for Modified Semantics
-/

variable {D : Type*} [Preorder D] [Zero D]

/--
Modified truth lemma: requires temporal coherence ONLY for the evaluated family.
-/
theorem bmcs_truth_lemma_mcs (B : BFMCS D)
    (fam : FMCS D) (hfam : fam ∈ B.families)
    (h_forward_F : ∀ t : D, ∀ φ : Formula,
      Formula.some_future φ ∈ fam.mcs t → ∃ s : D, t ≤ s ∧ φ ∈ fam.mcs s)
    (h_backward_P : ∀ t : D, ∀ φ : Formula,
      Formula.some_past φ ∈ fam.mcs t → ∃ s : D, s ≤ t ∧ φ ∈ fam.mcs s)
    (t : D) (φ : Formula) :
    φ ∈ fam.mcs t ↔ bmcs_truth_at_mcs B fam t φ := by
  induction φ generalizing t with
  | atom p => simp only [bmcs_truth_at_mcs]
  | bot =>
    simp only [bmcs_truth_at_mcs]
    constructor
    · intro h_bot
      exact (fam.is_mcs t).1 [Formula.bot]
        (fun ψ hψ => by simp at hψ; rw [hψ]; exact h_bot)
        ⟨DerivationTree.assumption [Formula.bot] Formula.bot (by simp)⟩
    · exact False.elim
  | imp ψ χ ih_ψ ih_χ =>
    simp only [bmcs_truth_at_mcs]
    have h_mcs := fam.is_mcs t
    constructor
    · intro h_imp h_ψ_true
      exact (ih_χ t).mp (set_mcs_implication_property h_mcs h_imp ((ih_ψ t).mpr h_ψ_true))
    · intro h_truth_imp
      rcases set_mcs_negation_complete h_mcs (ψ.imp χ) with h_imp | h_neg_imp
      · exact h_imp
      · exfalso
        -- neg(ψ → χ) ∈ MCS implies ψ ∈ MCS and neg χ ∈ MCS
        have h_ψ_mcs : ψ ∈ fam.mcs t := by
          have h_taut : [] ⊢ (ψ.imp χ).neg.imp ψ := neg_imp_implies_antecedent ψ χ
          exact set_mcs_implication_property h_mcs (theorem_in_mcs h_mcs h_taut) h_neg_imp
        have h_neg_χ : χ.neg ∈ fam.mcs t := by
          have h_taut : [] ⊢ (ψ.imp χ).neg.imp χ.neg := neg_imp_implies_neg_consequent ψ χ
          exact set_mcs_implication_property h_mcs (theorem_in_mcs h_mcs h_taut) h_neg_imp
        exact set_consistent_not_both h_mcs.1 χ
          ((ih_χ t).mpr (h_truth_imp ((ih_ψ t).mp h_ψ_mcs))) h_neg_χ
  | box ψ _ih =>
    simp only [bmcs_truth_at_mcs]
    exact ⟨B.modal_forward fam hfam ψ t, B.modal_backward fam hfam ψ t⟩
  | all_future ψ ih =>
    simp only [bmcs_truth_at_mcs]
    constructor
    · intro h_G s hts
      exact (ih s).mp (fam.forward_G t s ψ hts h_G)
    · intro h_all
      let tcf : TemporalCoherentFamily D := {
        toFMCS := fam
        forward_F := h_forward_F
        backward_P := h_backward_P
      }
      exact temporal_backward_G tcf t ψ (fun s hts => (ih s).mpr (h_all s hts))
  | all_past ψ ih =>
    simp only [bmcs_truth_at_mcs]
    constructor
    · intro h_H s hst
      exact (ih s).mp (fam.backward_H t s ψ hst h_H)
    · intro h_all
      let tcf : TemporalCoherentFamily D := {
        toFMCS := fam
        forward_F := h_forward_F
        backward_P := h_backward_P
      }
      exact temporal_backward_H tcf t ψ (fun s hst => (ih s).mpr (h_all s hst))

/-!
## Fully Saturated BFMCS Existence
-/

/--
For any consistent context, there exists a fully saturated BFMCS
over CanonicalBC with all required properties.
-/
theorem fully_saturated_bfmcs_exists_CanonicalBC
    (Gamma : List Formula) (h_cons : ContextConsistent Gamma) :
    ∃ (BC : Set Formula) (B : BFMCS (CanonicalBC BC))
      (root : CanonicalBC BC),
      (∀ gamma ∈ Gamma, gamma ∈ B.eval_family.mcs root) ∧
      (∀ t : CanonicalBC BC, ∀ φ : Formula,
        Formula.some_future φ ∈ B.eval_family.mcs t →
          ∃ s : CanonicalBC BC, t ≤ s ∧ φ ∈ B.eval_family.mcs s) ∧
      (∀ t : CanonicalBC BC, ∀ φ : Formula,
        Formula.some_past φ ∈ B.eval_family.mcs t →
          ∃ s : CanonicalBC BC, s ≤ t ∧ φ ∈ B.eval_family.mcs s) ∧
      is_modally_saturated B := by
  let M0 := lindenbaumMCS Gamma h_cons
  have h_mcs0 := lindenbaumMCS_is_mcs Gamma h_cons
  have h_extends := lindenbaumMCS_extends Gamma h_cons
  let BC := MCSBoxContent M0
  let root : CanonicalBC BC := ⟨M0, h_mcs0, rfl⟩
  refine ⟨BC, chainBundleBFMCS BC, root, ?_, ?_, ?_, ?_⟩
  · intro gamma h_mem
    exact h_extends (by simp [contextAsSet]; exact h_mem)
  · exact canonicalBC_forward_F BC
  · exact canonicalBC_backward_P BC
  · exact chainBundleBFMCS_modally_saturated BC

/--
Representation theorem: consistent formula has a satisfying BFMCS.
-/
theorem bmcs_representation_mcs (φ : Formula) (h_cons : ContextConsistent [φ]) :
    ∃ (BC : Set Formula) (B : BFMCS (CanonicalBC BC))
      (root : CanonicalBC BC),
      bmcs_truth_at_mcs B B.eval_family root φ := by
  obtain ⟨BC, B, root, h_ctx, h_fwd, h_bwd, _⟩ :=
    fully_saturated_bfmcs_exists_CanonicalBC [φ] h_cons
  haveI : Zero (CanonicalBC BC) := ⟨root⟩
  exact ⟨BC, B, root,
    (bmcs_truth_lemma_mcs B B.eval_family B.eval_family_mem h_fwd h_bwd root φ).mp
      (h_ctx φ (by simp))⟩

/--
Context representation: consistent context has a satisfying BFMCS.
-/
theorem bmcs_context_representation_mcs (Γ : List Formula) (h_cons : ContextConsistent Γ) :
    ∃ (BC : Set Formula) (B : BFMCS (CanonicalBC BC))
      (root : CanonicalBC BC),
      ∀ γ ∈ Γ, bmcs_truth_at_mcs B B.eval_family root γ := by
  obtain ⟨BC, B, root, h_ctx, h_fwd, h_bwd, _⟩ :=
    fully_saturated_bfmcs_exists_CanonicalBC Γ h_cons
  haveI : Zero (CanonicalBC BC) := ⟨root⟩
  exact ⟨BC, B, root, fun γ h_mem =>
    (bmcs_truth_lemma_mcs B B.eval_family B.eval_family_mem h_fwd h_bwd root γ).mp
      (h_ctx γ h_mem)⟩

/-!
## Completeness Theorems Using Modified Truth (Task 925 Phase 7)

These theorems prove weak and strong completeness using the `bmcs_truth_at_mcs`
semantics with the CanonicalBC-based BFMCS construction. This completeness chain
is entirely sorry-free, unlike the original chain through `fully_saturated_bfmcs_exists_int`.

### Key Difference from Completeness.lean

The original completeness chain (Completeness.lean) uses `bmcs_truth_at` with recursive
truth for Box, which requires temporal coherence of ALL families in the BFMCS. This led
to the `fully_saturated_bfmcs_exists_int` sorry (constant witness families are not
temporally coherent).

The new chain uses `bmcs_truth_at_mcs` where Box is defined by MCS membership:
  Box φ TRUE := ∀ fam' ∈ families, φ ∈ fam'.mcs t

This only requires temporal coherence of the evaluated family (the eval family),
which IS temporally coherent because it maps each CanonicalBC element to its own MCS.
-/

/--
Validity using modified truth: a formula is valid iff true in every BFMCS
for every family and time point.
-/
def bmcs_valid_mcs (φ : Formula) : Prop :=
  ∀ (BC : Set Formula) (B : BFMCS (CanonicalBC BC))
    (fam : FMCS (CanonicalBC BC)) (_ : fam ∈ B.families)
    (t : CanonicalBC BC), bmcs_truth_at_mcs B fam t φ

/--
Consequence using modified truth: φ is a consequence of Γ if whenever
Γ is satisfied, φ is also satisfied.
-/
def bmcs_consequence_mcs (Γ : List Formula) (φ : Formula) : Prop :=
  ∀ (BC : Set Formula) (B : BFMCS (CanonicalBC BC))
    (fam : FMCS (CanonicalBC BC)) (_ : fam ∈ B.families)
    (t : CanonicalBC BC),
    (∀ γ ∈ Γ, bmcs_truth_at_mcs B fam t γ) → bmcs_truth_at_mcs B fam t φ

/--
Context derivability: there exists a derivation of φ from Γ.
-/
def ContextDerivable_mcs (Γ : List Formula) (φ : Formula) : Prop :=
  Nonempty (DerivationTree Γ φ)

/--
Helper: If `⊬ φ` (not derivable from empty context), then `[φ.neg]` is consistent.

**Proof Strategy**:
Suppose `[φ.neg]` is inconsistent. By deduction theorem, `⊢ ¬¬φ`.
By double negation elimination, `⊢ φ`. Contradiction.
-/
lemma not_derivable_implies_neg_consistent_mcs (φ : Formula)
    (h_not_deriv : ¬Nonempty (DerivationTree [] φ)) :
    ContextConsistent [φ.neg] := by
  intro ⟨d_bot⟩
  have d_neg_neg : DerivationTree [] (φ.neg.neg) :=
    Bimodal.Metalogic.Core.deduction_theorem [] φ.neg Formula.bot d_bot
  have h_dne : DerivationTree [] (φ.neg.neg.imp φ) :=
    Bimodal.Theorems.Propositional.double_negation φ
  have d_phi : DerivationTree [] φ :=
    DerivationTree.modus_ponens [] φ.neg.neg φ h_dne d_neg_neg
  exact h_not_deriv ⟨d_phi⟩

/--
**Weak Completeness (Contrapositive Form)**: If `⊬ φ`, then `φ` is not valid
under modified truth semantics.

**Proof Strategy**:
1. If `⊬ φ`, then `[¬φ]` is consistent
2. By `bmcs_representation_mcs`, there exists a BFMCS where `¬φ` is true
3. So `φ` is false at that point
4. Therefore `φ` is not valid
-/
theorem bmcs_not_valid_mcs_of_not_derivable (φ : Formula)
    (h_not_deriv : ¬Nonempty (DerivationTree [] φ)) :
    ¬bmcs_valid_mcs φ := by
  have h_neg_cons : ContextConsistent [φ.neg] :=
    not_derivable_implies_neg_consistent_mcs φ h_not_deriv
  obtain ⟨BC, B, root, h_neg_true⟩ := bmcs_representation_mcs φ.neg h_neg_cons
  have h_phi_false : ¬bmcs_truth_at_mcs B B.eval_family root φ := by
    rw [← bmcs_truth_mcs_neg]
    exact h_neg_true
  intro h_valid
  apply h_phi_false
  exact h_valid BC B B.eval_family B.eval_family_mem root

/--
**Weak Completeness**: If `φ` is valid under modified truth semantics, then `⊢ φ`.

This is the main weak completeness theorem for the sorry-free construction.
-/
theorem bmcs_weak_completeness_mcs (φ : Formula) (h_valid : bmcs_valid_mcs φ) :
    Nonempty (DerivationTree [] φ) := by
  by_contra h_not
  exact bmcs_not_valid_mcs_of_not_derivable φ h_not h_valid

/--
Helper: If Γ ⊬ φ, then Γ ++ [¬φ] is consistent.
-/
lemma context_not_derivable_implies_extended_consistent_mcs
    (Γ : List Formula) (φ : Formula)
    (h_not_deriv : ¬ContextDerivable_mcs Γ φ) :
    ContextConsistent (Γ ++ [φ.neg]) := by
  intro ⟨d_bot⟩
  have h_subset : Γ ++ [φ.neg] ⊆ φ.neg :: Γ := by
    intro x hx; simp at hx ⊢; tauto
  have d_bot_reordered : (φ.neg :: Γ) ⊢ Formula.bot :=
    DerivationTree.weakening (Γ ++ [φ.neg]) (φ.neg :: Γ) Formula.bot d_bot h_subset
  have d_neg_neg : Γ ⊢ φ.neg.neg :=
    Bimodal.Metalogic.Core.deduction_theorem Γ φ.neg Formula.bot d_bot_reordered
  have h_dne : DerivationTree [] (φ.neg.neg.imp φ) :=
    Bimodal.Theorems.Propositional.double_negation φ
  have h_dne_ctx : Γ ⊢ φ.neg.neg.imp φ :=
    DerivationTree.weakening [] Γ (φ.neg.neg.imp φ) h_dne (by intro; simp)
  have d_phi : Γ ⊢ φ :=
    DerivationTree.modus_ponens Γ φ.neg.neg φ h_dne_ctx d_neg_neg
  exact h_not_deriv ⟨d_phi⟩

/--
**Strong Completeness (Contrapositive Form)**: If Γ ⊬ φ, then φ is not a
consequence of Γ under modified truth semantics.
-/
theorem bmcs_not_consequence_mcs_of_not_derivable (Γ : List Formula) (φ : Formula)
    (h_not_deriv : ¬ContextDerivable_mcs Γ φ) :
    ¬bmcs_consequence_mcs Γ φ := by
  have h_ext_cons : ContextConsistent (Γ ++ [φ.neg]) :=
    context_not_derivable_implies_extended_consistent_mcs Γ φ h_not_deriv
  obtain ⟨BC, B, root, h_all_true⟩ :=
    bmcs_context_representation_mcs (Γ ++ [φ.neg]) h_ext_cons
  have h_neg_true : bmcs_truth_at_mcs B B.eval_family root φ.neg := by
    apply h_all_true; simp
  have h_phi_false : ¬bmcs_truth_at_mcs B B.eval_family root φ := by
    rw [← bmcs_truth_mcs_neg]; exact h_neg_true
  have h_gamma_sat : ∀ γ ∈ Γ, bmcs_truth_at_mcs B B.eval_family root γ := by
    intro γ h_mem; apply h_all_true; simp [h_mem]
  intro h_conseq
  apply h_phi_false
  exact h_conseq BC B B.eval_family B.eval_family_mem root h_gamma_sat

/--
**Strong Completeness**: If φ is a consequence of Γ under modified truth
semantics, then Γ ⊢ φ.

This is the main strong completeness theorem for the sorry-free construction.
-/
theorem bmcs_strong_completeness_mcs (Γ : List Formula) (φ : Formula)
    (h_conseq : bmcs_consequence_mcs Γ φ) :
    ContextDerivable_mcs Γ φ := by
  by_contra h_not
  exact bmcs_not_consequence_mcs_of_not_derivable Γ φ h_not h_conseq

/-!
## Summary of Sorry-Free Completeness Chain

This module provides a COMPLETELY sorry-free completeness chain:

1. **chainBundleBFMCS**: Sorry-free BFMCS over CanonicalBC
2. **bmcs_truth_lemma_mcs**: Sorry-free truth lemma (per-family temporal coherence)
3. **fully_saturated_bfmcs_exists_CanonicalBC**: Sorry-free existence
4. **bmcs_representation_mcs**: Sorry-free representation
5. **bmcs_weak_completeness_mcs**: Sorry-free weak completeness
6. **bmcs_strong_completeness_mcs**: Sorry-free strong completeness

### What This Means

The original completeness chain (Completeness.lean) has a sorry via
`fully_saturated_bfmcs_exists_int`. This new chain eliminates that sorry by:
- Using `CanonicalBC` as the domain instead of `Int`
- Using modified truth `bmcs_truth_at_mcs` (Box by MCS membership)
- Only requiring temporal coherence of the eval family

Both chains prove the same meta-theorem:
  "If φ is valid, then ⊢ φ" (weak completeness)
  "If Γ ⊨ φ, then Γ ⊢ φ" (strong completeness)

The modified truth semantics defines validity/consequence slightly differently
(Box via MCS membership rather than recursive truth), but the resulting completeness
theorem is equally valid because it connects the same proof system to a sound and
complete semantics.
-/

end Bimodal.Metalogic.Bundle

-/

/-
================================================================================
SECTION 2: Dead EvalBFMCS Truth Code (from BFMCSTruth.lean)
================================================================================

Original location: Theories/Bimodal/Metalogic/Bundle/BFMCSTruth.lean
Original lines: 334-477
Reason for archival: Dead code - never referenced by any module. Created for a
  planned EvalBFMCS approach that was superseded by the BFMCS construction
  in Completeness.lean. Uses standard semantics (not non-standard), but is
  redundant with the `bmcs_truth_at` definition already in BFMCSTruth.lean.
================================================================================
-/

/-

namespace Bimodal.Metalogic.Bundle

open Bimodal.Syntax
open Bimodal.Metalogic.Core

variable {D : Type*} [Preorder D]

/-!
## EvalBFMCS Truth Definition

The EvalBFMCS structure from CoherentConstruction.lean provides a weaker but sufficient
structure for completeness proofs. It guarantees:
- `modal_forward_eval`: Box phi in eval_family → phi in all families
- `modal_backward_eval`: phi in all families → Box phi in eval_family

This suffices for the truth lemma when evaluating at the eval_family.
-/

-- Import EvalBFMCS from CoherentConstruction
-- Note: We define truth for EvalBFMCS by reusing the same recursive definition
-- but the modal coherence properties are different.

/--
Truth of a formula at a specific family and time within an EvalBFMCS.

**Parameters**:
- `B`: The EvalBFMCS providing the bundle of families
- `fam`: The specific family at which we evaluate
- `t`: The time point at which we evaluate
- `φ`: The formula to evaluate

This mirrors `bmcs_truth_at` exactly - the semantic definition is the same.
The difference is in the structure (EvalBFMCS vs BFMCS) and what coherence properties hold.
-/
def eval_bmcs_truth_at (families : Set (FMCS D))
    (fam : FMCS D) (t : D) : Formula → Prop
  | Formula.atom p => Formula.atom p ∈ fam.mcs t
  | Formula.bot => False
  | Formula.imp φ ψ => eval_bmcs_truth_at families fam t φ → eval_bmcs_truth_at families fam t ψ
  | Formula.box φ => ∀ fam' ∈ families, eval_bmcs_truth_at families fam' t φ
  | Formula.all_past φ => ∀ s, s ≤ t → eval_bmcs_truth_at families fam s φ
  | Formula.all_future φ => ∀ s, t ≤ s → eval_bmcs_truth_at families fam s φ

/--
Context is satisfied in an EvalBFMCS at a given family and time.
-/
def eval_bmcs_satisfies_context (families : Set (FMCS D))
    (fam : FMCS D) (t : D) (Γ : List Formula) : Prop :=
  ∀ γ ∈ Γ, eval_bmcs_truth_at families fam t γ

/-!
## EvalBFMCS Truth Properties

These lemmas mirror the BFMCS truth properties but for the EvalBFMCS structure.
-/

/--
Truth of negation in EvalBFMCS: `¬φ` is true iff `φ` is false.
-/
theorem eval_bmcs_truth_neg (families : Set (FMCS D))
    (fam : FMCS D) (t : D) (φ : Formula) :
    eval_bmcs_truth_at families fam t (Formula.neg φ) ↔
    ¬eval_bmcs_truth_at families fam t φ := by
  unfold Formula.neg
  simp only [eval_bmcs_truth_at]

/--
Truth of conjunction in EvalBFMCS: `φ ∧ ψ` is true iff both `φ` and `ψ` are true.
-/
theorem eval_bmcs_truth_and (families : Set (FMCS D))
    (fam : FMCS D) (t : D) (φ ψ : Formula) :
    eval_bmcs_truth_at families fam t (Formula.and φ ψ) ↔
    eval_bmcs_truth_at families fam t φ ∧ eval_bmcs_truth_at families fam t ψ := by
  unfold Formula.and Formula.neg
  simp only [eval_bmcs_truth_at]
  constructor
  · intro h
    by_contra h_neg
    simp only [not_and_or] at h_neg
    cases h_neg with
    | inl h_not_phi =>
      apply h
      intro hφ
      exact absurd hφ h_not_phi
    | inr h_not_psi =>
      apply h
      intro _ hψ
      exact absurd hψ h_not_psi
  · intro ⟨hφ, hψ⟩
    intro h_imp
    exact h_imp hφ hψ

/--
Truth of disjunction in EvalBFMCS: `φ ∨ ψ` is true iff `φ` or `ψ` is true.
-/
theorem eval_bmcs_truth_or (families : Set (FMCS D))
    (fam : FMCS D) (t : D) (φ ψ : Formula) :
    eval_bmcs_truth_at families fam t (Formula.or φ ψ) ↔
    eval_bmcs_truth_at families fam t φ ∨ eval_bmcs_truth_at families fam t ψ := by
  unfold Formula.or Formula.neg
  simp only [eval_bmcs_truth_at]
  constructor
  · intro h
    by_cases hφ : eval_bmcs_truth_at families fam t φ
    · left; exact hφ
    · right; exact h hφ
  · intro h h_not_phi
    cases h with
    | inl hφ => exact absurd hφ h_not_phi
    | inr hψ => exact hψ

/--
Truth of diamond (possibility) in EvalBFMCS: `◇φ` is true iff `φ` is true at some family.
-/
theorem eval_bmcs_truth_diamond (families : Set (FMCS D))
    (fam : FMCS D) (t : D) (φ : Formula) :
    eval_bmcs_truth_at families fam t (Formula.diamond φ) ↔
    ∃ fam' ∈ families, eval_bmcs_truth_at families fam' t φ := by
  unfold Formula.diamond Formula.neg
  simp only [eval_bmcs_truth_at]
  constructor
  · intro h
    by_contra h_no_witness
    push_neg at h_no_witness
    apply h
    intro fam' hfam' h_phi
    exact h_no_witness fam' hfam' h_phi
  · intro ⟨fam', hfam', hφ⟩ h_all
    exact h_all fam' hfam' hφ

/--
Box truth is independent of which family we evaluate at in EvalBFMCS.
-/
theorem eval_bmcs_truth_box_family_independent (families : Set (FMCS D))
    (fam1 fam2 : FMCS D) (_ : fam1 ∈ families) (_ : fam2 ∈ families)
    (t : D) (φ : Formula) :
    eval_bmcs_truth_at families fam1 t (Formula.box φ) ↔
    eval_bmcs_truth_at families fam2 t (Formula.box φ) := by
  constructor <;> (intro h; exact h)

/--
Box implies the formula at the same family (reflexivity / T axiom) in EvalBFMCS.
-/
theorem eval_bmcs_truth_box_reflexive (families : Set (FMCS D))
    (fam : FMCS D) (hfam : fam ∈ families) (t : D) (φ : Formula)
    (h : eval_bmcs_truth_at families fam t (Formula.box φ)) :
    eval_bmcs_truth_at families fam t φ := by
  simp only [eval_bmcs_truth_at] at h
  exact h fam hfam

end Bimodal.Metalogic.Bundle

-/
