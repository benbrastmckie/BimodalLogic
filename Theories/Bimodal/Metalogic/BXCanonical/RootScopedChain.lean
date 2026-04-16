import Bimodal.Metalogic.BXCanonical.OrderedSeedConsistency
import Bimodal.Metalogic.BXCanonical.CanonicalModel
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

/-! ## Round-Robin Forward Step

At each forward step n, resolve schedule[n % k] if it has an F-obligation,
otherwise use the enriched non-resolving seed (g_content ∪ f_carry).
Always include modal_fix(M₀) in the seed for box stability.
-/

/-- The enriched forward step seed: {target} ∪ g_content(M) ∪ f_carry(M) ∪ modal_fix(M₀)
when F(target) ∈ M, or g_content(M) ∪ f_carry(M) ∪ modal_fix(M₀) otherwise. -/
noncomputable def rr_fwd_seed (M M₀ : Set Formula) (h_mcs : SetMaximalConsistent M)
    (h₀ : SetMaximalConsistent M₀) (target : Formula) : Set Formula :=
  if Formula.some_future target ∈ M then
    {target} ∪ g_content M ∪ f_carry M ∪ modal_fix M₀
  else
    g_content M ∪ f_carry M ∪ modal_fix M₀

/-- The non-resolving seed g_content(M) ∪ f_carry(M) ∪ modal_fix(M₀) is consistent
when M is MCS and modal_fix(M₀) ⊆ M. -/
theorem rr_nonresolving_seed_consistent {M M₀ : Set Formula}
    (h_mcs : SetMaximalConsistent M) (h₀ : SetMaximalConsistent M₀)
    (h_modal : modal_fix M₀ ⊆ M) :
    SetConsistent (g_content M ∪ f_carry M ∪ modal_fix M₀) := by
  have h_sub : g_content M ∪ f_carry M ∪ modal_fix M₀ ⊆ M := by
    apply Set.union_subset
    · exact Set.union_subset
        (fun φ hφ => SetMaximalConsistent.implication_property h_mcs
          (theorem_in_mcs h_mcs (DerivationTree.axiom [] _ (Axiom.temp_t_future φ))) hφ)
        (f_carry_subset M)
    · exact h_modal
  intro L hL hd
  exact h_mcs.1 L (fun φ hφ => h_sub (hL φ hφ)) hd

/-! ## Round-Robin Chain Using Existing Infrastructure

Use the existing `fwd_succ` and `bwd_pred` from CanonicalModel.lean.
These already handle:
- Resolving steps: {target} ∪ g_content(M) (if F(target) ∈ M)
- Non-resolving steps: g_content(M) ∪ f_carry(M) (otherwise)

The key insight for forward_F: F(ψ) ∈ chain(t) with ψ in sigma_list.
Within k = |sigma_list| steps, ψ gets scheduled. If F(ψ) survives to that
step (preserved at non-resolving steps via f_carry), then ψ gets resolved.

If F(ψ) is lost at an intervening resolving step (for some other target χ):
then G(¬ψ) ∈ chain(s) for some s > t. F(ψ) never returns. ψ is never resolved.
But forward_F requires ψ ∈ chain(s') for some s' > t. ψ ∉ chain(s') for any s'.
CONTRADICTION? No — forward_F at chain(t) requires this only when F(ψ) ∈ chain(t).
The fact that F(ψ) is lost later doesn't affect the obligation at time t.
We need ψ ∈ chain(s') for SOME s' > t. If F(ψ) is lost at step s (resolving
step for χ), then we need ψ ∈ chain(s') for s' between t and s.
F(ψ) ∈ chain(t), chain(t+1), ..., chain(s-1) (preserved at non-resolving steps).
At step s: F(ψ) is lost. But ψ might have been scheduled between t and s.
If ψ was scheduled at step m (t < m < s): F(ψ) ∈ chain(m), so resolving step,
ψ ∈ chain(m+1). Witness found!

But what if ψ was NOT scheduled between t and s? Then F(ψ) survived all non-resolving
steps but was lost at step s (a resolving step for some other χ).

At the resolving step s for χ: F(χ) ∈ chain(s). The seed is {χ} ∪ g_content(chain(s)).
F(ψ) ∈ chain(s) but F(ψ) ∉ seed. So F(ψ) might not be in chain(s+1).
If F(ψ) ∉ chain(s+1): G(¬ψ) ∈ chain(s+1). ψ ∉ chain(s') for all s' > s.
No witness for forward_F at t.

THE PROBLEM REMAINS: resolving steps for OTHER formulas can permanently destroy
F(ψ), and if ψ wasn't scheduled between t and s, we have no witness.

The round-robin schedule visits each formula every k steps. But between two
visits of ψ, there can be resolving steps for OTHER formulas that destroy F(ψ).

SOLUTION FROM TEAM LEAD: The BX11 fold at each resolving step folds ALL formulas
in sigma, not just the target. The fold compound includes F(ψ) (protected).
Then F(F(ψ)) → F(ψ) ensures F(ψ) persists through the step.

But the SEED at a resolving step only includes {target} ∪ g_content(M).
The fold compound is NOT in the seed. We'd need to CHANGE the seed to include
the fold result.

THIS is the enriched seed approach. At each resolving step:
seed = {target, fold_rest} ∪ g_content(M)
where fold_rest is the BX11 fold of all remaining F-defects.

Consistency: F(target ∧ fold_rest) ∈ M by BX11 fold.
enriched_resolving_seed_consistent gives the seed is consistent.

Let me implement this. At each step:
1. Compute all F-formulas in sigma that are in M
2. BX11 fold them into F(β) ∈ M
3. Use enriched_resolving_seed_consistent to build seed {target, rest} ∪ g_content(M)
4. Lindenbaum extend

The target is the formula being resolved at this step. The rest is the other
formulas' F-conjunction.

Actually, the fold gives us F(target ∧ rest_compound) ∈ M. We peel: get M' with
target ∈ M' and rest_compound ∈ M'. From rest_compound ∈ M', by conjunction
elimination and FF_imp_F, all other F(ψ) ∈ M'. So all F-formulas are preserved!

This is the correct approach. Let me implement it.
-/

/-- The round-robin schedule: cycle through formulas in a list. -/
def rrSchedule (L : List Formula) (n : Nat) : Formula :=
  if h : L.length > 0 then L.get ⟨n % L.length, Nat.mod_lt n h⟩
  else Formula.bot  -- dummy for empty list

/-- The round-robin schedule always returns an element of the list. -/
theorem rrSchedule_mem (L : List Formula) (n : Nat) (h : L.length > 0) :
    rrSchedule L n ∈ L := by
  simp only [rrSchedule, dif_pos h]
  exact List.getElem_mem (Nat.mod_lt n h)

/-- For any ψ ∈ L, there exists a visit step m > n where rrSchedule L m = ψ.
This follows from the modular arithmetic of the round-robin schedule. -/
theorem rrSchedule_visits (L : List Formula) (n : Nat) (ψ : Formula)
    (h_len : L.length > 0) (hψ : ψ ∈ L) :
    ∃ m : Nat, n < m ∧ rrSchedule L m = ψ := by
  obtain ⟨j, hj_lt, hj_eq⟩ := List.getElem_of_mem hψ
  -- Take m = (n + 1) * L.length + j. Then m > n and m % L.length = j.
  refine ⟨(n + 1) * L.length + j, ?_, ?_⟩
  · -- (n + 1) * L.length + j > n
    have : n + 1 ≤ (n + 1) * L.length := Nat.le_mul_of_pos_right _ h_len
    omega
  · -- rrSchedule L ((n + 1) * L.length + j) = ψ
    unfold rrSchedule
    simp only [dif_pos h_len]
    have h_mod : ((n + 1) * L.length + j) % L.length = j := by
      rw [Nat.mul_comm]
      rw [Nat.mul_add_mod_self_left]
      exact Nat.mod_eq_of_lt hj_lt
    simp only [h_mod, List.get_eq_getElem, hj_eq]

/-- Enriched forward step: at a resolving step, use resolving_enriched_fwd_exists
to protect ALL F-formulas from sigma_list AND guarantee at least one defect is
resolved. At a non-resolving step, use the standard fwd_succ (which preserves
f_carry). -/
noncomputable def enriched_fwd_step (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (target : Formula) (sigma_list : List Formula) : Set Formula :=
  if h_F : Formula.some_future target ∈ M then
    let others := sigma_list.filter (fun χ => decide (Formula.some_future χ ∈ M))
    (resolving_enriched_fwd_exists h_mcs target h_F others (by
      intro χ hχ; exact of_decide_eq_true ((List.mem_filter.mp hχ).2))).choose
  else
    fwd_succ M h_mcs target

private theorem enriched_fwd_step_spec (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (target : Formula) (sigma_list : List Formula) (h_F : Formula.some_future target ∈ M) :
    let others := sigma_list.filter (fun χ => decide (Formula.some_future χ ∈ M))
    let M' := enriched_fwd_step M h_mcs target sigma_list
    SetMaximalConsistent M' ∧
    g_content M ⊆ M' ∧
    (target ∈ M' ∨ Formula.some_future target ∈ M') ∧
    (∀ χ, χ ∈ others → (χ ∈ M' ∨ Formula.some_future χ ∈ M')) ∧
    (∃ w, (w = target ∨ w ∈ others) ∧ Formula.some_future w ∈ M ∧ w ∈ M') := by
  simp only [enriched_fwd_step, dif_pos h_F]
  exact (resolving_enriched_fwd_exists h_mcs target h_F
    (sigma_list.filter (fun χ => decide (Formula.some_future χ ∈ M))) (by
    intro χ hχ; exact of_decide_eq_true ((List.mem_filter.mp hχ).2))).choose_spec

theorem enriched_fwd_step_mcs (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (target : Formula) (sigma_list : List Formula) :
    SetMaximalConsistent (enriched_fwd_step M h_mcs target sigma_list) := by
  unfold enriched_fwd_step; split
  · exact (resolving_enriched_fwd_exists h_mcs target ‹_›
      (sigma_list.filter (fun χ => decide (Formula.some_future χ ∈ M))) (by
      intro χ hχ; exact of_decide_eq_true ((List.mem_filter.mp hχ).2))).choose_spec.1
  · exact fwd_succ_mcs M h_mcs target

theorem enriched_fwd_step_g_content (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (target : Formula) (sigma_list : List Formula) :
    g_content M ⊆ enriched_fwd_step M h_mcs target sigma_list := by
  unfold enriched_fwd_step; split
  · exact (resolving_enriched_fwd_exists h_mcs target ‹_›
      (sigma_list.filter (fun χ => decide (Formula.some_future χ ∈ M))) (by
      intro χ hχ; exact of_decide_eq_true ((List.mem_filter.mp hχ).2))).choose_spec.2.1
  · exact fwd_succ_g_content M h_mcs target

/-- The key property: at a resolving step, each formula from sigma_list
with F(χ) ∈ M has either χ ∈ M' or F(χ) ∈ M'. -/
theorem enriched_fwd_step_preserves (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (target : Formula) (sigma_list : List Formula)
    (χ : Formula) (hχ_mem : χ ∈ sigma_list) (hFχ : Formula.some_future χ ∈ M) :
    χ ∈ enriched_fwd_step M h_mcs target sigma_list ∨
    Formula.some_future χ ∈ enriched_fwd_step M h_mcs target sigma_list := by
  unfold enriched_fwd_step; split
  case isTrue h_F =>
    have h_spec := (resolving_enriched_fwd_exists h_mcs target h_F
      (sigma_list.filter (fun ψ => decide (Formula.some_future ψ ∈ M))) (by
      intro ψ hψ; exact of_decide_eq_true ((List.mem_filter.mp hψ).2))).choose_spec
    have hχ_filtered : χ ∈ sigma_list.filter (fun ψ => decide (Formula.some_future ψ ∈ M)) := by
      exact List.mem_filter.mpr ⟨hχ_mem, decide_eq_true_eq.mpr hFχ⟩
    exact h_spec.2.2.2.1 χ hχ_filtered
  case isFalse h_not_F =>
    right; exact fwd_succ_f_carry M h_mcs target h_not_F ⟨hFχ, χ, rfl⟩

/-- At a resolving step where target ∈ sigma_list, at least one formula with
F-obligation is directly resolved (present in M', not just F-protected). -/
theorem enriched_fwd_step_resolves_one (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (target : Formula) (sigma_list : List Formula)
    (h_target_mem : target ∈ sigma_list)
    (h_F : Formula.some_future target ∈ M) :
    ∃ w, w ∈ sigma_list ∧ Formula.some_future w ∈ M ∧
      w ∈ enriched_fwd_step M h_mcs target sigma_list := by
  have h_spec := enriched_fwd_step_spec M h_mcs target sigma_list h_F
  obtain ⟨w, h_w_origin, h_w_F, h_w_in⟩ := h_spec.2.2.2.2
  refine ⟨w, ?_, h_w_F, h_w_in⟩
  rcases h_w_origin with rfl | h_in_others
  · exact h_target_mem
  · exact (List.mem_filter.mp h_in_others).1

/-- Forward step with BX11 fold protection.
At each step, the enriched seed protects all F-formulas from sigma_list. -/
noncomputable def rr_fwd_chain (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (sigma_list : List Formula) : (n : Nat) → { M : Set Formula // SetMaximalConsistent M }
  | 0 => ⟨M₀, h₀⟩
  | n + 1 =>
    let ⟨M, hM⟩ := rr_fwd_chain M₀ h₀ sigma_list n
    let target := rrSchedule sigma_list n
    ⟨enriched_fwd_step M hM target sigma_list,
     enriched_fwd_step_mcs M hM target sigma_list⟩

/-- Backward step symmetric. -/
noncomputable def rr_bwd_chain (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (sigma_list : List Formula) : (n : Nat) → { M : Set Formula // SetMaximalConsistent M }
  | 0 => ⟨M₀, h₀⟩
  | n + 1 =>
    let ⟨M, hM⟩ := rr_bwd_chain M₀ h₀ sigma_list n
    let target := rrSchedule sigma_list n
    ⟨bwd_pred M hM target, bwd_pred_mcs M hM target⟩

/-- Int-indexed chain assembly. -/
noncomputable def dd_chain (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (sigma_list : List Formula) (t : Int) : Set Formula :=
  if t ≥ 0 then (rr_fwd_chain M₀ h₀ sigma_list t.toNat).val
  else (rr_bwd_chain M₀ h₀ sigma_list ((-t).toNat)).val

theorem dd_chain_zero (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (sigma_list : List Formula) : dd_chain M₀ h₀ sigma_list 0 = M₀ := by
  simp [dd_chain, rr_fwd_chain]

theorem dd_chain_mcs (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (sigma_list : List Formula) (t : Int) :
    SetMaximalConsistent (dd_chain M₀ h₀ sigma_list t) := by
  simp only [dd_chain]; split
  · exact (rr_fwd_chain M₀ h₀ sigma_list t.toNat).property
  · exact (rr_bwd_chain M₀ h₀ sigma_list ((-t).toNat)).property

/-! ## g_content propagation

The forward chain has g_content(chain(n)) ⊆ chain(n+1) at each step
(from fwd_succ_g_content). The backward chain has h_content(chain(n)) ⊆ chain(n+1)
(from bwd_pred_h_content). These are the SAME as in the existing int_chain.
-/

theorem rr_fwd_chain_g_content_step (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (sigma_list : List Formula) (n : Nat) :
    g_content (rr_fwd_chain M₀ h₀ sigma_list n).val ⊆
      (rr_fwd_chain M₀ h₀ sigma_list (n + 1)).val := by
  show g_content (rr_fwd_chain M₀ h₀ sigma_list n).val ⊆
    enriched_fwd_step (rr_fwd_chain M₀ h₀ sigma_list n).val
      (rr_fwd_chain M₀ h₀ sigma_list n).property (rrSchedule sigma_list n) sigma_list
  exact enriched_fwd_step_g_content _ _ _ _

-- Transitive g_content propagation (same proof as fwd_chain_g_content_trans)
theorem rr_fwd_chain_g_content_trans (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (sigma_list : List Formula) {m n : Nat} (h : m ≤ n) :
    g_content (rr_fwd_chain M₀ h₀ sigma_list m).val ⊆
      (rr_fwd_chain M₀ h₀ sigma_list n).val := by
  induction n with
  | zero =>
    have : m = 0 := Nat.eq_zero_of_le_zero h; subst this
    intro φ hφ; exact SetMaximalConsistent.implication_property
      (rr_fwd_chain M₀ h₀ sigma_list 0).property
      (theorem_in_mcs (rr_fwd_chain M₀ h₀ sigma_list 0).property
        (DerivationTree.axiom [] _ (Axiom.temp_t_future φ))) hφ
  | succ n ih =>
    rcases Nat.eq_or_lt_of_le h with rfl | h_lt
    · exact fun φ hφ => SetMaximalConsistent.implication_property
        (rr_fwd_chain M₀ h₀ sigma_list (n + 1)).property
        (theorem_in_mcs (rr_fwd_chain M₀ h₀ sigma_list (n + 1)).property
          (DerivationTree.axiom [] _ (Axiom.temp_t_future φ))) hφ
    · intro φ hφ
      have h_GG := SetMaximalConsistent.all_future_all_future
        (rr_fwd_chain M₀ h₀ sigma_list m).property hφ
      exact rr_fwd_chain_g_content_step M₀ h₀ sigma_list n
        (ih (Nat.lt_succ_iff.mp h_lt) h_GG)

-- Backward chain h_content propagation
theorem rr_bwd_chain_h_content_step (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (sigma_list : List Formula) (n : Nat) :
    h_content (rr_bwd_chain M₀ h₀ sigma_list n).val ⊆
      (rr_bwd_chain M₀ h₀ sigma_list (n + 1)).val := by
  show h_content (rr_bwd_chain M₀ h₀ sigma_list n).val ⊆
    bwd_pred (rr_bwd_chain M₀ h₀ sigma_list n).val
      (rr_bwd_chain M₀ h₀ sigma_list n).property (rrSchedule sigma_list n)
  exact bwd_pred_h_content _ _ _

theorem rr_bwd_chain_h_content_trans (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (sigma_list : List Formula) {m n : Nat} (h : m ≤ n) :
    h_content (rr_bwd_chain M₀ h₀ sigma_list m).val ⊆
      (rr_bwd_chain M₀ h₀ sigma_list n).val := by
  induction n with
  | zero =>
    have : m = 0 := Nat.eq_zero_of_le_zero h; subst this
    intro φ hφ; exact SetMaximalConsistent.implication_property
      (rr_bwd_chain M₀ h₀ sigma_list 0).property
      (theorem_in_mcs (rr_bwd_chain M₀ h₀ sigma_list 0).property
        (DerivationTree.axiom [] _ (Axiom.temp_t_past φ))) hφ
  | succ n ih =>
    rcases Nat.eq_or_lt_of_le h with rfl | h_lt
    · exact fun φ hφ => SetMaximalConsistent.implication_property
        (rr_bwd_chain M₀ h₀ sigma_list (n + 1)).property
        (theorem_in_mcs (rr_bwd_chain M₀ h₀ sigma_list (n + 1)).property
          (DerivationTree.axiom [] _ (Axiom.temp_t_past φ))) hφ
    · intro φ hφ
      have h_HH := SetMaximalConsistent.all_past_all_past
        (rr_bwd_chain M₀ h₀ sigma_list m).property hφ
      exact rr_bwd_chain_h_content_step M₀ h₀ sigma_list n
        (ih (Nat.lt_succ_iff.mp h_lt) h_HH)

-- Full Int-indexed g_content propagation (same structure as int_chain_g_content)
theorem dd_chain_g_content (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (sigma_list : List Formula) {t t' : Int} (h_le : t ≤ t') :
    g_content (dd_chain M₀ h₀ sigma_list t) ⊆ dd_chain M₀ h₀ sigma_list t' := by
  simp only [dd_chain]
  split_ifs with ht ht'
  · exact rr_fwd_chain_g_content_trans M₀ h₀ sigma_list (Int.toNat_le_toNat h_le)
  · omega
  · intro χ hχ
    have h_G_in_bwd := hχ
    have h_GG := SetMaximalConsistent.all_future_all_future
      (rr_bwd_chain M₀ h₀ sigma_list ((-t).toNat)).property h_G_in_bwd
    have h_G_in_M0 : Formula.all_future χ ∈ M₀ := by
      have : g_content (rr_bwd_chain M₀ h₀ sigma_list ((-t).toNat)).val ⊆
          (rr_bwd_chain M₀ h₀ sigma_list 0).val :=
        h_content_subset_implies_g_content_reverse
          (rr_bwd_chain M₀ h₀ sigma_list 0).val
          (rr_bwd_chain M₀ h₀ sigma_list ((-t).toNat)).val
          (rr_bwd_chain M₀ h₀ sigma_list 0).property
          (rr_bwd_chain M₀ h₀ sigma_list ((-t).toNat)).property
          (rr_bwd_chain_h_content_trans M₀ h₀ sigma_list (Nat.zero_le _))
      simp [rr_bwd_chain] at this
      exact this h_GG
    exact rr_fwd_chain_g_content_trans M₀ h₀ sigma_list (Nat.zero_le _) h_G_in_M0
  · exact (h_content_subset_implies_g_content_reverse
      (rr_bwd_chain M₀ h₀ sigma_list ((-t').toNat)).val
      (rr_bwd_chain M₀ h₀ sigma_list ((-t).toNat)).val
      (rr_bwd_chain M₀ h₀ sigma_list ((-t').toNat)).property
      (rr_bwd_chain M₀ h₀ sigma_list ((-t).toNat)).property
      (rr_bwd_chain_h_content_trans M₀ h₀ sigma_list (by omega)))

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
  simp [dd_chain, rr_fwd_chain]

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

/-- Defect list: formulas from sigma_list that have F-obligations in M. -/
noncomputable def activeDefects (M : Set Formula) (sigma_list : List Formula) : List Formula :=
  sigma_list.filter (fun ψ => Formula.some_future ψ ∈ M)

/-- Every element of activeDefects has an F-obligation. -/
theorem activeDefects_F_mem {M : Set Formula} {sigma_list : List Formula}
    {ψ : Formula} (h : ψ ∈ activeDefects M sigma_list) :
    Formula.some_future ψ ∈ M := by
  simp only [activeDefects, List.mem_filter, decide_eq_true_eq] at h
  exact h.2

/-- Every element of activeDefects is in sigma_list. -/
theorem activeDefects_mem_sigma {M : Set Formula} {sigma_list : List Formula}
    {ψ : Formula} (h : ψ ∈ activeDefects M sigma_list) :
    ψ ∈ sigma_list := by
  simp only [activeDefects, List.mem_filter] at h
  exact h.1

/-- The discharge forward chain: iterate enriched_fwd_step for sigma_list.length steps,
then use identity (repeat terminal MCS). This is structurally the same as
rr_fwd_chain but with the important property that each step uses the enriched
seed that protects ALL F-formulas from sigma_list.

The chain is indexed by Nat: chain(0) = M₀, chain(n+1) = enriched_fwd_step(chain(n)).
The schedule cycles through sigma_list formulas as targets.
After sigma_list.length steps (one full cycle), every formula has been the target
at least once. The identity tail just repeats the terminal state. -/
noncomputable def discharge_fwd_chain (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (sigma_list : List Formula) :
    (n : Nat) → { M : Set Formula // SetMaximalConsistent M } :=
  rr_fwd_chain M₀ h₀ sigma_list

/-- The discharge chain has g_content propagation at each step. -/
theorem discharge_fwd_chain_g_content_step (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (sigma_list : List Formula) (n : Nat) :
    g_content (discharge_fwd_chain M₀ h₀ sigma_list n).val ⊆
      (discharge_fwd_chain M₀ h₀ sigma_list (n + 1)).val :=
  rr_fwd_chain_g_content_step M₀ h₀ sigma_list n

/-- The discharge chain has transitive g_content propagation. -/
theorem discharge_fwd_chain_g_content_trans (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (sigma_list : List Formula) {m n : Nat} (h : m ≤ n) :
    g_content (discharge_fwd_chain M₀ h₀ sigma_list m).val ⊆
      (discharge_fwd_chain M₀ h₀ sigma_list n).val :=
  rr_fwd_chain_g_content_trans M₀ h₀ sigma_list h

/-! ## φ → F(φ) and F-obligation constancy -/

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

/-- Strengthened target resolution: when target is bx11_earlier than all others,
the successor M' has target directly resolved AND all other F-obligations
preserved (not just disjunctively). -/
theorem target_resolving_fwd_exists_strong {M : Set Formula} (h_mcs : SetMaximalConsistent M)
    (target : Formula) (h_F_target : Formula.some_future target ∈ M)
    (others : List Formula) (h_F_others : ∀ χ, χ ∈ others → Formula.some_future χ ∈ M)
    (h_earliest : ∀ χ, χ ∈ others → bx11_earlier M target χ) :
    ∃ M' : Set Formula, SetMaximalConsistent M' ∧
      g_content M ⊆ M' ∧ target ∈ M' ∧
      (∀ χ, χ ∈ others → Formula.some_future χ ∈ M') := by
  obtain ⟨M', h_mcs', h_g, h_target, h_others⟩ :=
    target_stays_direct_in_fold h_mcs target h_F_target others h_F_others h_earliest
  refine ⟨M', h_mcs', h_g, h_target, fun χ hχ => ?_⟩
  rcases h_others χ hχ with h_direct | h_F
  · exact phi_in_mcs_imp_F_phi h_mcs' χ h_direct
  · exact h_F

/-- F-obligation persistence: F(ψ) ∈ chain(n) → F(ψ) ∈ chain(n+1).
Combines enriched_fwd_step_preserves (F(ψ) ∈ M → ψ ∈ M' ∨ F(ψ) ∈ M')
with phi_in_mcs_imp_F_phi (ψ ∈ M' → F(ψ) ∈ M'). -/
theorem rr_fwd_chain_F_obligation_persists (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (sigma_list : List Formula) (n : Nat) (ψ : Formula)
    (hψ : ψ ∈ sigma_list)
    (h_F : Formula.some_future ψ ∈ (rr_fwd_chain M₀ h₀ sigma_list n).val) :
    Formula.some_future ψ ∈ (rr_fwd_chain M₀ h₀ sigma_list (n + 1)).val := by
  rcases enriched_fwd_step_preserves _ _ _ _ ψ hψ h_F with h | h
  · exact phi_in_mcs_imp_F_phi
      (rr_fwd_chain M₀ h₀ sigma_list (n + 1)).property ψ h
  · exact h

/-- F-obligation non-appearance: F(ψ) ∉ chain(n) → F(ψ) ∉ chain(n+1).
From no_new_f_defects: G(¬ψ) ∈ chain(n) implies F(ψ) ∉ chain(n+1). -/
theorem rr_fwd_chain_F_obligation_absent (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (sigma_list : List Formula) (n : Nat) (ψ : Formula)
    (h_not_F : Formula.some_future ψ ∉ (rr_fwd_chain M₀ h₀ sigma_list n).val) :
    Formula.some_future ψ ∉ (rr_fwd_chain M₀ h₀ sigma_list (n + 1)).val := by
  have h_G : Formula.all_future (Formula.neg ψ) ∈ (rr_fwd_chain M₀ h₀ sigma_list n).val := by
    rcases SetMaximalConsistent.negation_complete
      (rr_fwd_chain M₀ h₀ sigma_list n).property
      (Formula.some_future ψ) with h | h
    · exact absurd h h_not_F
    · exact SetMaximalConsistent.double_neg_elim
        (rr_fwd_chain M₀ h₀ sigma_list n).property _ h
  exact no_new_f_defects
    (rr_fwd_chain M₀ h₀ sigma_list n).property
    (rr_fwd_chain M₀ h₀ sigma_list (n + 1)).property
    (enriched_fwd_step_g_content _ _ _ _) ψ h_G

/-- F-obligation constancy (forward): F(ψ) ∈ chain(n) → F(ψ) ∈ chain(m) for all m ≥ n. -/
theorem rr_fwd_chain_F_obligation_forward (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (sigma_list : List Formula) (n m : Nat) (ψ : Formula)
    (hψ : ψ ∈ sigma_list) (h_le : n ≤ m)
    (h_F : Formula.some_future ψ ∈ (rr_fwd_chain M₀ h₀ sigma_list n).val) :
    Formula.some_future ψ ∈ (rr_fwd_chain M₀ h₀ sigma_list m).val := by
  induction m with
  | zero => exact Nat.eq_zero_of_le_zero h_le ▸ h_F
  | succ m ih =>
    rcases Nat.eq_or_lt_of_le h_le with rfl | h_lt
    · exact h_F
    · exact rr_fwd_chain_F_obligation_persists M₀ h₀ sigma_list m ψ hψ
        (ih (Nat.lt_succ_iff.mp h_lt))

/-- F-obligation constancy (backward): F(ψ) ∈ chain(m) → F(ψ) ∈ chain(n) for all n ≤ m.
Contrapositive of F_obligation_absent iterated. -/
theorem rr_fwd_chain_F_obligation_backward (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (sigma_list : List Formula) (n m : Nat) (ψ : Formula)
    (h_le : n ≤ m)
    (h_F : Formula.some_future ψ ∈ (rr_fwd_chain M₀ h₀ sigma_list m).val) :
    Formula.some_future ψ ∈ (rr_fwd_chain M₀ h₀ sigma_list n).val := by
  by_contra h_not
  suffices h_abs : ∀ k, n ≤ k →
      Formula.some_future ψ ∉ (rr_fwd_chain M₀ h₀ sigma_list k).val from
    h_abs m h_le h_F
  intro k h_nk
  induction k with
  | zero => exact Nat.eq_zero_of_le_zero h_nk ▸ h_not
  | succ k ih =>
    rcases Nat.eq_or_lt_of_le h_nk with rfl | h_lt
    · exact h_not
    · exact rr_fwd_chain_F_obligation_absent M₀ h₀ sigma_list k ψ
        (ih (Nat.lt_succ_iff.mp h_lt))

/-! ## Forward_F for the round-robin chain -/

/-- Forward F: F(ψ) ∈ chain(t) with ψ = sigma_list[j] → ∃ s > t, ψ ∈ chain(s).

The proof: ψ is visited by the schedule at step j + k*m for each m.
F(ψ) is preserved at non-resolving steps (via f_carry) and resolved at
the next resolving step for ψ. The key is that between resolving steps
for OTHER formulas, f_carry preserves F(ψ) at non-resolving steps.
At resolving steps for χ ≠ ψ: F(ψ) may be lost (this is the obstacle).

For this round-robin chain (which uses fwd_succ — the same as int_chain),
forward_F has the SAME obstacle as int_chain.

TO FIX THIS: we need to use the enriched seed at resolving steps.
This requires modifying fwd_succ to include BX11 fold protection.

Let me define a MODIFIED fwd_succ that uses the enriched seed.

F-preservation: at each forward step, F(ψ) ∈ chain(n) implies
ψ ∈ chain(n+1) or F(ψ) ∈ chain(n+1), for ψ ∈ sigma_list. -/
theorem rr_fwd_chain_F_preserved (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (sigma_list : List Formula) (n : Nat) (ψ : Formula)
    (hψ : ψ ∈ sigma_list)
    (h_F : Formula.some_future ψ ∈ (rr_fwd_chain M₀ h₀ sigma_list n).val) :
    ψ ∈ (rr_fwd_chain M₀ h₀ sigma_list (n + 1)).val ∨
    Formula.some_future ψ ∈ (rr_fwd_chain M₀ h₀ sigma_list (n + 1)).val :=
  enriched_fwd_step_preserves _ _ _ _ ψ hψ h_F

/-- F(ψ) propagates through the forward chain: if F(ψ) ∈ chain(n),
then for all m ≥ n, either ψ ∈ chain(s) for some n < s ≤ m+1,
or F(ψ) ∈ chain(m+1). -/
theorem rr_fwd_chain_F_propagate (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (sigma_list : List Formula) (n : Nat) (ψ : Formula)
    (hψ : ψ ∈ sigma_list)
    (h_F : Formula.some_future ψ ∈ (rr_fwd_chain M₀ h₀ sigma_list n).val)
    (m : Nat) (h_le : n ≤ m) :
    (∃ s : Nat, n < s ∧ s ≤ m + 1 ∧ ψ ∈ (rr_fwd_chain M₀ h₀ sigma_list s).val) ∨
    Formula.some_future ψ ∈ (rr_fwd_chain M₀ h₀ sigma_list (m + 1)).val := by
  induction m with
  | zero =>
    have : n = 0 := Nat.eq_zero_of_le_zero h_le; subst this
    rcases rr_fwd_chain_F_preserved M₀ h₀ sigma_list 0 ψ hψ h_F with h | h
    · exact Or.inl ⟨1, Nat.zero_lt_one, le_refl 1, h⟩
    · exact Or.inr h
  | succ m ih =>
    rcases Nat.eq_or_lt_of_le h_le with rfl | h_lt
    · -- n = m + 1
      rcases rr_fwd_chain_F_preserved M₀ h₀ sigma_list (m + 1) ψ hψ h_F with h | h
      · exact Or.inl ⟨m + 2, by omega, le_refl _, h⟩
      · exact Or.inr h
    · -- n < m + 1, i.e., n ≤ m
      rcases ih (Nat.lt_succ_iff.mp h_lt) with ⟨s, h_lt_s, h_le_s, h_in⟩ | h_F_m
      · exact Or.inl ⟨s, h_lt_s, by omega, h_in⟩
      · -- F(ψ) ∈ chain(m+1). Apply preservation at step m+1.
        rcases rr_fwd_chain_F_preserved M₀ h₀ sigma_list (m + 1) ψ hψ h_F_m with h | h
        · exact Or.inl ⟨m + 2, by omega, le_refl _, h⟩
        · exact Or.inr h

/- =====================================================================
   PROOF SKETCH: Goldblatt WF-Induction for forward_F
   =====================================================================

   GOAL: Prove rr_fwd_chain_forward_F:
     If F(ψ) ∈ chain(n), then ∃ s > n, ψ ∈ chain(s).

   STRATEGY: Replace the existing `rr_fwd_chain` (which uses `enriched_fwd_step`
   and round-robin scheduling) with a depth-stratified chain that uses the simple
   `fwd_succ` step. Prove forward_F by well-founded induction on `f_nesting_depth`
   within `deferralClosure(root)`.

   ─────────────────────────────────────────────────────────────────────
   1. DEFINITIONS
   ─────────────────────────────────────────────────────────────────────

   Existing infrastructure (all sorry-free):

   - `f_nesting_depth : Formula → Nat`
       Counts outermost consecutive F-operators.
       f_nesting_depth(F(F(F(p)))) = 3, f_nesting_depth(p) = 0.

   - `deferralClosure(root) : Finset Formula`
       Finite set of formulas relevant to resolution. Contains closureWithNeg(root)
       plus deferral disjunctions and seriality formulas.

   - `g_content(M) = {φ | G(φ) ∈ M}`
       Strips the G-operator. Does NOT include F-formulas.

   - `f_carry(M) = {φ ∈ M | ∃ χ, φ = F(χ)}`
       The set of F-formulas literally present in M.

   - `fwd_succ(M, ψ)`:
       RESOLVING case (F(ψ) ∈ M):
         Lindenbaum extension of {ψ} ∪ g_content(M).
         Result: ψ ∈ fwd_succ(M,ψ) AND g_content(M) ⊆ fwd_succ(M,ψ).
         NOTE: f_carry(M) is NOT included. Other F-formulas may be lost.
       NON-RESOLVING case (F(ψ) ∉ M):
         Lindenbaum extension of g_content(M) ∪ f_carry(M).
         Result: g_content(M) ⊆ result AND f_carry(M) ⊆ result.
         F-formulas are preserved but no specific formula is resolved.

   - `forward_temporal_witness_seed_consistent`:
       If F(ψ) ∈ M (MCS), then {ψ} ∪ g_content(M) is consistent.
       (Proof via generalized temporal K: inconsistency would give G(¬ψ) ∈ M,
       contradicting F(ψ) = ¬G(¬ψ) ∈ M.)

   - `enriched_seed_consistent`:
       g_content(M) ∪ f_carry(M) ⊆ M for any MCS M, hence consistent.

   - `restricted_temporal_backward_G_strict(fam, root, h_forward_F, t, φ, ...)`:
       If φ ∈ fam.mcs(s) for all s > t, AND neg(φ) ∈ deferralClosure(root),
       AND forward_F holds (as explicit hypothesis), THEN G(φ) ∈ fam.mcs(t).
       Proof: If ¬G(φ), then F(¬φ), and forward_F gives witness contradicting φ.

   ─────────────────────────────────────────────────────────────────────
   2. THE CORE OBSTRUCTION WITH THE EXISTING CHAIN
   ─────────────────────────────────────────────────────────────────────

   The existing `rr_fwd_chain` uses `enriched_fwd_step` with round-robin scheduling.
   Report 26 proves definitively that this chain CANNOT prove forward_F:

   - The BX11 fold ordering can perpetually favor formula A over formula B.
   - At every step scheduled for B, A is "bx11_earlier" and gets resolved instead.
   - B is deferred forever: F(B) persists in every chain state but B never appears.
   - This is semantically consistent (2-formula counterexample in Report 26).

   The `enriched_fwd_step` resolves ONE formula per step (the bx11-earliest),
   but this does not guarantee every formula is eventually resolved.

   ─────────────────────────────────────────────────────────────────────
   3. THE GOLDBLATT WF-INDUCTION CONSTRUCTION
   ─────────────────────────────────────────────────────────────────────

   Key insight: We do NOT need a single chain that resolves all F-defects
   simultaneously. Instead, we prove forward_F by well-founded induction on
   `f_nesting_depth(ψ)` where F(ψ) ∈ chain(n). The chain construction itself
   uses simple `fwd_succ` (not enriched), and the proof shows that each specific
   ψ gets resolved within finitely many steps.

   THEOREM (forward_F by WF-induction):
     For all ψ with F(ψ) ∈ chain(n), there exists s > n with ψ ∈ chain(s).

   Proof by strong induction on f_nesting_depth(ψ).

   ─────────────────────────────────────────────────────────────────────
   3a. BASE CASE: f_nesting_depth(ψ) = 0
   ─────────────────────────────────────────────────────────────────────

   ψ contains no outermost F-operators (e.g., ψ = p, ψ = G(q), ψ = p ∧ q).

   Given: F(ψ) ∈ chain(n).

   Construction: Apply `fwd_succ(chain(n), ψ)`.
   Since F(ψ) ∈ chain(n), this is the RESOLVING case:
     seed = {ψ} ∪ g_content(chain(n))
   By `fwd_succ_resolves`: ψ ∈ fwd_succ(chain(n), ψ).

   So if we can arrange for the chain to take a step targeting ψ at position n+1,
   we get ψ ∈ chain(n+1). Done.

   IMPORTANT: This requires the chain construction to CHOOSE ψ as the target
   at step n+1. With the depth-stratified construction (Section 4 below), this
   is achieved by scheduling ψ's resolution at a dedicated step.

   Alternatively, with ANY chain using `fwd_succ`, if at ψ's next visit step m,
   F(ψ) is still in chain(m), then ψ ∈ chain(m+1) by `fwd_succ_resolves`.
   The question is: does F(ψ) persist from chain(n) to chain(m)?

   F-PERSISTENCE ANALYSIS for the simple fwd_succ chain:
   - At NON-RESOLVING steps (F(target) ∉ chain(k)):
     f_carry(chain(k)) ⊆ chain(k+1) by `fwd_succ_f_carry`.
     So F(ψ) ∈ chain(k) implies F(ψ) ∈ chain(k+1). PRESERVED.
   - At RESOLVING steps for TARGET (F(target) ∈ chain(k)):
     seed = {target} ∪ g_content(chain(k)).
     f_carry is NOT included. F(ψ) may NOT be in chain(k+1).

   So F(ψ) can be LOST at a resolving step for a different target.

   However, if F(ψ) is lost at step k (where target ≠ ψ and F(target) ∈ chain(k)),
   then since chain(k+1) is an MCS and F(ψ) ∉ chain(k+1), we have
   ¬F(ψ) = G(¬ψ) ∈ chain(k+1). By g_content propagation, ¬ψ ∈ chain(k+2),
   ¬ψ ∈ chain(k+3), etc. -- ¬ψ persists in ALL future chain states.

   But at chain(n), F(ψ) ∈ chain(n), so ¬G(¬ψ) ∈ chain(n). For ψ to never
   appear in any future chain state, we need ¬ψ in all chain(s) for s > k.
   From g_content propagation: G(¬ψ) ∈ chain(k+1), hence ¬ψ ∈ g_content(chain(k+1)),
   hence ¬ψ propagates forward forever.

   KEY REALIZATION: This does NOT contradict F(ψ) ∈ chain(n), because chain(n)
   and chain(k+1) are DIFFERENT MCS's. F(ψ) ∈ chain(n) does not imply ψ must
   appear somewhere -- that's exactly what we're trying to prove!

   RESOLUTION: Use a DEDICATED chain for each F-defect. Instead of one chain
   with round-robin scheduling, build a per-defect chain:

   For F(ψ) ∈ M₀ (depth 0):
     Define chain_ψ(0) = M₀, chain_ψ(1) = fwd_succ(M₀, ψ).
     Since F(ψ) ∈ M₀: ψ ∈ chain_ψ(1) by `fwd_succ_resolves`.
     g_content(M₀) ⊆ chain_ψ(1) by `fwd_succ_g_content`.

   This gives a ONE-STEP RESOLUTION for each depth-0 F-defect.

   For the general chain, use `fwd_succ(chain(n), ψ)` as chain(n+1)
   (i.e., target ψ at step n), giving ψ ∈ chain(n+1) immediately.
   NO F-PERSISTENCE NEEDED for the target formula.

   ─────────────────────────────────────────────────────────────────────
   3b. INDUCTIVE CASE: f_nesting_depth(ψ) = k+1
   ─────────────────────────────────────────────────────────────────────

   IH: For all χ with f_nesting_depth(χ) ≤ k and F(χ) ∈ chain(m) for some m,
       there exists s > m with χ ∈ chain(s).

   Given: F(ψ) ∈ chain(n), f_nesting_depth(ψ) = k+1.

   Since f_nesting_depth(ψ) = k+1 ≥ 1, ψ has the form F(ψ') for some ψ'
   with f_nesting_depth(ψ') = k. (By definition of f_nesting_depth: if
   f_nesting_depth(ψ) = k+1, then ψ = F(ψ') for some ψ'.)

   So F(ψ) = F(F(ψ')).

   Step 1: By `FF_imp_F_mcs`, F(F(ψ')) ∈ chain(n) implies F(ψ') ∈ chain(n).

   Step 2: By IH (since f_nesting_depth(ψ') = k ≤ k), there exists s > n
   with ψ' ∈ chain(s).

   Step 3: ψ = F(ψ'), and ψ' ∈ chain(s).
   By `phi_in_mcs_imp_F_phi` (φ ∈ M → F(φ) ∈ M for any MCS M):
     ψ' ∈ chain(s) implies F(ψ') ∈ chain(s), i.e., ψ ∈ chain(s).

   Wait -- `phi_in_mcs_imp_F_phi` gives F(ψ') ∈ chain(s), not ψ = F(ψ') ∈ chain(s).
   But ψ = F(ψ'), so F(ψ') = ψ. Hence ψ ∈ chain(s). Done!

   Actually, let me re-examine: ψ = F(ψ'). We need ψ ∈ chain(s), i.e.,
   F(ψ') ∈ chain(s). We have ψ' ∈ chain(s). Does ψ' ∈ M imply F(ψ') ∈ M?

   YES: `phi_in_mcs_imp_F_phi` states φ ∈ M → F(φ) ∈ M.
   This follows from reflexivity of F: F(φ) = ¬G(¬φ), and the T-axiom
   G(¬φ) → ¬φ gives by contraposition φ → ¬G(¬φ) = F(φ).

   So: ψ' ∈ chain(s) → F(ψ') ∈ chain(s) → ψ ∈ chain(s). Done.

   ─────────────────────────────────────────────────────────────────────
   3c. WAIT -- THE BASE CASE NEEDS REFINEMENT
   ─────────────────────────────────────────────────────────────────────

   The argument above for the base case said "use fwd_succ(chain(n), ψ) as
   chain(n+1)." But this means the chain construction depends on which ψ we
   are trying to resolve, i.e., it is a PER-FORMULA chain, not a single chain
   for all formulas.

   For the theorem statement `rr_fwd_chain_forward_F`, the chain is already
   fixed (it's `rr_fwd_chain`). We cannot retroactively change the chain to
   target a specific ψ.

   TWO RESOLUTIONS:

   (A) REPLACE rr_fwd_chain with a new chain construction that schedules
       each F-defect at a dedicated step. The round-robin schedule already
       visits each ψ ∈ sigma_list infinitely often. At ψ's visit step m:
       - If F(ψ) ∈ chain(m): fwd_succ resolves ψ at step m+1.
       - If F(ψ) ∉ chain(m): nothing to resolve (non-resolving step).
       The question is whether F(ψ) persists from chain(n) to the next visit
       step m. As analyzed in 3a, it may not (F(ψ) can be lost).

   (B) USE A SEPARATE CHAIN for the proof, then connect back.
       For each F(ψ) ∈ chain(n), build a new chain:
         new_chain(0) = chain(n), new_chain(1) = fwd_succ(chain(n), ψ).
       Then ψ ∈ new_chain(1). But ψ ∈ new_chain(1) is NOT the same as
       ψ ∈ rr_fwd_chain(n+1). This approach does not directly close the sorry.

   (C) PROVE forward_F ABOUT A NEW CHAIN (not rr_fwd_chain), then wire
       dd_fmcs/dd_bfmcs to use the new chain instead.

   Resolution (C) is the correct approach. We:
   1. Define a NEW chain `wf_fwd_chain` using `fwd_succ` with a depth-aware
      schedule.
   2. Prove `wf_fwd_chain_forward_F` by WF-induction.
   3. Wire dd_fmcs to use `wf_fwd_chain` instead of `rr_fwd_chain`.
   4. Either re-prove `rr_fwd_chain_forward_F` by delegating to the new chain,
      or replace `rr_fwd_chain` entirely.

   ─────────────────────────────────────────────────────────────────────
   3d. REVISED BASE CASE WITH DEDICATED CHAIN
   ─────────────────────────────────────────────────────────────────────

   With the dedicated chain approach, each target gets its own 1-step extension.

   Construction of `wf_fwd_chain`:
     wf_fwd_chain(M₀, sigma_list, 0) = M₀
     wf_fwd_chain(M₀, sigma_list, n+1) =
       fwd_succ(wf_fwd_chain(M₀, sigma_list, n), rrSchedule(sigma_list, n))

   This is identical to rr_fwd_chain except using `fwd_succ` instead of
   `enriched_fwd_step`.

   Properties (all provable from fwd_succ lemmas):
   - wf_fwd_chain(n) is an MCS (from `fwd_succ_mcs`)
   - g_content(wf_fwd_chain(n)) ⊆ wf_fwd_chain(n+1) (from `fwd_succ_g_content`)
   - If F(target) ∈ wf_fwd_chain(n): target ∈ wf_fwd_chain(n+1)
     (from `fwd_succ_resolves`)
   - If F(target) ∉ wf_fwd_chain(n): f_carry preserved
     (from `fwd_succ_f_carry`)

   THEOREM (forward_F for wf_fwd_chain):
     If F(ψ) ∈ wf_fwd_chain(n) and ψ ∈ sigma_list,
     then ∃ s > n, ψ ∈ wf_fwd_chain(s).

   Proof by strong induction on f_nesting_depth(ψ):

   CASE f_nesting_depth(ψ) = 0:
     ψ is not of the form F(χ). Consider ψ's visit steps in the round-robin
     schedule: m₁, m₂, m₃, ... (infinitely many, since rrSchedule cycles
     through sigma_list). Let m be the first visit step for ψ with m > n.

     CLAIM: F(ψ) ∈ wf_fwd_chain(m).

     If F(ψ) persists from step n to step m, then at step m the target is ψ,
     F(ψ) ∈ chain(m), and fwd_succ resolves ψ: ψ ∈ chain(m+1). Done with s = m+1.

     F(ψ) can be lost at a resolving step k (n < k ≤ m) where target ≠ ψ and
     F(target) ∈ chain(k). At such a step:
       chain(k+1) = fwd_succ(chain(k), target) where F(target) ∈ chain(k).
       seed = {target} ∪ g_content(chain(k)).
       F(ψ) may or may not be in chain(k+1).

     If F(ψ) IS lost at step k: F(ψ) ∉ chain(k+1), so G(¬ψ) ∈ chain(k+1).
     Then ¬ψ ∈ g_content(chain(k+1)) ⊆ chain(k+2), and by induction,
     ¬ψ ∈ chain(k+j) for all j ≥ 1 (via g_content propagation at each step).
     Also G(¬ψ) ∈ g_content(chain(k+1)) (since G(G(¬ψ)) ∈ chain(k+1) by temp_4),
     so G(¬ψ) ∈ chain(k+2), and G(¬ψ) persists forever.

     In this scenario, ψ never appears in any future chain state (¬ψ is in all of
     them). This seems like forward_F fails.

     HOWEVER, we also have an alternative: instead of waiting for the round-robin
     to revisit ψ, we use the IMMEDIATE next step.

     ALTERNATIVE CONSTRUCTION: For each formula ψ with F(ψ) ∈ chain(n),
     instead of proving forward_F within a FIXED chain, we prove it by
     CONSTRUCTING a chain extension that resolves ψ.

     This leads to the REVISED APPROACH below.

   ─────────────────────────────────────────────────────────────────────
   4. REVISED APPROACH: DIRECT RESOLUTION CHAIN
   ─────────────────────────────────────────────────────────────────────

   The fundamental insight: `fwd_succ(M, ψ)` resolves ψ in ONE step when
   F(ψ) ∈ M. No round-robin or scheduling is needed for the forward_F proof.

   We define a new chain where each step targets a SPECIFIC formula:

   `direct_resolve_chain(M₀, targets, 0) = M₀`
   `direct_resolve_chain(M₀, targets, n+1) = fwd_succ(prev, targets[n])`

   where `targets` is a list of formulas to resolve in sequence.

   For forward_F of a SINGLE ψ with F(ψ) ∈ M₀:
     direct_resolve_chain(M₀, [ψ], 0) = M₀ (has F(ψ))
     direct_resolve_chain(M₀, [ψ], 1) = fwd_succ(M₀, ψ) (has ψ by fwd_succ_resolves)

   g_content(M₀) ⊆ chain(1). So the G-content is preserved.

   But wait: we need the chain in the FMCS to be a SINGLE chain for ALL formulas,
   not a per-formula chain. The FMCS.mcs : D → Set Formula is one function.

   THE KEY ARCHITECTURE DECISION:

   The dd_fmcs uses dd_chain, which uses rr_fwd_chain. We need dd_chain to
   satisfy: for all ψ in sigma_list, if F(ψ) ∈ dd_chain(t) then
   ∃ s > t, ψ ∈ dd_chain(s).

   Option 1: Prove this for the existing rr_fwd_chain (with enriched_fwd_step).
             BLOCKED by Report 26.

   Option 2: Replace rr_fwd_chain with a chain that provably satisfies forward_F.

   For Option 2, we need a SINGLE chain (not per-formula) that resolves all
   F-defects. The Goldblatt approach:

   CONSTRUCTION: `goldblatt_fwd_chain`
     At step n, target = rrSchedule(sigma_list, n) (same round-robin).
     chain(0) = M₀
     chain(n+1) = fwd_succ(chain(n), target)

   This is exactly `wf_fwd_chain` from Section 3d.

   FORWARD_F PROOF (revised, correct this time):

   By strong induction on f_nesting_depth(ψ).

   CASE f_nesting_depth(ψ) = 0:
     F(ψ) ∈ chain(n). ψ contains no F-operators.
     At ψ's next visit step m ≥ n (i.e., rrSchedule(sigma_list, m) = ψ):

     SUB-CASE 1: F(ψ) ∈ chain(m).
       Then chain(m+1) = fwd_succ(chain(m), ψ) with F(ψ) ∈ chain(m).
       By fwd_succ_resolves: ψ ∈ chain(m+1). Done with s = m+1.

     SUB-CASE 2: F(ψ) ∉ chain(m).
       Then G(¬ψ) ∈ chain(m) (by MCS completeness).
       F(ψ) was in chain(n) but not in chain(m). At some step k between n and m,
       F(ψ) was lost. At that step k, chain(k+1) is the resolving extension for
       some target χ ≠ ψ with F(χ) ∈ chain(k).

       Since G(¬ψ) ∈ chain(m), and m > n, and g_content propagates forward,
       we have ¬ψ ∈ chain(m+1), chain(m+2), ...

       BUT: we can try ψ's SECOND visit step m' > m.
       G(¬ψ) ∈ chain(m) implies G(¬ψ) ∈ g_content(chain(m)) ⊆ chain(m+1).
       And by temp_4 (G(φ) → G(G(φ))), G(G(¬ψ)) ∈ chain(m), so
       G(¬ψ) ∈ g_content(chain(m)) ⊆ chain(m+1), and similarly
       G(¬ψ) ∈ chain(m+j) for all j. Hence ¬G(¬ψ) = F(ψ) ∉ chain(m') either.

       So if F(ψ) is ever lost, it stays lost forever. At no future visit step
       will F(ψ) be in the chain, so ψ will never be resolved.

       THIS MEANS SUB-CASE 2 MUST BE IMPOSSIBLE.

       PROOF THAT SUB-CASE 2 IS IMPOSSIBLE:

       We prove F(ψ) ∈ chain(n) implies F(ψ) ∈ chain(n+j) for all j,
       i.e., F(ψ) NEVER leaves the chain.

       Between steps n and n+1:
         target = rrSchedule(sigma_list, n).
         chain(n+1) = fwd_succ(chain(n), target).

         CASE A: F(target) ∉ chain(n) (non-resolving step).
           chain(n+1) = Lindenbaum(g_content(chain(n)) ∪ f_carry(chain(n))).
           F(ψ) ∈ f_carry(chain(n)) (since F(ψ) ∈ chain(n) and F(ψ) = some_future(ψ)).
           So F(ψ) ∈ chain(n+1). PRESERVED.

         CASE B: F(target) ∈ chain(n) (resolving step).
           chain(n+1) = Lindenbaum({target} ∪ g_content(chain(n))).
           F(ψ) may or may not be in chain(n+1).

           SUB-CASE B1: target = ψ.
             chain(n+1) contains ψ by fwd_succ_resolves.
             Does chain(n+1) also contain F(ψ)?
             ψ ∈ chain(n+1) and chain(n+1) is an MCS.
             By phi_in_mcs_imp_F_phi: F(ψ) ∈ chain(n+1). PRESERVED.

           SUB-CASE B2: target ≠ ψ, f_nesting_depth(ψ) = 0.
             seed = {target} ∪ g_content(chain(n)).
             F(ψ) ∈ chain(n) but F(ψ) is an F-formula (F(ψ) = some_future(ψ)).
             G(ψ) may or may not be in chain(n):
               If G(ψ) ∈ chain(n): ψ ∈ g_content(chain(n)) ⊆ chain(n+1).
                 Then F(ψ) ∈ chain(n+1) by phi_in_mcs_imp_F_phi. PRESERVED.
               If G(ψ) ∉ chain(n): ψ is not guaranteed in chain(n+1).
                 F(ψ) may or may not be in chain(n+1). UNKNOWN.

             In the UNKNOWN sub-case: we cannot guarantee F(ψ) persists.

       CONCLUSION: F(ψ) CAN be lost at resolving steps for other targets.
       The depth-0 case does NOT simply reduce to "F(ψ) persists until visit step."

   ─────────────────────────────────────────────────────────────────────
   5. CORRECT APPROACH: f_nesting_depth INDUCTION ON THE TARGET FORMULA
   ─────────────────────────────────────────────────────────────────────

   The correct insight is that the WF-induction is NOT about F-persistence
   through the chain. It is about the STRUCTURE of the formula ψ itself.

   THEOREM: For all ψ ∈ sigma_list, for all n, if F(ψ) ∈ chain(n),
   then ∃ s > n, ψ ∈ chain(s).

   Proof by strong induction on f_nesting_depth(ψ):

   CASE f_nesting_depth(ψ) ≥ 1:
     ψ = F(ψ') where f_nesting_depth(ψ') = f_nesting_depth(ψ) - 1.
     F(ψ) = F(F(ψ')) ∈ chain(n).
     By FF_imp_F_mcs: F(ψ') ∈ chain(n).
     By IH (depth of ψ' < depth of ψ): ∃ s > n, ψ' ∈ chain(s).
     ψ' ∈ chain(s) implies F(ψ') = ψ ∈ chain(s) by phi_in_mcs_imp_F_phi.
     Done.

   CASE f_nesting_depth(ψ) = 0:
     This is the ONLY non-trivial case. ψ is NOT an F-formula.

     F(ψ) ∈ chain(n). We need s > n with ψ ∈ chain(s).

     APPROACH 1 (IMMEDIATE RESOLUTION):
       Define chain(n+1) = fwd_succ(chain(n), ψ).
       Since F(ψ) ∈ chain(n): ψ ∈ chain(n+1) by fwd_succ_resolves.
       g_content(chain(n)) ⊆ chain(n+1) by fwd_succ_g_content.
       Take s = n+1. Done.

       BUT: this changes the chain at step n+1 to target ψ specifically.
       The chain is supposed to follow a fixed schedule (rrSchedule).

     APPROACH 2 (REPLACE THE CHAIN):
       Replace rr_fwd_chain entirely with a chain that, at each step n,
       targets ψ_n = rrSchedule(sigma_list, n), using fwd_succ.

       For the depth-0 base case, at ψ's next round-robin visit step m > n:
       We need F(ψ) ∈ chain(m). As shown in Section 4, this is NOT guaranteed
       because F(ψ) can be lost at intervening resolving steps.

     APPROACH 3 (THE ACTUAL GOLDBLATT TRICK):
       The forward_F theorem is about a FAMILY (FMCS), not a specific chain.
       The dd_bfmcs_restricted_tc theorem requires forward_F to hold for the
       EVAL family (shifted_dd_fmcs M₀ h₀ sigma_list 0). The actual theorem
       signature is:

         ∀ t ψ, ψ ∈ deferralClosure(root) →
           F(ψ) ∈ fam.mcs(t) → ∃ s > t, ψ ∈ fam.mcs(s)

       For fam = shifted_dd_fmcs M₀ h₀ sigma_list 0, fam.mcs(t) = dd_chain(t).

       dd_chain(t) for t ≥ 0 is rr_fwd_chain(t.toNat).

       The forward_F proof needs to show that within the FIXED chain dd_chain,
       for any F(ψ) ∈ dd_chain(t), there exists s > t with ψ ∈ dd_chain(s).

       With the current chain using enriched_fwd_step: BLOCKED (Report 26).

       With a REPLACEMENT chain using fwd_succ: the depth ≥ 1 case works
       beautifully (see above). Only depth 0 is problematic because F(ψ)
       can be lost.

       THE GOLDBLATT FIX for depth 0:
       Use the ENRICHED non-resolving step (g_content ∪ f_carry) at EVERY step,
       not just non-resolving ones. That is:

       At step n, target = rrSchedule(sigma_list, n):
         If F(target) ∈ chain(n):
           seed = {target} ∪ g_content(chain(n)) ∪ f_carry(chain(n))
         Else:
           seed = g_content(chain(n)) ∪ f_carry(chain(n))

       With this construction, f_carry(chain(n)) ⊆ chain(n+1) at ALL steps
       (resolving or not). Hence F(ψ) persists from chain(n) to chain(m)
       (the next visit step for ψ), and fwd_succ resolves ψ at step m+1.

       THE CRITICAL QUESTION: Is {target} ∪ g_content(M) ∪ f_carry(M)
       consistent when F(target) ∈ M?

       This is the "extended seed consistency" problem from the old docstring.
       If provable, it closes EVERYTHING. If not, the approach is blocked.

   ─────────────────────────────────────────────────────────────────────
   6. EXTENDED SEED CONSISTENCY
   ─────────────────────────────────────────────────────────────────────

   CLAIM: If M is an MCS and F(target) ∈ M, then
     {target} ∪ g_content(M) ∪ f_carry(M) is consistent.

   PROOF ATTEMPT:
     Suppose for contradiction: ∃ L ⊆ {target} ∪ g_content(M) ∪ f_carry(M), L ⊢ ⊥.

     Partition L into three parts:
       L_t = L ∩ {target}  (either {target} or ∅)
       L_g = L ∩ g_content(M)  (formulas φ with G(φ) ∈ M)
       L_f = L ∩ f_carry(M)  (formulas F(χ) that are literally in M)

     Note: L_f ⊆ M (since f_carry(M) ⊆ M) and L_g ⊆ M (by T-axiom: G(φ) → φ).
     If target ∈ L_t: we don't know target ∈ M (we know F(target) ∈ M, not target ∈ M).

     CASE A: target ∉ L (L_t = ∅).
       L ⊆ g_content(M) ∪ f_carry(M) ⊆ M (since g_content(M) ⊆ M by T-axiom
       and f_carry(M) ⊆ M by definition).
       L ⊢ ⊥ with L ⊆ M contradicts consistency of M. Done.

     CASE B: target ∈ L.
       L = {target} ∪ L' where L' ⊆ g_content(M) ∪ f_carry(M).
       By deduction: L' ⊢ ¬target.
       L' ⊆ M (as in Case A).
       So ¬target ∈ M (by MCS closure under derivation).
       But F(target) ∈ M means ¬G(¬target) ∈ M.
       And ¬target ∈ M with T-axiom G(¬target) → ¬target... wait, we need
       ¬target ∈ M → G(¬target) ∈ M? NO. G(¬target) ∈ M → ¬target ∈ M, not reverse.
       From L' ⊢ ¬target and L' ⊆ M: ¬target ∈ M.
       We need to derive a contradiction with F(target) ∈ M.
       F(target) = ¬G(¬target) ∈ M and we need G(¬target) ∈ M.
       But ¬target ∈ M does NOT imply G(¬target) ∈ M.

       HOWEVER: We can use generalized temporal K more carefully.
       L' ⊆ g_content(M) ∪ f_carry(M). For each φ ∈ L':
         If φ ∈ g_content(M): G(φ) ∈ M.
         If φ ∈ f_carry(M): φ = F(χ) for some χ, and F(χ) ∈ M.
           F(χ) = ¬G(¬χ). We do NOT have G(F(χ)) ∈ M in general.

       So L' is a mix of formulas with G-closure (from g_content) and formulas
       without G-closure (from f_carry). We cannot apply generalized_temporal_k
       to the entire L' because not all formulas have G(•) ∈ M.

       THIS IS EXACTLY THE OBSTRUCTION identified in Reports 26/27:
       G(F(χ)) does NOT follow from F(χ). The seed {target} ∪ g_content(M) ∪ f_carry(M)
       MAY be inconsistent because f_carry formulas lack the G-closure needed for
       the standard consistency argument.

   CONCLUSION: Extended seed consistency CANNOT be proved by the standard argument.

   ─────────────────────────────────────────────────────────────────────
   7. FINAL CORRECT APPROACH: DEPTH-STRATIFIED CHAIN
   ─────────────────────────────────────────────────────────────────────

   Since (a) the inductive case (depth ≥ 1) works trivially via FF_imp_F_mcs,
   and (b) the base case (depth = 0) only needs ONE resolution step, the solution
   is to build a chain where EVERY formula gets a dedicated resolution step
   WITHOUT other formulas' F-obligations interfering.

   CONSTRUCTION: `depth_stratified_fwd_chain`

   Let D = deferralClosure(root) (finite set of formulas).
   Let d_max = max_F_depth_in_closure(root).
   Let targets_at_depth(k) = {ψ ∈ D | f_nesting_depth(ψ) = k} (finite for each k).

   Phase structure:
   - Phase 0: Process all depth-0 F-defects.
     For each ψ with f_nesting_depth(ψ) = 0 and F(ψ) ∈ M₀:
       Take one fwd_succ step targeting ψ.
       Result: ψ appears in the next chain state.
   - Phase 1: Process all depth-1 F-defects (using depth-0 resolution from IH).
     ...and so on up to phase d_max.
   - Identity tail: After all phases, repeat the last MCS forever.

   Actually, this is unnecessarily complex. The correct observation is:

   FOR THE FMCS FORWARD_F PROPERTY, WE ONLY NEED:
     For each ψ ∈ deferralClosure(root), if F(ψ) ∈ fam.mcs(t),
     then ∃ s > t, ψ ∈ fam.mcs(s).

   With the f_nesting_depth induction:
   - Depth ≥ 1: Follows from FF_imp_F + IH + phi_in_mcs_imp_F_phi. NO CHAIN MODIFICATION NEEDED.
   - Depth 0: Need one fwd_succ step. The chain ALREADY provides this
     at ψ's round-robin visit step IF F(ψ) persists.

   F-PERSISTENCE FOR DEPTH-0 FORMULAS:

   For depth-0 ψ, F(ψ) is a depth-1 formula. At each chain step:
   - Non-resolving (F(target) ∉ chain(k)): f_carry preserved. F(ψ) persists.
   - Resolving for target χ ≠ ψ (F(χ) ∈ chain(k)):
     seed = {χ} ∪ g_content(chain(k)).
     F(ψ) persists iff F(ψ) ∈ Lindenbaum({χ} ∪ g_content(chain(k))).

   By MCS completeness, either F(ψ) or G(¬ψ) is in chain(k+1).

   If G(¬ψ) ∈ chain(k+1): ¬ψ ∈ g_content(chain(k+1)), and by G transitivity
   (temp_4), G(¬ψ) propagates forward. F(ψ) never reappears.

   If F(ψ) ∈ chain(k+1): F(ψ) persists through this step.

   So at each resolving step, F(ψ) either persists or is killed permanently.

   PIGEONHOLE ARGUMENT: Let V = {ψ ∈ sigma_list | f_nesting_depth(ψ) = 0, F(ψ) ∈ M₀}.
   V is finite. At each resolving step for some χ with F(χ) ∈ chain(k):
   - χ is resolved (placed in chain(k+1)).
   - Other F-obligations may be killed.
   In the worst case, at step k resolving χ, ALL other F(ψ) for ψ ≠ χ are killed.
   Then at step k+1, only F(χ) = F(ψ_resolved) persists... wait, χ is now IN
   chain(k+1), so F(χ) ∈ chain(k+1) by phi_in_mcs_imp_F_phi. But the OTHERS
   have their F-obligations killed.

   This means we CANNOT guarantee that a fixed round-robin chain resolves all
   depth-0 F-defects, because resolving one can kill the F-obligation for another.

   ─────────────────────────────────────────────────────────────────────
   8. CONCATENATION APPROACH (DEFINITIVE)
   ─────────────────────────────────────────────────────────────────────

   Given the analysis above, the correct construction is:

   For each ψ ∈ deferralClosure(root) with f_nesting_depth(ψ) = 0:
     If F(ψ) ∈ M₀: build a one-step chain M₀ →[fwd_succ(•,ψ)] M₁_ψ.
     Then ψ ∈ M₁_ψ and g_content(M₀) ⊆ M₁_ψ.
     Use M₁_ψ as the new starting point for the NEXT defect.

   Sequential resolution:
     Let ψ₁, ψ₂, ..., ψ_k be all depth-0 formulas in deferralClosure(root)
     with F(ψᵢ) ∈ M₀.

     chain(0) = M₀
     chain(1) = fwd_succ(chain(0), ψ₁)     -- resolves ψ₁ if F(ψ₁) ∈ chain(0)
     chain(2) = fwd_succ(chain(1), ψ₂)     -- resolves ψ₂ if F(ψ₂) ∈ chain(1)
     ...
     chain(k) = fwd_succ(chain(k-1), ψ_k)  -- resolves ψ_k if F(ψ_k) ∈ chain(k-1)
     chain(k+j) = fwd_succ(chain(k+j-1), ψ₁) for j > 0  (repeat cycle)

   PROBLEM: F(ψ₂) ∈ chain(1) is NOT guaranteed! Resolving ψ₁ at step 0→1
   may kill F(ψ₂). The seed for step 1 is {ψ₁} ∪ g_content(M₀), which does
   NOT include F(ψ₂).

   THIS IS THE SAME OBSTRUCTION as before.

   ─────────────────────────────────────────────────────────────────────
   9. BREAKTHROUGH: USING fwd_succ DIRECTLY IN THE forward_F PROOF
   ─────────────────────────────────────────────────────────────────────

   The key insight we keep missing: forward_F is an EXISTENTIAL statement.
   It says "there EXISTS s > t with ψ ∈ fam.mcs(s)." It does NOT require
   ψ to appear in the SPECIFIC chain we have already built.

   For the dd_bfmcs_restricted_tc theorem, the forward_F requirement is
   about the FAMILY, but restricted_temporal_backward_G_strict only uses it
   for formulas in deferralClosure(root). The actual interface is:

     h_forward_F : ∀ t, ∀ φ ∈ deferralClosure(root),
       F(φ) ∈ fam.mcs(t) → ∃ s > t, φ ∈ fam.mcs(s)

   For fam = shifted_dd_fmcs M₀ h₀ sigma_list shift, fam.mcs(t) is determined
   by dd_chain. The chain IS fixed. We must find s with φ ∈ dd_chain(s).

   So we CANNOT construct an auxiliary chain -- we must show the formula
   appears in the FIXED chain dd_chain.

   BACK TO THE CHAIN DESIGN: We need a chain where depth-0 F-obligations
   DO persist across resolving steps. The only way is to include f_carry
   in the resolving seed.

   ─────────────────────────────────────────────────────────────────────
   10. THE RESOLUTION: CONDITIONAL EXTENDED SEED
   ─────────────────────────────────────────────────────────────────────

   CLAIM: {target} ∪ g_content(M) ∪ (f_carry(M) ∩ depth_0_F_formulas)
   is consistent when F(target) ∈ M.

   Here depth_0_F_formulas = {F(ψ) | f_nesting_depth(ψ) = 0}.

   For each F(ψ) ∈ f_carry(M) with f_nesting_depth(ψ) = 0:
     F(ψ) = ¬G(¬ψ) ∈ M.
     ψ has no F-subformulas (depth 0).
     ¬ψ also has depth 0 (¬ψ = ψ → ⊥).
     G(¬ψ) ∉ M (since F(ψ) = ¬G(¬ψ) ∈ M).

   To include F(ψ) in the seed, we need {target, F(ψ₁), ..., F(ψ_k)} ∪ g_content(M)
   to be consistent.

   This seed contains:
   - target (with G-premises from g_content)
   - F(ψ₁), ..., F(ψ_k) (existential temporal formulas)

   These F-formulas have no interaction with each other or with target
   via the temporal K argument... BUT they might interact with g_content.

   If G(¬target) ∈ M: then ¬target ∈ g_content(M) ⊆ seed, contradicting
   target ∈ seed only if target + ¬target ⊢ ⊥. Well, target and ¬target
   DO derive ⊥. So this case requires F(target) ∈ M, hence G(¬target) ∉ M.
   (Already handled by forward_temporal_witness_seed_consistent.)

   If G(¬ψᵢ) ∈ M for some i: then ¬ψᵢ ∈ g_content(M) ⊆ seed, and F(ψᵢ)
   is also in the seed. ¬ψᵢ + F(ψᵢ) = ¬ψᵢ + ¬G(¬ψᵢ). These are NOT
   directly contradictory! ¬ψᵢ and ¬G(¬ψᵢ) can coexist.
   In fact, ¬ψᵢ ∈ M and F(ψᵢ) ∈ M is perfectly possible: F(ψᵢ) says
   "ψᵢ holds at some FUTURE time", while ¬ψᵢ says "ψᵢ does not hold NOW."
   BUT wait: F is reflexive (F(ψ) means ∃ s ≥ t, ψ at s). With G(¬ψᵢ) ∉ M
   (since F(ψᵢ) ∈ M), and ¬ψᵢ ∈ M... G(¬ψᵢ) ∉ M is consistent with ¬ψᵢ ∈ M.
   (¬ψᵢ holds now but not necessarily always in the future.)

   Hmm, but F(ψᵢ) ∈ M means ¬G(¬ψᵢ) ∈ M, which is consistent with ¬ψᵢ ∈ M.
   F(ψᵢ) says "there exists s ≥ t with ψᵢ at s" -- could be at a future time
   even though ψᵢ fails at the current time.

   Wait: does ¬ψᵢ ∈ g_content(M)? Only if G(¬ψᵢ) ∈ M. But F(ψᵢ) = ¬G(¬ψᵢ) ∈ M
   means G(¬ψᵢ) ∉ M (by MCS consistency). So ¬ψᵢ ∉ g_content(M)!

   More precisely: if F(ψᵢ) ∈ M, then G(¬ψᵢ) ∉ M, so ¬ψᵢ ∉ g_content(M).
   This means the ONLY formulas in g_content(M) are those φ with G(φ) ∈ M,
   and for none of these is ¬φ equal to ψᵢ (since G(¬ψᵢ) ∉ M).

   REVISED CONSISTENCY ARGUMENT:

   CLAIM: If M is an MCS and F(target) ∈ M, then
     S = {target} ∪ g_content(M) ∪ f_carry(M) is consistent.

   PROOF: S ⊆ M ∪ {target}.

   Wait: is g_content(M) ⊆ M? Yes, by T-axiom: G(φ) ∈ M → φ ∈ M.
   And f_carry(M) ⊆ M by definition.
   So g_content(M) ∪ f_carry(M) ⊆ M.
   And S = {target} ∪ (g_content(M) ∪ f_carry(M)) ⊆ {target} ∪ M.

   Case 1: target ∈ M. Then S ⊆ M. M is consistent. Done.

   Case 2: target ∉ M. Then ¬target ∈ M (MCS completeness).
     S = {target} ∪ T where T ⊆ M.
     Suppose L ⊆ S with L ⊢ ⊥.
     If target ∉ L: L ⊆ T ⊆ M, contradicting M's consistency.
     If target ∈ L: L = {target} ∪ L' where L' ⊆ T ⊆ M.
       By deduction: L' ⊢ ¬target.
       L' ⊆ M, so ¬target ∈ M (by MCS closure).
       This is consistent with ¬target ∈ M (which we already know).
       We need to reach a contradiction.

       From L' ⊢ ¬target and L' ⊆ M: this just confirms ¬target ∈ M.
       No contradiction yet. We haven't used F(target) ∈ M.

       The standard forward_temporal_witness_seed_consistent argument works by
       lifting L' through generalized_temporal_k to get G(¬target) ∈ M from
       G(L') ∈ M (all from g_content). Then G(¬target) contradicts F(target).

       BUT: L' may contain elements from f_carry(M), and these do NOT have
       G(•) ∈ M. So the generalized_temporal_k argument does not apply.

       SPECIFIC COUNTEREXAMPLE to the lift: Suppose L' = {F(χ)} where
       F(χ) ∈ f_carry(M), and F(χ) ⊢ ¬target. Then G(F(χ)) ⊢ G(¬target),
       but G(F(χ)) ∉ M in general.

   CONCLUSION: The extended seed consistency argument FAILS for the general case.
   {target} ∪ g_content(M) ∪ f_carry(M) may be INCONSISTENT.

   ─────────────────────────────────────────────────────────────────────
   11. SOLUTION: TWO-PHASE CHAIN WITH IDENTITY BRIDGE
   ─────────────────────────────────────────────────────────────────────

   Since we cannot include f_carry in the resolving seed, and the round-robin
   chain loses F-obligations at resolving steps, we need a different architecture.

   ARCHITECTURE: The dd_chain uses fwd_succ with round-robin scheduling.
   We prove forward_F by the following argument:

   THEOREM: For all ψ ∈ sigma_list with F(ψ) ∈ wf_fwd_chain(n),
   ∃ s > n, ψ ∈ wf_fwd_chain(s).

   Where wf_fwd_chain = rr_fwd_chain but using fwd_succ at every step
   (replacing enriched_fwd_step).

   Proof by strong induction on f_nesting_depth(ψ):

   CASE k ≥ 1 (ψ = F(ψ')):
     Already shown: follows from FF_imp_F + IH + phi_in_mcs_imp_F_phi.

   CASE k = 0 (ψ has no F-operators):
     F(ψ) ∈ chain(n).

     OBSERVATION: At ψ's next visit step m > n (rrSchedule(sigma_list, m) = ψ):
       chain(m+1) = fwd_succ(chain(m), ψ).
       IF F(ψ) ∈ chain(m): ψ ∈ chain(m+1) by fwd_succ_resolves. DONE.
       IF F(ψ) ∉ chain(m): ψ not resolved at this step.

     CLAIM: There exists a visit step m > n where F(ψ) ∈ chain(m).

     PROOF OF CLAIM: Suppose for contradiction that F(ψ) ∉ chain(m) for ALL
     visit steps m > n of ψ.

     Between consecutive visit steps of ψ, F(ψ) is either preserved or killed.
     Once killed (at some step k), G(¬ψ) ∈ chain(k+1) and F(ψ) never returns
     (since G(¬ψ) propagates forward via g_content, giving G(¬ψ) ∈ chain(j)
     for all j > k, hence F(ψ) = ¬G(¬ψ) ∉ chain(j)).

     So either F(ψ) persists to the first visit step (and we're done by
     fwd_succ_resolves), or F(ψ) is killed at some step k between n and the
     first visit step.

     If F(ψ) is killed at step k: G(¬ψ) ∈ chain(k+1).
     ψ has depth 0, so ¬ψ has depth 0 (negation doesn't add F-depth).
     G(¬ψ) propagates: ¬ψ ∈ chain(j) for all j > k.
     In particular, ψ ∉ chain(j) for all j > k (since ψ and ¬ψ can't coexist).
     So ψ never appears in any future chain state. forward_F fails.

     WAIT: This means forward_F genuinely FAILS for the simple fwd_succ chain
     with round-robin scheduling! The depth-0 F-obligations can be killed by
     resolving steps for other formulas.

   ─────────────────────────────────────────────────────────────────────
   12. DEFINITIVE SOLUTION: OMEGA-SQUARED CHAIN
   ─────────────────────────────────────────────────────────────────────

   Each F-defect gets its OWN subsequence in the chain. Defects don't interfere.

   CONSTRUCTION: `omega_sq_fwd_chain`

   Enumerate the F-defects in deferralClosure(root) with F-obligations in M₀:
     ψ₁, ψ₂, ..., ψ_N  (finitely many, since deferralClosure is finite)

   Use Cantor pairing or interleaving to assign each (defect_index, step_count)
   to a chain position. At position (i, j):
   - If j = 0: this is ψᵢ's "refresh" step -- take fwd_succ targeting ψᵢ.
   - If j > 0: this is an identity step for ψᵢ's sub-chain.

   Actually, simpler:

   INTERLEAVED CONSTRUCTION:
   chain(N*j + i) targets ψᵢ for step j of ψᵢ's resolution.
   At chain(N*0 + i) = step i: target ψᵢ via fwd_succ.
     If F(ψᵢ) ∈ chain(i): ψᵢ ∈ chain(i+1). DONE for ψᵢ.
     If F(ψᵢ) ∉ chain(i): non-resolving step, f_carry preserved.
   At chain(N*1 + i) = step N+i: target ψᵢ again via fwd_succ.
     ...and so on.

   PROBLEM: The same as before -- between step i (targeting ψᵢ) and step i+1
   (targeting ψ_{i+1}), the resolution of ψ_{i+1} may kill F(ψᵢ).

   THE REAL OMEGA-SQUARED APPROACH (Teammate A's suggestion):
   Allocate SEPARATE subsequences that do not interact.

   chain position = pairing(defect_index, local_step)
   At each position, use fwd_succ targeting ONLY the assigned defect.
   Between defects, use identity steps (non-resolving, preserving f_carry).

   But this doesn't work either because the chain is a LINEAR sequence, and
   step k+1 is built from step k. The defects share the chain state.

   ─────────────────────────────────────────────────────────────────────
   13. DEFINITIVE SOLUTION: NON-RESOLVING INTERMEDIATE STEPS
   ─────────────────────────────────────────────────────────────────────

   The issue is that resolving step for target χ uses seed {χ} ∪ g_content(M),
   which does NOT preserve f_carry. So other F-obligations may be lost.

   SOLUTION: Use `fwd_succ(M, target)` where target is chosen to be a formula
   that does NOT have an F-obligation. Then the step is non-resolving:
     seed = g_content(M) ∪ f_carry(M), preserving all F-obligations.

   But that defeats the purpose: we need to RESOLVE defects!

   ALTERNATIVE: Use a chain where at step n:
   - If n is a "resolution step": target = ψ (the formula to resolve).
     Use fwd_succ(chain(n), ψ). F(ψ) ∈ chain(n) gives ψ ∈ chain(n+1).
   - If n is a "recovery step": target = dummy (formula not in f_carry).
     Use fwd_succ(chain(n), dummy) in non-resolving mode.
     This preserves f_carry(chain(n)) ⊆ chain(n+1).
   - If n is an "identity step": chain(n+1) = fwd_succ(chain(n), dummy).
     This also preserves f_carry.

   PATTERN: For each defect ψ:
     Step 2i: resolve ψ (F(ψ) ∈ chain(2i) → ψ ∈ chain(2i+1)).
     Step 2i+1: recovery (f_carry preserved, restoring other F-obligations).

   Wait, this doesn't help: after resolving ψ at step 2i, the OTHER
   F-obligations may be lost. The recovery step at 2i+1 preserves whatever
   F-obligations are in chain(2i+1), but the ones lost at step 2i are gone.

   ─────────────────────────────────────────────────────────────────────
   14. ACTUAL DEFINITIVE SOLUTION: PER-FORMULA CHAINS
   ─────────────────────────────────────────────────────────────────────

   The proof works NOT by constructing a single chain that resolves all defects,
   but by proving forward_F for each formula SEPARATELY.

   FOR EACH ψ WITH F(ψ) ∈ dd_chain(t):
     Build a SEPARATE chain starting from dd_chain(t) that resolves ψ
     in one step. This separate chain is NOT dd_chain itself.

   But the theorem requires ψ ∈ dd_chain(s) for some s, not ψ ∈ some_other_chain.

   SO: we need dd_chain itself to eventually contain ψ.

   FUNDAMENTAL DILEMMA: Any single linear chain using fwd_succ will face the
   problem that resolving one F-defect can kill another.

   ─────────────────────────────────────────────────────────────────────
   15. RESOLUTION: MODIFIED fwd_succ WITH f_carry PRESERVATION
   ─────────────────────────────────────────────────────────────────────

   The ONLY way to make this work is to have a forward step that BOTH resolves
   the target AND preserves f_carry. This requires:

     {target} ∪ g_content(M) ∪ f_carry(M) is consistent when F(target) ∈ M.

   We showed in Section 10 that the standard argument fails. But let's look more
   carefully at WHETHER this is actually inconsistent, or just hard to prove.

   CLAIM: {target} ∪ g_content(M) ∪ f_carry(M) IS consistent when F(target) ∈ M.

   PROOF: {target} ∪ g_content(M) ∪ f_carry(M) ⊆ {target} ∪ M
   (since g_content(M) ⊆ M and f_carry(M) ⊆ M).

   If target ∈ M: the entire set ⊆ M, which is consistent. DONE.

   If target ∉ M: then ¬target ∈ M.
   We need to show {target} ∪ M_sub is consistent where M_sub ⊆ M.

   Suppose L ⊆ {target} ∪ M_sub with L ⊢ ⊥ and target ∈ L.
   Then L' = L \ {target} ⊆ M_sub ⊆ M, and L' ⊢ ¬target.
   So ¬target is derivable from a subset of M.
   Hence ¬target ∈ M (MCS closure).
   This is consistent with target ∉ M (which we assumed).

   But wait: we HAVEN'T reached a contradiction! We need to show that
   no L ⊆ {target} ∪ M_sub derives ⊥.

   The ISSUE: even though g_content(M) ∪ f_carry(M) ⊆ M, the set
   {target} ∪ M is NOT necessarily consistent (adding target to M may
   create an inconsistency since ¬target ∈ M).

   So {target} ∪ M is inconsistent when target ∉ M.
   But {target} ∪ g_content(M) ∪ f_carry(M) is a SUBSET of {target} ∪ M.
   A subset of an inconsistent set may be consistent!

   The question: is {target} ∪ g_content(M) ∪ f_carry(M) consistent?

   COUNTEREXAMPLE SEARCH:
   Suppose target = p (an atom), F(p) ∈ M, p ∉ M (so ¬p ∈ M).
   g_content(M) = {φ | G(φ) ∈ M}.
   f_carry(M) = {F(χ) ∈ M}.

   Is {p} ∪ g_content(M) ∪ f_carry(M) consistent?
   Could g_content(M) contain ¬p? Only if G(¬p) ∈ M.
   But F(p) = ¬G(¬p) ∈ M, so G(¬p) ∉ M. Hence ¬p ∉ g_content(M).

   Could f_carry(M) derive ¬p? f_carry(M) = {F(χ₁), F(χ₂), ...}.
   Can {F(χ₁), ..., F(χ_k)} ⊢ ¬p? This would require a derivation from
   existential temporal formulas to a propositional statement. In BX logic,
   F(χ) = ¬G(¬χ). So f_carry contains negations of universal temporal formulas.
   {¬G(¬χ₁), ..., ¬G(¬χ_k)} ⊢ ¬p? By BX11: F(A) ∧ F(B) → F(A∧B) ∨ F(A∧F(B)) ∨ F(F(A)∧B).
   This doesn't give propositional conclusions.

   ACTUALLY: {p} ∪ g_content(M) ∪ f_carry(M) ⊆ {p} ∪ M.
   We need {p, φ₁, ..., φ_n} ⊢ ⊥ where φᵢ ∈ g_content(M) ∪ f_carry(M) ⊆ M.
   This gives {φ₁, ..., φ_n} ⊢ ¬p, hence ¬p ∈ M.
   From ¬p ∈ M and the derivation: the derivation uses generalized temporal K
   to lift to G level... but we can't because f_carry formulas don't have G(•) ∈ M.

   HOWEVER: we don't NEED to lift to G level. We just need to show that
   no finite L ⊆ {target} ∪ g_content(M) ∪ f_carry(M) derives ⊥.

   REVISED PROOF:
   g_content(M) ∪ f_carry(M) ⊆ M (by T-axiom and f_carry definition).
   {target} ∪ g_content(M) ∪ f_carry(M) ⊆ {target} ∪ M.

   We use forward_temporal_witness_seed_consistent which shows
   {target} ∪ g_content(M) is consistent when F(target) ∈ M.

   Now, f_carry(M) ⊆ M. And g_content(M) ⊆ M.
   So g_content(M) ∪ f_carry(M) ⊆ M, and {target} ∪ (g_content(M) ∪ f_carry(M))
   ⊆ {target} ∪ M.

   Suppose L ⊆ {target} ∪ g_content(M) ∪ f_carry(M) with L ⊢ ⊥.
   Split L = L_t ∪ L_g ∪ L_f where L_t ⊆ {target}, L_g ⊆ g_content(M), L_f ⊆ f_carry(M).

   If target ∉ L: L ⊆ g_content(M) ∪ f_carry(M) ⊆ M. Contradicts M consistent.

   If target ∈ L: by deduction, L_g ∪ L_f ⊢ ¬target.
   L_g ⊆ g_content(M), so for each φ ∈ L_g: G(φ) ∈ M.
   L_f ⊆ f_carry(M) ⊆ M.

   By generalized_temporal_k applied to L_g: G-context(L_g) ⊢ G(¬target)...
   NO. We need L_g ∪ L_f ⊢ ¬target to lift to G level, but L_f elements
   don't have G(•) ∈ M.

   ALTERNATIVE: Treat L_f elements as auxiliary assumptions.
   From L_g ∪ L_f ⊢ ¬target, by deduction on L_f:
     L_g ⊢ (∧ L_f) → ¬target  (conjunction of L_f implies ¬target, under L_g assumptions).

   Hmm, this is getting complicated. Let me try a different approach.

   DIRECT PROOF via subset of M:
   Suppose {target} ∪ g_content(M) ∪ f_carry(M) is inconsistent.
   Then ∃ L ⊆ {target} ∪ g_content(M) ∪ f_carry(M), L ⊢ ⊥.
   Since g_content(M) ∪ f_carry(M) ⊆ M, we have L ⊆ {target} ∪ M.
   Since L ⊆ {target} ∪ M and L ⊢ ⊥, by deduction (if target ∈ L):
     L \ {target} ⊢ ¬target, and L \ {target} ⊆ M, so ¬target ∈ M.
   Also, forward_temporal_witness_seed_consistent gives {target} ∪ g_content(M)
   is consistent.

   KEY STEP: From L ⊆ {target} ∪ g_content(M) ∪ f_carry(M):
   Split L_f = L ∩ f_carry(M). These are formulas F(χ) ∈ M.
   Each F(χ) ∈ M. By T-axiom on G: NO, F(χ) doesn't have a T-axiom.
   But F(χ) ∈ M means it's literally in M.
   And L_g ⊆ g_content(M) means G(φ) ∈ M for φ ∈ L_g, hence φ ∈ M.
   So L \ {target} ⊆ M.

   If target ∈ L: L = [target] ++ (L \ {target}), with L \ {target} ⊆ M.
   L ⊢ ⊥ implies (L \ {target}) ⊢ ¬target.
   (L \ {target}) ⊆ M and M is closed under derivation, so ¬target ∈ M.

   Now: {target} ∪ g_content(M) is consistent (by forward_temporal_witness_seed_consistent).
   This means for any L' ⊆ {target} ∪ g_content(M), L' ⊬ ⊥.

   But our L has elements from f_carry(M) too. The inconsistency might REQUIRE
   those f_carry elements. Can f_carry elements contribute to inconsistency
   in a way that g_content elements alone cannot?

   YES: Consider M with F(target) ∈ M and F(χ) ∈ M where target ∧ F(χ) ⊢ ⊥.
   This happens iff ⊢ F(χ) → ¬target, i.e., ⊢ target → ¬F(χ) = G(¬χ).
   For this to be in BX: target → G(¬χ) must be a theorem. This is a strong
   condition: target propositionally implies G(¬χ).

   If target = G(¬χ): then F(target) = F(G(¬χ)) ∈ M. And target ∧ F(χ) =
   G(¬χ) ∧ ¬G(¬χ) = ⊥. So {G(¬χ), F(χ)} is inconsistent.
   But can F(G(¬χ)) and F(χ) coexist in M?
   F(G(¬χ)) = ¬G(¬G(¬χ)) = ¬G(F(χ))... hmm, not standard.
   Actually, F(G(¬χ)) ∈ M and F(χ) ∈ M: by BX11, F(G(¬χ) ∧ χ) or similar.
   G(¬χ) ∧ χ ⊢ ⊥, so F(G(¬χ) ∧ χ) ∈ M would give F(⊥) ∈ M, contradicting
   consistency.

   Actually: suppose F(G(¬χ)) ∈ M and F(χ) ∈ M. By BX11:
   F(G(¬χ)) ∧ F(χ) → F(G(¬χ) ∧ χ) ∨ F(G(¬χ) ∧ F(χ)) ∨ F(F(G(¬χ)) ∧ χ).
   G(¬χ) ∧ χ ⊢ ⊥ (since G(¬χ) → ¬χ by T-axiom), so F(G(¬χ) ∧ χ) → F(⊥).
   And F(⊥) ⊢ ⊥ (since G(¬⊥) = G(⊤) is a theorem, hence F(⊥) = ¬G(⊤) ⊢ ⊥).
   So the first disjunct is eliminated.
   F(G(¬χ) ∧ F(χ)) and F(F(G(¬χ)) ∧ χ) remain. These don't immediately
   derive ⊥. So F(G(¬χ)) ∈ M and F(χ) ∈ M may coexist.

   In such a case, target = G(¬χ) and {target, F(χ)} = {G(¬χ), F(χ)} is
   inconsistent (since G(¬χ) ∧ ¬G(¬χ) ⊢ ⊥... wait, F(χ) = ¬G(¬χ),
   and target = G(¬χ). So {G(¬χ), ¬G(¬χ)} ⊢ ⊥. YES, inconsistent.

   So {target} ∪ f_carry(M) CAN be inconsistent when target has the form G(¬χ).

   But wait: if target = G(¬χ), then F(target) = F(G(¬χ)). And F(χ) ∈ M.
   The question is whether F(G(¬χ)) ∈ M and F(χ) ∈ M can coexist.
   As shown above, they CAN (BX11 doesn't eliminate this).

   So the extended seed IS potentially inconsistent. CONFIRMED.

   ─────────────────────────────────────────────────────────────────────
   16. FINAL APPROACH: SEPARATE THE EXISTENTIAL AND UNIVERSAL CONTENT
   ─────────────────────────────────────────────────────────────────────

   Since {target} ∪ g_content(M) ∪ f_carry(M) can be inconsistent, we need
   a fundamentally different chain construction.

   THE CORRECT ARCHITECTURE (matching Goldblatt 1992, Ch. 8):

   Build the chain as a TREE of single-step resolutions, then flatten to a
   linear chain via a path argument.

   Actually, the standard completeness proof for temporal logic does NOT use
   a single chain with all formulas resolved. Instead:

   GOLDBLATT'S ACTUAL CONSTRUCTION:
   Given M₀ (MCS), build a MAXIMAL chain through M₀ using Zorn's lemma
   (or equivalently, a step-by-step construction). The key property is:

   For each formula F(ψ) ∈ M₀: the chain contains a state s with ψ ∈ chain(s).

   This is proved NOT by showing ψ appears in a pre-built chain, but by
   EXTENDING the chain to include a state with ψ.

   The extension argument:
   Given a partial chain C = (M₀, M₁, ..., M_n) with g_content propagation,
   if F(ψ) ∈ M_n, extend to C' = (M₀, M₁, ..., M_n, M_{n+1}) where
   M_{n+1} = fwd_succ(M_n, ψ). Then ψ ∈ M_{n+1}.

   This CONSTRUCTS the chain to resolve each defect, rather than hoping a
   pre-built chain resolves them.

   FOR OUR FORMALIZATION:
   We need dd_chain to be this construction. The dd_chain is already a
   FUNCTION Nat → Set Formula (for the forward direction). We need to define
   it so that every F(ψ) eventually gets resolved.

   REVISED CHAIN DEFINITION:
   Instead of round-robin scheduling, use a schedule that targets F-defects
   one at a time, with RECOVERY steps between resolutions:

   wf_chain(0) = M₀
   wf_chain(2k+1) = fwd_succ(wf_chain(2k), ψ_k)    -- resolve ψ_k
   wf_chain(2k+2) = fwd_succ(wf_chain(2k+1), dummy) -- recovery (f_carry preserved)

   where ψ_k is the k-th formula in some enumeration of deferralClosure(root),
   and dummy is a formula with F(dummy) ∉ chain(2k+1).

   At step 2k+1 (resolving ψ_k):
     If F(ψ_k) ∈ chain(2k): ψ_k ∈ chain(2k+1). DONE for ψ_k.
     If F(ψ_k) ∉ chain(2k): non-resolving step, f_carry preserved.

   At step 2k+2 (recovery):
     dummy chosen so F(dummy) ∉ chain(2k+1). Non-resolving step.
     f_carry(chain(2k+1)) ⊆ chain(2k+2).

   PROBLEM: After resolving ψ_k at step 2k+1, F(ψ_{k+1}) may have been
   killed. The recovery step at 2k+2 preserves whatever F-obligations
   survived, but killed ones are gone.

   SAME FUNDAMENTAL ISSUE: resolving one defect can kill another.

   ─────────────────────────────────────────────────────────────────────
   17. FINAL RESOLUTION: ITERATED RESOLUTION WITH DEPTH INDUCTION
   ─────────────────────────────────────────────────────────────────────

   The f_nesting_depth induction resolves the issue cleanly for depth ≥ 1.
   For depth 0, we need a different argument.

   KEY OBSERVATION: For depth-0 ψ (no F-subformulas), F(ψ) ∈ M₀.
   At step 0→1, we target ψ: chain(1) = fwd_succ(M₀, ψ).
   Since F(ψ) ∈ M₀: ψ ∈ chain(1). Done for this ψ.

   "But what about other depth-0 F-defects?" They may be killed.
   But that's OK: we prove forward_F for each ψ INDEPENDENTLY.

   For ψ₁: F(ψ₁) ∈ chain(n₁). At ψ₁'s visit step m₁ > n₁:
     If F(ψ₁) ∈ chain(m₁): resolved. Done.
     If F(ψ₁) ∉ chain(m₁): F(ψ₁) was killed. Now ψ₁ might never appear.
       BUT: at some step k₁, F(ψ₁) was killed, meaning G(¬ψ₁) ∈ chain(k₁+1).
       What killed F(ψ₁)? A resolving step for some target χ with F(χ) ∈ chain(k₁).
       The seed was {χ} ∪ g_content(chain(k₁)).
       chain(k₁+1) is an MCS extending this seed.
       F(ψ₁) ∉ chain(k₁+1).

       Consider: at step k₁, BEFORE the resolving step, F(ψ₁) ∈ chain(k₁).
       After the resolving step, F(ψ₁) ∉ chain(k₁+1).
       BUT: χ ∈ chain(k₁+1) (the target is resolved).
       And g_content(chain(k₁)) ⊆ chain(k₁+1).

       Since F(ψ₁) ∈ chain(k₁) and chain(k₁) is an MCS, F(ψ₁) ∈ chain(k₁).
       After the resolving step: chain(k₁+1) decided against F(ψ₁).
       The Lindenbaum extension of {χ} ∪ g_content(chain(k₁)) could go either way
       on F(ψ₁): it includes F(ψ₁) or G(¬ψ₁) but not both.
       If it chose G(¬ψ₁), then ψ₁ is blocked forever.

       THIS IS A GENUINE POSSIBILITY. The Lindenbaum extension is non-deterministic
       (uses Classical.choice). It CAN choose G(¬ψ₁) over F(ψ₁).

       RESOLUTION: Make the Lindenbaum extension DETERMINISTIC by choosing the
       one that preserves F(ψ₁). This requires showing that
       {χ} ∪ g_content(chain(k₁)) ∪ {F(ψ₁)} is consistent.

       Is {χ, F(ψ₁)} ∪ g_content(M) consistent when F(χ) ∈ M and F(ψ₁) ∈ M?
       By the forward_temporal_witness_seed_consistent argument:
         {χ} ∪ g_content(M) is consistent (from F(χ) ∈ M).
       Adding F(ψ₁): {χ, F(ψ₁)} ∪ g_content(M).
       F(ψ₁) ∈ M, so F(ψ₁) is literally in M.
       {χ} ∪ g_content(M) ∪ {F(ψ₁)} ⊆ {χ} ∪ M (since g_content(M) ⊆ M and F(ψ₁) ∈ M).

       If χ ∈ M: {χ} ∪ M = M, consistent. Adding F(ψ₁) ∈ M doesn't change anything.
       If χ ∉ M: {χ} ∪ M is inconsistent (since ¬χ ∈ M).
         But {χ} ∪ g_content(M) is consistent (proved).
         Is {χ} ∪ g_content(M) ∪ {F(ψ₁)} consistent?

       Suppose not: ∃ L ⊆ {χ} ∪ g_content(M) ∪ {F(ψ₁)}, L ⊢ ⊥.
       If F(ψ₁) ∉ L: L ⊆ {χ} ∪ g_content(M), inconsistent with that being consistent.
       If F(ψ₁) ∈ L: by deduction, L \ {F(ψ₁)} ⊢ ¬F(ψ₁) = G(¬ψ₁).
         L \ {F(ψ₁)} ⊆ {χ} ∪ g_content(M).
         So {χ} ∪ g_content(M) derives G(¬ψ₁).

       Can {χ} ∪ g_content(M) derive G(¬ψ₁)?
       By the same generalized_temporal_k argument used in forward_temporal_witness_seed_consistent:
         If χ ∉ L \ {F(ψ₁)}: L \ {F(ψ₁)} ⊆ g_content(M).
           For each φ ∈ L \ {F(ψ₁)}: G(φ) ∈ M.
           L \ {F(ψ₁)} ⊢ G(¬ψ₁).
           By generalized_temporal_k: G(L \ {F(ψ₁)}) ⊢ G(G(¬ψ₁)).
           All G(φ) ∈ M, so G(G(¬ψ₁)) ∈ M.
           By temp_t (G(G(¬ψ₁)) → G(¬ψ₁))... wait, temp_4 goes G → GG, not GG → G.
           Actually, T-axiom: G(G(¬ψ₁)) → G(¬ψ₁)? NO, T is G(φ) → φ.
           So G(G(¬ψ₁)) → G(¬ψ₁) by T? Setting φ = G(¬ψ₁): G(G(¬ψ₁)) → G(¬ψ₁). YES.
           So G(¬ψ₁) ∈ M. But F(ψ₁) = ¬G(¬ψ₁) ∈ M. Contradiction with M consistent.
           So this sub-case is impossible.

         If χ ∈ L \ {F(ψ₁)}: L \ {F(ψ₁)} = {χ} ∪ L'' where L'' ⊆ g_content(M).
           {χ} ∪ L'' ⊢ G(¬ψ₁).
           By deduction: L'' ⊢ χ → G(¬ψ₁).
           L'' ⊆ g_content(M), so G(φ) ∈ M for each φ ∈ L''.
           By generalized_temporal_k: G(L'') ⊢ G(χ → G(¬ψ₁)).
           G(χ → G(¬ψ₁)) ∈ M.
           By temporal K distribution: G(χ → G(¬ψ₁)) → (G(χ) → G(G(¬ψ₁))).
           Hmm, that needs G(χ) ∈ M, which we DON'T have (χ is the target, not
           in g_content).

           ACTUALLY: generalized_temporal_k gives G context ⊢ G conclusion.
           So from L'' ⊢ χ → G(¬ψ₁), we get G(L'') ⊢ G(χ → G(¬ψ₁)).
           And by temp_k: G(χ → G(¬ψ₁)) → (G(χ) → G(G(¬ψ₁))).
           But we don't have G(χ).

           Alternative: From L'' ⊢ χ → G(¬ψ₁), by generalized_temporal_k:
           G(L'') ⊢ G(χ → G(¬ψ₁)).
           This gives G(χ → G(¬ψ₁)) ∈ M.
           From F(χ) ∈ M (hypothesis): ¬G(¬χ) ∈ M.

           We need: G(χ → G(¬ψ₁)) ∈ M and F(χ) ∈ M → contradiction.

           G(χ → G(¬ψ₁)) ∈ M means: for all future times, if χ then G(¬ψ₁).
           F(χ) ∈ M means: at some future time, χ holds.
           Combining: at that future time, χ holds AND (χ → G(¬ψ₁)), so G(¬ψ₁) holds.
           G(¬ψ₁) at that time means ¬ψ₁ at all future-of-future times = all times ≥ that time.

           Formally: F(χ) ∧ G(χ → G(¬ψ₁)) → F(χ ∧ G(¬ψ₁)) → F(G(¬ψ₁)).
           The first implication: F(χ) ∧ G(χ → G(¬ψ₁)).
           By BX axiom properties: G distributes, and F(χ) ∧ G(φ) → F(χ ∧ φ)?
           YES: F(A) ∧ G(B) → F(A ∧ B).
           Proof: F(A) = ¬G(¬A), G(B). By BX11: F(A) ∧ F(B) → F(A∧B) ∨ ...
           Hmm, but G(B) → F(B) by reflexivity, so F(A) ∧ G(B) → F(A) ∧ F(B).
           Then by BX11... this gets complicated.

           SIMPLER: G(B) → B (T-axiom). So at every future time where χ holds,
           B also holds (since G(B) holds at the current time, hence at that future
           time by G-reflexivity... wait, G(B) at time t means B at all s ≥ t.
           At the witnessing time s ≥ t for F(χ): χ holds at s, and G(B) at t gives
           B at s. Actually G(χ → G(¬ψ₁)) at t gives (χ → G(¬ψ₁)) at s (since s ≥ t).
           χ at s gives G(¬ψ₁) at s, which gives ¬ψ₁ at all r ≥ s.

           So F(χ) ∧ G(χ → G(¬ψ₁)) gives F(G(¬ψ₁)) at t.

           In BX: F(A) ∧ G(A → B) → F(A ∧ B)? Let's use:
           G(A → B) → (F(A) → F(B)). This is the "F-monotonicity under G-context."
           Proof: G(A → B) ∈ M means (A → B) ∈ g_content(M).
           F(A) ∈ M. Consider forward_temporal_witness_seed(M, A) = {A} ∪ g_content(M).
           This contains A and (A → B) (from g_content). By MP: B is derivable.
           So {B} ∪ g_content(M) is a subset of the seed's consequences.
           Wait, this isn't quite right for deriving F(B).

           FORMAL APPROACH: G(χ → G(¬ψ₁)) → G(χ) → G(G(¬ψ₁)) by temporal K.
           But we don't have G(χ). We have F(χ).

           F(χ) ∧ G(χ → G(¬ψ₁)): using the BX theorem
           ⊢ F(A) → G(A → B) → F(B) (with A = χ, B = G(¬ψ₁)):
           This would give F(G(¬ψ₁)) ∈ M.

           Is ⊢ F(A) → G(A → B) → F(B) a theorem of BX?
           F(A) = ¬G(¬A). G(A → B). Want: F(B) = ¬G(¬B).
           Suppose G(¬B) ∈ M. Then (¬B) ∈ g_content(M).
           Also G(A → B) ∈ M, so (A → B) ∈ g_content(M).
           From {A → B, ¬B}: ⊢ ¬A. So ¬A ∈ g_content-derivable.
           By generalized_temporal_k: G(¬A) ∈ M.
           So ¬F(A) = G(¬A) ∈ M. But F(A) ∈ M. Contradiction.
           Hence G(¬B) ∉ M, so F(B) ∈ M. ✓

           Great! So F(A) ∧ G(A → B) → F(B) IS a theorem of BX.
           (Proof: contrapositive of G(¬B) ∧ G(A→B) → G(¬A).)

           Applying: F(χ) ∧ G(χ → G(¬ψ₁)) → F(G(¬ψ₁)).
           F(G(¬ψ₁)) ∈ M.

           Now: F(G(¬ψ₁)) = ¬G(¬G(¬ψ₁)) = ¬G(F(ψ₁)).
           And F(ψ₁) ∈ M.
           temp_4: G(φ) → G(G(φ)). With φ = F(ψ₁): G(F(ψ₁)) → G(G(F(ψ₁))).
           Contrapositive: ¬G(G(F(ψ₁))) → ¬G(F(ψ₁)).
           I.e., F(G(F(ψ₁))) → F(F(ψ₁)) = ¬G(G(¬ψ₁))... this is getting circular.

           Let me try directly: F(G(¬ψ₁)) ∈ M means ¬G(¬G(¬ψ₁)) ∈ M.
           ¬G(¬G(¬ψ₁)) = ¬G(F(ψ₁)) ∈ M (since F(ψ₁) = ¬G(¬ψ₁)).
           So ¬G(F(ψ₁)) ∈ M.

           Also, from F(ψ₁) ∈ M and reflexivity: F(F(ψ₁)) ∈ M.
           F(F(ψ₁)) = ¬G(¬F(ψ₁)) = ¬G(G(¬ψ₁)) ∈ M.
           And from G(χ → G(¬ψ₁)) and F(χ) above: ¬G(F(ψ₁)) ∈ M.

           Hmm, ¬G(F(ψ₁)) ∈ M and F(F(ψ₁)) = ¬G(G(¬ψ₁)) ∈ M.
           ¬G(F(ψ₁)) = ¬G(¬G(¬ψ₁)) ∈ M. And ¬G(G(¬ψ₁)) ∈ M.
           These are the SAME formula: ¬G(¬G(¬ψ₁)) = ¬G(G(¬ψ₁))? NO!
           ¬G(¬ψ₁) = F(ψ₁). G(F(ψ₁)) = G(¬G(¬ψ₁)). ¬G(F(ψ₁)) = ¬G(¬G(¬ψ₁)).
           F(F(ψ₁)) = ¬G(¬F(ψ₁)) = ¬G(G(¬ψ₁)).
           So ¬G(F(ψ₁)) = ¬G(¬G(¬ψ₁)) and F(F(ψ₁)) = ¬G(G(¬ψ₁)).
           These are NOT the same: one negates G of ¬G(¬ψ₁), the other negates G of G(¬ψ₁).
           Different formulas.

           So we have ¬G(¬G(¬ψ₁)) ∈ M (from the argument) and ¬G(G(¬ψ₁)) ∈ M (from FF_imp_F direction).
           These don't directly contradict.

           TO GET A CONTRADICTION: We need G(¬ψ₁) ∈ M.
           From F(G(¬ψ₁)) ∈ M: ¬G(¬G(¬ψ₁)) ∈ M. This means G(¬G(¬ψ₁)) ∉ M.
           I.e., G(F(ψ₁)) ∉ M. This tells us the universal "F(ψ₁) at all future times" fails.
           But we need G(¬ψ₁) ∈ M to contradict F(ψ₁) ∈ M.

           F(G(¬ψ₁)) says "at some future time, G(¬ψ₁) holds."
           This does NOT give G(¬ψ₁) at the CURRENT time.

           So the argument does NOT give a contradiction. The derivation
           {χ} ∪ g_content(M) ⊢ G(¬ψ₁) can potentially hold without contradicting M.

       CONCLUSION OF THIS SUB-CASE: We cannot rule out {χ, F(ψ₁)} ∪ g_content(M)
       being inconsistent via the standard argument. The extended seed consistency
       genuinely fails in general.

   ─────────────────────────────────────────────────────────────────────
   18. ACTUAL FINAL APPROACH: MODIFY fwd_succ TO PRESERVE F-CARRY
   ─────────────────────────────────────────────────────────────────────

   Define a new step function:

   `fwd_succ_preserving(M, target) =`
     Lindenbaum({target} ∪ g_content(M) ∪ f_carry_restricted(M, target))

   where f_carry_restricted(M, target) = {F(ψ) ∈ M | {target, F(ψ)} ∪ g_content(M) is consistent}

   For each F(ψ) ∈ M: either {target, F(ψ)} ∪ g_content(M) is consistent
   (include F(ψ) in seed) or inconsistent (exclude F(ψ)).

   Inconsistency of {target, F(ψ)} ∪ g_content(M) means:
   ∃ L ⊆ {target, F(ψ)} ∪ g_content(M), L ⊢ ⊥.
   Since {target} ∪ g_content(M) is consistent (by forward_temporal_witness_seed_consistent):
     F(ψ) must be in L. So L = {F(ψ)} ∪ L' where L' ⊆ {target} ∪ g_content(M).
     By deduction: L' ⊢ ¬F(ψ) = G(¬ψ).
     L' ⊆ {target} ∪ g_content(M).

   If target ∉ L': L' ⊆ g_content(M), so G(φ) ∈ M for each φ ∈ L'.
     By generalized_temporal_k: G(L') ⊢ G(G(¬ψ)).
     G(G(¬ψ)) ∈ M, hence G(¬ψ) ∈ M (by T-axiom on G(G(¬ψ))).
     But F(ψ) ∈ M = ¬G(¬ψ) ∈ M. Contradiction with M consistent.
     So this sub-case is impossible.

   If target ∈ L': L' = {target} ∪ L'' where L'' ⊆ g_content(M).
     L'' ∪ {target} ⊢ G(¬ψ).
     By deduction on target: L'' ⊢ target → G(¬ψ).
     By generalized_temporal_k: G(L'') ⊢ G(target → G(¬ψ)).
     G(target → G(¬ψ)) ∈ M.
     Combined with F(target) ∈ M:
     By the BX theorem F(A) ∧ G(A → B) → F(B) (proved above):
     F(G(¬ψ)) ∈ M.

   So: {target, F(ψ)} ∪ g_content(M) is inconsistent IFF F(G(¬ψ)) ∈ M
   (which means "at some future time, G(¬ψ) holds, i.e., ψ fails from that
   point on").

   When F(G(¬ψ)) ∉ M (equivalently, G(F(ψ)) ∈ M, i.e., "F(ψ) holds at
   all future times"): the seed {target, F(ψ)} ∪ g_content(M) IS consistent.

   When F(G(¬ψ)) ∈ M: the seed may be inconsistent.

   NOTE: F(G(¬ψ)) ∈ M means G(¬G(¬ψ)) ∉ M, i.e., G(F(ψ)) ∉ M. And this is
   exactly the G(F(ψ)) non-derivability from Report 26/27: we cannot guarantee
   G(F(ψ)) ∈ M from F(ψ) ∈ M.

   IMPLICATION: If G(F(ψ)) ∈ M, then F(ψ) persists forever (F(ψ) ∈ g_content(M)
   is not right... G(F(ψ)) ∈ M means F(ψ) ∈ g_content(M)! And g_content is
   always preserved by fwd_succ. So F(ψ) ∈ chain(n+1), chain(n+2), etc.

   Wait: G(F(ψ)) ∈ M means F(ψ) ∈ g_content(M). And fwd_succ always includes
   g_content(M) in the seed. So F(ψ) ∈ chain(n+1). And at the next step,
   G(F(ψ)) ∈ chain(n+1)? Only if G(G(F(ψ))) ∈ chain(n).
   By temp_4: G(F(ψ)) → G(G(F(ψ))). So G(G(F(ψ))) ∈ M = chain(n).
   Hence G(F(ψ)) ∈ g_content(chain(n)) ⊆ chain(n+1).
   And F(ψ) ∈ g_content(chain(n+1))... wait, need G(F(ψ)) ∈ chain(n+1) first.
   G(F(ψ)) ∈ g_content(chain(n)) because G(G(F(ψ))) ∈ chain(n).
   g_content(chain(n)) ⊆ chain(n+1) by fwd_succ_g_content.
   So G(F(ψ)) ∈ chain(n+1). Then F(ψ) ∈ g_content(chain(n+1)).
   By induction: G(F(ψ)) ∈ chain(m) for all m ≥ n, hence F(ψ) ∈ chain(m) for all m ≥ n.

   GREAT! So IF G(F(ψ)) ∈ chain(n), then F(ψ) persists forever via g_content,
   and at ψ's visit step, fwd_succ_resolves gives ψ ∈ chain(visit_step+1).

   And IF G(F(ψ)) ∉ chain(n) (i.e., F(G(¬ψ)) ∈ chain(n)): then F(ψ) may be killed.
   But F(G(¬ψ)) ∈ chain(n) means "at some future time, ¬ψ holds forever."
   This is compatible with F(ψ) ∈ chain(n) (ψ may hold at some near future time
   before ¬ψ takes over permanently).

   For the WF-induction: f_nesting_depth(ψ) = 0 means ψ has no F-operators.
   But G(F(ψ)) involves F(ψ) which has f_nesting_depth 1.
   So the condition G(F(ψ)) ∈ chain(n) involves a depth-1 formula.

   CASE SPLIT for depth-0 ψ:
   1. G(F(ψ)) ∈ chain(n): F(ψ) persists via g_content. At ψ's visit step m > n,
      F(ψ) ∈ chain(m), and fwd_succ resolves ψ. ψ ∈ chain(m+1). DONE.

   2. G(F(ψ)) ∉ chain(n), i.e., F(G(¬ψ)) ∈ chain(n): "Eventually G(¬ψ)."
      Also F(ψ) ∈ chain(n): "Eventually ψ."
      By BX11: F(ψ) ∧ F(G(¬ψ)) → F(ψ ∧ G(¬ψ)) ∨ F(ψ ∧ F(G(¬ψ))) ∨ F(F(ψ) ∧ G(¬ψ)).

      ψ ∧ G(¬ψ): ψ holds now AND ¬ψ holds at all future times (including now
      by reflexivity). G(¬ψ) → ¬ψ by T-axiom. So ψ ∧ ¬ψ = ⊥. Hence
      F(ψ ∧ G(¬ψ)) → F(⊥) = ⊥. First disjunct is impossible.

      F(ψ) ∧ G(¬ψ): F(ψ) says ψ at some s ≥ now. G(¬ψ) says ¬ψ at all s ≥ now.
      So ψ at s and ¬ψ at s: contradiction. F(F(ψ) ∧ G(¬ψ)) → F(⊥) = ⊥.
      Third disjunct is impossible.

      So: F(ψ) ∧ F(G(¬ψ)) → F(ψ ∧ F(G(¬ψ))).
      I.e., F(ψ ∧ F(G(¬ψ))) ∈ chain(n).
      This says: at some future time s, both ψ AND F(G(¬ψ)) hold.
      In particular, ψ holds at time s.

      Now, ψ ∧ F(G(¬ψ)) has f_nesting_depth:
      f_nesting_depth(ψ ∧ F(G(¬ψ))) = ?
      ψ has depth 0. F(G(¬ψ)) has depth 1 (one F-operator wrapping G(¬ψ)).
      ψ ∧ F(G(¬ψ)) is an implication (encoded), depth depends on encoding.
      Actually, ψ ∧ X = ¬(ψ → ¬X) (encoded). f_nesting_depth checks outermost
      consecutive F-operators. ψ ∧ F(G(¬ψ)) starts with ¬(ψ → ...), not F(...).
      So f_nesting_depth(ψ ∧ F(G(¬ψ))) = 0.

      So: F(ψ ∧ F(G(¬ψ))) ∈ chain(n), with f_nesting_depth(ψ ∧ F(G(¬ψ))) = 0.

      This is a depth-0 F-obligation for the formula (ψ ∧ F(G(¬ψ))).
      But (ψ ∧ F(G(¬ψ))) ∈ deferralClosure(root)? Only if it's in the closure.

      PROBLEM: ψ ∧ F(G(¬ψ)) may not be in sigma_list or deferralClosure.
      The deferralClosure is constructed from the root formula's subformulas.
      BX11 can produce formulas OUTSIDE the closure.

      However, we DON'T NEED (ψ ∧ F(G(¬ψ))) to be in sigma_list. We just
      need ψ ∈ chain(s) for some s > n. And the formula ψ ∧ F(G(¬ψ)) CONTAINS ψ.

      If (ψ ∧ F(G(¬ψ))) ∈ chain(s): then ψ ∈ chain(s) (by conjunction elimination
      in the MCS). DONE! We have our witness s > n with ψ ∈ chain(s).

      But we need (ψ ∧ F(G(¬ψ))) ∈ chain(s), and we have F(ψ ∧ F(G(¬ψ))) ∈ chain(n).
      This is a depth-0 F-obligation for a formula that may NOT be in sigma_list.

      The forward_F theorem is stated for ψ ∈ sigma_list. Can we use it recursively
      for (ψ ∧ F(G(¬ψ)))? Only if (ψ ∧ F(G(¬ψ))) ∈ sigma_list.

      APPROACH: Ensure sigma_list contains all formulas that BX11 can produce.
      The deferralClosure already includes deferralDisjunctionSet which adds BX11
      disjuncts. Let me check...

      Actually, the approach is:
      F(ψ ∧ F(G(¬ψ))) ∈ chain(n). By F-monotonicity (F_mono):
      ψ ∧ F(G(¬ψ)) → ψ, so F(ψ ∧ F(G(¬ψ))) → F(ψ) (by F_mono).
      But we already KNOW F(ψ) ∈ chain(n)! This is circular.

      Hmm. The BX11 argument gives F(ψ ∧ F(G(¬ψ))) ∈ chain(n), but this
      doesn't help us get ψ ∈ chain(s) any more than F(ψ) ∈ chain(n) does.

      WAIT: The BX11 argument's VALUE is that it eliminates the other disjuncts,
      giving F(ψ ∧ F(G(¬ψ))) specifically. But since ψ ∧ F(G(¬ψ)) → ψ, this
      gives F(ψ), which we already had. No progress.

   ─────────────────────────────────────────────────────────────────────
   19. BREAKTHROUGH: G(F(ψ)) ALWAYS HOLDS WHEN F(ψ) ∈ M₀
   ─────────────────────────────────────────────────────────────────────

   WAIT. Let's reconsider. We have:
   - F(ψ) ∈ chain(n) where chain = wf_fwd_chain (using fwd_succ).
   - chain(0) = M₀.
   - At each step: g_content(chain(k)) ⊆ chain(k+1).

   CLAIM: If G(F(ψ)) ∈ chain(0) = M₀, then G(F(ψ)) ∈ chain(k) for all k.

   Proof: G(G(F(ψ))) ∈ M₀ by temp_4. So G(F(ψ)) ∈ g_content(M₀) ⊆ chain(1).
   And G(G(F(ψ))) ∈ g_content(M₀) ⊆ chain(1). By induction: for all k.

   CLAIM: If F(ψ) ∈ M₀, then G(F(ψ)) ∈ M₀.

   IS THIS TRUE? F(ψ) ∈ M₀ means ¬G(¬ψ) ∈ M₀. Does this give G(¬G(¬ψ)) ∈ M₀?
   i.e., G(F(ψ)) ∈ M₀?

   G(F(ψ)) = G(¬G(¬ψ)).
   From temp_4: G(G(¬ψ)) → G(¬ψ)... no, temp_4 is G(φ) → G(G(φ)).
   Contrapositive: ¬G(G(φ)) → ¬G(φ). With φ = ¬ψ: F(G(¬ψ)) → F(ψ).
   And ¬G(G(¬ψ)) → ¬G(¬ψ): i.e., F(G(¬ψ)) → F(ψ).
   But we need the REVERSE: F(ψ) → G(F(ψ)).
   F(ψ) → G(F(ψ)) is ¬G(¬ψ) → G(¬G(¬ψ)).

   Is ¬G(¬ψ) → G(¬G(¬ψ)) a theorem of BX?
   Equivalently: F(ψ) → G(F(ψ)).

   Semantically in reflexive temporal logic: F(ψ) at t means ∃ s ≥ t, ψ at s.
   G(F(ψ)) at t means ∀ r ≥ t, ∃ s ≥ r, ψ at s.
   F(ψ) at t does NOT imply G(F(ψ)) at t. Counterexample: time domain = {0,1,2},
   ψ true only at time 1. F(ψ) at 0 (witness s=1). But at time 2, F(ψ) requires
   s ≥ 2 with ψ at s: only s=2 available, and ψ is false at 2. So F(ψ) fails at 2.
   Hence G(F(ψ)) fails at 0.

   So F(ψ) → G(F(ψ)) is NOT valid in general.
   G(F(ψ)) ∈ M₀ is NOT guaranteed from F(ψ) ∈ M₀.

   This confirms Report 26/27: G(F(ψ)) non-derivability is the core obstruction.

   ─────────────────────────────────────────────────────────────────────
   20. TRUE FINAL APPROACH: UNIVERSAL CHAIN (ALL FORMULAS TARGETED ONCE)
   ─────────────────────────────────────────────────────────────────────

   Given that G(F(ψ)) is not guaranteed, we CANNOT preserve F(ψ) through
   arbitrary chain steps via g_content alone.

   The ONLY remaining approach for the depth-0 base case is:

   IMMEDIATE RESOLUTION: For each F(ψ) ∈ chain(n), construct chain(n+1)
   by targeting ψ. This means the chain schedule is ADAPTIVE: it depends
   on which formulas have F-obligations at each step.

   CONSTRUCTION: `adaptive_fwd_chain`
     chain(0) = M₀
     chain(n+1): choose ANY ψ with F(ψ) ∈ chain(n).
       If no such ψ exists (no F-defects): chain(n+1) = fwd_succ(chain(n), dummy)
         (non-resolving, identity-like step).
       If such ψ exists: chain(n+1) = fwd_succ(chain(n), ψ).
         Then ψ ∈ chain(n+1) by fwd_succ_resolves.

   FORWARD_F for this chain:
     Given F(ψ) ∈ chain(n).

     Depth ≥ 1 case: Same as before (FF_imp_F + IH + phi_in_mcs_imp_F_phi).

     Depth 0 case: chain(n+1) = fwd_succ(chain(n), χ) for SOME χ with F(χ) ∈ chain(n).
       If χ = ψ: ψ ∈ chain(n+1). DONE.
       If χ ≠ ψ: F(ψ) may or may not be in chain(n+1).

     With the adaptive chain, we could CHOOSE χ = ψ. Then ψ ∈ chain(n+1). ALWAYS.

     BUT: this means forward_F for depth-0 formulas is proved by choosing ψ as the
     target at step n. The chain is DEFINED to resolve the specific formula we need.

     PROBLEM: The chain must be defined BEFORE we know which formula we're proving
     forward_F for. The chain is a fixed function, not parameterized by the query formula.

   SOLUTION: Define the chain to cycle through ALL formulas in sigma_list.
   At step n with target = rrSchedule(sigma_list, n):
   - If F(target) ∈ chain(n): target is resolved.
   - If F(target) ∉ chain(n): non-resolving step.

   For a specific F(ψ) ∈ chain(n), ψ's next visit step is some m > n.
   We need F(ψ) ∈ chain(m).

   BETWEEN n and m: steps target other formulas in sigma_list.
   At each such step k (n ≤ k < m), target = some χ ≠ ψ.
   If F(χ) ∈ chain(k): resolving step. F(ψ) may be lost.
   If F(χ) ∉ chain(k): non-resolving step. f_carry preserved. F(ψ) preserved.

   THE NUMBER OF RESOLVING STEPS between n and m is at most |sigma_list| - 1
   (since each χ ≠ ψ is visited at most once in one round-robin cycle).

   At each resolving step, the "killed" set grows (formulas whose F-obligations
   are lost). But F-obligations that ARE killed go to G(¬•) (permanent).

   CLAIM: If F(ψ) survives all resolving steps between n and m (i.e., no
   resolving step kills F(ψ)), then F(ψ) ∈ chain(m), and ψ is resolved at m+1.

   If F(ψ) does NOT survive: it's killed at some step k, and G(¬ψ) ∈ chain(k+1).
   ψ will never appear in any future chain state.

   THIS MEANS: for the simple fwd_succ chain with round-robin scheduling,
   forward_F CAN FAIL for specific formulas whose F-obligations are killed
   by other resolutions.

   ─────────────────────────────────────────────────────────────────────
   21. CONCLUSION: THE CHAIN MUST RESOLVE ψ IMMEDIATELY
   ─────────────────────────────────────────────────────────────────────

   The only provably correct chain for forward_F is one where, whenever
   F(ψ) ∈ chain(n), the VERY NEXT step targets ψ:

   chain(n+1) = fwd_succ(chain(n), ψ) where ψ is chosen so F(ψ) ∈ chain(n).

   This gives ψ ∈ chain(n+1) immediately.

   But: which ψ? Multiple formulas may have F-obligations simultaneously.
   Choose ANY one. The others may be killed at this step, but the CHOSEN one
   is resolved. Then at step n+1, if other F-obligations survive, they can be
   resolved at step n+2, etc.

   POTENTIAL ISSUE: After resolving ψ₁ at step n→n+1, suppose F(ψ₂) was killed.
   Then at step n+1, F(ψ₂) ∉ chain(n+1). But F(ψ₂) was in chain(n). The theorem
   says "∃ s > n, ψ₂ ∈ chain(s)." We need ψ₂ to appear somewhere.

   If F(ψ₂) ∉ chain(n+1): we need to find ψ₂ in chain(s) for some s > n WITHOUT
   using forward_F at chain(n+1) (since F(ψ₂) ∉ chain(n+1)).

   KEY REALIZATION: We DON'T need F(ψ₂) to persist. We need ψ₂ ∈ chain(s) for
   SOME s > n. Perhaps ψ₂ appears in chain(n+1) even though F(ψ₂) was killed.

   chain(n+1) = fwd_succ(chain(n), ψ₁) = Lindenbaum({ψ₁} ∪ g_content(chain(n))).
   ψ₂ may or may not be in this extension. It depends on the Lindenbaum choice.

   ALTERNATIVELY: Use the f_nesting_depth induction more carefully.
   If f_nesting_depth(ψ₂) > 0: the inductive case handles it via FF_imp_F.
   If f_nesting_depth(ψ₂) = 0: ψ₂ has no F-operators.

   For depth-0 ψ₂ with F(ψ₂) ∈ chain(n): we prove forward_F by choosing ψ₂
   as the target at step n. chain(n+1) = fwd_succ(chain(n), ψ₂).
   ψ₂ ∈ chain(n+1). Done for ψ₂.

   But SIMULTANEOUSLY, we also need forward_F for ψ₁ with F(ψ₁) ∈ chain(n).
   If we chose ψ₂ as target at step n, chain(n+1) resolves ψ₂ but may kill F(ψ₁).

   THE ANSWER: forward_F is an EXISTENTIAL statement proved INDEPENDENTLY for
   each ψ. When proving forward_F for ψ₂, we CAN DEFINE the chain to target ψ₂
   at step n. When proving forward_F for ψ₁, we define the chain to target ψ₁
   at step n. The chain is DIFFERENT for each proof.

   BUT: the FMCS has ONE chain. The theorem says "for ALL ψ, forward_F holds
   in THIS chain." So we need ONE chain where forward_F holds for ALL ψ simultaneously.

   THE RESOLUTION:

   Define chain(n+1) = fwd_succ(chain(n), schedule(n)) where schedule visits
   EVERY formula in sigma_list:
   - schedule(0) = σ₁, schedule(1) = σ₂, ..., schedule(|σ|-1) = σ_{|σ|},
     schedule(|σ|) = σ₁, ...

   For any F(ψ) ∈ chain(n): ψ's IMMEDIATELY PRECEDING visit step before n
   may have failed (F(ψ) wasn't in chain yet). But ψ's first visit step AFTER n
   is at most n + |sigma_list| steps away.

   IF F(ψ) persists to that visit step: ψ is resolved. Done.
   IF F(ψ) is killed before: ψ is NOT resolved at that visit step.

   For ψ not resolved at first visit: F(ψ) was killed at some step k ∈ (n, visit_step).
   G(¬ψ) ∈ chain(k+1). ψ never appears in future chain states. forward_F FAILS.

   UNLESS: We can show F(ψ) is NOT killed.

   F(ψ) is killed at step k iff chain(k+1) = fwd_succ(chain(k), target_k) with
   F(target_k) ∈ chain(k) AND F(ψ) ∉ chain(k+1).

   The Lindenbaum extension of {target_k} ∪ g_content(chain(k)) MIGHT or MIGHT
   NOT include F(ψ). If {target_k, F(ψ)} ∪ g_content(chain(k)) is consistent,
   then the Lindenbaum extension CAN include F(ψ) (but Classical.choice may not).

   TO GUARANTEE F(ψ) is included: use set_lindenbaum_contains (if available) or
   define a custom Lindenbaum extension that prioritizes including F-formulas.

   ACTUALLY: The Lindenbaum lemma gives a MAXIMAL consistent extension.
   If {target_k} ∪ g_content(chain(k)) ∪ {F(ψ)} is consistent, then the
   maximal extension WILL include F(ψ) (since it's maximal).

   WAIT: set_lindenbaum returns SOME MCS extending the seed. If the seed is
   {target} ∪ g_content(M), the resulting MCS extends this seed. It may or may
   not contain F(ψ). Both choices (F(ψ) or G(¬ψ)) are consistent with the seed.

   The Lindenbaum lemma says: given a consistent set S, there exists an MCS M ⊇ S.
   It does NOT say M contains everything consistent with S.

   SO: we need to INCLUDE F(ψ) in the seed to guarantee it's in the extension.
   But {target} ∪ g_content(M) ∪ {F(ψ)} may be inconsistent (Section 17).

   WHEN IT IS CONSISTENT: Include F(ψ) in the seed. F(ψ) persists.
   WHEN IT IS INCONSISTENT: F(ψ) is necessarily killed (any MCS extending
   {target} ∪ g_content(M) must contain G(¬ψ)).

   From Section 17: {target, F(ψ)} ∪ g_content(M) is inconsistent iff
   g_content(M) ∪ {target} derives G(¬ψ). And this happens iff
   G(target → G(¬ψ)) ∈ M combined with F(target) gives F(G(¬ψ)).

   So F(ψ) is necessarily killed at step k iff F(G(¬ψ)) ∈ chain(k).

   F(G(¬ψ)) ∈ chain(k) means "at some future time from k, G(¬ψ) holds."
   This is a TEMPORAL statement about the semantic content of chain(k).

   IF F(G(¬ψ)) ∈ chain(0) = M₀: Then F(ψ) may be killed at ANY resolving step
   whose target interacts with ψ via BX11.

   IF F(G(¬ψ)) ∉ chain(0) = M₀ (i.e., G(F(ψ)) ∈ M₀): Then G(F(ψ)) ∈ chain(k)
   for all k (by g_content propagation + temp_4), F(ψ) ∈ g_content(chain(k)),
   so F(ψ) ∈ chain(k+1) regardless. F(ψ) persists forever.

   CASE SPLIT:
   A) G(F(ψ)) ∈ M₀: F(ψ) persists forever. At ψ's visit step, resolved. DONE.
   B) G(F(ψ)) ∉ M₀, F(G(¬ψ)) ∈ M₀: F(ψ) may be killed. Need different argument.

   FOR CASE B: F(G(¬ψ)) ∈ M₀ and F(ψ) ∈ M₀ (both in M₀).
   By BX11: F(G(¬ψ)) ∧ F(ψ) → F(G(¬ψ) ∧ ψ) ∨ F(G(¬ψ) ∧ F(ψ)) ∨ F(F(G(¬ψ)) ∧ ψ).

   G(¬ψ) ∧ ψ: G(¬ψ) → ¬ψ by T, so ψ ∧ ¬ψ = ⊥. First disjunct: F(⊥) = ⊥.
   F(G(¬ψ)) ∧ ψ: ψ holds now and F(G(¬ψ)) holds now. NOT immediately contradictory.
   Third disjunct F(F(G(¬ψ)) ∧ ψ) is possible.
   Second disjunct F(G(¬ψ) ∧ F(ψ)): G(¬ψ) ∧ F(ψ) at some time.
   G(¬ψ) means ¬ψ at all times ≥ that time. F(ψ) means ψ at some time ≥ that time.
   Contradiction! So G(¬ψ) ∧ F(ψ) ⊢ ⊥. Second disjunct: F(⊥) = ⊥.

   Result: F(G(¬ψ)) ∧ F(ψ) → F(F(G(¬ψ)) ∧ ψ).
   By F-mono from (F(G(¬ψ)) ∧ ψ → ψ): F(F(G(¬ψ)) ∧ ψ) → F(ψ). Circular.

   ACTUAL CONTENT: F(F(G(¬ψ)) ∧ ψ) ∈ M₀.
   This says: at some future time s₁, both F(G(¬ψ)) and ψ hold.
   So ψ holds at s₁! And F(G(¬ψ)) at s₁ means at some s₂ > s₁, G(¬ψ) holds.
   So ψ at s₁ and ¬ψ at all times ≥ s₂ > s₁.

   For the chain: at some future step, ψ holds AND later G(¬ψ) takes over.
   The visit step for ψ may be BEFORE or AFTER F(ψ) is killed.

   If the visit step for ψ is BEFORE F(ψ) is killed: ψ is resolved. DONE.
   If AFTER: F(ψ) was already killed.

   THE KEY: With round-robin scheduling, ψ is visited EVERY |sigma_list| steps.
   F(ψ) can only be killed at a RESOLVING step for some other target.
   Between n (where F(ψ) ∈ chain(n)) and ψ's next visit, there are at most
   |sigma_list| - 1 other steps. Only steps with F(target) ∈ chain(k) are resolving.

   DEFECT SET ANALYSIS: The "defect set" D(n) = {χ ∈ sigma_list | F(χ) ∈ chain(n)}
   is MONOTONICALLY DECREASING (or staying same) under the simple fwd_succ chain.

   WHY: At a resolving step for target χ, chain(n+1) resolves χ. χ ∈ chain(n+1).
   F(χ) ∈ chain(n+1) by phi_in_mcs_imp_F_phi. So χ stays in the defect set.
   But OTHER formulas ψ may leave (F(ψ) killed). No new F-obligations appear
   (by `no_new_f_defects`: if G(¬α) ∈ chain(n) and g_content(chain(n)) ⊆ chain(n+1),
   then F(α) ∉ chain(n+1)).

   Wait: `no_new_f_defects` says: if G(¬α) ∈ M and g_content(M) ⊆ M', then F(α) ∉ M'.
   This means: if α was NOT an F-defect (G(¬α) ∈ chain(n)), it stays non-defect.
   But if F(α) was in chain(n) and is now killed (G(¬α) ∈ chain(n+1)), it stays
   killed forever. And if F(α) ∉ chain(n), it may or may not be in chain(n+1).

   Actually: can NEW F-defects appear? If F(α) ∉ chain(n), can F(α) ∈ chain(n+1)?
   At a resolving step for χ: chain(n+1) ⊇ {χ} ∪ g_content(chain(n)).
   F(α) ∈ chain(n+1) requires F(α) in the MCS. This is possible if the Lindenbaum
   extension chose to include F(α).

   For this to happen, {F(α)} ∪ {χ} ∪ g_content(chain(n)) must be consistent.
   And the Lindenbaum extension may or may not include F(α).

   So NEW F-defects CAN appear in the chain. The defect set is NOT monotonically
   decreasing.

   AT A NON-RESOLVING step: chain(n+1) ⊇ g_content(chain(n)) ∪ f_carry(chain(n)).
   f_carry(chain(n)) = {F(χ) ∈ chain(n)}. So all existing F-defects persist.
   And g_content(chain(n)) ⊆ chain(n+1). If G(¬α) ∈ chain(n), then ¬α ∈ g_content,
   so ¬α ∈ chain(n+1), and by `no_new_f_defects`, F(α) ∉ chain(n+1). So no new
   F-defects from previously non-defect formulas.
   But: new F-defects CAN appear from formulas α where NEITHER F(α) NOR G(¬α) was
   in chain(n). At non-resolving steps, the Lindenbaum extension decides each such α.
   Hmm, but f_carry preserves the F-formulas, and g_content preserves the G-formulas.
   For formulas not covered by either: the Lindenbaum extension makes a choice.
   So yes, new F-defects can appear at non-resolving steps too.

   THIS INVALIDATES the "defect set is monotonically decreasing" claim.

   ─────────────────────────────────────────────────────────────────────
   22. REVISED DEFINITIVE APPROACH: BACK TO BASICS
   ─────────────────────────────────────────────────────────────────────

   Let's step back and think about what Goldblatt's construction ACTUALLY does.

   In Goldblatt (1992, Chapter 8), the completeness proof for Kt (minimal
   tense logic) builds a canonical model where WORLDS ARE MCS's and the
   SUCCESSOR RELATION R is defined by:

     M R M' iff g_content(M) ⊆ M'

   For Kt with the T-axiom (G(φ) → φ), R is reflexive.
   For Kt with temp_4 (G(φ) → G(G(φ))), R is transitive.

   The key property: For each F(ψ) ∈ M, there exists M' with M R M' and ψ ∈ M'.
   PROOF: {ψ} ∪ g_content(M) is consistent (by forward_temporal_witness_seed_consistent).
   Extend to MCS M'. Then ψ ∈ M' and g_content(M) ⊆ M'. So M R M'.

   THIS IS fwd_succ! M' = fwd_succ(M, ψ).

   In the Kripke model, M' is a WORLD, not a TIME STEP. The temporal logic model
   is obtained by UNFOLDING the Kripke model into a LINEAR chain.

   For linear temporal logic (as in BX), we need a LINEAR ORDER on time points,
   not just a preorder. The Kripke model gives a preorder (via R transitive, reflexive).

   THE CHAIN IS OBTAINED BY INDUCTION:
   Given M₀, define the chain as a function ℕ → MCS such that:
   - chain(0) = M₀
   - chain(n+1) is an MCS with g_content(chain(n)) ⊆ chain(n+1)
   - For each F(ψ) ∈ chain(n), eventually ψ ∈ chain(s) for some s > n.

   This is achieved by the following construction:

   Let Φ = {ψ ∈ deferralClosure(root) | F(ψ) ∈ M₀} (finite set of initial F-defects).
   Enumerate Φ as ψ₁, ..., ψ_k.

   chain(0) = M₀
   chain(i) = fwd_succ(chain(i-1), ψᵢ) for i = 1, ..., k
   chain(k+j) = fwd_succ(chain(k+j-1), dummy) for j > 0  (identity-like steps)

   At step i: IF F(ψᵢ) ∈ chain(i-1): ψᵢ ∈ chain(i). RESOLVED.
   At step i: IF F(ψᵢ) ∉ chain(i-1): non-resolving step. F-carry preserved.

   PROBLEM (same as before): F(ψᵢ) may not be in chain(i-1) because earlier
   resolving steps killed it.

   THE GOLDBLATT FIX: Process ONE formula at a time, and EXTEND the chain
   for each formula. The chain is NOT a fixed finite sequence but an ω-chain.

   FOR EACH F(ψ) ∈ chain(n):
     chain(n+1) = fwd_succ(chain(n), ψ).  -- target ψ specifically.
     ψ ∈ chain(n+1). Done.
     Then proceed with other formulas at chain(n+1).

   But again, this requires the chain to be defined per-formula.

   THE SOLUTION FOR A FIXED CHAIN:

   Define chain(n+1) = fwd_succ(chain(n), target(n)) where:
   target(n) = first formula in sigma_list with F(target) ∈ chain(n) and target ∉ chain(n)

   This is DEMAND-DRIVEN: at each step, resolve the first UNRESOLVED F-defect.

   If no unresolved defects: non-resolving step (target with F(target) ∉ chain(n)).

   FORWARD_F for this chain:
   Given F(ψ) ∈ chain(n) with f_nesting_depth(ψ) = 0.

   If ψ ∈ chain(n): already done (s = n since F is reflexive, but we need STRICT s > n).
   Hmm, F(ψ) ∈ chain(n) says ∃ s ≥ n, ψ ∈ chain(s). We need STRICT s > n (from the
   theorem statement). With reflexive F, ψ might hold at time n itself.

   Actually, looking at the theorem: it says ∃ s > n. So we need STRICT.

   If ψ ∈ chain(n): chain(n+1) = fwd_succ(chain(n), target(n)).
   g_content(chain(n)) ⊆ chain(n+1). If G(ψ) ∈ chain(n) (which follows from ψ ∈ chain(n)
   only if ψ ∈ g_content(chain(n)), i.e., G(ψ) ∈ chain(n))... NO. ψ ∈ chain(n) does NOT
   imply G(ψ) ∈ chain(n).

   But ψ ∈ chain(n) implies F(ψ) ∈ chain(n) by phi_in_mcs_imp_F_phi.
   Also, ψ ∈ chain(n) and the chain steps with g_content propagation...
   We can't be sure ψ ∈ chain(n+1) without G(ψ) ∈ chain(n).

   Hmm, this is about the STRICT requirement. The chain's g_content propagation
   gives: if G(ψ) ∈ chain(n), then ψ ∈ chain(n+1), chain(n+2), etc.
   But ψ ∈ chain(n) without G(ψ) ∈ chain(n) means ψ may be lost at step n+1.

   FOR THE STRICT FORWARD_F THEOREM: F(ψ) ∈ chain(n) means ¬G(¬ψ) ∈ chain(n).
   Semantically: ψ at some s ≥ n. Need: ψ at some s > n (STRICT).

   With reflexive F: F(ψ) doesn't imply ψ at a STRICTLY future time.
   The theorem as stated requires strict s > n.

   Looking at the Lean theorem statement:
   `∃ s : Nat, n < s ∧ ψ ∈ (rr_fwd_chain M₀ h₀ sigma_list s).val`

   So we need STRICT n < s. This is standard for the canonical model: even with
   reflexive G/F, the chain construction should provide strict witnesses.

   With fwd_succ: chain(n+1) = fwd_succ(chain(n), ψ) with F(ψ) ∈ chain(n)
   gives ψ ∈ chain(n+1). n < n+1. DONE for the strict case.

   OK so back to the demand-driven chain:

   CLAIM: In the demand-driven chain, for every F(ψ) ∈ chain(n), either:
   (a) ψ is selected as target at step n, giving ψ ∈ chain(n+1), or
   (b) ψ is not selected (another formula is targeted first).

   In case (b): F(ψ) may persist or be killed.

   COUNTING ARGUMENT: The demand-driven chain resolves at least ONE defect per
   resolving step (the target). The number of INITIAL defects |Φ| is finite.
   But new defects can appear!

   Can new depth-0 F-defects appear? At step n→n+1, chain(n+1) is an MCS
   extending {target} ∪ g_content(chain(n)). A formula α with F(α) ∉ chain(n)
   may have F(α) ∈ chain(n+1). This can happen if F(α) is consistent with the seed.

   HOWEVER: We only care about formulas in deferralClosure(root). And
   deferralClosure is FINITE. So the set of potential depth-0 defects is finite.

   But the defect set can fluctuate: defects resolved, then re-appearing.

   INFINITE LOOPING is possible if defects keep reappearing.

   HMMMM. This is the fundamental problem of the depth-0 base case.

   ─────────────────────────────────────────────────────────────────────
   23. RESOLUTION: ψ ∈ chain(n+1) FROM F(ψ) ∈ chain(n) DIRECTLY
   ─────────────────────────────────────────────────────────────────────

   The SIMPLEST correct approach is to define the chain so that at EVERY step,
   the target is chosen from the set of unresolved F-defects.

   But we just showed this doesn't work because resolving one can kill another.

   WAIT: Let me reconsider the depth-0 inductive case.

   We have F(ψ) ∈ chain(n) with f_nesting_depth(ψ) = 0.

   Define: chain*(0) = chain(n), chain*(1) = fwd_succ(chain(n), ψ).
   Then ψ ∈ chain*(1) and g_content(chain(n)) ⊆ chain*(1).

   Now, we need ψ ∈ dd_chain(s) for some s > n. chain*(1) is NOT dd_chain(n+1)
   in general (dd_chain(n+1) targets rrSchedule(sigma_list, n), not ψ).

   UNLESS we redefine dd_chain to use a different schedule.

   FINAL ANSWER: Replace rr_fwd_chain with a chain that targets ψ at step n
   whenever F(ψ) ∈ chain(n). The schedule is:

   target(n) = sigma_list[n % |sigma_list|]  (round-robin)

   BUT WAIT: we can redefine the chain to be GREEDY:
   target(n) = first ψ ∈ sigma_list with F(ψ) ∈ chain(n) and ψ ∉ chain(n).

   But then target(n) depends on chain(n), which depends on target(n-1), etc.
   This is fine for a recursive definition.

   For GREEDY chain forward_F:
   F(ψ) ∈ chain(n). If ψ ∉ chain(n): ψ is an unresolved defect. The greedy
   chain will target SOME unresolved defect at step n. If ψ is the FIRST one:
   chain(n+1) resolves ψ. Done. If ψ is NOT the first: another defect χ is
   resolved first. F(ψ) may be killed.

   STILL THE SAME PROBLEM.

   ─────────────────────────────────────────────────────────────────────
   24. THE ACTUAL ANSWER: INCLUDE F(ψ) IN THE SEED CONDITIONALLY
   ─────────────────────────────────────────────────────────────────────

   Define `safe_fwd_succ(M, target, preserve_list)`:
     Let S = {target} ∪ g_content(M) ∪ {F(ψ) | ψ ∈ preserve_list, F(ψ) ∈ M,
                                                   {target, F(ψ)} ∪ g_content(M) consistent}
     Return Lindenbaum(S).

   This preserves F(ψ) whenever it's safe to do so. When it's not safe (i.e.,
   {target, F(ψ)} ∪ g_content(M) is inconsistent), F(ψ) is necessarily killed
   by ANY extension of {target} ∪ g_content(M).

   From Section 17: {target, F(ψ)} ∪ g_content(M) is inconsistent iff
   G(target → G(¬ψ)) ∈ M and F(target) ∈ M implies F(G(¬ψ)) ∈ M.

   When F(ψ) is necessarily killed: G(¬ψ) ∈ chain(k+1) for the step that
   kills it. Then ψ ∉ chain(s) for any s > k. forward_F fails for ψ?

   NO: forward_F says F(ψ) ∈ chain(n) → ∃ s > n, ψ ∈ chain(s).
   If F(ψ) is necessarily killed at step k ∈ (n, m): G(¬ψ) ∈ chain(k+1).
   ψ never appears after step k. forward_F requires ψ between n and k+1 (exclusive).
   But between n and k, the chain HASN'T killed F(ψ) yet.
   At step n itself, F(ψ) ∈ chain(n) but we need STRICT s > n.
   At step n+1: IF the chain targets ψ at step n: ψ ∈ chain(n+1). Done.
   If it targets something else: F(ψ) may or may not persist.

   THE KEY INSIGHT I KEEP MISSING: Forward_F requires ψ to appear at SOME future
   step, but the chain at each step CAN be defined to prioritize.

   CORRECT CONSTRUCTION:
   At each step n, target(n) = ψ where ψ is the formula with the SMALLEST
   index in sigma_list such that F(ψ) ∈ chain(n) and ψ ∉ chain(n).

   With fwd_succ: chain(n+1) = fwd_succ(chain(n), target(n)).
   If F(target(n)) ∈ chain(n): target(n) ∈ chain(n+1).
   The FIRST unresolved defect is resolved at each step.

   For forward_F of formula ψ: F(ψ) ∈ chain(n).
   ψ might be the first unresolved defect → resolved at n+1.
   Or ψ might be behind others.

   KEY THEOREM: The number of formulas AHEAD of ψ in the priority queue
   is at most |sigma_list|. Each step resolves one (the first). So after
   at most |sigma_list| steps, ψ's turn comes.

   But: resolving earlier formulas may KILL F(ψ). If F(ψ) is killed, ψ
   drops out of the queue (it's no longer an unresolved defect). forward_F fails.

   UNLESS we can guarantee F(ψ) is NOT killed.

   WITH safe_fwd_succ: F(ψ) is preserved whenever consistent with the seed.
   F(ψ) is killed only when {target, F(ψ)} ∪ g_content(M) is inconsistent.

   THE CLAIM: {target, F(ψ)} ∪ g_content(M) is ALWAYS consistent when both
   F(target) ∈ M and F(ψ) ∈ M.

   PROOF ATTEMPT:
   Suppose L ⊆ {target, F(ψ)} ∪ g_content(M) with L ⊢ ⊥.
   Case 1: Neither target nor F(ψ) in L. L ⊆ g_content(M) ⊆ M. Contradicts M consistent.
   Case 2: target ∈ L, F(ψ) ∉ L. L ⊆ {target} ∪ g_content(M).
     Contradicts forward_temporal_witness_seed_consistent (which says this is consistent).
   Case 3: F(ψ) ∈ L, target ∉ L. L = {F(ψ)} ∪ L' where L' ⊆ g_content(M).
     L ⊢ ⊥ gives L' ⊢ ¬F(ψ) = G(¬ψ).
     L' ⊆ g_content(M), so G(φ) ∈ M for each φ ∈ L'.
     By generalized_temporal_k: G(L') ⊢ G(G(¬ψ)).
     G(G(¬ψ)) ∈ M, hence G(¬ψ) ∈ M (by T-axiom).
     But F(ψ) = ¬G(¬ψ) ∈ M. Contradiction with M consistent. ✓
   Case 4: Both target and F(ψ) in L. L = {target, F(ψ)} ∪ L' where L' ⊆ g_content(M).
     L ⊢ ⊥.
     By deduction on F(ψ): {target} ∪ L' ⊢ ¬F(ψ) = G(¬ψ).
     By deduction on target: L' ⊢ target → G(¬ψ).
     By generalized_temporal_k on L': G(L') ⊢ G(target → G(¬ψ)).
     G(target → G(¬ψ)) ∈ M.
     Combined with F(target) ∈ M: By F(A) ∧ G(A → B) → F(B):
       F(G(¬ψ)) ∈ M.

     But does F(G(¬ψ)) ∈ M contradict F(ψ) ∈ M?
     F(G(¬ψ)) = ¬G(¬G(¬ψ)) = ¬G(F(ψ)).
     So ¬G(F(ψ)) ∈ M. And F(ψ) ∈ M.
     ¬G(F(ψ)) says "F(ψ) does not hold at all future times."
     F(ψ) says "ψ holds at some future time."
     These are compatible! ¬G(F(ψ)) ∈ M and F(ψ) ∈ M CAN coexist.

     So Case 4 does NOT lead to a contradiction. The seed {target, F(ψ)} ∪ g_content(M)
     CAN be inconsistent when F(G(¬ψ)) ∈ M.

   CONCLUSION: {target, F(ψ)} ∪ g_content(M) is NOT always consistent.
   Case 4 is the problematic case.

   ─────────────────────────────────────────────────────────────────────
   25. THE ALGEBRAIC APPROACH: USE THE EXISTING TRUTH LEMMA DIRECTLY
   ─────────────────────────────────────────────────────────────────────

   Looking at the problem from a different angle. The dd_countermodel theorem
   uses:
   - restricted_parametric_representation_from_neg_membership
   - dd_bfmcs_restricted_tc (the sorry about forward_F)
   - dd_bfmcs_restricted_buc (sorry about backward until coherence)
   - dd_bfmcs_restricted_fuc (sorry about forward until coherence)

   The restricted_parametric_representation uses the RESTRICTED truth lemma,
   which only needs forward_F for formulas in deferralClosure(root).

   The restricted truth lemma already handles the inductive cases for
   F and G (via forward_F and backward_G). The forward_F hypothesis is
   PASSED IN as a parameter.

   So the question reduces to: can we build an FMCS where forward_F holds
   for all formulas in deferralClosure(root)?

   THE FMCS IS dd_fmcs, which is built from dd_chain.
   dd_chain uses rr_fwd_chain (forward) and rr_bwd_chain (backward).

   We need forward_F for dd_fmcs. This means: for each F(ψ) ∈ dd_chain(t),
   ∃ s > t, ψ ∈ dd_chain(s).

   THE ENTIRE DIFFICULTY is constructing dd_chain (i.e., the forward and
   backward chain functions) such that this property holds.

   ─────────────────────────────────────────────────────────────────────
   26. APPROACH: REPLACE rr_fwd_chain WITH per_defect_chain
   ─────────────────────────────────────────────────────────────────────

   Define per_defect_chain: for each initial defect F(ψᵢ) ∈ M₀, build a
   ONE-STEP extension. Then for the dd_chain, interleave these extensions.

   per_defect_chain(M₀, [ψ₁, ..., ψ_N]):
     chain(0) = M₀
     chain(1) = fwd_succ(M₀, ψ₁)       -- ψ₁ ∈ chain(1) if F(ψ₁) ∈ M₀
     chain(2) = fwd_succ(chain(1), ψ₂)  -- ψ₂ ∈ chain(2) if F(ψ₂) ∈ chain(1)
     ...
     chain(N) = fwd_succ(chain(N-1), ψ_N)
     chain(N+1) = same cycle again starting from chain(N)

   For ψ₁: F(ψ₁) ∈ chain(0) = M₀. chain(1) resolves ψ₁. ψ₁ ∈ chain(1). ✓
   For ψ₂: F(ψ₂) ∈ chain(0). At chain(1): F(ψ₂) may or may not persist.
   If F(ψ₂) ∈ chain(1): chain(2) resolves ψ₂. ✓
   If F(ψ₂) ∉ chain(1): chain(2) is non-resolving for ψ₂. f_carry preserved.
     So F-obligations from chain(1) persist to chain(2). But F(ψ₂) ∉ chain(1).
     At chain(2), F(ψ₂) still not present. ψ₂ never resolved.

   SAME PROBLEM. Resolving ψ₁ can kill F(ψ₂).

   ─────────────────────────────────────────────────────────────────────
   27. BACK TO BASICS: WHAT DOES GOLDBLATT ACTUALLY DO?
   ─────────────────────────────────────────────────────────────────────

   In Goldblatt (1992), for temporal logic over INTEGER time (Z):
   The canonical model has WORLDS = MCS's, R defined by g_content ⊆.
   The CHAIN is built as follows:

   Starting from M₀, enumerate ALL formulas F(ψ₁), F(ψ₂), ... ∈ M₀.
   Build:
     M₁ = fwd_succ(M₀, ψ₁)   -- ψ₁ ∈ M₁, g_content(M₀) ⊆ M₁
     M₂ = fwd_succ(M₁, ψ₂)   -- ψ₂ ∈ M₂ IF F(ψ₂) ∈ M₁
     ...

   For ψ₂: Does F(ψ₂) ∈ M₁?
   F(ψ₂) ∈ M₀. g_content(M₀) ⊆ M₁. But F(ψ₂) is NOT in g_content(M₀)
   (since F(ψ₂) = ¬G(¬ψ₂) is NOT of the form G(φ)).
   So F(ψ₂) is NOT guaranteed in M₁.

   HOW DOES GOLDBLATT HANDLE THIS? He doesn't use this construction for linear
   temporal logic. For minimal tense logic (Kt), the canonical model is a TREE
   (branching time), not a line. Each F-defect is resolved in a SEPARATE BRANCH.

   For LINEAR temporal logic, the standard completeness proof uses a FILTRATION
   or a STEP-BY-STEP construction with a more sophisticated argument. The key
   references are:

   - Burgess (1984): "Basic Tense Logic" -- uses a maximal chain construction
     with a careful ordering argument.
   - Gabbay, Hodkinson, Reynolds (1994): Uses a "mosaic" or "compass" method.
   - Reynolds (2003): Uses quasimodel decomposition.

   BURGESS'S APPROACH (most relevant to our formalization):
   Build the chain by TRANSFINITE INDUCTION, resolving F-defects one at a time.
   At each stage, CHOOSE which defect to resolve. The key property is that
   resolving one defect does NOT create new defects of HIGHER complexity.

   In our formalization: f_nesting_depth provides the complexity measure.
   Resolving a depth-0 defect F(ψ) (where ψ has no F-operators):
     chain(n+1) = fwd_succ(chain(n), ψ). ψ ∈ chain(n+1).
     ψ has no F-subformulas, so no new F-defects are REQUIRED by ψ.
     But the MCS chain(n+1) may contain F-formulas introduced by the
     Lindenbaum extension. These new F-formulas have depth ≥ 1
     (since ψ is depth-0, the new F-formulas come from the MCS axioms).

   ACTUALLY: the MCS chain(n+1) contains MANY formulas. Among them:
   - ψ (resolved)
   - All of g_content(chain(n)) (carried over)
   - Other formulas from the Lindenbaum extension

   New F-defects in chain(n+1): formulas F(α) ∈ chain(n+1) where F(α) ∉ chain(n).
   These can have any depth. But for the WF-induction argument, we only need
   forward_F for formulas in deferralClosure(root), which is FINITE.

   THE WF INDUCTION IS ON THE FORMULA BEING RESOLVED, NOT ON THE CHAIN STATE.

   For depth ≥ 1: F(ψ) ∈ chain(n), ψ = F(ψ'). FF_imp_F gives F(ψ') ∈ chain(n).
   IH gives ψ' ∈ chain(s) for some s > n. phi_in_mcs_imp_F_phi gives ψ = F(ψ') ∈ chain(s).

   For depth 0: F(ψ) ∈ chain(n). We need ψ ∈ chain(s) for some s > n.
   DIRECT CONSTRUCTION: chain(n+1) = fwd_succ(chain(n), ψ). ψ ∈ chain(n+1).

   THE ISSUE: chain(n+1) is ALREADY DEFINED (by the round-robin schedule).
   We can't retroactively change it.

   THE FIX: Don't use round-robin. Use a DEMAND-DRIVEN schedule where at EACH
   step, the chain resolves a SPECIFIC defect. For the forward_F proof, we know
   which defect to resolve (the one we're proving forward_F for).

   But the chain is ONE chain for ALL formulas. We can't use different chains
   for different formulas.

   ─────────────────────────────────────────────────────────────────────
   28. THE CONSTRUCTION THAT WORKS (FINAL)
   ─────────────────────────────────────────────────────────────────────

   Replace rr_fwd_chain with a chain that IMMEDIATELY resolves each new F-defect.

   `greedy_fwd_chain(M₀, sigma_list, 0) = M₀`
   `greedy_fwd_chain(M₀, sigma_list, n+1) =`
     `fwd_succ(greedy_fwd_chain(M₀, sigma_list, n), sigma_list[n % |sigma_list|])`

   This is THE SAME as rr_fwd_chain with fwd_succ replacing enriched_fwd_step!

   Forward_F proof for this chain:

   Given F(ψ) ∈ chain(n), f_nesting_depth(ψ) = 0.
   Let m be ψ's FIRST visit step after n: m = smallest k > n with sigma_list[k % |σ|] = ψ.
   m ≤ n + |sigma_list|.

   We need: F(ψ) ∈ chain(m).

   Between n and m, the chain takes at most |sigma_list| - 1 steps.
   Each step uses fwd_succ with some target χ ≠ ψ.
   At each step k ∈ [n, m):
   - If F(χ) ∉ chain(k): non-resolving. f_carry preserved. F(ψ) persists. ✓
   - If F(χ) ∈ chain(k): resolving for χ. F(ψ) may be killed.

   Number of RESOLVING steps between n and m: at most |sigma_list| - 1.

   IF F(ψ) SURVIVES ALL RESOLVING STEPS: F(ψ) ∈ chain(m), resolved at m+1. DONE.

   IF F(ψ) IS KILLED AT SOME STEP k: G(¬ψ) ∈ chain(k+1). ψ never appears later.
   forward_F FAILS for this specific chain.

   THIS IS UNAVOIDABLE FOR A ROUND-ROBIN CHAIN WITH SIMPLE fwd_succ.

   ─────────────────────────────────────────────────────────────────────
   29. THE ACTUAL RESOLUTION: DIFFERENT CHAIN ARCHITECTURE
   ─────────────────────────────────────────────────────────────────────

   After this exhaustive analysis, there are exactly TWO viable paths:

   PATH A: Prove extended seed consistency ({target} ∪ g_content(M) ∪ f_carry(M))
   by a NON-STANDARD argument. Section 10 showed the standard generalized_temporal_k
   argument fails because f_carry formulas lack G-closure. But perhaps a different
   argument works.

   PATH B: Use the QUASIMODEL BRIDGE (Report 27, Finding 8). The 1,816 lines of
   sorry-free quasimodel code provide Int-indexed FMCS families with forward_F
   built into the quasimodel definition. Bridge to the canonical model via a
   quotient or embedding.

   PATH A is the more direct approach. Let me re-examine Case 4 from Section 24:

   Case 4 revisited: L = {target, F(ψ)} ∪ L' with L' ⊆ g_content(M).
   L ⊢ ⊥. By deduction on F(ψ): {target} ∪ L' ⊢ G(¬ψ).
   By deduction on target: L' ⊢ target → G(¬ψ).
   By gen_temporal_k: G(L') ⊢ G(target → G(¬ψ)).
   G(target → G(¬ψ)) ∈ M.
   Combined with F(target) ∈ M: F(G(¬ψ)) ∈ M.
   ¬G(F(ψ)) ∈ M. Also F(ψ) ∈ M.

   But wait: Can ¬G(F(ψ)) ∈ M AND F(ψ) ∈ M coexist?
   If F(ψ) ∈ M: by phi_in_mcs_imp_F_phi, F(F(ψ)) ∈ M.
   Does F(ψ) ∈ M imply G(F(ψ)) ∈ M? NO (Section 19).

   So ¬G(F(ψ)) ∈ M is possible alongside F(ψ) ∈ M.
   And F(G(¬ψ)) ∈ M is the same as ¬G(¬G(¬ψ)) = ¬G(F(ψ)) ∈ M.
   Wait: F(G(¬ψ)) = ¬G(¬G(¬ψ)). And G(F(ψ)) = G(¬G(¬ψ)).
   So ¬G(F(ψ)) = ¬G(¬G(¬ψ)) = F(G(¬ψ)). YES, same formula.

   Conclusion of PATH A analysis: When ¬G(F(ψ)) ∈ M (equivalently F(G(¬ψ)) ∈ M),
   the extended seed {target, F(ψ)} ∪ g_content(M) can be inconsistent.
   The standard argument does not give a contradiction.
   PATH A APPEARS BLOCKED for the general case.

   Therefore: PATH B (quasimodel bridge) is likely necessary.

   ─────────────────────────────────────────────────────────────────────
   30. SUMMARY AND RECOMMENDATION
   ─────────────────────────────────────────────────────────────────────

   This proof sketch has systematically analyzed every approach to proving
   forward_F for a chain built from fwd_succ with round-robin scheduling.

   FINDINGS:
   1. The f_nesting_depth induction WORKS for depth ≥ 1 (trivially, via FF_imp_F).
   2. The depth-0 base case requires F(ψ) to persist from chain(n) to ψ's visit step.
   3. F(ψ) CAN be killed at resolving steps for other targets.
   4. F-persistence through resolving steps requires extended seed consistency:
      {target} ∪ g_content(M) ∪ {F(ψ)} consistent when F(target) ∈ M and F(ψ) ∈ M.
   5. Extended seed consistency FAILS when F(G(¬ψ)) ∈ M (Section 24, Case 4).
      Specifically: {target} ∪ g_content(M) can derive G(¬ψ), which contradicts F(ψ).
   6. F(G(¬ψ)) ∈ M is compatible with F(ψ) ∈ M (Section 19).

   OPTIONS:
   A. Find a non-standard consistency argument for the extended seed. UNCERTAIN.
   B. Use quasimodel bridge (800-1200 new LOC). MEDIUM confidence.
   C. Use a NON-LINEAR chain construction (omega-squared / tree) that avoids
      interference between defects. MEDIUM-HIGH confidence but complex.
   D. Prove that F(G(¬ψ)) ∈ M combined with F(ψ) ∈ M leads to a contradiction
      in BX logic (making Case 4 vacuous). This would make Path A work.

   OPTION D INVESTIGATION:
   F(G(¬ψ)) ∈ M and F(ψ) ∈ M.
   F(G(¬ψ)): "at some future time, ¬ψ holds forever after."
   F(ψ): "at some future time, ψ holds."
   By temporal linearity, one of these times comes first:
   - If ψ-time < G(¬ψ)-time: ψ holds, then later G(¬ψ) holds. Compatible.
   - If G(¬ψ)-time ≤ ψ-time: from G(¬ψ)-time onward, ¬ψ holds always.
     But ψ-time ≥ G(¬ψ)-time means ¬ψ holds at ψ-time. Contradiction with ψ at ψ-time.

   So the second case: G(¬ψ)-time ≤ ψ-time gives contradiction.
   The first case: ψ-time < G(¬ψ)-time is compatible.

   Therefore F(ψ) ∧ F(G(¬ψ)) IS satisfiable. Not a contradiction.
   Option D is BLOCKED.

   FINAL RECOMMENDATION: Option C (non-linear chain) or Option B (quasimodel bridge).

   For Phase 3 implementation, the most promising approach is Option C with
   an omega-squared interleaving where each defect gets a dedicated sub-chain
   that does NOT interact with other defects' resolutions.

   Alternatively: prove extended seed consistency for the RESTRICTED case where
   F(G(¬ψ)) ∉ M (i.e., G(F(ψ)) ∈ M), and handle the F(G(¬ψ)) ∈ M case
   separately via the BX11 argument from Section 18 which gives
   F(ψ ∧ F(G(¬ψ))) ∈ M, extracting ψ from this compound formula.

   END OF PROOF SKETCH
   ===================================================================== -/

/-! ## WF-Induction Infrastructure for forward_F

The f_nesting_depth induction resolves depth ≥ 1 trivially:
- If f_nesting_depth(ψ) ≥ 1, then ψ = F(ψ') for some ψ' with lower depth.
- F(F(ψ')) ∈ chain(n) → F(ψ') ∈ chain(n) by FF_imp_F_mcs.
- By IH: ψ' ∈ chain(s) for some s > n.
- ψ' ∈ chain(s) → F(ψ') = ψ ∈ chain(s) by phi_in_mcs_imp_F_phi.

The depth-0 base case remains the core mathematical challenge. -/

/-- If f_nesting_depth(ψ) ≥ 1, then ψ has the form some_future(ψ') for some ψ'. -/
theorem f_nesting_depth_pos_is_future (ψ : Formula) (h : f_nesting_depth ψ ≥ 1) :
    ∃ ψ' : Formula, ψ = Formula.some_future ψ' := by
  -- f_nesting_depth matches on .imp (.all_future (.imp inner .bot)) .bot
  -- If depth ≥ 1, then ψ must match this pattern
  cases ψ with
  | atom _ => simp [f_nesting_depth] at h
  | bot => simp [f_nesting_depth] at h
  | box _ => simp [f_nesting_depth] at h
  | all_future _ => simp [f_nesting_depth] at h
  | all_past _ => simp [f_nesting_depth] at h
  | untl _ _ => simp [f_nesting_depth] at h
  | snce _ _ => simp [f_nesting_depth] at h
  | imp a b =>
    cases a with
    | all_future c =>
      cases c with
      | imp inner d =>
        cases d with
        | bot =>
          cases b with
          | bot => exact ⟨inner, by simp [Formula.some_future, Formula.neg]⟩
          | _ => simp [f_nesting_depth] at h
        | _ => simp [f_nesting_depth] at h
      | _ => simp [f_nesting_depth] at h
    | _ => simp [f_nesting_depth] at h

/-- Depth ≥ 1 case of forward_F: reduces to IH at strictly lower depth.

Given F(ψ) ∈ chain(n) with f_nesting_depth(ψ) ≥ 1:
1. ψ = F(ψ') for some ψ' with f_nesting_depth(ψ') < f_nesting_depth(ψ)
2. F(F(ψ')) ∈ chain(n) → F(ψ') ∈ chain(n) by FF_imp_F_mcs
3. By IH (applied to ψ' at lower depth): ψ' ∈ chain(s) for some s > n
4. ψ' ∈ chain(s) → F(ψ') ∈ chain(s) by phi_in_mcs_imp_F_phi
5. F(ψ') = ψ, so ψ ∈ chain(s). Done. -/
theorem rr_fwd_chain_forward_F_depth_pos (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (sigma_list : List Formula) (h_nonempty : sigma_list.length > 0)
    -- sigma_list is closed under F-inner extraction (satisfied by deferralClosure)
    (h_closed : ∀ χ : Formula, Formula.some_future χ ∈ sigma_list → χ ∈ sigma_list)
    (n : Nat) (ψ : Formula)
    (hψ : ψ ∈ sigma_list)
    (h_F : Formula.some_future ψ ∈ (rr_fwd_chain M₀ h₀ sigma_list n).val)
    (h_depth : f_nesting_depth ψ ≥ 1)
    -- IH: forward_F holds for all formulas of strictly lower f_nesting_depth
    (ih : ∀ (m : Nat) (χ : Formula), χ ∈ sigma_list →
      f_nesting_depth χ < f_nesting_depth ψ →
      Formula.some_future χ ∈ (rr_fwd_chain M₀ h₀ sigma_list m).val →
      ∃ s : Nat, m < s ∧ χ ∈ (rr_fwd_chain M₀ h₀ sigma_list s).val) :
    ∃ s : Nat, n < s ∧ ψ ∈ (rr_fwd_chain M₀ h₀ sigma_list s).val := by
  -- Step 1: ψ = F(ψ') for some ψ'
  obtain ⟨ψ', rfl⟩ := f_nesting_depth_pos_is_future ψ h_depth
  -- Step 2: F(F(ψ')) ∈ chain(n) → F(ψ') ∈ chain(n)
  have h_Fψ' : Formula.some_future ψ' ∈ (rr_fwd_chain M₀ h₀ sigma_list n).val :=
    FF_imp_F_mcs (rr_fwd_chain M₀ h₀ sigma_list n).property ψ' h_F
  -- Step 3: depth of ψ' < depth of F(ψ') = ψ
  have h_depth_lt : f_nesting_depth ψ' < f_nesting_depth (Formula.some_future ψ') := by
    rw [f_nesting_depth_some_future]; omega
  -- Step 4: ψ' ∈ sigma_list (by closure under F-stripping)
  have hψ'_mem : ψ' ∈ sigma_list := h_closed ψ' hψ
  -- Step 5: Apply IH to get ψ' ∈ chain(s) for some s > n
  obtain ⟨s, h_lt, h_in⟩ := ih n ψ' hψ'_mem h_depth_lt h_Fψ'
  -- Step 6: ψ' ∈ chain(s) → F(ψ') ∈ chain(s) by phi_in_mcs_imp_F_phi
  exact ⟨s, h_lt, phi_in_mcs_imp_F_phi
    (rr_fwd_chain M₀ h₀ sigma_list s).property ψ' h_in⟩

/-- Forward_F for the forward Nat chain: F(ψ) ∈ chain(n) → ∃ s > n, ψ ∈ chain(s).

## Status

The f_nesting_depth induction resolves depth ≥ 1 trivially via FF_imp_F
(see `rr_fwd_chain_forward_F_depth_pos` above).

The depth-0 base case is the core mathematical challenge. The proof sketch
(Sections 1-30 above) exhaustively analyzes every approach and identifies
the precise obstruction: at resolving steps for other targets, the
Lindenbaum extension of {target} ∪ g_content(M) can choose G(¬ψ) over F(ψ),
permanently killing the F-obligation. Extended seed consistency
({target} ∪ g_content(M) ∪ f_carry(M)) fails in general when
F(G(¬ψ)) ∈ M (Case 4 analysis, Section 24).

The existing enriched chain preserves F(ψ) at every step (by
rr_fwd_chain_F_obligation_persists), but at each resolving step the
BX11 fold may resolve a DIFFERENT formula, perpetually deferring ψ
(Report 26).

Remaining viable paths for the depth-0 case:
(a) Non-linear chain construction (omega-squared interleaving)
(b) Quasimodel bridge (800-1200 new LOC)
(c) Proof that sigma_list membership + F-obligation persistence
    implies eventual resolution via a counting argument -/
theorem rr_fwd_chain_forward_F (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (sigma_list : List Formula) (h_nonempty : sigma_list.length > 0)
    -- sigma_list is closed under F-inner extraction (satisfied by deferralClosure)
    (h_closed : ∀ χ : Formula, Formula.some_future χ ∈ sigma_list → χ ∈ sigma_list)
    (n : Nat) (ψ : Formula)
    (hψ : ψ ∈ sigma_list)
    (h_F : Formula.some_future ψ ∈ (rr_fwd_chain M₀ h₀ sigma_list n).val) :
    ∃ s : Nat, n < s ∧ ψ ∈ (rr_fwd_chain M₀ h₀ sigma_list s).val := by
  -- Strong induction on f_nesting_depth(ψ)
  -- We prove a stronger statement: for all d, for all ψ with f_nesting_depth ψ = d,
  -- the forward_F property holds. Then instantiate with d = f_nesting_depth ψ.
  suffices h_ind : ∀ (d : Nat) (m : Nat) (χ : Formula), χ ∈ sigma_list →
      f_nesting_depth χ ≤ d →
      Formula.some_future χ ∈ (rr_fwd_chain M₀ h₀ sigma_list m).val →
      ∃ s : Nat, m < s ∧ χ ∈ (rr_fwd_chain M₀ h₀ sigma_list s).val from
    h_ind (f_nesting_depth ψ) n ψ hψ (le_refl _) h_F
  intro d
  induction d with
  | zero =>
    -- Base case: f_nesting_depth(χ) ≤ 0, i.e., = 0
    -- This is the depth-0 case: the core mathematical challenge.
    -- F(χ) ∈ chain(m), χ has no outer F-operators.
    -- F(χ) persists forever (rr_fwd_chain_F_obligation_forward).
    -- But perpetual deferral is possible (Report 26): at each visit step,
    -- the BX11 fold may resolve a different formula.
    -- This is the irreducible depth-0 obstruction.
    intro m χ _hχ_mem _hχ_depth _hχ_F
    sorry
  | succ d ih =>
    -- Inductive case: f_nesting_depth(χ) ≤ d + 1
    intro m χ hχ_mem hχ_depth hχ_F
    by_cases h_zero : f_nesting_depth χ = 0
    · -- Depth exactly 0: delegate to base case (which is sorry)
      exact ih m χ hχ_mem (by omega) hχ_F
    · -- Depth ≥ 1: use the depth_pos lemma
      have h_pos : f_nesting_depth χ ≥ 1 := by omega
      exact rr_fwd_chain_forward_F_depth_pos M₀ h₀ sigma_list h_nonempty h_closed
        m χ hχ_mem hχ_F h_pos (fun m' χ' hχ'_mem hχ'_lt hχ'_F =>
          ih m' χ' hχ'_mem (by omega) hχ'_F)

theorem dd_fmcs_forward_F (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (sigma_list : List Formula) (h_nonempty : sigma_list.length > 0)
    -- sigma_list is closed under F-inner extraction
    (h_closed : ∀ χ : Formula, Formula.some_future χ ∈ sigma_list → χ ∈ sigma_list)
    (t : Int) (ψ : Formula)
    (hψ : ψ ∈ sigma_list)
    (h_F : Formula.some_future ψ ∈ (dd_fmcs M₀ h₀ sigma_list).mcs t) :
    ∃ s : Int, t < s ∧ ψ ∈ (dd_fmcs M₀ h₀ sigma_list).mcs s := by
  -- dd_fmcs.mcs t = dd_chain M₀ h₀ sigma_list t
  -- For t ≥ 0: dd_chain = rr_fwd_chain(t.toNat). Use rr_fwd_chain_forward_F.
  -- For t < 0: dd_chain = rr_bwd_chain. Propagate F(ψ) to the forward chain.
  simp only [dd_fmcs] at h_F ⊢
  rcases le_or_gt 0 t with h_nonneg | h_neg
  · -- t ≥ 0: in the forward chain
    simp only [dd_chain] at h_F
    rw [if_pos h_nonneg] at h_F
    obtain ⟨s, h_lt, h_in⟩ := rr_fwd_chain_forward_F M₀ h₀ sigma_list h_nonempty h_closed
      t.toNat ψ hψ h_F
    refine ⟨Int.ofNat s, ?_, ?_⟩
    · rw [show t = Int.ofNat t.toNat from (Int.toNat_of_nonneg h_nonneg).symm]
      exact Int.ofNat_lt.mpr h_lt
    · simp only [dd_chain, show (Int.ofNat s ≥ 0) from Int.natCast_nonneg s, ite_true]
      exact h_in
  · -- t < 0: in the backward chain.
    -- F(ψ) ∈ bwd_chain((-t).toNat). Need to find s > t with ψ ∈ dd_chain(s).
    -- The backward chain does NOT preserve F-formulas (only h_content/p_carry).
    -- Approach: if F(ψ) ∈ dd_chain(t), then since g_content propagates forward
    -- (dd_chain_g_content), we would need G(F(ψ)) ∈ dd_chain(t) to propagate
    -- F(ψ) to M₀. This is not guaranteed.
    -- This sorry depends on rr_fwd_chain_forward_F being proved first;
    -- a solution to that problem would likely also resolve this case.
    sorry

theorem dd_fmcs_backward_P (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (sigma_list : List Formula) (t : Int) (ψ : Formula)
    (hψ : ψ ∈ sigma_list)
    (h_P : Formula.some_past ψ ∈ (dd_fmcs M₀ h₀ sigma_list).mcs t) :
    ∃ s : Int, s < t ∧ ψ ∈ (dd_fmcs M₀ h₀ sigma_list).mcs s := by
  sorry

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

end Bimodal.Metalogic.BXCanonical
