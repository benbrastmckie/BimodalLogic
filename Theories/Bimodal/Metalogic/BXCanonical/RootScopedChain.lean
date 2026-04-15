import Bimodal.Metalogic.BXCanonical.OrderedSeedConsistency
import Bimodal.Metalogic.BXCanonical.CanonicalModel
import Bimodal.Metalogic.Bundle.UntilSinceCoherence

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

/-- Forward_F for the forward Nat chain: F(ψ) ∈ chain(n) → ∃ s > n, ψ ∈ chain(s).

## Proof infrastructure (completed)

The `enriched_fwd_step` now uses `resolving_enriched_fwd_exists` which guarantees
via `enriched_fwd_fold_with_witness` that at least one formula with F-obligation
is directly resolved at each resolving step (see `enriched_fwd_step_resolves_one`).

## Remaining difficulty

The F-obligation set {χ ∈ sigma_list | F(χ) ∈ chain(m)} is STABLE: it never
grows (by `no_new_f_defects`) and never shrinks (because χ ∈ M → F(χ) ∈ M
for any MCS M, by contrapositive of temp_t). This means:
- Every formula that ever gains an F-obligation keeps it forever
- The "defect set" {χ | F(χ) ∈ chain(m) ∧ χ ∉ chain(m)} can fluctuate:
  formulas can be resolved (χ ∈ chain(m+1)) but then lost again at a later
  step (χ ∉ chain(m+2) while F(χ) persists)

So the defect count is NOT a valid well-founded measure for induction.

## Correct approach (not yet implemented)

The fix requires proving consistency of the extended seed:
  {target} ∪ g_content(M) ∪ f_carry(M) is consistent when F(target) ∈ M.

This would allow defining a forward step that BOTH resolves the target
(target ∈ M') AND preserves all F-formulas (f_carry(M) ⊆ M').
With such a step, forward_F follows immediately: at ψ's visit step,
F(ψ) ∈ chain(m) (by f_carry persistence) and target = ψ gives ψ ∈ chain(m+1).

The consistency proof likely requires showing that g_content(M) cannot derive
G(¬χ) for any F(χ) ∈ f_carry(M), combined with the target consistency from
forward_temporal_witness_seed_consistent. The standard generalized_temporal_k
argument does not directly extend to seeds containing F-formulas alongside
G-formulas, because G(F(χ)) ∈ M is not guaranteed from F(χ) ∈ M. -/
theorem rr_fwd_chain_forward_F (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (sigma_list : List Formula) (h_nonempty : sigma_list.length > 0)
    (n : Nat) (ψ : Formula)
    (hψ : ψ ∈ sigma_list)
    (h_F : Formula.some_future ψ ∈ (rr_fwd_chain M₀ h₀ sigma_list n).val) :
    ∃ s : Nat, n < s ∧ ψ ∈ (rr_fwd_chain M₀ h₀ sigma_list s).val := by
  sorry

theorem dd_fmcs_forward_F (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (sigma_list : List Formula) (h_nonempty : sigma_list.length > 0)
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
    obtain ⟨s, h_lt, h_in⟩ := rr_fwd_chain_forward_F M₀ h₀ sigma_list h_nonempty
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
