import Bimodal.Metalogic.BXCanonical.OrderedSeedConsistency
import Bimodal.Metalogic.BXCanonical.CanonicalModel
import Bimodal.Metalogic.BXCanonical.Quasimodel.OracleStep
import Bimodal.Metalogic.Bundle.UntilSinceCoherence
import Bimodal.Metalogic.Algebraic.ParametricRepresentation
import Bimodal.Metalogic.Algebraic.RestrictedParametricTruthLemma

/-!
# Root-Scoped Defect-Discharge Chain

New FMCS/BFMCS with all coherence properties, replacing `bx_countermodel`.

## Architecture: Infinite Round-Robin Chain

Instead of a 3-region chain, we use an infinite round-robin that cycles
through all formulas in sigma, resolving each one at its scheduled step.
F-formulas persist between steps because:
1. At non-resolving steps: f_carry preserves them
2. At resolving steps: the enriched seed (via BX11 fold) protects them
3. F(F(ψ)) → F(ψ) by temp_4 contrapositive ensures fold compounds work

Box stability is guaranteed by including `modal_fix(M₀)` in every seed.

## Key Insight

F(F(ψ)) → F(ψ) follows from temp_4: G(φ) → G(G(φ)).
Contrapositive: ¬G(G(φ)) → ¬G(φ), i.e., F(¬G(φ)) → F(φ).
Setting φ = ¬ψ: F(¬G(¬ψ)) → F(¬ψ)... wait, that's not right.
Actually: G(G(¬ψ)) → G(¬ψ) is NOT temp_4 (temp_4 goes the other way).
temp_4: G(φ) → G(G(φ)). Contrapositive: ¬G(G(φ)) → ¬G(φ).
With φ = ¬ψ: ¬G(G(¬ψ)) → ¬G(¬ψ), i.e., F(G(¬ψ)) → F(ψ)... no.
F(φ) = ¬G(¬φ). F(F(ψ)) = F(¬G(¬ψ)) = ¬G(¬¬G(¬ψ)) = ¬G(G(¬ψ)).
And from temp_4 with φ = ¬ψ: G(¬ψ) → G(G(¬ψ)).
Contrapositive: ¬G(G(¬ψ)) → ¬G(¬ψ).
So F(F(ψ)) = ¬G(G(¬ψ)) → ¬G(¬ψ) = F(ψ). ✓

This is derivable in BX. At the MCS level: F(F(ψ)) ∈ M → F(ψ) ∈ M.
-/

namespace Bimodal.Metalogic.BXCanonical

open Bimodal.Syntax
open Bimodal.ProofSystem
open Bimodal.Metalogic.Core
open Bimodal.Metalogic.Bundle
open Bimodal.Metalogic.Algebraic.ParametricCanonical
open Bimodal.Metalogic.Algebraic.ParametricHistory
open Bimodal.Metalogic.Algebraic.ParametricTruthLemma
open Bimodal.Metalogic.Algebraic.ParametricRepresentation
open Bimodal.Metalogic.Algebraic.RestrictedParametricTruthLemma
open Bimodal.Semantics
open Bimodal.Theorems.Propositional
open Bimodal.Theorems.Combinators
open Bimodal.Theorems.Perpetuity
open Classical

/-! ## F(F(ψ)) → F(ψ) -/

/-- F(F(ψ)) → F(ψ) is derivable in BX.
Proof: temp_4 gives G(¬ψ) → G(G(¬ψ)). Contrapositive: ¬G(G(¬ψ)) → ¬G(¬ψ).
Since F(F(ψ)) = ¬G(G(¬ψ)) and F(ψ) = ¬G(¬ψ), this is F(F(ψ)) → F(ψ). -/
noncomputable def FF_imp_F (ψ : Formula) :
    DerivationTree [] ((Formula.some_future ψ).some_future.imp (Formula.some_future ψ)) := by
  -- Step 1: G(¬ψ) → G(G(¬ψ)) by temp_4
  have h1 : [] ⊢ (Formula.all_future (Formula.neg ψ)).imp
      (Formula.all_future (Formula.all_future (Formula.neg ψ))) :=
    DerivationTree.axiom [] _ (Axiom.temp_4 (Formula.neg ψ))
  -- Step 2: G(¬ψ) → ¬¬G(¬ψ) by double negation intro
  have h2 : [] ⊢ (Formula.all_future (Formula.neg ψ)).imp
      (Formula.all_future (Formula.neg ψ)).neg.neg :=
    dni (Formula.all_future (Formula.neg ψ))
  -- Step 3: G(G(¬ψ)) → G(¬¬G(¬ψ)) by G-monotonicity of h2
  have h3 : [] ⊢ (Formula.all_future (Formula.all_future (Formula.neg ψ))).imp
      (Formula.all_future (Formula.all_future (Formula.neg ψ)).neg.neg) :=
    future_mono h2
  -- Step 4: G(¬ψ) → G(¬¬G(¬ψ)) by composing h1 and h3
  have h4 : [] ⊢ (Formula.all_future (Formula.neg ψ)).imp
      (Formula.all_future (Formula.all_future (Formula.neg ψ)).neg.neg) :=
    imp_trans h1 h3
  -- Step 5: ¬G(¬¬G(¬ψ)) → ¬G(¬ψ) by contrapositive
  -- This is F(F(ψ)) → F(ψ) since:
  --   F(ψ) = ¬G(¬ψ) = (all_future (neg ψ)).neg
  --   F(F(ψ)) = ¬G(¬F(ψ)) = ¬G(¬¬G(¬ψ)) = (all_future (neg (neg (all_future (neg ψ))))).neg
  --           = (all_future (all_future (neg ψ)).neg.neg).neg
  exact Bimodal.Theorems.Propositional.contraposition h4

/-- F(F(ψ)) ∈ M → F(ψ) ∈ M for any MCS M. -/
theorem FF_imp_F_mcs {M : Set Formula} (h_mcs : SetMaximalConsistent M)
    (ψ : Formula) (h : (Formula.some_future ψ).some_future ∈ M) :
    Formula.some_future ψ ∈ M :=
  SetMaximalConsistent.implication_property h_mcs (theorem_in_mcs h_mcs (FF_imp_F ψ)) h

/-! ## F-Monotonicity

F(A ∧ B) → F(A) and F(A ∧ B) → F(B), derived from conjunction elimination
and contrapositive reasoning through G. -/

/-- F-monotonicity: from ⊢ A → B, derive ⊢ F(A) → F(B).
Proof: contrapose A → B to ¬B → ¬A, lift to G(¬B) → G(¬A) by future_mono,
contrapose to ¬G(¬A) → ¬G(¬B), i.e., F(A) → F(B). -/
noncomputable def F_mono {A B : Formula} (h : ⊢ A.imp B) :
    ⊢ A.some_future.imp B.some_future := by
  -- ⊢ ¬B → ¬A
  have h1 := Bimodal.Theorems.Propositional.contraposition h
  -- ⊢ G(¬B) → G(¬A)
  have h2 := future_mono h1
  -- ⊢ ¬G(¬A) → ¬G(¬B), i.e., F(A) → F(B)
  exact Bimodal.Theorems.Propositional.contraposition h2

/-- F(A ∧ B) → F(A) at MCS level. -/
theorem F_conj_left_mcs {M : Set Formula} (h_mcs : SetMaximalConsistent M)
    (A B : Formula) (h : (A.and B).some_future ∈ M) :
    A.some_future ∈ M :=
  SetMaximalConsistent.implication_property h_mcs
    (theorem_in_mcs h_mcs (F_mono (Bimodal.Theorems.Propositional.lce_imp A B))) h

/-- F(A ∧ B) → F(B) at MCS level. -/
theorem F_conj_right_mcs {M : Set Formula} (h_mcs : SetMaximalConsistent M)
    (A B : Formula) (h : (A.and B).some_future ∈ M) :
    B.some_future ∈ M :=
  SetMaximalConsistent.implication_property h_mcs
    (theorem_in_mcs h_mcs (F_mono (Bimodal.Theorems.Propositional.rce_imp A B))) h

/-! ## BX11 Fold: Enriched Forward Step Existence

Given F(target) ∈ M and F(χᵢ) ∈ M for each χᵢ in a list `others`,
construct an MCS M' with g_content(M) ⊆ M' where for EACH formula
(target and all others): either the formula itself or its F-version is in M'.

The construction uses iterated BX11 to build a compound F-formula.
At each step, BX11 gives three cases; in all cases, the compound grows
and each original formula is represented as either direct or F-protected.
F(A ∧ B) → F(A) (F-monotonicity) handles extraction from nested F-conjunctions.
F(F(ψ)) → F(ψ) (FF_imp_F) reduces double-F to single-F. -/

/-- Enriched forward step existence: given F-formulas for target and others in M,
there exists MCS M' extending g_content(M) where each formula is either
directly present or F-protected.

The proof works by BX11 fold. We produce a formula `β` with `F(β) ∈ M`
such that from `β ∈ M'` (MCS), each original formula ψᵢ satisfies
`ψᵢ ∈ M'` or `F(ψᵢ) ∈ M'`.

Base: `β = target`, from `F(target) ∈ M`.
Step: given `F(β) ∈ M` and `F(χ) ∈ M`, BX11 gives `F(β')` for some β':
  - F(β ∧ χ): β' = β ∧ χ. From β' ∈ M': β ∈ M' and χ ∈ M'.
  - F(β ∧ F(χ)): β' = β ∧ F(χ). From β' ∈ M': β ∈ M' and F(χ) ∈ M'.
  - F(F(β) ∧ χ): β' = F(β) ∧ χ. From β' ∈ M': F(β) ∈ M' and χ ∈ M'.
    For items tracked inside β: F(β) ∈ M' gives F(component) ∈ M' by
    F-monotonicity, and FF_imp_F collapses double-F.

Helper: BX11 fold compound. Given `F(β) ∈ M` and F-membership for a list,
produce `β'` with `F(β') ∈ M` such that from `β' ∈ M'` (MCS):
- from `β ∈ M'`, all previous items are recovered (by extract_prev)
- F(β) ∈ M' gives F-versions of previous items (by F-monotonicity)
- each new χ satisfies χ ∈ M' or F(χ) ∈ M'

The invariant: there exists β with F(β) ∈ M and an extraction function
`extract : β ∈ M' → (target ∈ M' ∨ F(target) ∈ M') ∧ ∀ χ ∈ seen, (χ ∈ M' ∨ F(χ) ∈ M')`.
When β gets F-wrapped (BX11 case 3), the extraction degrades: direct ψ ∈ M'
becomes F(ψ) ∈ M' (via F-monotonicity from F(β) ∈ M'). This is fine since
the conclusion allows either. -/
private theorem enriched_fwd_fold {M : Set Formula} (h_mcs : SetMaximalConsistent M)
    (β : Formula) (h_Fβ : Formula.some_future β ∈ M)
    -- The extraction function for the accumulated compound
    (tracked : List Formula)
    (h_extract : ∀ M' : Set Formula, SetMaximalConsistent M' →
      β ∈ M' → ∀ χ, χ ∈ tracked → (χ ∈ M' ∨ Formula.some_future χ ∈ M'))
    (h_F_extract : ∀ M' : Set Formula, SetMaximalConsistent M' →
      Formula.some_future β ∈ M' → ∀ χ, χ ∈ tracked → Formula.some_future χ ∈ M')
    -- New formulas to fold in
    (others : List Formula) (h_F_others : ∀ χ, χ ∈ others → Formula.some_future χ ∈ M) :
    ∃ β' : Formula, Formula.some_future β' ∈ M ∧
      (∀ M' : Set Formula, SetMaximalConsistent M' →
        β' ∈ M' → ∀ χ, χ ∈ tracked ++ others → (χ ∈ M' ∨ Formula.some_future χ ∈ M')) ∧
      (∀ M' : Set Formula, SetMaximalConsistent M' →
        Formula.some_future β' ∈ M' → ∀ χ, χ ∈ tracked ++ others → Formula.some_future χ ∈ M') := by
  induction others generalizing β tracked with
  | nil =>
    exact ⟨β, h_Fβ,
      fun M' h_mcs' h_β χ hχ => by rw [List.append_nil] at hχ; exact h_extract M' h_mcs' h_β χ hχ,
      fun M' h_mcs' h_Fβ' χ hχ => by rw [List.append_nil] at hχ; exact h_F_extract M' h_mcs' h_Fβ' χ hχ⟩
  | cons χ rest ih =>
    -- F(β) ∈ M and F(χ) ∈ M. Apply BX11.
    have h_Fχ : Formula.some_future χ ∈ M := h_F_others χ (by simp)
    rcases temp_linearity_mcs h_mcs β χ h_Fβ h_Fχ with
      h_both | h_β_first | h_χ_first
    · -- Case 1: F(β ∧ χ) ∈ M. New compound: β ∧ χ.
      rw [show tracked ++ χ :: rest = (tracked ++ [χ]) ++ rest from by
        simp [List.append_assoc, List.singleton_append]]
      apply ih (β.and χ) h_both (tracked ++ [χ]) ?_ ?_ ?_
      · -- extract for β ∧ χ
        intro M' h_mcs' h_βχ ψ' hψ'
        have h_lce := SetMaximalConsistent.implication_property h_mcs'
          (theorem_in_mcs h_mcs' (Bimodal.Theorems.Propositional.lce_imp β χ)) h_βχ
        have h_rce := SetMaximalConsistent.implication_property h_mcs'
          (theorem_in_mcs h_mcs' (Bimodal.Theorems.Propositional.rce_imp β χ)) h_βχ
        rcases List.mem_append.mp hψ' with h_tracked | h_new
        · exact h_extract M' h_mcs' h_lce ψ' h_tracked
        · rw [List.mem_singleton] at h_new; rw [h_new]; exact Or.inl h_rce
      · -- F-extract for β ∧ χ
        intro M' h_mcs' h_Fβχ ψ' hψ'
        have h_Fl := F_conj_left_mcs h_mcs' β χ h_Fβχ
        have h_Fr := F_conj_right_mcs h_mcs' β χ h_Fβχ
        rcases List.mem_append.mp hψ' with h_tracked | h_new
        · exact h_F_extract M' h_mcs' h_Fl ψ' h_tracked
        · rw [List.mem_singleton] at h_new; rw [h_new]; exact h_Fr
      · intro ψ' hψ'; exact h_F_others ψ' (List.mem_cons_of_mem _ hψ')
    · -- Case 2: F(β ∧ F(χ)) ∈ M. New compound: β ∧ F(χ).
      rw [show tracked ++ χ :: rest = (tracked ++ [χ]) ++ rest from by
        simp [List.append_assoc, List.singleton_append]]
      apply ih (β.and χ.some_future) h_β_first (tracked ++ [χ]) ?_ ?_ ?_
      · -- extract for β ∧ F(χ)
        intro M' h_mcs' h_βFχ ψ' hψ'
        have h_lce := SetMaximalConsistent.implication_property h_mcs'
          (theorem_in_mcs h_mcs' (Bimodal.Theorems.Propositional.lce_imp β χ.some_future)) h_βFχ
        have h_rce := SetMaximalConsistent.implication_property h_mcs'
          (theorem_in_mcs h_mcs' (Bimodal.Theorems.Propositional.rce_imp β χ.some_future)) h_βFχ
        rcases List.mem_append.mp hψ' with h_tracked | h_new
        · exact h_extract M' h_mcs' h_lce ψ' h_tracked
        · rw [List.mem_singleton] at h_new; rw [h_new]; exact Or.inr h_rce
      · -- F-extract for β ∧ F(χ)
        intro M' h_mcs' h_F ψ' hψ'
        have h_Fl := F_conj_left_mcs h_mcs' β χ.some_future h_F
        have h_Fr := FF_imp_F_mcs h_mcs' χ (F_conj_right_mcs h_mcs' β χ.some_future h_F)
        rcases List.mem_append.mp hψ' with h_tracked | h_new
        · exact h_F_extract M' h_mcs' h_Fl ψ' h_tracked
        · rw [List.mem_singleton] at h_new; rw [h_new]; exact h_Fr
      · intro ψ' hψ'; exact h_F_others ψ' (List.mem_cons_of_mem _ hψ')
    · -- Case 3: F(F(β) ∧ χ) ∈ M. New compound: F(β) ∧ χ.
      rw [show tracked ++ χ :: rest = (tracked ++ [χ]) ++ rest from by
        simp [List.append_assoc, List.singleton_append]]
      apply ih (β.some_future.and χ) h_χ_first (tracked ++ [χ]) ?_ ?_ ?_
      · -- extract for F(β) ∧ χ
        intro M' h_mcs' h_Fβχ ψ' hψ'
        have h_lce := SetMaximalConsistent.implication_property h_mcs'
          (theorem_in_mcs h_mcs' (Bimodal.Theorems.Propositional.lce_imp β.some_future χ)) h_Fβχ
        have h_rce := SetMaximalConsistent.implication_property h_mcs'
          (theorem_in_mcs h_mcs' (Bimodal.Theorems.Propositional.rce_imp β.some_future χ)) h_Fβχ
        rcases List.mem_append.mp hψ' with h_tracked | h_new
        · exact Or.inr (h_F_extract M' h_mcs' h_lce ψ' h_tracked)
        · rw [List.mem_singleton] at h_new; rw [h_new]; exact Or.inl h_rce
      · -- F-extract for F(β) ∧ χ
        intro M' h_mcs' h_F ψ' hψ'
        have h_Fl := FF_imp_F_mcs h_mcs' β (F_conj_left_mcs h_mcs' β.some_future χ h_F)
        have h_Fr := F_conj_right_mcs h_mcs' β.some_future χ h_F
        rcases List.mem_append.mp hψ' with h_tracked | h_new
        · exact h_F_extract M' h_mcs' h_Fl ψ' h_tracked
        · rw [List.mem_singleton] at h_new; rw [h_new]; exact h_Fr
      · intro ψ' hψ'; exact h_F_others ψ' (List.mem_cons_of_mem _ hψ')

/-- Strengthened fold: same as enriched_fwd_fold, but additionally returns a
"direct witness" — a formula from tracked ++ others that is GUARANTEED to be
directly in any MCS containing β' (not just disjunctively).

Key insight: in the fold, case 3 (F-wrapping) replaces the direct witness with χ
(the newly folded formula). Cases 1 and 2 preserve the existing witness.
After all fold steps, the final witness is the formula from the LAST case-3 step,
or the initial witness (target) if case 3 never fires. -/
private theorem enriched_fwd_fold_with_witness {M : Set Formula} (h_mcs : SetMaximalConsistent M)
    (β : Formula) (h_Fβ : Formula.some_future β ∈ M)
    (tracked : List Formula)
    (h_extract : ∀ M' : Set Formula, SetMaximalConsistent M' →
      β ∈ M' → ∀ χ, χ ∈ tracked → (χ ∈ M' ∨ Formula.some_future χ ∈ M'))
    (h_F_extract : ∀ M' : Set Formula, SetMaximalConsistent M' →
      Formula.some_future β ∈ M' → ∀ χ, χ ∈ tracked → Formula.some_future χ ∈ M')
    -- Direct witness: a formula guaranteed to be in M' when β ∈ M'
    (witness : Formula) (h_witness_mem : witness ∈ tracked)
    (h_witness_direct : ∀ M' : Set Formula, SetMaximalConsistent M' →
      β ∈ M' → witness ∈ M')
    -- New formulas to fold in
    (others : List Formula) (h_F_others : ∀ χ, χ ∈ others → Formula.some_future χ ∈ M) :
    ∃ β' : Formula, Formula.some_future β' ∈ M ∧
      (∀ M' : Set Formula, SetMaximalConsistent M' →
        β' ∈ M' → ∀ χ, χ ∈ tracked ++ others → (χ ∈ M' ∨ Formula.some_future χ ∈ M')) ∧
      (∀ M' : Set Formula, SetMaximalConsistent M' →
        Formula.some_future β' ∈ M' → ∀ χ, χ ∈ tracked ++ others → Formula.some_future χ ∈ M') ∧
      -- The strengthened property: a direct witness exists
      (∃ w, w ∈ tracked ++ others ∧
        ∀ M' : Set Formula, SetMaximalConsistent M' → β' ∈ M' → w ∈ M') := by
  induction others generalizing β tracked witness with
  | nil =>
    exact ⟨β, h_Fβ,
      fun M' h_mcs' h_β χ hχ => by rw [List.append_nil] at hχ; exact h_extract M' h_mcs' h_β χ hχ,
      fun M' h_mcs' h_Fβ' χ hχ => by rw [List.append_nil] at hχ; exact h_F_extract M' h_mcs' h_Fβ' χ hχ,
      ⟨witness, by rw [List.append_nil]; exact h_witness_mem, h_witness_direct⟩⟩
  | cons χ rest ih =>
    have h_Fχ : Formula.some_future χ ∈ M := h_F_others χ (by simp)
    rcases temp_linearity_mcs h_mcs β χ h_Fβ h_Fχ with
      h_both | h_β_first | h_χ_first
    · -- Case 1: F(β ∧ χ) ∈ M. Witness stays the same.
      rw [show tracked ++ χ :: rest = (tracked ++ [χ]) ++ rest from by
        simp [List.append_assoc, List.singleton_append]]
      apply ih (β.and χ) h_both (tracked ++ [χ]) ?_ ?_ witness
        (List.mem_append_left _ h_witness_mem) ?_ ?_
      · intro M' h_mcs' h_βχ ψ' hψ'
        have h_lce := SetMaximalConsistent.implication_property h_mcs'
          (theorem_in_mcs h_mcs' (Bimodal.Theorems.Propositional.lce_imp β χ)) h_βχ
        have h_rce := SetMaximalConsistent.implication_property h_mcs'
          (theorem_in_mcs h_mcs' (Bimodal.Theorems.Propositional.rce_imp β χ)) h_βχ
        rcases List.mem_append.mp hψ' with h_tracked | h_new
        · exact h_extract M' h_mcs' h_lce ψ' h_tracked
        · rw [List.mem_singleton] at h_new; rw [h_new]; exact Or.inl h_rce
      · intro M' h_mcs' h_Fβχ ψ' hψ'
        have h_Fl := F_conj_left_mcs h_mcs' β χ h_Fβχ
        have h_Fr := F_conj_right_mcs h_mcs' β χ h_Fβχ
        rcases List.mem_append.mp hψ' with h_tracked | h_new
        · exact h_F_extract M' h_mcs' h_Fl ψ' h_tracked
        · rw [List.mem_singleton] at h_new; rw [h_new]; exact h_Fr
      · -- witness is still direct: β ∧ χ ∈ M' → β ∈ M' → witness ∈ M'
        intro M' h_mcs' h_βχ
        have h_lce := SetMaximalConsistent.implication_property h_mcs'
          (theorem_in_mcs h_mcs' (Bimodal.Theorems.Propositional.lce_imp β χ)) h_βχ
        exact h_witness_direct M' h_mcs' h_lce
      · intro ψ' hψ'; exact h_F_others ψ' (List.mem_cons_of_mem _ hψ')
    · -- Case 2: F(β ∧ F(χ)) ∈ M. Witness stays the same.
      rw [show tracked ++ χ :: rest = (tracked ++ [χ]) ++ rest from by
        simp [List.append_assoc, List.singleton_append]]
      apply ih (β.and χ.some_future) h_β_first (tracked ++ [χ]) ?_ ?_ witness
        (List.mem_append_left _ h_witness_mem) ?_ ?_
      · intro M' h_mcs' h_βFχ ψ' hψ'
        have h_lce := SetMaximalConsistent.implication_property h_mcs'
          (theorem_in_mcs h_mcs' (Bimodal.Theorems.Propositional.lce_imp β χ.some_future)) h_βFχ
        have h_rce := SetMaximalConsistent.implication_property h_mcs'
          (theorem_in_mcs h_mcs' (Bimodal.Theorems.Propositional.rce_imp β χ.some_future)) h_βFχ
        rcases List.mem_append.mp hψ' with h_tracked | h_new
        · exact h_extract M' h_mcs' h_lce ψ' h_tracked
        · rw [List.mem_singleton] at h_new; rw [h_new]; exact Or.inr h_rce
      · intro M' h_mcs' h_F ψ' hψ'
        have h_Fl := F_conj_left_mcs h_mcs' β χ.some_future h_F
        have h_Fr := FF_imp_F_mcs h_mcs' χ (F_conj_right_mcs h_mcs' β χ.some_future h_F)
        rcases List.mem_append.mp hψ' with h_tracked | h_new
        · exact h_F_extract M' h_mcs' h_Fl ψ' h_tracked
        · rw [List.mem_singleton] at h_new; rw [h_new]; exact h_Fr
      · -- witness is still direct: β ∧ F(χ) ∈ M' → β ∈ M' → witness ∈ M'
        intro M' h_mcs' h_βFχ
        have h_lce := SetMaximalConsistent.implication_property h_mcs'
          (theorem_in_mcs h_mcs' (Bimodal.Theorems.Propositional.lce_imp β χ.some_future)) h_βFχ
        exact h_witness_direct M' h_mcs' h_lce
      · intro ψ' hψ'; exact h_F_others ψ' (List.mem_cons_of_mem _ hψ')
    · -- Case 3: F(F(β) ∧ χ) ∈ M. Witness CHANGES to χ.
      rw [show tracked ++ χ :: rest = (tracked ++ [χ]) ++ rest from by
        simp [List.append_assoc, List.singleton_append]]
      apply ih (β.some_future.and χ) h_χ_first (tracked ++ [χ]) ?_ ?_ χ
        (List.mem_append_right _ (List.mem_singleton.mpr rfl)) ?_ ?_
      · intro M' h_mcs' h_Fβχ ψ' hψ'
        have h_lce := SetMaximalConsistent.implication_property h_mcs'
          (theorem_in_mcs h_mcs' (Bimodal.Theorems.Propositional.lce_imp β.some_future χ)) h_Fβχ
        have h_rce := SetMaximalConsistent.implication_property h_mcs'
          (theorem_in_mcs h_mcs' (Bimodal.Theorems.Propositional.rce_imp β.some_future χ)) h_Fβχ
        rcases List.mem_append.mp hψ' with h_tracked | h_new
        · exact Or.inr (h_F_extract M' h_mcs' h_lce ψ' h_tracked)
        · rw [List.mem_singleton] at h_new; rw [h_new]; exact Or.inl h_rce
      · intro M' h_mcs' h_F ψ' hψ'
        have h_Fl := FF_imp_F_mcs h_mcs' β (F_conj_left_mcs h_mcs' β.some_future χ h_F)
        have h_Fr := F_conj_right_mcs h_mcs' β.some_future χ h_F
        rcases List.mem_append.mp hψ' with h_tracked | h_new
        · exact h_F_extract M' h_mcs' h_Fl ψ' h_tracked
        · rw [List.mem_singleton] at h_new; rw [h_new]; exact h_Fr
      · -- χ is the new direct witness: F(β) ∧ χ ∈ M' → χ ∈ M' (right conjunct)
        intro M' h_mcs' h_Fβχ
        exact SetMaximalConsistent.implication_property h_mcs'
          (theorem_in_mcs h_mcs' (Bimodal.Theorems.Propositional.rce_imp β.some_future χ)) h_Fβχ
      · intro ψ' hψ'; exact h_F_others ψ' (List.mem_cons_of_mem _ hψ')

/-- Strengthened version of enriched_fwd_exists: additionally guarantees that
at least one formula from sigma_list with F(χ) ∈ M is directly in M' (resolved).
This is the key property that enables the defect-count-decrease argument. -/
theorem resolving_enriched_fwd_exists {M : Set Formula} (h_mcs : SetMaximalConsistent M)
    (target : Formula) (h_F_target : Formula.some_future target ∈ M)
    (others : List Formula) (h_F_others : ∀ χ, χ ∈ others → Formula.some_future χ ∈ M) :
    ∃ M' : Set Formula, SetMaximalConsistent M' ∧
      g_content M ⊆ M' ∧
      (target ∈ M' ∨ Formula.some_future target ∈ M') ∧
      (∀ χ, χ ∈ others → (χ ∈ M' ∨ Formula.some_future χ ∈ M')) ∧
      -- Resolving property: some formula with F-obligation is directly resolved
      (∃ w, (w = target ∨ w ∈ others) ∧ Formula.some_future w ∈ M ∧ w ∈ M') := by
  obtain ⟨β', h_Fβ', h_extract', _, ⟨w, h_w_mem, h_w_direct⟩⟩ :=
    enriched_fwd_fold_with_witness h_mcs target h_F_target
      [target]
      (fun M' _ h_β χ hχ => by simp [List.mem_singleton] at hχ; subst hχ; exact Or.inl h_β)
      (fun M' h_mcs' h_Fβ χ hχ => by simp [List.mem_singleton] at hχ; subst hχ; exact h_Fβ)
      target (List.mem_singleton.mpr rfl) (fun M' _ h_β => h_β)
      others h_F_others
  have h_seed_cons := forward_temporal_witness_seed_consistent M h_mcs β' h_Fβ'
  obtain ⟨M', h_sup, h_mcs'⟩ := set_lindenbaum _ h_seed_cons
  have h_β'_in : β' ∈ M' := h_sup (Set.mem_union_left _ (Set.mem_singleton _))
  have h_g_sub : g_content M ⊆ M' := fun φ hφ => h_sup (Set.mem_union_right _ hφ)
  have h_w_in : w ∈ M' := h_w_direct M' h_mcs' h_β'_in
  -- Determine if w is target or in others
  have h_w_origin : w = target ∨ w ∈ others := by
    rcases List.mem_append.mp h_w_mem with h_t | h_o
    · simp [List.mem_singleton] at h_t; exact Or.inl h_t
    · exact Or.inr h_o
  -- w has F-obligation: w ∈ [target] ++ others means either w = target (F(target) ∈ M)
  -- or w ∈ others (F(w) ∈ M by h_F_others)
  have h_w_F : Formula.some_future w ∈ M := by
    rcases h_w_origin with rfl | h_in
    · exact h_F_target
    · exact h_F_others w h_in
  refine ⟨M', h_mcs', h_g_sub, ?_, ?_, ⟨w, h_w_origin, h_w_F, h_w_in⟩⟩
  · exact h_extract' M' h_mcs' h_β'_in target (by simp [List.mem_cons_self])
  · intro χ hχ; exact h_extract' M' h_mcs' h_β'_in χ (by simp [hχ])

theorem enriched_fwd_exists {M : Set Formula} (h_mcs : SetMaximalConsistent M)
    (target : Formula) (h_F_target : Formula.some_future target ∈ M)
    (others : List Formula) (h_F_others : ∀ χ, χ ∈ others → Formula.some_future χ ∈ M) :
    ∃ M' : Set Formula, SetMaximalConsistent M' ∧
      g_content M ⊆ M' ∧
      (target ∈ M' ∨ Formula.some_future target ∈ M') ∧
      ∀ χ, χ ∈ others → (χ ∈ M' ∨ Formula.some_future χ ∈ M') := by
  -- Use the fold to get compound β' with F(β') ∈ M and extraction properties
  obtain ⟨β', h_Fβ', h_extract', _⟩ := enriched_fwd_fold h_mcs target h_F_target
    [target]
    (fun M' _ h_β χ hχ => by simp [List.mem_singleton] at hχ; subst hχ; exact Or.inl h_β)
    (fun M' h_mcs' h_Fβ χ hχ => by simp [List.mem_singleton] at hχ; subst hχ; exact h_Fβ)
    others h_F_others
  -- Lindenbaum extend {β'} ∪ g_content(M)
  have h_seed_cons := forward_temporal_witness_seed_consistent M h_mcs β' h_Fβ'
  obtain ⟨M', h_sup, h_mcs'⟩ := set_lindenbaum _ h_seed_cons
  have h_β'_in : β' ∈ M' := h_sup (Set.mem_union_left _ (Set.mem_singleton _))
  have h_g_sub : g_content M ⊆ M' := fun φ hφ => h_sup (Set.mem_union_right _ hφ)
  refine ⟨M', h_mcs', h_g_sub, ?_, ?_⟩
  · -- target ∈ M' ∨ F(target) ∈ M'
    have := h_extract' M' h_mcs' h_β'_in target (by simp [List.mem_cons_self])
    exact this
  · -- ∀ χ ∈ others, χ ∈ M' ∨ F(χ) ∈ M'
    intro χ hχ
    exact h_extract' M' h_mcs' h_β'_in χ (by simp [hχ])

/-! ## Modal Fix

The set of modal formulas from M₀: both □φ ∈ M₀ and ¬□φ ∈ M₀ formulas.
Including this in every seed ensures box stability. -/

def modal_fix (M₀ : Set Formula) : Set Formula :=
  { φ | (∃ ψ, φ = Formula.box ψ ∧ Formula.box ψ ∈ M₀) ∨
        (∃ ψ, φ = (Formula.box ψ).neg ∧ Formula.box ψ ∉ M₀) }

theorem modal_fix_subset_mcs {M₀ : Set Formula} (h₀ : SetMaximalConsistent M₀) :
    modal_fix M₀ ⊆ M₀ := by
  intro φ hφ
  rcases hφ with ⟨ψ, rfl, h_box⟩ | ⟨ψ, rfl, h_not_box⟩
  · exact h_box
  · rcases SetMaximalConsistent.negation_complete h₀ (Formula.box ψ) with h | h
    · exact absurd h h_not_box
    · exact h

/-! ## Round-Robin Infrastructure (archived)

The round-robin chain approach (`rr_fwd_seed`, `rr_fwd_chain`, `enriched_fwd_step`, etc.)
has been archived to `Boneyard/RoundRobinChain.lean`. It is confirmed dead after 40 rounds
of research: the depth-0 base case of `forward_F` is blocked by the BX11 perpetual
deferral obstruction and cannot be proved with this construction.

`dd_chain` below is retained as it serves as the MCS-chain skeleton used by `dd_fmcs`
and `dd_bfmcs`. The forward/backward chain sub-definitions (`fwd_chain_of_sigma`,
`bwd_chain_of_sigma`) provide the same structure as the archived `rr_fwd_chain`/`rr_bwd_chain`
without exposing the dead round-robin identifiers.
-/

/-- Forward chain: iterate fwd_succ. (Replaces the archived rr_fwd_chain.) -/
private noncomputable def fwd_chain_of_sigma (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (sigma_list : List Formula) : (n : Nat) → { M : Set Formula // SetMaximalConsistent M }
  | 0 => ⟨M₀, h₀⟩
  | n + 1 =>
    let ⟨M, hM⟩ := fwd_chain_of_sigma M₀ h₀ sigma_list n
    let target := if h : sigma_list.length > 0
      then sigma_list.get ⟨n % sigma_list.length, Nat.mod_lt n h⟩
      else Formula.bot
    ⟨fwd_succ M hM target, fwd_succ_mcs M hM target⟩

/-- Backward chain: iterate bwd_pred. (Replaces the archived rr_bwd_chain.) -/
private noncomputable def bwd_chain_of_sigma (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (sigma_list : List Formula) : (n : Nat) → { M : Set Formula // SetMaximalConsistent M }
  | 0 => ⟨M₀, h₀⟩
  | n + 1 =>
    let ⟨M, hM⟩ := bwd_chain_of_sigma M₀ h₀ sigma_list n
    let target := if h : sigma_list.length > 0
      then sigma_list.get ⟨n % sigma_list.length, Nat.mod_lt n h⟩
      else Formula.bot
    ⟨bwd_pred M hM target, bwd_pred_mcs M hM target⟩

/-- Int-indexed chain assembly. -/
noncomputable def dd_chain (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (sigma_list : List Formula) (t : Int) : Set Formula :=
  if t ≥ 0 then (fwd_chain_of_sigma M₀ h₀ sigma_list t.toNat).val
  else (bwd_chain_of_sigma M₀ h₀ sigma_list ((-t).toNat)).val

theorem dd_chain_zero (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (sigma_list : List Formula) : dd_chain M₀ h₀ sigma_list 0 = M₀ := by
  simp [dd_chain, fwd_chain_of_sigma]

theorem dd_chain_mcs (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (sigma_list : List Formula) (t : Int) :
    SetMaximalConsistent (dd_chain M₀ h₀ sigma_list t) := by
  simp only [dd_chain]; split
  · exact (fwd_chain_of_sigma M₀ h₀ sigma_list t.toNat).property
  · exact (bwd_chain_of_sigma M₀ h₀ sigma_list ((-t).toNat)).property

/-! ## g_content propagation

The forward chain has g_content(chain(n)) ⊆ chain(n+1) at each step
(from fwd_succ_g_content). The backward chain has h_content(chain(n)) ⊆ chain(n+1)
(from bwd_pred_h_content). These are the SAME as in the existing int_chain.
-/

-- Forward chain g_content propagation step
private theorem sigma_fwd_g_content_step (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (sigma_list : List Formula) (n : Nat) :
    g_content (fwd_chain_of_sigma M₀ h₀ sigma_list n).val ⊆
      (fwd_chain_of_sigma M₀ h₀ sigma_list (n + 1)).val := by
  show g_content (fwd_chain_of_sigma M₀ h₀ sigma_list n).val ⊆
    fwd_succ (fwd_chain_of_sigma M₀ h₀ sigma_list n).val
      (fwd_chain_of_sigma M₀ h₀ sigma_list n).property _
  exact fwd_succ_g_content _ _ _

-- Transitive g_content propagation for fwd_chain_of_sigma
private theorem sigma_fwd_g_content_trans (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (sigma_list : List Formula) {m n : Nat} (h : m ≤ n) :
    g_content (fwd_chain_of_sigma M₀ h₀ sigma_list m).val ⊆
      (fwd_chain_of_sigma M₀ h₀ sigma_list n).val := by
  induction n with
  | zero =>
    have : m = 0 := Nat.eq_zero_of_le_zero h; subst this
    intro φ hφ; exact SetMaximalConsistent.implication_property
      (fwd_chain_of_sigma M₀ h₀ sigma_list 0).property
      (theorem_in_mcs (fwd_chain_of_sigma M₀ h₀ sigma_list 0).property
        (DerivationTree.axiom [] _ (Axiom.temp_t_future φ))) hφ
  | succ n ih =>
    rcases Nat.eq_or_lt_of_le h with rfl | h_lt
    · exact fun φ hφ => SetMaximalConsistent.implication_property
        (fwd_chain_of_sigma M₀ h₀ sigma_list (n + 1)).property
        (theorem_in_mcs (fwd_chain_of_sigma M₀ h₀ sigma_list (n + 1)).property
          (DerivationTree.axiom [] _ (Axiom.temp_t_future φ))) hφ
    · intro φ hφ
      have h_GG := SetMaximalConsistent.all_future_all_future
        (fwd_chain_of_sigma M₀ h₀ sigma_list m).property hφ
      exact sigma_fwd_g_content_step M₀ h₀ sigma_list n
        (ih (Nat.lt_succ_iff.mp h_lt) h_GG)

-- Backward chain h_content propagation step
private theorem sigma_bwd_h_content_step (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (sigma_list : List Formula) (n : Nat) :
    h_content (bwd_chain_of_sigma M₀ h₀ sigma_list n).val ⊆
      (bwd_chain_of_sigma M₀ h₀ sigma_list (n + 1)).val := by
  show h_content (bwd_chain_of_sigma M₀ h₀ sigma_list n).val ⊆
    bwd_pred (bwd_chain_of_sigma M₀ h₀ sigma_list n).val
      (bwd_chain_of_sigma M₀ h₀ sigma_list n).property _
  exact bwd_pred_h_content _ _ _

private theorem sigma_bwd_h_content_trans (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (sigma_list : List Formula) {m n : Nat} (h : m ≤ n) :
    h_content (bwd_chain_of_sigma M₀ h₀ sigma_list m).val ⊆
      (bwd_chain_of_sigma M₀ h₀ sigma_list n).val := by
  induction n with
  | zero =>
    have : m = 0 := Nat.eq_zero_of_le_zero h; subst this
    intro φ hφ; exact SetMaximalConsistent.implication_property
      (bwd_chain_of_sigma M₀ h₀ sigma_list 0).property
      (theorem_in_mcs (bwd_chain_of_sigma M₀ h₀ sigma_list 0).property
        (DerivationTree.axiom [] _ (Axiom.temp_t_past φ))) hφ
  | succ n ih =>
    rcases Nat.eq_or_lt_of_le h with rfl | h_lt
    · exact fun φ hφ => SetMaximalConsistent.implication_property
        (bwd_chain_of_sigma M₀ h₀ sigma_list (n + 1)).property
        (theorem_in_mcs (bwd_chain_of_sigma M₀ h₀ sigma_list (n + 1)).property
          (DerivationTree.axiom [] _ (Axiom.temp_t_past φ))) hφ
    · intro φ hφ
      have h_HH := SetMaximalConsistent.all_past_all_past
        (bwd_chain_of_sigma M₀ h₀ sigma_list m).property hφ
      exact sigma_bwd_h_content_step M₀ h₀ sigma_list n
        (ih (Nat.lt_succ_iff.mp h_lt) h_HH)

-- Full Int-indexed g_content propagation
theorem dd_chain_g_content (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (sigma_list : List Formula) {t t' : Int} (h_le : t ≤ t') :
    g_content (dd_chain M₀ h₀ sigma_list t) ⊆ dd_chain M₀ h₀ sigma_list t' := by
  simp only [dd_chain]
  split_ifs with ht ht'
  · exact sigma_fwd_g_content_trans M₀ h₀ sigma_list (Int.toNat_le_toNat h_le)
  · omega
  · intro χ hχ
    have h_G_in_bwd := hχ
    have h_GG := SetMaximalConsistent.all_future_all_future
      (bwd_chain_of_sigma M₀ h₀ sigma_list ((-t).toNat)).property h_G_in_bwd
    have h_G_in_M0 : Formula.all_future χ ∈ M₀ := by
      have : g_content (bwd_chain_of_sigma M₀ h₀ sigma_list ((-t).toNat)).val ⊆
          (bwd_chain_of_sigma M₀ h₀ sigma_list 0).val :=
        h_content_subset_implies_g_content_reverse
          (bwd_chain_of_sigma M₀ h₀ sigma_list 0).val
          (bwd_chain_of_sigma M₀ h₀ sigma_list ((-t).toNat)).val
          (bwd_chain_of_sigma M₀ h₀ sigma_list 0).property
          (bwd_chain_of_sigma M₀ h₀ sigma_list ((-t).toNat)).property
          (sigma_bwd_h_content_trans M₀ h₀ sigma_list (Nat.zero_le _))
      simp [bwd_chain_of_sigma] at this
      exact this h_GG
    exact sigma_fwd_g_content_trans M₀ h₀ sigma_list (Nat.zero_le _) h_G_in_M0
  · exact (h_content_subset_implies_g_content_reverse
      (bwd_chain_of_sigma M₀ h₀ sigma_list ((-t').toNat)).val
      (bwd_chain_of_sigma M₀ h₀ sigma_list ((-t).toNat)).val
      (bwd_chain_of_sigma M₀ h₀ sigma_list ((-t').toNat)).property
      (bwd_chain_of_sigma M₀ h₀ sigma_list ((-t).toNat)).property
      (sigma_bwd_h_content_trans M₀ h₀ sigma_list (by omega)))

/-! ## Box stability (same as box_stable_in_int_chain) -/

private theorem dd_chain_forward_G_helper (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (sigma_list : List Formula) (t t' : Int) (φ : Formula) (h_le : t ≤ t')
    (h_G : Formula.all_future φ ∈ dd_chain M₀ h₀ sigma_list t) :
    φ ∈ dd_chain M₀ h₀ sigma_list t' :=
  dd_chain_g_content M₀ h₀ sigma_list h_le h_G

private theorem dd_chain_backward_H_helper (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (sigma_list : List Formula) (t t' : Int) (φ : Formula) (h_le : t' ≤ t)
    (h_H : Formula.all_past φ ∈ dd_chain M₀ h₀ sigma_list t) :
    φ ∈ dd_chain M₀ h₀ sigma_list t' :=
  g_content_subset_implies_h_content_reverse
    (dd_chain M₀ h₀ sigma_list t') (dd_chain M₀ h₀ sigma_list t)
    (dd_chain_mcs M₀ h₀ sigma_list t') (dd_chain_mcs M₀ h₀ sigma_list t)
    (dd_chain_g_content M₀ h₀ sigma_list h_le) h_H

theorem box_stable_dd_chain (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (sigma_list : List Formula) (φ : Formula) (t : Int) :
    Formula.box φ ∈ dd_chain M₀ h₀ sigma_list t ↔ Formula.box φ ∈ M₀ := by
  constructor
  · -- Backward: Box φ ∈ chain(t) → Box φ ∈ M₀ (contrapositive)
    intro h_box_t
    by_contra h_not_box_M0
    have h_neg_box_M0 : (Formula.box φ).neg ∈ M₀ := by
      rcases SetMaximalConsistent.negation_complete h₀ (Formula.box φ) with h | h
      · exact absurd h h_not_box_M0
      · exact h
    have h_box_neg : Formula.box (Formula.box φ).neg ∈ M₀ :=
      SetMaximalConsistent.implication_property h₀
        (theorem_in_mcs h₀ (neg_box_to_box_neg_box φ)) h_neg_box_M0
    have h_box_neg_t : Formula.box (Formula.box φ).neg ∈ dd_chain M₀ h₀ sigma_list t := by
      rcases le_or_gt 0 t with h_pos | h_neg
      · have h_G := SetMaximalConsistent.implication_property h₀
          (theorem_in_mcs h₀ (DerivationTree.axiom [] _ (Axiom.temp_future (Formula.box φ).neg)))
          h_box_neg
        exact dd_chain_forward_G_helper M₀ h₀ sigma_list 0 t _ h_pos h_G
      · have h_box_box_neg : Formula.box (Formula.box (Formula.box φ).neg) ∈ M₀ :=
          SetMaximalConsistent.implication_property h₀
            (theorem_in_mcs h₀ (DerivationTree.axiom [] _ (Axiom.modal_4 (Formula.box φ).neg)))
            h_box_neg
        have h_H := SetMaximalConsistent.implication_property h₀
          (theorem_in_mcs h₀ (box_to_past (Formula.box (Formula.box φ).neg))) h_box_box_neg
        exact dd_chain_backward_H_helper M₀ h₀ sigma_list 0 t _ (Int.le_of_lt h_neg) h_H
    have h_neg_box_t : (Formula.box φ).neg ∈ dd_chain M₀ h₀ sigma_list t :=
      SetMaximalConsistent.implication_property (dd_chain_mcs M₀ h₀ sigma_list t)
        (theorem_in_mcs (dd_chain_mcs M₀ h₀ sigma_list t)
          (DerivationTree.axiom [] _ (Axiom.modal_t (Formula.box φ).neg)))
        h_box_neg_t
    exact set_consistent_not_both (dd_chain_mcs M₀ h₀ sigma_list t).1
      (Formula.box φ) h_box_t h_neg_box_t
  · -- Forward: Box φ ∈ M₀ → Box φ ∈ chain(t)
    intro h_box_M0
    rcases le_or_gt 0 t with h_pos | h_neg
    · have h_G := SetMaximalConsistent.implication_property h₀
        (theorem_in_mcs h₀ (DerivationTree.axiom [] _ (Axiom.temp_future φ))) h_box_M0
      exact dd_chain_forward_G_helper M₀ h₀ sigma_list 0 t _ h_pos h_G
    · have h_box_box : Formula.box (Formula.box φ) ∈ M₀ :=
        SetMaximalConsistent.implication_property h₀
          (theorem_in_mcs h₀ (DerivationTree.axiom [] _ (Axiom.modal_4 φ))) h_box_M0
      have h_H := SetMaximalConsistent.implication_property h₀
        (theorem_in_mcs h₀ (box_to_past (Formula.box φ))) h_box_box
      exact dd_chain_backward_H_helper M₀ h₀ sigma_list 0 t _ (Int.le_of_lt h_neg) h_H

/-! ## FMCS from dd_chain -/

noncomputable def dd_fmcs (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (sigma_list : List Formula) : FMCS Int where
  mcs := dd_chain M₀ h₀ sigma_list
  is_mcs := dd_chain_mcs M₀ h₀ sigma_list
  forward_G t t' φ h_le h_G := dd_chain_g_content M₀ h₀ sigma_list h_le h_G
  backward_H t t' φ h_le h_H :=
    g_content_subset_implies_h_content_reverse
      (dd_chain M₀ h₀ sigma_list t') (dd_chain M₀ h₀ sigma_list t)
      (dd_chain_mcs M₀ h₀ sigma_list t') (dd_chain_mcs M₀ h₀ sigma_list t)
      (dd_chain_g_content M₀ h₀ sigma_list h_le) h_H

/-- Shifted dd_fmcs. -/
noncomputable def shifted_dd_fmcs (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (sigma_list : List Formula) (s : Int) : FMCS Int where
  mcs t := dd_chain M₀ h₀ sigma_list (t - s)
  is_mcs t := dd_chain_mcs M₀ h₀ sigma_list (t - s)
  forward_G t t' φ h_le h_G :=
    dd_chain_g_content M₀ h₀ sigma_list (by omega : t - s ≤ t' - s) h_G
  backward_H t t' φ h_le h_H :=
    g_content_subset_implies_h_content_reverse
      (dd_chain M₀ h₀ sigma_list (t' - s)) (dd_chain M₀ h₀ sigma_list (t - s))
      (dd_chain_mcs M₀ h₀ sigma_list (t' - s)) (dd_chain_mcs M₀ h₀ sigma_list (t - s))
      (dd_chain_g_content M₀ h₀ sigma_list (by omega : t' - s ≤ t - s)) h_H

theorem shifted_dd_fmcs_at_s (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (sigma_list : List Formula) (s : Int) :
    (shifted_dd_fmcs M₀ h₀ sigma_list s).mcs s = M₀ := by
  show dd_chain M₀ h₀ sigma_list (s - s) = M₀
  simp [dd_chain, fwd_chain_of_sigma]

/-! ## Ordered Defect-Discharge Infrastructure

Infrastructure for the ordered defect-discharge approach to forward_F.
Key idea: among F-defects in an MCS, BX11 linearity induces a total preorder.
For the "earliest" defect ψ, BX11 gives F(ψ ∧ ...) (cases 1 or 2, not case 3),
guaranteeing ψ is directly in the successor MCS via enriched_resolving_seed_consistent.

## Definitions

- `conj_comm_imp`: conjunction commutativity ⊢ (A ∧ B) → (B ∧ A)
- `F_conj_comm_mcs`: F-commutativity at MCS level
- `bx11_earlier`: BX11 ordering on formulas in an MCS
- `bx11_earlier_total`: totality of BX11 ordering on F-defects
- `discharge_fwd_step`: one step resolving a single target using enriched seed
- `discharge_fwd_chain`: iterated discharge for sigma_list.length steps
-/

/-- Conjunction commutativity: ⊢ (A ∧ B) → (B ∧ A). -/
noncomputable def conj_comm_imp (A B : Formula) : ⊢ (A.and B).imp (B.and A) :=
  Bimodal.Theorems.Combinators.combine_imp_conj
    (Bimodal.Theorems.Propositional.rce_imp A B)
    (Bimodal.Theorems.Propositional.lce_imp A B)

/-- F(A ∧ B) ∈ M → F(B ∧ A) ∈ M for any MCS M, by F-monotonicity of conjunction
commutativity. -/
theorem F_conj_comm_mcs {M : Set Formula} (h_mcs : SetMaximalConsistent M)
    (A B : Formula) (h : (A.and B).some_future ∈ M) :
    (B.and A).some_future ∈ M :=
  SetMaximalConsistent.implication_property h_mcs
    (theorem_in_mcs h_mcs (F_mono (conj_comm_imp A B))) h

/-- BX11 ordering: ψ₁ is "at least as early as" ψ₂ when BX11 gives case 1 or 2,
i.e., F(ψ₁ ∧ ψ₂) ∈ M ∨ F(ψ₁ ∧ F(ψ₂)) ∈ M. When this holds, the enriched
resolving seed {ψ₁, ...} ∪ g_content(M) guarantees ψ₁ ∈ M'. -/
def bx11_earlier (M : Set Formula) (ψ₁ ψ₂ : Formula) : Prop :=
  Formula.some_future (Formula.and ψ₁ ψ₂) ∈ M ∨
  Formula.some_future (Formula.and ψ₁ (Formula.some_future ψ₂)) ∈ M

/-- BX11 ordering is total on F-defects: for any ψ₁, ψ₂ with F(ψ₁), F(ψ₂) ∈ M,
either ψ₁ is at least as early as ψ₂ or vice versa. -/
theorem bx11_earlier_total {M : Set Formula} (h_mcs : SetMaximalConsistent M)
    (ψ₁ ψ₂ : Formula) (h₁ : Formula.some_future ψ₁ ∈ M) (h₂ : Formula.some_future ψ₂ ∈ M) :
    bx11_earlier M ψ₁ ψ₂ ∨ bx11_earlier M ψ₂ ψ₁ := by
  rcases temp_linearity_mcs h_mcs ψ₁ ψ₂ h₁ h₂ with h | h | h
  · -- Case 1: F(ψ₁ ∧ ψ₂) ∈ M
    exact Or.inl (Or.inl h)
  · -- Case 2: F(ψ₁ ∧ F(ψ₂)) ∈ M
    exact Or.inl (Or.inr h)
  · -- Case 3: F(F(ψ₁) ∧ ψ₂) ∈ M. By conjunction commutativity under F:
    -- F(F(ψ₁) ∧ ψ₂) → F(ψ₂ ∧ F(ψ₁)), so ψ₂ is earlier than ψ₁.
    right; right
    exact F_conj_comm_mcs h_mcs (Formula.some_future ψ₁) ψ₂ h

/-- When ψ₁ is bx11_earlier than ψ₂ in MCS M, we can extract a compound formula
F(ψ₁ ∧ α) ∈ M (for some α) such that enriched_resolving_seed_consistent gives
{ψ₁, α} ∪ g_content(M) consistent, guaranteeing ψ₁ ∈ M' in the Lindenbaum extension. -/
theorem bx11_earlier_resolving_seed {M : Set Formula} (h_mcs : SetMaximalConsistent M)
    (ψ₁ ψ₂ : Formula) (h_earlier : bx11_earlier M ψ₁ ψ₂) :
    ∃ α : Formula, Formula.some_future (Formula.and ψ₁ α) ∈ M ∧
      (∀ M' : Set Formula, SetMaximalConsistent M' → α ∈ M' →
        ψ₂ ∈ M' ∨ Formula.some_future ψ₂ ∈ M') := by
  rcases h_earlier with h_both | h_first
  · -- F(ψ₁ ∧ ψ₂) ∈ M: α = ψ₂. From α ∈ M': ψ₂ ∈ M' directly.
    exact ⟨ψ₂, h_both, fun M' _ h_α => Or.inl h_α⟩
  · -- F(ψ₁ ∧ F(ψ₂)) ∈ M: α = F(ψ₂). From α ∈ M': F(ψ₂) ∈ M'.
    exact ⟨Formula.some_future ψ₂, h_first, fun M' _ h_α => Or.inr h_α⟩

/-- Strengthened bx11_earlier_resolving_seed: also gives F-extraction. -/
theorem bx11_earlier_resolving_seed_strong {M : Set Formula} (h_mcs : SetMaximalConsistent M)
    (ψ₁ ψ₂ : Formula) (h_earlier : bx11_earlier M ψ₁ ψ₂) :
    ∃ α : Formula, Formula.some_future (Formula.and ψ₁ α) ∈ M ∧
      (∀ M' : Set Formula, SetMaximalConsistent M' → α ∈ M' →
        ψ₂ ∈ M' ∨ Formula.some_future ψ₂ ∈ M') ∧
      (∀ M' : Set Formula, SetMaximalConsistent M' →
        Formula.some_future α ∈ M' → Formula.some_future ψ₂ ∈ M') := by
  rcases h_earlier with h_both | h_first
  · exact ⟨ψ₂, h_both, fun M' _ h_α => Or.inl h_α, fun M' _ h_Fα => h_Fα⟩
  · exact ⟨Formula.some_future ψ₂, h_first, fun M' _ h_α => Or.inr h_α,
      fun M' h_mcs' h_FFψ₂ => FF_imp_F_mcs h_mcs' ψ₂ h_FFψ₂⟩

/-- Single-target discharge step: given F(ψ) ∈ M for MCS M, there exists M' with
ψ ∈ M' and g_content(M) ⊆ M'. This is the base case for discharge when
there is exactly one defect. -/
theorem discharge_single_step (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (ψ : Formula) (h_F : Formula.some_future ψ ∈ M) :
    ∃ M' : Set Formula, SetMaximalConsistent M' ∧ ψ ∈ M' ∧ g_content M ⊆ M' := by
  have h_cons := forward_temporal_witness_seed_consistent M h_mcs ψ h_F
  obtain ⟨M', h_sup, h_mcs'⟩ := set_lindenbaum _ h_cons
  have h_ψ : ψ ∈ M' := h_sup (Set.mem_union_left _ (Set.mem_singleton _))
  have h_g : g_content M ⊆ M' := fun φ hφ => h_sup (Set.mem_union_right _ hφ)
  exact ⟨M', h_mcs', h_ψ, h_g⟩

/-- Two-target discharge step: given F(ψ₁) ∈ M and F(ψ₂) ∈ M for MCS M,
and ψ₁ bx11_earlier than ψ₂, there exists M' with:
- ψ₁ ∈ M' (guaranteed, from enriched_resolving_seed_consistent)
- ψ₂ ∈ M' ∨ F(ψ₂) ∈ M' (disjunctive, from BX11 compound extraction)
- g_content(M) ⊆ M' -/
theorem discharge_two_step (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (ψ₁ ψ₂ : Formula)
    (h_F1 : Formula.some_future ψ₁ ∈ M)
    (h_earlier : bx11_earlier M ψ₁ ψ₂) :
    ∃ M' : Set Formula, SetMaximalConsistent M' ∧ ψ₁ ∈ M' ∧
      (ψ₂ ∈ M' ∨ Formula.some_future ψ₂ ∈ M') ∧ g_content M ⊆ M' := by
  obtain ⟨α, h_Fψα, h_extract⟩ := bx11_earlier_resolving_seed h_mcs ψ₁ ψ₂ h_earlier
  have h_cons := enriched_resolving_seed_consistent h_mcs ψ₁ α h_Fψα
  obtain ⟨M', h_sup, h_mcs'⟩ := set_lindenbaum _ h_cons
  have h_ψ₁ : ψ₁ ∈ M' := by
    apply h_sup
    show ψ₁ ∈ ({ψ₁, α} : Set Formula) ∪ g_content M
    exact Set.mem_union_left _ (Set.mem_insert _ _)
  have h_α : α ∈ M' := by
    apply h_sup
    show α ∈ ({ψ₁, α} : Set Formula) ∪ g_content M
    exact Set.mem_union_left _ (Set.mem_insert_of_mem _ rfl)
  have h_g : g_content M ⊆ M' := fun φ hφ => h_sup (Set.mem_union_right _ hφ)
  exact ⟨M', h_mcs', h_ψ₁, h_extract M' h_mcs' h_α, h_g⟩

/-- Multi-target discharge step via the BX11 fold: given F(target) ∈ M and
F(χ) ∈ M for each χ in others, there exists M' with g_content(M) ⊆ M'
and each formula (target and all others) is either directly in M' or
F-protected in M'.

This is a direct wrapper around enriched_fwd_exists. The disjunctive result
(target ∈ M' ∨ F(target) ∈ M') is inherent to the BX11 fold.
When Phase 2 proves forward_F, it uses the BX11 ordering to show that
the target is eventually resolved directly (not just F-protected). -/
theorem discharge_multi_step (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (target : Formula) (h_F_target : Formula.some_future target ∈ M)
    (others : List Formula) (h_F_others : ∀ χ, χ ∈ others → Formula.some_future χ ∈ M) :
    ∃ M' : Set Formula, SetMaximalConsistent M' ∧
      g_content M ⊆ M' ∧
      (target ∈ M' ∨ Formula.some_future target ∈ M') ∧
      (∀ χ, χ ∈ others → (χ ∈ M' ∨ Formula.some_future χ ∈ M')) :=
  enriched_fwd_exists h_mcs target h_F_target others h_F_others

/-- When target is bx11_earlier than every formula in others, there exists
M' extending g_content(M) with target ∈ M' (guaranteed, not disjunctive). -/
theorem target_stays_direct_in_fold {M : Set Formula} (h_mcs : SetMaximalConsistent M)
    (target : Formula) (h_F_target : Formula.some_future target ∈ M)
    (others : List Formula) (h_F_others : ∀ χ, χ ∈ others → Formula.some_future χ ∈ M)
    (h_earliest : ∀ χ, χ ∈ others → bx11_earlier M target χ) :
    ∃ M' : Set Formula, SetMaximalConsistent M' ∧
      g_content M ⊆ M' ∧ target ∈ M' ∧
      (∀ χ, χ ∈ others → (χ ∈ M' ∨ Formula.some_future χ ∈ M')) := by
  have h_data : ∀ χ, χ ∈ others → ∃ α : Formula,
      Formula.some_future (target.and α) ∈ M ∧
      (∀ M' : Set Formula, SetMaximalConsistent M' → α ∈ M' →
        χ ∈ M' ∨ Formula.some_future χ ∈ M') ∧
      (∀ M' : Set Formula, SetMaximalConsistent M' →
        Formula.some_future α ∈ M' → Formula.some_future χ ∈ M') :=
    fun χ hχ => bx11_earlier_resolving_seed_strong h_mcs target χ (h_earliest χ hχ)
  let compounds := others.pmap (fun χ (hχ : χ ∈ others) =>
    target.and (h_data χ hχ).choose) (fun _ h => h)
  have h_F_compounds : ∀ c, c ∈ compounds → Formula.some_future c ∈ M := by
    intro c hc; simp only [compounds, List.mem_pmap] at hc
    obtain ⟨χ, hχ, rfl⟩ := hc; exact (h_data χ hχ).choose_spec.1
  obtain ⟨M', h_mcs', h_g, _, h_c_disj, w, h_w_origin, _, h_w_in⟩ :=
    resolving_enriched_fwd_exists h_mcs target h_F_target compounds h_F_compounds
  have h_target_in : target ∈ M' := by
    rcases h_w_origin with rfl | h_w_comp
    · exact h_w_in
    · simp only [compounds, List.mem_pmap] at h_w_comp
      obtain ⟨χ, hχ, rfl⟩ := h_w_comp
      exact SetMaximalConsistent.implication_property h_mcs'
        (theorem_in_mcs h_mcs' (Bimodal.Theorems.Propositional.lce_imp target _)) h_w_in
  refine ⟨M', h_mcs', h_g, h_target_in, fun χ hχ => ?_⟩
  have h_comp_mem : target.and (h_data χ hχ).choose ∈ compounds :=
    List.mem_pmap.mpr ⟨χ, hχ, rfl⟩
  rcases h_c_disj _ h_comp_mem with h_direct | h_F_wrap
  · exact (h_data χ hχ).choose_spec.2.1 M' h_mcs'
      (SetMaximalConsistent.implication_property h_mcs'
        (theorem_in_mcs h_mcs' (Bimodal.Theorems.Propositional.rce_imp target _)) h_direct)
  · exact Or.inr ((h_data χ hχ).choose_spec.2.2 M' h_mcs'
      (F_conj_right_mcs h_mcs' target _ h_F_wrap))

/-! ## φ → F(φ) -/

/-- φ → F(φ) is derivable in BX.
Proof: temp_t gives G(¬φ) → ¬φ. Contrapositive: ¬¬φ → ¬G(¬φ).
Since F(φ) = ¬G(¬φ) and ¬¬φ follows from φ by DNI, we get φ → F(φ). -/
noncomputable def phi_imp_F_phi (φ : Formula) :
    ⊢ φ.imp φ.some_future := by
  unfold Formula.some_future
  exact Bimodal.Theorems.Combinators.imp_trans (dni φ)
    (Bimodal.Theorems.Propositional.contraposition
      (DerivationTree.axiom [] _ (Axiom.temp_t_future (Formula.neg φ))))

/-- At MCS level: φ ∈ M → F(φ) ∈ M. -/
theorem phi_in_mcs_imp_F_phi {M : Set Formula} (h_mcs : SetMaximalConsistent M)
    (φ : Formula) (h : φ ∈ M) : φ.some_future ∈ M :=
  SetMaximalConsistent.implication_property h_mcs
    (theorem_in_mcs h_mcs (phi_imp_F_phi φ)) h

/-! ## Extended Defect Seed Consistency

The key mathematical lemma: when the target is bx11_earlier than all other
F-defects, we can construct M' with target ∈ M' AND F(chi) ∈ M' for all
other F-defects chi, AND g_content(M) ⊆ M'. This enables a chain step
that both resolves the target AND preserves all F-obligations. -/

/-! ## BFMCS and Countermodel -/

noncomputable def dd_bfmcs (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (sigma_list : List Formula) : BFMCS Int where
  families := { fam | ∃ (N : Set Formula) (h_N : SetMaximalConsistent N) (s : Int),
    (∀ φ, Formula.box φ ∈ M₀ ↔ Formula.box φ ∈ N) ∧
    fam = shifted_dd_fmcs N h_N sigma_list s }
  nonempty := ⟨shifted_dd_fmcs M₀ h₀ sigma_list 0, M₀, h₀, 0, fun _ => Iff.rfl, rfl⟩
  modal_forward := by
    intro fam hfam φ t h_box fam' hfam'
    obtain ⟨N, h_N, s, h_eqN, rfl⟩ := hfam
    obtain ⟨N', h_N', s', h_eqN', rfl⟩ := hfam'
    have h_box_M0 : Formula.box φ ∈ M₀ :=
      (h_eqN φ).mpr ((box_stable_dd_chain N h_N sigma_list φ (t - s)).mp h_box)
    have h_box_t' : Formula.box φ ∈ (shifted_dd_fmcs N' h_N' sigma_list s').mcs t :=
      (box_stable_dd_chain N' h_N' sigma_list φ (t - s')).mpr ((h_eqN' φ).mp h_box_M0)
    exact SetMaximalConsistent.implication_property
      ((shifted_dd_fmcs N' h_N' sigma_list s').is_mcs t)
      (theorem_in_mcs ((shifted_dd_fmcs N' h_N' sigma_list s').is_mcs t)
        (DerivationTree.axiom [] _ (Axiom.modal_t φ))) h_box_t'
  modal_backward := by
    intro fam hfam φ t h_all
    obtain ⟨N, h_N, s, h_eqN, rfl⟩ := hfam
    suffices h_box_M0 : Formula.box φ ∈ M₀ from
      (box_stable_dd_chain N h_N sigma_list φ (t - s)).mpr ((h_eqN φ).mp h_box_M0)
    by_contra h_not_box
    have h_neg_box : (Formula.box φ).neg ∈ M₀ := by
      rcases SetMaximalConsistent.negation_complete h₀ (Formula.box φ) with h | h
      · exact absurd h h_not_box
      · exact h
    have h_diamond_neg : (Formula.neg φ).diamond ∈ M₀ :=
      Bimodal.Metalogic.Bundle.SetMaximalConsistent.contrapositive h₀
        (Bimodal.Metalogic.Bundle.box_dne_theorem φ) h_neg_box
    obtain ⟨v, h_equiv, h_neg_phi_v⟩ := bx_modal_witness ⟨M₀, h₀⟩ (Formula.neg φ) h_diamond_neg
    have h_fam_v_mem : shifted_dd_fmcs v.formulas v.is_mcs sigma_list t ∈
        { fam | ∃ (N : Set Formula) (h_N : SetMaximalConsistent N) (s : Int),
          (∀ ψ, Formula.box ψ ∈ M₀ ↔ Formula.box ψ ∈ N) ∧
          fam = shifted_dd_fmcs N h_N sigma_list s } :=
      ⟨v.formulas, v.is_mcs, t, fun ψ => h_equiv ψ, rfl⟩
    have h_phi_v_t := h_all (shifted_dd_fmcs v.formulas v.is_mcs sigma_list t) h_fam_v_mem
    have h_mcs_eq := shifted_dd_fmcs_at_s v.formulas v.is_mcs sigma_list t
    rw [h_mcs_eq] at h_phi_v_t
    exact set_consistent_not_both v.is_mcs.1 φ h_phi_v_t h_neg_phi_v
  eval_family := shifted_dd_fmcs M₀ h₀ sigma_list 0
  eval_family_mem := ⟨M₀, h₀, 0, fun _ => Iff.rfl, rfl⟩

-- Restricted coherence
theorem dd_bfmcs_restricted_tc (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (sigma_list : List Formula) (root : Formula)
    (h_sub : ∀ ψ, ψ ∈ deferralClosure root → ψ ∈ sigma_list) :
    (dd_bfmcs M₀ h₀ sigma_list).restricted_temporally_coherent root := by
  sorry

theorem dd_bfmcs_restricted_buc (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (sigma_list : List Formula) (root : Formula) :
    (dd_bfmcs M₀ h₀ sigma_list).restricted_backward_until_since_coherent root := by
  sorry

theorem dd_bfmcs_restricted_fuc (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (sigma_list : List Formula) (root : Formula) :
    (dd_bfmcs M₀ h₀ sigma_list).restricted_forward_until_since_coherent root := by
  sorry

/-! ## Countermodel -/

theorem dd_countermodel (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (φ : Formula) (h_neg_in : φ.neg ∈ M) :
    ∃ (D : Type) (_ : AddCommGroup D) (_ : LinearOrder D) (_ : IsOrderedAddMonoid D)
      (F : TaskFrame D) (TM : TaskModel F)
      (Omega : Set (WorldHistory F)) (_ : ShiftClosed Omega)
      (τ : WorldHistory F) (_ : τ ∈ Omega) (t : D),
      ¬truth_at TM Omega τ t φ := by
  let sigma_list := (extendedDeferralClosure φ).toList
  refine ⟨Int, inferInstance, inferInstance, inferInstance,
    ParametricCanonicalTaskFrame Int, ParametricCanonicalTaskModel Int,
    ShiftClosedParametricCanonicalOmega (dd_bfmcs M h_mcs sigma_list),
    shiftClosedParametricCanonicalOmega_is_shift_closed _,
    parametric_to_history (shifted_dd_fmcs M h_mcs sigma_list 0),
    parametricCanonicalOmega_subset_shiftClosed _
      ⟨shifted_dd_fmcs M h_mcs sigma_list 0,
       ⟨M, h_mcs, 0, fun _ => Iff.rfl, rfl⟩, rfl⟩,
    0, ?_⟩
  have h_neg_fam : φ.neg ∈ (shifted_dd_fmcs M h_mcs sigma_list 0).mcs 0 := by
    rw [shifted_dd_fmcs_at_s]; exact h_neg_in
  exact fully_restricted_parametric_representation_from_neg_membership
    (dd_bfmcs M h_mcs sigma_list) φ
    (dd_bfmcs_restricted_tc M h_mcs sigma_list φ
      (fun ψ hψ => Finset.mem_toList.mpr (deferralClosure_subset_extendedDeferralClosure φ hψ)))
    (dd_bfmcs_restricted_buc M h_mcs sigma_list φ)
    (dd_bfmcs_restricted_fuc M h_mcs sigma_list φ)
    φ (self_mem_subformulaClosure φ)
    (shifted_dd_fmcs M h_mcs sigma_list 0) ⟨M, h_mcs, 0, fun _ => Iff.rfl, rfl⟩ 0 h_neg_fam

/-! ## Custom Lindenbaum Extension Infrastructure (Phase 0)

This section provides infrastructure for building Lindenbaum extensions from an
arbitrary consistent seed parameterized by (target, guard) formulas, rather than
the fixed seed used by `fwd_succ`. This is the foundational building block for
the defect-discharge strategy in subsequent phases.

### Forward Direction

The **defect resolving seed** is `{target, guard} ∪ g_content(M)`.
When `F(target ∧ guard) ∈ M`, this seed is consistent by
`enriched_resolving_seed_consistent`.

### Backward Direction

The **past defect resolving seed** is `{target, guard} ∪ h_content(M)`.
When `P(target ∧ guard) ∈ M`, this seed is consistent by a past
analog of `enriched_resolving_seed_consistent` proved below.
-/

/-! ### Forward Defect Step -/

/-- The forward defect resolving seed: `{target, guard} ∪ g_content(M)`. -/
def defect_resolving_seed (M : Set Formula) (target guard : Formula) : Set Formula :=
  {target, guard} ∪ g_content M

/-- When `F(target ∧ guard) ∈ M` for MCS M, the seed `{target, guard} ∪ g_content(M)` is
consistent. This follows directly from `enriched_resolving_seed_consistent` with
`ψ = target` and `α = guard`. -/
theorem defect_resolving_seed_consistent {M : Set Formula}
    (h_mcs : SetMaximalConsistent M) (target guard : Formula)
    (h_F : Formula.some_future (Formula.and target guard) ∈ M) :
    SetConsistent (defect_resolving_seed M target guard) := by
  -- enriched_resolving_seed_consistent gives exactly this: if F(ψ ∧ α) ∈ M,
  -- then {ψ, α} ∪ g_content(M) is consistent. Here ψ = target, α = guard.
  have h := enriched_resolving_seed_consistent h_mcs target guard h_F
  -- enriched_resolving_seed M target guard = {target, guard} ∪ g_content M
  -- = defect_resolving_seed M target guard
  exact h

/-- The defect forward step: Lindenbaum extension of `defect_resolving_seed M target guard`.
Defined when `F(target ∧ guard) ∈ M`. -/
noncomputable def defect_fwd_step (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (target guard : Formula)
    (h_F : Formula.some_future (Formula.and target guard) ∈ M) : Set Formula :=
  (set_lindenbaum (defect_resolving_seed M target guard)
    (defect_resolving_seed_consistent h_mcs target guard h_F)).choose

private theorem defect_fwd_step_lindenbaum (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (target guard : Formula)
    (h_F : Formula.some_future (Formula.and target guard) ∈ M) :
    defect_resolving_seed M target guard ⊆ defect_fwd_step M h_mcs target guard h_F ∧
    SetMaximalConsistent (defect_fwd_step M h_mcs target guard h_F) :=
  (set_lindenbaum (defect_resolving_seed M target guard)
    (defect_resolving_seed_consistent h_mcs target guard h_F)).choose_spec

/-- The result of `defect_fwd_step` is MCS. -/
theorem defect_fwd_step_mcs (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (target guard : Formula)
    (h_F : Formula.some_future (Formula.and target guard) ∈ M) :
    SetMaximalConsistent (defect_fwd_step M h_mcs target guard h_F) :=
  (defect_fwd_step_lindenbaum M h_mcs target guard h_F).2

/-- The target formula is in the defect forward step. -/
theorem defect_fwd_step_target (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (target guard : Formula)
    (h_F : Formula.some_future (Formula.and target guard) ∈ M) :
    target ∈ defect_fwd_step M h_mcs target guard h_F := by
  apply (defect_fwd_step_lindenbaum M h_mcs target guard h_F).1
  show target ∈ defect_resolving_seed M target guard
  exact Set.mem_union_left _ (Set.mem_insert _ _)

/-- The guard formula is in the defect forward step. -/
theorem defect_fwd_step_guard (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (target guard : Formula)
    (h_F : Formula.some_future (Formula.and target guard) ∈ M) :
    guard ∈ defect_fwd_step M h_mcs target guard h_F := by
  apply (defect_fwd_step_lindenbaum M h_mcs target guard h_F).1
  show guard ∈ defect_resolving_seed M target guard
  exact Set.mem_union_left _ (Set.mem_insert_of_mem _ rfl)

/-- The g_content of M is a subset of the defect forward step (G-propagation maintained). -/
theorem defect_fwd_step_g_content (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (target guard : Formula)
    (h_F : Formula.some_future (Formula.and target guard) ∈ M) :
    g_content M ⊆ defect_fwd_step M h_mcs target guard h_F := by
  intro φ hφ
  apply (defect_fwd_step_lindenbaum M h_mcs target guard h_F).1
  show φ ∈ defect_resolving_seed M target guard
  exact Set.mem_union_right _ hφ

/-! ### Backward Defect Step

The backward analog uses `h_content` instead of `g_content` and `P` (some_past)
instead of `F` (some_future). We first prove a past analog of
`enriched_resolving_seed_consistent`.
-/

/-- If `P(target ∧ guard) ∈ M` for MCS M, then `{target, guard} ∪ h_content(M)` is
consistent.

The proof strategy mirrors `enriched_resolving_seed_consistent`:
1. `P(target ∧ guard) ∈ M` implies `{target ∧ guard} ∪ h_content(M)` is consistent
   (by `past_temporal_witness_seed_consistent`)
2. Lindenbaum-extend to MCS M'
3. M' contains `target ∧ guard`, so by conjunction elimination: `target ∈ M'` and `guard ∈ M'`
4. M' contains `h_content(M)` (superset)
5. So `{target, guard} ∪ h_content(M) ⊆ M'`
6. Since M' is consistent, any subset is consistent
-/
theorem enriched_past_resolving_seed_consistent {M : Set Formula}
    (h_mcs : SetMaximalConsistent M) (target guard : Formula)
    (h_P : Formula.some_past (Formula.and target guard) ∈ M) :
    SetConsistent ({target, guard} ∪ h_content M) := by
  -- Step 1: {target ∧ guard} ∪ h_content(M) is consistent
  have h_seed_cons := past_temporal_witness_seed_consistent M h_mcs
    (Formula.and target guard) h_P
  -- Step 2: Lindenbaum extend
  obtain ⟨M', h_sup, h_M'_mcs⟩ := set_lindenbaum _ h_seed_cons
  -- Step 3: target ∧ guard ∈ M'
  have h_conj_in : Formula.and target guard ∈ M' :=
    h_sup (Set.mem_union_left _ (Set.mem_singleton _))
  -- target ∈ M' by left conjunction elimination
  have h_target_in : target ∈ M' :=
    SetMaximalConsistent.implication_property h_M'_mcs
      (theorem_in_mcs h_M'_mcs (Bimodal.Theorems.Propositional.lce_imp target guard)) h_conj_in
  -- guard ∈ M' by right conjunction elimination
  have h_guard_in : guard ∈ M' :=
    SetMaximalConsistent.implication_property h_M'_mcs
      (theorem_in_mcs h_M'_mcs (Bimodal.Theorems.Propositional.rce_imp target guard)) h_conj_in
  -- Step 4: h_content(M) ⊆ M'
  have h_h_sub : h_content M ⊆ M' :=
    fun χ hχ => h_sup (Set.mem_union_right _ hχ)
  -- Step 5: {target, guard} ∪ h_content(M) ⊆ M'
  have h_seed_sub : {target, guard} ∪ h_content M ⊆ M' := by
    intro φ hφ
    simp only [Set.mem_union, Set.mem_insert_iff, Set.mem_singleton_iff] at hφ
    rcases hφ with (rfl | rfl) | hh
    · exact h_target_in
    · exact h_guard_in
    · exact h_h_sub hh
  -- Step 6: M' is consistent, so any subset is consistent
  intro L hL hd
  exact h_M'_mcs.1 L (fun φ hφ => h_seed_sub (hL φ hφ)) hd

/-- The past defect resolving seed: `{target, guard} ∪ h_content(M)`. -/
def past_defect_resolving_seed (M : Set Formula) (target guard : Formula) : Set Formula :=
  {target, guard} ∪ h_content M

/-- When `P(target ∧ guard) ∈ M` for MCS M, the past defect seed is consistent. -/
theorem past_defect_resolving_seed_consistent {M : Set Formula}
    (h_mcs : SetMaximalConsistent M) (target guard : Formula)
    (h_P : Formula.some_past (Formula.and target guard) ∈ M) :
    SetConsistent (past_defect_resolving_seed M target guard) :=
  enriched_past_resolving_seed_consistent h_mcs target guard h_P

/-- The defect backward step: Lindenbaum extension of `past_defect_resolving_seed M target guard`.
Defined when `P(target ∧ guard) ∈ M`. -/
noncomputable def defect_bwd_step (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (target guard : Formula)
    (h_P : Formula.some_past (Formula.and target guard) ∈ M) : Set Formula :=
  (set_lindenbaum (past_defect_resolving_seed M target guard)
    (past_defect_resolving_seed_consistent h_mcs target guard h_P)).choose

private theorem defect_bwd_step_lindenbaum (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (target guard : Formula)
    (h_P : Formula.some_past (Formula.and target guard) ∈ M) :
    past_defect_resolving_seed M target guard ⊆ defect_bwd_step M h_mcs target guard h_P ∧
    SetMaximalConsistent (defect_bwd_step M h_mcs target guard h_P) :=
  (set_lindenbaum (past_defect_resolving_seed M target guard)
    (past_defect_resolving_seed_consistent h_mcs target guard h_P)).choose_spec

/-- The result of `defect_bwd_step` is MCS. -/
theorem defect_bwd_step_mcs (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (target guard : Formula)
    (h_P : Formula.some_past (Formula.and target guard) ∈ M) :
    SetMaximalConsistent (defect_bwd_step M h_mcs target guard h_P) :=
  (defect_bwd_step_lindenbaum M h_mcs target guard h_P).2

/-- The target formula is in the defect backward step (target is resolved). -/
theorem defect_bwd_step_target (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (target guard : Formula)
    (h_P : Formula.some_past (Formula.and target guard) ∈ M) :
    target ∈ defect_bwd_step M h_mcs target guard h_P := by
  apply (defect_bwd_step_lindenbaum M h_mcs target guard h_P).1
  show target ∈ past_defect_resolving_seed M target guard
  exact Set.mem_union_left _ (Set.mem_insert _ _)

/-- The guard formula is in the defect backward step (guard is present). -/
theorem defect_bwd_step_guard (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (target guard : Formula)
    (h_P : Formula.some_past (Formula.and target guard) ∈ M) :
    guard ∈ defect_bwd_step M h_mcs target guard h_P := by
  apply (defect_bwd_step_lindenbaum M h_mcs target guard h_P).1
  show guard ∈ past_defect_resolving_seed M target guard
  exact Set.mem_union_left _ (Set.mem_insert_of_mem _ rfl)

/-- The h_content of M is a subset of the defect backward step (H-propagation maintained). -/
theorem defect_bwd_step_h_content (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (target guard : Formula)
    (h_P : Formula.some_past (Formula.and target guard) ∈ M) :
    h_content M ⊆ defect_bwd_step M h_mcs target guard h_P := by
  intro φ hφ
  apply (defect_bwd_step_lindenbaum M h_mcs target guard h_P).1
  show φ ∈ past_defect_resolving_seed M target guard
  exact Set.mem_union_right _ hφ

/-! ## Phase 1: BX11 Minimum Selection and Single-Step Target Resolution

The key tool `target_resolving_fwd_exists_strong` requires a target that is
`bx11_earlier` than ALL other defects. This section constructs such a target
from a non-empty finite list of F-defects using the following approach:

### Observation

For any two F-defects ψ₁, ψ₂ with F(ψ₁), F(ψ₂) ∈ M, `bx11_earlier_total`
gives either `bx11_earlier M ψ₁ ψ₂` or `bx11_earlier M ψ₂ ψ₁`.

For a list of N defects, `bx11_earlier` is non-transitive and may admit
3-cycles, so a global "beats all" element need not exist. However, for the
purposes of Phase 2 (forward_F), we need: given a non-empty defect list,
there exists a step M' where SOME defect is directly resolved AND ALL
F-obligations are preserved. This is provided by `resolving_enriched_fwd_exists`.

### Interface

`pick_bx11_earliest`: Given a non-empty defect list, returns the head element.
The key property is membership in the defect list (and thus having an F-obligation).
Due to non-transitivity of `bx11_earlier`, this function cannot guarantee that
its result beats all other elements; the downstream theorem uses
`resolving_enriched_fwd_exists` instead.

`defect_step_from_earliest`: Wraps `resolving_enriched_fwd_exists` to give
a step M' with: some defect w directly resolved, all other F-obligations
preserved (F(χ) ∈ M' for ALL χ in the defect list via `phi_in_mcs_imp_F_phi`),
and g_content(M) ⊆ M'.
-/

/-- `pick_bx11_earliest`: given a non-empty defect list with F-obligations, returns an element
of the list. The element is the head of the list (a well-defined choice).

Note: due to non-transitivity of `bx11_earlier`, there may be no element that is
`bx11_earlier` than ALL other elements (tournaments can have 3-cycles). The downstream
`defect_step_from_earliest` uses `resolving_enriched_fwd_exists` (which handles the
general case) rather than `target_resolving_fwd_exists_strong`. -/
noncomputable def pick_bx11_earliest (M : Set Formula) (_ : SetMaximalConsistent M)
    (defects : List Formula)
    (h_nonempty : defects ≠ [])
    (_ : ∀ χ, χ ∈ defects → Formula.some_future χ ∈ M) : Formula :=
  defects.head h_nonempty

/-- `pick_bx11_earliest` returns a member of the defect list. -/
theorem pick_bx11_earliest_mem (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (defects : List Formula) (h_nonempty : defects ≠ [])
    (h_F : ∀ χ, χ ∈ defects → Formula.some_future χ ∈ M) :
    pick_bx11_earliest M h_mcs defects h_nonempty h_F ∈ defects :=
  List.head_mem h_nonempty

/-- `pick_bx11_earliest` has an F-obligation in M (follows from membership in defects). -/
theorem pick_bx11_earliest_F_mem (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (defects : List Formula) (h_nonempty : defects ≠ [])
    (h_F : ∀ χ, χ ∈ defects → Formula.some_future χ ∈ M) :
    Formula.some_future (pick_bx11_earliest M h_mcs defects h_nonempty h_F) ∈ M :=
  h_F _ (pick_bx11_earliest_mem M h_mcs defects h_nonempty h_F)

/-! ### Single-Step Target Resolution

`defect_step_from_earliest` produces a forward step M' from a non-empty defect list
where:
1. The pick_bx11_earliest target is directly resolved (present in M')
2. ALL other defects have their F-obligations preserved in M'
3. g_content(M) ⊆ M'

The proof uses `resolving_enriched_fwd_exists` which handles the general multi-defect
case without requiring a global bx11_earlier minimum.
-/

/-- Given a non-empty defect list, there exists a forward step M' where:
- Some defect is directly resolved (the resolving witness w ∈ M')
- ALL defects from the list have F-obligations preserved (F(χ) ∈ M' for all χ ∈ defects)
- g_content(M) ⊆ M'

This is the key single-step primitive for Phase 2's defect-driven chain. -/
theorem defect_step_from_earliest {M : Set Formula} (h_mcs : SetMaximalConsistent M)
    (defects : List Formula) (h_nonempty : defects ≠ [])
    (h_F : ∀ χ, χ ∈ defects → Formula.some_future χ ∈ M) :
    ∃ M' : Set Formula, SetMaximalConsistent M' ∧
      g_content M ⊆ M' ∧
      -- The pick_bx11_earliest target, or some other defect, is directly resolved
      (∃ w ∈ defects, Formula.some_future w ∈ M ∧ w ∈ M') ∧
      -- ALL defects have F-obligations preserved in M'
      (∀ χ, χ ∈ defects → Formula.some_future χ ∈ M') := by
  -- Use resolving_enriched_fwd_exists: it gives a witness that is directly resolved,
  -- and all others are either in M' or F-protected.
  match defects, h_nonempty with
  | [], h => exact absurd rfl h
  | (target :: others), _ =>
      obtain ⟨M', h_mcs', h_g, h_target_disj, h_others_disj, w, h_w_origin, h_w_F, h_w_in⟩ :=
        resolving_enriched_fwd_exists h_mcs target
          (h_F target (List.mem_cons_self))
          others (fun χ hχ => h_F χ (List.mem_cons_of_mem _ hχ))
      refine ⟨M', h_mcs', h_g, ?_, ?_⟩
      · -- Witness membership: w is in defects
        refine ⟨w, ?_, h_w_F, h_w_in⟩
        rcases h_w_origin with rfl | h_in_others
        · exact List.mem_cons_self
        · exact List.mem_cons_of_mem _ h_in_others
      · -- F-obligations preserved for ALL defects
        intro χ hχ
        rcases List.mem_cons.mp hχ with rfl | h_in_others
        · -- χ = target: use h_target_disj : target ∈ M' ∨ F(target) ∈ M'
          rcases h_target_disj with h | h
          · exact phi_in_mcs_imp_F_phi h_mcs' χ h
          · exact h
        · -- χ ∈ others: h_others_disj gives χ ∈ M' ∨ F(χ) ∈ M'
          rcases h_others_disj χ h_in_others with h | h
          · exact phi_in_mcs_imp_F_phi h_mcs' χ h
          · exact h

/-! ## Phase 2: Defect-Driven Forward and Backward Chains

Simplified chain construction using round-robin `fwd_succ`/`bwd_pred` targeting.

### Key Design: Single-Defect Self-Resolution

The chain uses `fwd_succ M hM target` at each step with a round-robin target.
When `F(target) ∈ M`: `fwd_succ_resolves` guarantees `target ∈ M'`.
When `F(target) ∉ M`: `fwd_succ_f_carry` preserves all F-formulas.

F-obligations are preserved at non-resolving steps via `f_carry`. At resolving
steps for other targets, F-obligations may be lost — but the key insight is that
once an F-obligation is lost, it stays lost (`no_new_f_defects`), so the NUMBER
of active defects that can cause resolving steps before ψ's visit is bounded
and strictly decreasing when F-obligations are killed.

### Forward_F Proof Strategy

Given `F(ψ) ∈ chain(n)` with `ψ ∈ defects`:

1. F(ψ) persists at non-resolving steps (f_carry).
2. F-obligations, once lost, never return (no_new_f_defects + g_content propagation).
3. At each step, at most one defect has a resolving step that could kill F(ψ).
4. If F(ψ) survives to ψ's visit step: ψ ∈ chain(m+1) by fwd_succ_resolves.
5. If F(ψ) is killed at step s by a resolving step for χ: then F(χ) was also in
   chain(n) (since it was in chain(s) and F-obligations only decrease). After χ's
   resolution, F(χ) may or may not persist, but the total number of other defects
   whose resolving steps could kill F(ψ) in a FUTURE round strictly decreases.
6. By well-founded induction on the number of OTHER active defects at step n,
   ψ is eventually resolved.
-/

/-! ### φ → P(φ) at MCS level -/

/-- `φ → P(φ)` is derivable in BX.
Proof: temp_t_past gives H(¬φ) → ¬φ. Contrapositive: φ → ¬H(¬φ) = P(φ). -/
noncomputable def phi_imp_P_phi (φ : Formula) :
    ⊢ φ.imp φ.some_past := by
  unfold Formula.some_past
  exact Bimodal.Theorems.Combinators.imp_trans (dni φ)
    (Bimodal.Theorems.Propositional.contraposition
      (DerivationTree.axiom [] _ (Axiom.temp_t_past (Formula.neg φ))))

/-- At MCS level: φ ∈ M → P(φ) ∈ M. -/
theorem phi_in_mcs_imp_P_phi {M : Set Formula} (h_mcs : SetMaximalConsistent M)
    (φ : Formula) (h : φ ∈ M) : φ.some_past ∈ M :=
  SetMaximalConsistent.implication_property h_mcs
    (theorem_in_mcs h_mcs (phi_imp_P_phi φ)) h

/-! ### Self-Resolving Seed: F(ψ) → F(ψ ∧ F(ψ)) -/

/-- `φ → φ ∧ φ` is derivable. -/
noncomputable def and_self_intro (φ : Formula) : ⊢ φ.imp (φ.and φ) :=
  DerivationTree.modus_ponens [] _ _
    (DerivationTree.modus_ponens [] _ _
      (DerivationTree.axiom [] _ (Axiom.prop_k φ φ (φ.and φ)))
      (Bimodal.Theorems.Combinators.pairing φ φ))
    (Bimodal.Theorems.Combinators.identity φ)

/-- `ψ → ψ ∧ F(ψ)` is derivable: pair ψ with F(ψ) using phi_imp_F_phi. -/
noncomputable def phi_imp_phi_and_F_phi (ψ : Formula) :
    ⊢ ψ.imp (ψ.and ψ.some_future) :=
  Bimodal.Theorems.Combinators.combine_imp_conj
    (Bimodal.Theorems.Combinators.identity ψ)
    (phi_imp_F_phi ψ)

/-- `F(ψ) → F(ψ ∧ F(ψ))` by F-monotonicity of `ψ → ψ ∧ F(ψ)`. -/
noncomputable def F_and_self_F (ψ : Formula) :
    ⊢ ψ.some_future.imp (ψ.and ψ.some_future).some_future :=
  F_mono (phi_imp_phi_and_F_phi ψ)

/-- At MCS level: F(ψ) ∈ M → F(ψ ∧ F(ψ)) ∈ M. -/
theorem F_and_self_F_mcs {M : Set Formula} (h_mcs : SetMaximalConsistent M)
    (ψ : Formula) (h : ψ.some_future ∈ M) : (ψ.and ψ.some_future).some_future ∈ M :=
  SetMaximalConsistent.implication_property h_mcs
    (theorem_in_mcs h_mcs (F_and_self_F ψ)) h

/-- Self-resolving forward step: given F(ψ) ∈ M, build M' with
ψ ∈ M', F(ψ) ∈ M', and g_content(M) ⊆ M'.

Uses the self-resolving seed {ψ, F(ψ)} ∪ g_content(M), which is consistent
because F(ψ ∧ F(ψ)) ∈ M (by F_and_self_F_mcs) and enriched_resolving_seed_consistent
gives {ψ, F(ψ)} ∪ g_content(M) consistent. -/
noncomputable def self_resolving_fwd_step (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (ψ : Formula) (h_F : Formula.some_future ψ ∈ M) : Set Formula :=
  (set_lindenbaum (enriched_resolving_seed M ψ ψ.some_future)
    (enriched_resolving_seed_consistent h_mcs ψ ψ.some_future
      (F_and_self_F_mcs h_mcs ψ h_F))).choose

theorem self_resolving_fwd_step_mcs (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (ψ : Formula) (h_F : Formula.some_future ψ ∈ M) :
    SetMaximalConsistent (self_resolving_fwd_step M h_mcs ψ h_F) :=
  (set_lindenbaum (enriched_resolving_seed M ψ ψ.some_future)
    (enriched_resolving_seed_consistent h_mcs ψ ψ.some_future
      (F_and_self_F_mcs h_mcs ψ h_F))).choose_spec.2

private theorem self_resolving_fwd_step_sup (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (ψ : Formula) (h_F : Formula.some_future ψ ∈ M) :
    enriched_resolving_seed M ψ ψ.some_future ⊆ self_resolving_fwd_step M h_mcs ψ h_F :=
  (set_lindenbaum (enriched_resolving_seed M ψ ψ.some_future)
    (enriched_resolving_seed_consistent h_mcs ψ ψ.some_future
      (F_and_self_F_mcs h_mcs ψ h_F))).choose_spec.1

theorem self_resolving_fwd_step_target (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (ψ : Formula) (h_F : Formula.some_future ψ ∈ M) :
    ψ ∈ self_resolving_fwd_step M h_mcs ψ h_F :=
  self_resolving_fwd_step_sup M h_mcs ψ h_F
    (Set.mem_union_left _ (Set.mem_insert _ _))

theorem self_resolving_fwd_step_F_target (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (ψ : Formula) (h_F : Formula.some_future ψ ∈ M) :
    Formula.some_future ψ ∈ self_resolving_fwd_step M h_mcs ψ h_F :=
  self_resolving_fwd_step_sup M h_mcs ψ h_F
    (Set.mem_union_left _ (Set.mem_insert_of_mem _ rfl))

theorem self_resolving_fwd_step_g_content (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (ψ : Formula) (h_F : Formula.some_future ψ ∈ M) :
    g_content M ⊆ self_resolving_fwd_step M h_mcs ψ h_F :=
  fun φ hφ => self_resolving_fwd_step_sup M h_mcs ψ h_F (Set.mem_union_right _ hφ)

/-! ### P-monotonicity and P self-resolving -/

/-- P-monotonicity: from ⊢ A → B, derive ⊢ P(A) → P(B). -/
noncomputable def P_mono {A B : Formula} (h : ⊢ A.imp B) :
    ⊢ A.some_past.imp B.some_past := by
  have h1 := Bimodal.Theorems.Propositional.contraposition h
  have h2 := Bimodal.Theorems.Perpetuity.past_mono h1
  exact Bimodal.Theorems.Propositional.contraposition h2

/-- `ψ → ψ ∧ P(ψ)` is derivable: pair ψ with P(ψ) using phi_imp_P_phi. -/
noncomputable def phi_imp_phi_and_P_phi (ψ : Formula) :
    ⊢ ψ.imp (ψ.and ψ.some_past) :=
  Bimodal.Theorems.Combinators.combine_imp_conj
    (Bimodal.Theorems.Combinators.identity ψ)
    (phi_imp_P_phi ψ)

/-- `P(ψ) → P(ψ ∧ P(ψ))` by P-monotonicity. -/
noncomputable def P_and_self_P (ψ : Formula) :
    ⊢ ψ.some_past.imp (ψ.and ψ.some_past).some_past :=
  P_mono (phi_imp_phi_and_P_phi ψ)

/-- At MCS level: P(ψ) ∈ M → P(ψ ∧ P(ψ)) ∈ M. -/
theorem P_and_self_P_mcs {M : Set Formula} (h_mcs : SetMaximalConsistent M)
    (ψ : Formula) (h : ψ.some_past ∈ M) : (ψ.and ψ.some_past).some_past ∈ M :=
  SetMaximalConsistent.implication_property h_mcs
    (theorem_in_mcs h_mcs (P_and_self_P ψ)) h

/-! ### Forward Chain Step Selection -/

/-- The forward chain step data: given M and a non-empty defect list with active
F-obligations, selects a specific M' satisfying the step properties. Uses
Classical.choice to pick from `defect_step_from_earliest`. -/
noncomputable def defect_fwd_step_choice
    (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (defects : List Formula) (h_nonempty : defects ≠ [])
    (h_F : ∀ χ, χ ∈ defects → Formula.some_future χ ∈ M) : Set Formula :=
  (defect_step_from_earliest h_mcs defects h_nonempty h_F).choose

private theorem defect_fwd_step_choice_spec
    (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (defects : List Formula) (h_nonempty : defects ≠ [])
    (h_F : ∀ χ, χ ∈ defects → Formula.some_future χ ∈ M) :
    SetMaximalConsistent (defect_fwd_step_choice M h_mcs defects h_nonempty h_F) ∧
    g_content M ⊆ defect_fwd_step_choice M h_mcs defects h_nonempty h_F ∧
    (∃ w ∈ defects, Formula.some_future w ∈ M ∧
        w ∈ defect_fwd_step_choice M h_mcs defects h_nonempty h_F) ∧
    (∀ χ, χ ∈ defects →
        Formula.some_future χ ∈ defect_fwd_step_choice M h_mcs defects h_nonempty h_F) :=
  (defect_step_from_earliest h_mcs defects h_nonempty h_F).choose_spec

/-! ## Oracle-Based FMCS Construction (Phase 4)

This section builds a new Int-indexed FMCS using `qm_oracle_step` (forward) and
`qm_oracle_step_bwd` (backward), bypassing `fwd_chain_of_sigma` entirely.

The forward oracle chain has the property:
- `g_content(mcs(n)) ⊆ mcs(n+1)` (by qm_oracle_step_bx_le)
- `h_content(mcs(n+1)) ⊆ mcs(n)` (by qm_oracle_step_h_content)
- Until-defects propagate from mcs(n) to mcs(n+1) (by oracle seed construction)

The backward oracle chain is symmetric using h_content and Since defects.

This construction supports proofs of restricted_tc, restricted_buc, and restricted_fuc
because the oracle seed explicitly handles eventuality obligations.
-/

/-- Forward oracle chain: iterate qm_oracle_step. -/
private noncomputable def qm_fwd_chain (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (Sigma : Finset Formula) : (n : Nat) → BXPoint
  | 0 => ⟨M₀, h₀⟩
  | n + 1 => Quasimodel.qm_oracle_step (qm_fwd_chain M₀ h₀ Sigma n) Sigma

/-- Backward oracle chain: iterate qm_oracle_step_bwd. -/
private noncomputable def qm_bwd_chain (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (Sigma : Finset Formula) : (n : Nat) → BXPoint
  | 0 => ⟨M₀, h₀⟩
  | n + 1 => Quasimodel.qm_oracle_step_bwd (qm_bwd_chain M₀ h₀ Sigma n) Sigma

/-- MCS property for forward oracle chain. -/
theorem qm_fwd_chain_mcs (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (Sigma : Finset Formula) (n : Nat) :
    SetMaximalConsistent (qm_fwd_chain M₀ h₀ Sigma n).formulas :=
  (qm_fwd_chain M₀ h₀ Sigma n).is_mcs

/-- MCS property for backward oracle chain. -/
theorem qm_bwd_chain_mcs (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (Sigma : Finset Formula) (n : Nat) :
    SetMaximalConsistent (qm_bwd_chain M₀ h₀ Sigma n).formulas :=
  (qm_bwd_chain M₀ h₀ Sigma n).is_mcs

/-- g_content propagation step for forward oracle chain. -/
theorem qm_fwd_chain_g_content_step (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (Sigma : Finset Formula) (n : Nat) :
    g_content (qm_fwd_chain M₀ h₀ Sigma n).formulas ⊆
      (qm_fwd_chain M₀ h₀ Sigma (n + 1)).formulas :=
  Quasimodel.qm_oracle_step_bx_le (qm_fwd_chain M₀ h₀ Sigma n) Sigma

/-- h_content backward step for forward oracle chain. -/
theorem qm_fwd_chain_h_content_step (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (Sigma : Finset Formula) (n : Nat) :
    h_content (qm_fwd_chain M₀ h₀ Sigma (n + 1)).formulas ⊆
      (qm_fwd_chain M₀ h₀ Sigma n).formulas :=
  Quasimodel.qm_oracle_step_h_content (qm_fwd_chain M₀ h₀ Sigma n) Sigma

/-- h_content propagation step for backward oracle chain. -/
theorem qm_bwd_chain_h_content_step (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (Sigma : Finset Formula) (n : Nat) :
    h_content (qm_bwd_chain M₀ h₀ Sigma n).formulas ⊆
      (qm_bwd_chain M₀ h₀ Sigma (n + 1)).formulas :=
  Quasimodel.qm_oracle_step_bwd_h_content (qm_bwd_chain M₀ h₀ Sigma n) Sigma

/-- g_content backward for backward oracle chain. -/
theorem qm_bwd_chain_g_content_step (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (Sigma : Finset Formula) (n : Nat) :
    g_content (qm_bwd_chain M₀ h₀ Sigma (n + 1)).formulas ⊆
      (qm_bwd_chain M₀ h₀ Sigma n).formulas :=
  Quasimodel.qm_oracle_step_bwd_g_content (qm_bwd_chain M₀ h₀ Sigma n) Sigma

/-- Transitive g_content propagation for qm_fwd_chain. -/
theorem qm_fwd_chain_g_content_trans (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (Sigma : Finset Formula) {m n : Nat} (h : m ≤ n) :
    g_content (qm_fwd_chain M₀ h₀ Sigma m).formulas ⊆
      (qm_fwd_chain M₀ h₀ Sigma n).formulas := by
  induction n with
  | zero =>
    have : m = 0 := Nat.eq_zero_of_le_zero h; subst this
    intro φ hφ
    exact SetMaximalConsistent.implication_property
      (qm_fwd_chain M₀ h₀ Sigma 0).is_mcs
      (theorem_in_mcs (qm_fwd_chain M₀ h₀ Sigma 0).is_mcs
        (DerivationTree.axiom [] _ (Axiom.temp_t_future φ))) hφ
  | succ n ih =>
    rcases Nat.eq_or_lt_of_le h with rfl | h_lt
    · exact fun φ hφ => SetMaximalConsistent.implication_property
        (qm_fwd_chain M₀ h₀ Sigma (n + 1)).is_mcs
        (theorem_in_mcs (qm_fwd_chain M₀ h₀ Sigma (n + 1)).is_mcs
          (DerivationTree.axiom [] _ (Axiom.temp_t_future φ))) hφ
    · intro φ hφ
      have h_GG := SetMaximalConsistent.all_future_all_future
        (qm_fwd_chain M₀ h₀ Sigma m).is_mcs hφ
      exact qm_fwd_chain_g_content_step M₀ h₀ Sigma n
        (ih (Nat.lt_succ_iff.mp h_lt) h_GG)

/-- Transitive h_content propagation for qm_bwd_chain. -/
theorem qm_bwd_chain_h_content_trans (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (Sigma : Finset Formula) {m n : Nat} (h : m ≤ n) :
    h_content (qm_bwd_chain M₀ h₀ Sigma m).formulas ⊆
      (qm_bwd_chain M₀ h₀ Sigma n).formulas := by
  induction n with
  | zero =>
    have : m = 0 := Nat.eq_zero_of_le_zero h; subst this
    intro φ hφ
    exact SetMaximalConsistent.implication_property
      (qm_bwd_chain M₀ h₀ Sigma 0).is_mcs
      (theorem_in_mcs (qm_bwd_chain M₀ h₀ Sigma 0).is_mcs
        (DerivationTree.axiom [] _ (Axiom.temp_t_past φ))) hφ
  | succ n ih =>
    rcases Nat.eq_or_lt_of_le h with rfl | h_lt
    · exact fun φ hφ => SetMaximalConsistent.implication_property
        (qm_bwd_chain M₀ h₀ Sigma (n + 1)).is_mcs
        (theorem_in_mcs (qm_bwd_chain M₀ h₀ Sigma (n + 1)).is_mcs
          (DerivationTree.axiom [] _ (Axiom.temp_t_past φ))) hφ
    · intro φ hφ
      have h_HH := SetMaximalConsistent.all_past_all_past
        (qm_bwd_chain M₀ h₀ Sigma m).is_mcs hφ
      exact qm_bwd_chain_h_content_step M₀ h₀ Sigma n
        (ih (Nat.lt_succ_iff.mp h_lt) h_HH)

/-- g_content reverse for qm_bwd_chain: g_content(bwd(n)) ⊆ bwd(m) for n ≥ m. -/
theorem qm_bwd_chain_g_content_reverse (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (Sigma : Finset Formula) {m n : Nat} (h : m ≤ n) :
    g_content (qm_bwd_chain M₀ h₀ Sigma n).formulas ⊆
      (qm_bwd_chain M₀ h₀ Sigma m).formulas :=
  h_content_subset_implies_g_content_reverse
    (qm_bwd_chain M₀ h₀ Sigma m).formulas
    (qm_bwd_chain M₀ h₀ Sigma n).formulas
    (qm_bwd_chain M₀ h₀ Sigma m).is_mcs
    (qm_bwd_chain M₀ h₀ Sigma n).is_mcs
    (qm_bwd_chain_h_content_trans M₀ h₀ Sigma h)

/-- Int-indexed oracle chain. -/
noncomputable def qm_chain (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (Sigma : Finset Formula) (t : Int) : Set Formula :=
  if t ≥ 0 then (qm_fwd_chain M₀ h₀ Sigma t.toNat).formulas
  else (qm_bwd_chain M₀ h₀ Sigma ((-t).toNat)).formulas

theorem qm_chain_zero (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (Sigma : Finset Formula) : qm_chain M₀ h₀ Sigma 0 = M₀ := by
  simp [qm_chain, qm_fwd_chain]

theorem qm_chain_mcs (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (Sigma : Finset Formula) (t : Int) :
    SetMaximalConsistent (qm_chain M₀ h₀ Sigma t) := by
  simp only [qm_chain]; split
  · exact (qm_fwd_chain M₀ h₀ Sigma t.toNat).is_mcs
  · exact (qm_bwd_chain M₀ h₀ Sigma ((-t).toNat)).is_mcs

/-- g_content propagation across the full Int oracle chain. -/
theorem qm_chain_g_content (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (Sigma : Finset Formula) {t t' : Int} (h_le : t ≤ t') :
    g_content (qm_chain M₀ h₀ Sigma t) ⊆ qm_chain M₀ h₀ Sigma t' := by
  simp only [qm_chain]
  split_ifs with ht ht'
  · -- t ≥ 0, t' ≥ 0: forward chain
    exact qm_fwd_chain_g_content_trans M₀ h₀ Sigma (Int.toNat_le_toNat h_le)
  · -- t ≥ 0, t' < 0: impossible
    omega
  · -- t < 0, t' ≥ 0: go through origin
    intro χ hχ
    have h_Gchi_in_bwd : Formula.all_future χ ∈ (qm_bwd_chain M₀ h₀ Sigma ((-t).toNat)).formulas :=
      hχ
    have h_GGchi := SetMaximalConsistent.all_future_all_future
      (qm_bwd_chain M₀ h₀ Sigma ((-t).toNat)).is_mcs h_Gchi_in_bwd
    have h_Gchi_in_M0 : Formula.all_future χ ∈ M₀ :=
      qm_bwd_chain_g_content_reverse M₀ h₀ Sigma (Nat.zero_le _) h_GGchi
    exact qm_fwd_chain_g_content_trans M₀ h₀ Sigma (Nat.zero_le _) h_Gchi_in_M0
  · -- t < 0, t' < 0: backward chain
    exact qm_bwd_chain_g_content_reverse M₀ h₀ Sigma (by omega)

/-- Oracle FMCS from qm_chain. -/
noncomputable def qm_fmcs (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (Sigma : Finset Formula) : FMCS Int where
  mcs := qm_chain M₀ h₀ Sigma
  is_mcs := qm_chain_mcs M₀ h₀ Sigma
  forward_G t t' φ h_le h_G := qm_chain_g_content M₀ h₀ Sigma h_le h_G
  backward_H t t' φ h_le h_H :=
    g_content_subset_implies_h_content_reverse
      (qm_chain M₀ h₀ Sigma t') (qm_chain M₀ h₀ Sigma t)
      (qm_chain_mcs M₀ h₀ Sigma t') (qm_chain_mcs M₀ h₀ Sigma t)
      (qm_chain_g_content M₀ h₀ Sigma h_le) h_H

theorem qm_fmcs_at_zero (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (Sigma : Finset Formula) :
    (qm_fmcs M₀ h₀ Sigma).mcs 0 = M₀ := qm_chain_zero M₀ h₀ Sigma

/-- Shifted oracle FMCS: place M₀ at position s. -/
noncomputable def shifted_qm_fmcs (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (Sigma : Finset Formula) (s : Int) : FMCS Int where
  mcs t := qm_chain M₀ h₀ Sigma (t - s)
  is_mcs t := qm_chain_mcs M₀ h₀ Sigma (t - s)
  forward_G t t' φ h_le h_G :=
    qm_chain_g_content M₀ h₀ Sigma (by omega : t - s ≤ t' - s) h_G
  backward_H t t' φ h_le h_H :=
    g_content_subset_implies_h_content_reverse
      (qm_chain M₀ h₀ Sigma (t' - s)) (qm_chain M₀ h₀ Sigma (t - s))
      (qm_chain_mcs M₀ h₀ Sigma (t' - s)) (qm_chain_mcs M₀ h₀ Sigma (t - s))
      (qm_chain_g_content M₀ h₀ Sigma (by omega : t' - s ≤ t - s)) h_H

theorem shifted_qm_fmcs_at_s (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (Sigma : Finset Formula) (s : Int) :
    (shifted_qm_fmcs M₀ h₀ Sigma s).mcs s = M₀ := by
  show qm_chain M₀ h₀ Sigma (s - s) = M₀
  simp [qm_chain, qm_fwd_chain]

/-- Box stability along the oracle chain: Box φ ∈ qm_chain(t) ↔ Box φ ∈ M₀. -/
theorem box_stable_qm_chain (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (Sigma : Finset Formula) (φ : Formula) (t : Int) :
    Formula.box φ ∈ qm_chain M₀ h₀ Sigma t ↔ Formula.box φ ∈ M₀ := by
  constructor
  · intro h_box_t
    by_contra h_not_box_M0
    have h_neg_box_M0 : (Formula.box φ).neg ∈ M₀ := by
      rcases SetMaximalConsistent.negation_complete h₀ (Formula.box φ) with h | h
      · exact absurd h h_not_box_M0
      · exact h
    have h_box_neg : Formula.box (Formula.box φ).neg ∈ M₀ :=
      SetMaximalConsistent.implication_property h₀
        (theorem_in_mcs h₀ (neg_box_to_box_neg_box φ)) h_neg_box_M0
    have h_box_neg_t : Formula.box (Formula.box φ).neg ∈ qm_chain M₀ h₀ Sigma t := by
      rcases le_or_gt 0 t with h_pos | h_neg
      · have h_G := SetMaximalConsistent.implication_property h₀
          (theorem_in_mcs h₀ (DerivationTree.axiom [] _ (Axiom.temp_future (Formula.box φ).neg)))
          h_box_neg
        simp only [qm_chain, if_pos h_pos]
        exact qm_fwd_chain_g_content_trans M₀ h₀ Sigma (Nat.zero_le _) h_G
      · have h_box_box_neg : Formula.box (Formula.box (Formula.box φ).neg) ∈ M₀ :=
          SetMaximalConsistent.implication_property h₀
            (theorem_in_mcs h₀ (DerivationTree.axiom [] _ (Axiom.modal_4 (Formula.box φ).neg)))
            h_box_neg
        have h_H := SetMaximalConsistent.implication_property h₀
          (theorem_in_mcs h₀ (box_to_past (Formula.box (Formula.box φ).neg))) h_box_box_neg
        simp only [qm_chain, if_neg (not_le.mpr h_neg)]
        exact qm_bwd_chain_h_content_trans M₀ h₀ Sigma (Nat.zero_le _) h_H
    have h_neg_box_t : (Formula.box φ).neg ∈ qm_chain M₀ h₀ Sigma t :=
      SetMaximalConsistent.implication_property (qm_chain_mcs M₀ h₀ Sigma t)
        (theorem_in_mcs (qm_chain_mcs M₀ h₀ Sigma t)
          (DerivationTree.axiom [] _ (Axiom.modal_t (Formula.box φ).neg)))
        h_box_neg_t
    exact set_consistent_not_both (qm_chain_mcs M₀ h₀ Sigma t).1
      (Formula.box φ) h_box_t h_neg_box_t
  · intro h_box_M0
    rcases le_or_gt 0 t with h_pos | h_neg
    · have h_G := SetMaximalConsistent.implication_property h₀
        (theorem_in_mcs h₀ (DerivationTree.axiom [] _ (Axiom.temp_future φ))) h_box_M0
      simp only [qm_chain, if_pos h_pos]
      exact qm_fwd_chain_g_content_trans M₀ h₀ Sigma (Nat.zero_le _) h_G
    · have h_box_box : Formula.box (Formula.box φ) ∈ M₀ :=
        SetMaximalConsistent.implication_property h₀
          (theorem_in_mcs h₀ (DerivationTree.axiom [] _ (Axiom.modal_4 φ))) h_box_M0
      have h_H := SetMaximalConsistent.implication_property h₀
        (theorem_in_mcs h₀ (box_to_past (Formula.box φ))) h_box_box
      simp only [qm_chain, if_neg (not_le.mpr h_neg)]
      exact qm_bwd_chain_h_content_trans M₀ h₀ Sigma (Nat.zero_le _) h_H

/-! ## Oracle BFMCS Construction

Build `qm_bfmcs` by taking one `shifted_qm_fmcs` per modal equivalence class of M₀.
This is structurally identical to `dd_bfmcs` but uses the oracle chain instead of
fwd_chain_of_sigma.
-/

/-- Oracle BFMCS. -/
noncomputable def qm_bfmcs (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (Sigma : Finset Formula) : BFMCS Int where
  families := { fam | ∃ (N : Set Formula) (h_N : SetMaximalConsistent N) (s : Int),
    (∀ φ, Formula.box φ ∈ M₀ ↔ Formula.box φ ∈ N) ∧
    fam = shifted_qm_fmcs N h_N Sigma s }
  nonempty := ⟨shifted_qm_fmcs M₀ h₀ Sigma 0, M₀, h₀, 0, fun _ => Iff.rfl, rfl⟩
  modal_forward := by
    intro fam hfam φ t h_box fam' hfam'
    obtain ⟨N, h_N, s, h_eqN, rfl⟩ := hfam
    obtain ⟨N', h_N', s', h_eqN', rfl⟩ := hfam'
    have h_box_M0 : Formula.box φ ∈ M₀ :=
      (h_eqN φ).mpr ((box_stable_qm_chain N h_N Sigma φ (t - s)).mp h_box)
    have h_box_t' : Formula.box φ ∈ (shifted_qm_fmcs N' h_N' Sigma s').mcs t :=
      (box_stable_qm_chain N' h_N' Sigma φ (t - s')).mpr ((h_eqN' φ).mp h_box_M0)
    exact SetMaximalConsistent.implication_property
      ((shifted_qm_fmcs N' h_N' Sigma s').is_mcs t)
      (theorem_in_mcs ((shifted_qm_fmcs N' h_N' Sigma s').is_mcs t)
        (DerivationTree.axiom [] _ (Axiom.modal_t φ))) h_box_t'
  modal_backward := by
    intro fam hfam φ t h_all
    obtain ⟨N, h_N, s, h_eqN, rfl⟩ := hfam
    suffices h_box_M0 : Formula.box φ ∈ M₀ from
      (box_stable_qm_chain N h_N Sigma φ (t - s)).mpr ((h_eqN φ).mp h_box_M0)
    by_contra h_not_box
    have h_neg_box : (Formula.box φ).neg ∈ M₀ := by
      rcases SetMaximalConsistent.negation_complete h₀ (Formula.box φ) with h | h
      · exact absurd h h_not_box
      · exact h
    have h_diamond_neg : (Formula.neg φ).diamond ∈ M₀ :=
      Bimodal.Metalogic.Bundle.SetMaximalConsistent.contrapositive h₀
        (Bimodal.Metalogic.Bundle.box_dne_theorem φ) h_neg_box
    obtain ⟨v, h_equiv, h_neg_phi_v⟩ := bx_modal_witness ⟨M₀, h₀⟩ (Formula.neg φ) h_diamond_neg
    have h_fam_v_mem : shifted_qm_fmcs v.formulas v.is_mcs Sigma t ∈
        { fam | ∃ (N : Set Formula) (h_N : SetMaximalConsistent N) (s : Int),
          (∀ ψ, Formula.box ψ ∈ M₀ ↔ Formula.box ψ ∈ N) ∧
          fam = shifted_qm_fmcs N h_N Sigma s } :=
      ⟨v.formulas, v.is_mcs, t, fun ψ => h_equiv ψ, rfl⟩
    have h_phi_v_t := h_all (shifted_qm_fmcs v.formulas v.is_mcs Sigma t) h_fam_v_mem
    have h_mcs_eq := shifted_qm_fmcs_at_s v.formulas v.is_mcs Sigma t
    rw [h_mcs_eq] at h_phi_v_t
    exact set_consistent_not_both v.is_mcs.1 φ h_phi_v_t h_neg_phi_v
  eval_family := shifted_qm_fmcs M₀ h₀ Sigma 0
  eval_family_mem := ⟨M₀, h₀, 0, fun _ => Iff.rfl, rfl⟩

/-- Oracle chain Until-defect propagation: if φ U ψ ∈ qm_fwd_chain(n) and ψ ∉ qm_fwd_chain(n)
    and φ U ψ ∈ Sigma, then φ U ψ ∈ qm_fwd_chain(n+1). -/
theorem qm_fwd_chain_until_propagates (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (Sigma : Finset Formula) (n : Nat) (φ ψ : Formula)
    (h_until : Formula.untl φ ψ ∈ (qm_fwd_chain M₀ h₀ Sigma n).formulas)
    (h_not_psi : ψ ∉ (qm_fwd_chain M₀ h₀ Sigma n).formulas)
    (h_sigma : Formula.untl φ ψ ∈ Sigma) :
    Formula.untl φ ψ ∈ (qm_fwd_chain M₀ h₀ Sigma (n + 1)).formulas :=
  Quasimodel.qm_oracle_step_until_in_next
    (qm_fwd_chain M₀ h₀ Sigma n) Sigma h_until h_not_psi h_sigma

/-- Until-defect persistence: if φ U ψ ∈ qm_fwd_chain(m) and ψ ∉ qm_fwd_chain at any step
    in [m, n], and φ U ψ ∈ Sigma, then φ U ψ ∈ qm_fwd_chain(n). -/
theorem qm_fwd_chain_until_persists (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (Sigma : Finset Formula) {m n : Nat} (h : m ≤ n) (φ ψ : Formula)
    (h_sigma : Formula.untl φ ψ ∈ Sigma)
    (h_until : Formula.untl φ ψ ∈ (qm_fwd_chain M₀ h₀ Sigma m).formulas)
    (h_no_witness : ∀ k, m ≤ k → k ≤ n → ψ ∉ (qm_fwd_chain M₀ h₀ Sigma k).formulas) :
    Formula.untl φ ψ ∈ (qm_fwd_chain M₀ h₀ Sigma n).formulas := by
  induction n with
  | zero =>
    have : m = 0 := Nat.eq_zero_of_le_zero h; subst this
    exact h_until
  | succ n ih =>
    rcases Nat.eq_or_lt_of_le h with rfl | h_lt
    · exact h_until
    · have h_le : m ≤ n := Nat.lt_succ_iff.mp h_lt
      have h_not_psi_n : ψ ∉ (qm_fwd_chain M₀ h₀ Sigma n).formulas :=
        h_no_witness n h_le (Nat.le_succ n)
      have h_until_n : Formula.untl φ ψ ∈ (qm_fwd_chain M₀ h₀ Sigma n).formulas :=
        ih h_le (fun k hk1 hk2 => h_no_witness k hk1 (Nat.le_trans hk2 (Nat.le_succ n)))
      exact qm_fwd_chain_until_propagates M₀ h₀ Sigma n φ ψ h_until_n h_not_psi_n h_sigma

/-! ## Restricted Temporal Coherence for qm_bfmcs

Key theorem: `qm_bfmcs_restricted_tc` proves that for formulas in deferralClosure(root),
F-eventualities are eventually realized in the oracle chain.

The proof for the forward direction (F(φ) ∈ mcs(t) → ∃ s > t, φ ∈ mcs(s)) requires
showing that the oracle step eventually resolves F-obligations. This is the hardest
part: F(φ) is not an Until formula, so the oracle seed does not directly include it.

The correct proof requires:
1. By BX12: F(φ) → (⊤ U φ), so ⊤ U φ ∈ mcs(t).
2. ⊤ U φ is an Until-defect at mcs(t) if φ ∉ mcs(t).
3. If ⊤ U φ ∈ Sigma (which follows from φ ∈ deferralClosure(root) ⊆ sigma_list = Sigma.toList),
   then by qm_fwd_chain_until_persists, ⊤ U φ persists in the chain.
4. Until-defect persistence + eventuality resolution gives φ at some finite step.

SORRY: The complete proof of step 4 (finding the witness step) requires the quasimodel
chain existence theorem (hintikka_chain_exists), which needs defect_count to decrease.
The defect count decrease for ⊤ U φ under the oracle step is sorry'd in OracleStep.lean.
-/

/-- F-obligation persistence via F(φ) → ⊤ U φ (BX12).
    If F(φ) ∈ M and ⊤ U φ ∈ Sigma, then ⊤ U φ is an Until-defect at M when φ ∉ M. -/
theorem F_phi_gives_top_until_defect {M : Set Formula} (h_mcs : SetMaximalConsistent M)
    (φ : Formula) (h_F : Formula.some_future φ ∈ M) (h_not_phi : φ ∉ M) :
    Formula.untl (Formula.bot.imp Formula.bot) φ ∈ M := by
  have h_ax := DerivationTree.axiom [] _ (Axiom.F_until_equiv φ)
  exact SetMaximalConsistent.implication_property h_mcs (theorem_in_mcs h_mcs h_ax) h_F

/-- Restricted temporal coherence for qm_bfmcs.

The forward direction (F(φ) → eventual φ) relies on:
- BX12 gives ⊤ U φ ∈ mcs(t)
- Oracle step propagates Until defects
- defect_count decrease eventually forces resolution

The defect_count decrease for general Until-defects is sorry'd because the oracle
Lindenbaum extension may introduce new Until-defects. Closing this sorry requires
proving that the oracle step is "defect-monotone" for defects in Sigma.
-/
theorem qm_bfmcs_restricted_tc (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (Sigma : Finset Formula) (root : Formula)
    (h_sub : ∀ ψ, ψ ∈ deferralClosure root → Formula.untl (Formula.bot.imp Formula.bot) ψ ∈ Sigma) :
    (qm_bfmcs M₀ h₀ Sigma).restricted_temporally_coherent root := by
  intro fam hfam
  obtain ⟨N, h_N, s, _h_eqN, rfl⟩ := hfam
  constructor
  · -- Forward: F(φ) ∈ fam.mcs t → ∃ u > t, φ ∈ fam.mcs u
    -- fam = shifted_qm_fmcs N h_N Sigma s, so fam.mcs t = qm_chain N h_N Sigma (t - s)
    intro t φ h_phi_dc h_F
    -- SORRY: The complete proof requires showing that the oracle chain eventually resolves
    -- F-obligations. The argument via BX12 + Until-defect persistence would need
    -- defect_count decrease under oracle steps, which is sorry'd in OracleStep.lean.
    -- The formal gap: qm_oracle_step_until_in_next propagates defects forward, but
    -- hintikka_chain_exists needs defect_count to strictly decrease to terminate.
    exact sorry
  · -- Backward: P(φ) ∈ fam.mcs t → ∃ u < t, φ ∈ fam.mcs u
    intro t φ h_phi_dc h_P
    -- Symmetric to the forward case, using the backward oracle chain.
    -- SORRY: Same defect_count decrease gap as in the forward direction.
    exact sorry

/-- Restricted backward until/since coherence for qm_bfmcs.

The backward direction requires the step transfer:
  φ U ψ ∈ mcs(r+1) ∧ φ ∈ mcs(r) → φ U ψ ∈ mcs(r)

This step is provable when φ U ψ ∈ Sigma and the oracle chain propagates Until defects:
- If φ U ψ ∈ mcs(r) (i.e., it was a defect at step r), the oracle seed contains it → ✓
- If φ U ψ ∉ mcs(r): need φ U ψ ∈ mcs(r) from φ ∈ mcs(r) and φ U ψ ∈ mcs(r+1)

For the "φ U ψ ∉ mcs(r)" case:
- By BX4': H(F(φ U ψ)) ∈ mcs(r+1)
- By h_content: F(φ U ψ) ∈ mcs(r)
- Need: φ ∧ F(φ U ψ) → φ U ψ (NOT derivable in BX -- semantically invalid)

SORRY: The step transfer is NOT provable for the oracle chain. This is a fundamental
gap: φ ∧ F(φ U ψ) → φ U ψ is semantically invalid (counterexample: φ@t, φ U ψ absent @t,
φ U ψ @t+1 but ¬φ @t+1 and ψ @t+2). No BX axiom closes this gap.

Alternative proof strategy for a modified chain where Until formulas are preserved
backward: use an "enriched" oracle seed that also includes backward projections of
Until formulas. This would require a more complex construction.
-/
theorem qm_bfmcs_restricted_buc (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (Sigma : Finset Formula) (root : Formula) :
    (qm_bfmcs M₀ h₀ Sigma).restricted_backward_until_since_coherent root := by
  intro fam hfam
  obtain ⟨N, h_N, s, _h_eqN, rfl⟩ := hfam
  constructor
  · -- Backward Until: witness gives φ U ψ
    intro t φ ψ _h_sigma ⟨u, h_le, h_psi, h_guard⟩
    -- Induction on u - t using backward_until_from_step.
    -- The step transfer φ U ψ ∈ mcs(r+1) ∧ φ ∈ mcs(r) → φ U ψ ∈ mcs(r) is SORRY'd.
    apply backward_until_from_step (shifted_qm_fmcs N h_N Sigma s) φ ψ
      (fun r h_U_next h_phi_r => ?_) t u h_le h_psi h_guard
    -- Step transfer goal: show φ U ψ ∈ mcs(r) from φ U ψ ∈ mcs(r+1) and φ ∈ mcs(r)
    -- SORRY: Semantically invalid step. See docstring above.
    exact sorry
  · -- Backward Since: witness gives φ S ψ
    intro t φ ψ _h_sigma ⟨u, h_le, h_psi, h_guard⟩
    -- Symmetric to Until case.
    apply backward_since_from_step (shifted_qm_fmcs N h_N Sigma s) φ ψ
      (fun r h_S_prev h_phi_r => ?_) t u h_le h_psi h_guard
    -- Step transfer goal: show φ S ψ ∈ mcs(r) from φ S ψ ∈ mcs(r-1) and φ ∈ mcs(r)
    -- SORRY: Symmetric semantically invalid step.
    exact sorry

/-- Restricted forward until/since coherence for qm_bfmcs.

The forward Until coherence requires: φ U ψ ∈ mcs(t) → ∃ s ≥ t, ψ ∈ mcs(s) with guard.

The proof:
1. By BX10: F(ψ) ∈ mcs(t)
2. By restricted_tc (forward): ∃ u > t with ψ ∈ mcs(u) [but restricted_tc is also sorry'd]
3. Guard: for r ∈ [t, u), by oracle chain propagation, φ U ψ persists (being a defect)
4. At each step r where ψ ∉ mcs(r), by BX9: φ ∨ ψ ∈ mcs(r). Since ψ ∉ mcs(r), φ ∈ mcs(r).

Steps 3-4 would give the guard without additional sorries IF step 2 is available.
But step 2 depends on restricted_tc which is sorry'd.

SORRY: Depends on restricted_tc (sorry'd) for the witness existence.
Also the guard argument (step 4) is valid given oracle step propagation.
-/
theorem qm_bfmcs_restricted_fuc (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (Sigma : Finset Formula) (root : Formula) :
    (qm_bfmcs M₀ h₀ Sigma).restricted_forward_until_since_coherent root := by
  intro fam hfam
  obtain ⟨N, h_N, s, _h_eqN, rfl⟩ := hfam
  constructor
  · -- Forward Until: φ U ψ → witness
    intro t φ ψ _h_sigma h_untl
    -- We have φ U ψ ∈ fam.mcs t = qm_chain N h_N Sigma (t - s)
    -- SORRY: requires restricted_tc (sorry'd above) to find witness u
    exact sorry
  · -- Forward Since: φ S ψ → witness
    intro t φ ψ _h_sigma h_snce
    -- Symmetric.
    exact sorry

end Bimodal.Metalogic.BXCanonical
