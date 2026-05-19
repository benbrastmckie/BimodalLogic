/-!
# Point Insertion Legacy Code (Archived)

Code archived from `PointInsertion.lean` during task 107 Phase 3
(Restructure Lemma 2.6 with Burgess D0 Seed).

These functions were part of an approach that tried to prove
`g_content(A) ⊆ B` and `h_content(C) ⊆ B` for `BurgessR3Maximal(A, B, C)`.
The consistent case of each was proved, but the inconsistent case hits a
"density gap": `G(φ) ∈ A` and `untl(φ.neg, γ) ∈ A` are semantically
contradictory on dense orders but BX has no density axiom to derive ⊥.

The new approach in `splitting_seed_consistent` consolidates both sorry
sites into a single density gap sorry, and documents the gap clearly.

## Archived Functions

- `G_conj_strengthen`: G(β → β∧φ) ∈ A from G(φ) ∈ A
- `g_content_consistent_case`: Consistent case helper for g_content ⊆ B
- `H_conj_strengthen`: H(β → β∧ψ) ∈ C from H(ψ) ∈ C
- `g_content_sub_B_of_BurgessR3Maximal`: g_content(A) ⊆ B (2 sorry sites)
- `h_content_sub_B_of_BurgessR3Maximal`: h_content(C) ⊆ B (2 sorry sites)
- `splitting_seed_consistent` (old version): Seed consistency via g_content ⊆ B

## Date
2026-04-30, Task 107 Phase 3

## See Also
- `PointInsertion.lean`: Current implementation with consolidated sorry
- `RRelation.lean`: `burgessR3Maximal_from_g_content_sub`
-/

-- NOTE: This file is NOT compiled. It is a documentation archive only.
-- The code below is preserved for reference and was valid Lean 4 at the
-- time of archival but may not compile standalone due to removed imports.

/-
/-- Helper: G(β → β∧φ) ∈ A from G(φ) ∈ A, using conj_intro_curried + TG + temp_k_dist. -/
private theorem G_conj_strengthen {A : Set Formula}
    (h_mcs_A : SetMaximalConsistent A) (β φ : Formula)
    (h_Gφ : Formula.all_future φ ∈ A) :
    (β.imp (Formula.and β φ)).all_future ∈ A := by
  have d_conj := conj_intro_curried β φ
  exact SetMaximalConsistent.implication_property h_mcs_A
    (SetMaximalConsistent.implication_property h_mcs_A
      (theorem_in_mcs h_mcs_A (Bimodal.Theorems.TemporalDerived.temp_k_dist_derived φ (β.imp (Formula.and β φ)))))
      (theorem_in_mcs h_mcs_A (DerivationTree.temporal_necessitation _ d_conj)))
    h_Gφ

/-- Consistent case helper for g_content_sub_B: when {φ}∪B consistent and G(φ) ∈ A,
    dc_delta_B_burgessR3 produces burgessR3(A, DC({φ}∪B), C). -/
private theorem g_content_consistent_case {A B C : Set Formula}
    (h_mcs_A : SetMaximalConsistent A) (h_mcs_C : SetMaximalConsistent C)
    (h_r3m : BurgessR3Maximal A B C)
    (h_gc : g_content A ⊆ C)
    {φ : Formula} (h_Gφ : Formula.all_future φ ∈ A)
    (h_cons : SetConsistent ({φ} ∪ B)) :
    burgessR3 A (deductiveClosure ({φ} ∪ B)) C := by
  apply dc_delta_B_burgessR3 h_mcs_A h_mcs_C h_r3m.1 h_r3m.2.1
  · -- Until: ∀ β ∈ B, ∀ γ ∈ C, untl(β ∧ φ, γ) ∈ A
    intro β hβ γ hγ
    exact untl_left_mono_G h_mcs_A (G_conj_strengthen h_mcs_A β φ h_Gφ) (h_r3m.2.1.1 β hβ γ hγ)
  · -- Since: ∀ β ∈ B, ∀ α ∈ A, snce(β ∧ φ, α) ∈ C via burgessR_implies_burgessRSince
    intro β hβ α hα
    have h_burgessR : burgessR A (Formula.and β φ) C := fun γ hγ =>
      untl_left_mono_G h_mcs_A (G_conj_strengthen h_mcs_A β φ h_Gφ) (h_r3m.2.1.1 β hβ γ hγ)
    exact burgessR_implies_burgessRSince h_mcs_A h_mcs_C h_burgessR α hα

/-- Helper: H(β → β∧ψ) ∈ C from H(ψ) ∈ C, using conj_intro_curried + past_necessitation + past_k_dist. -/
private theorem H_conj_strengthen {C : Set Formula}
    (h_mcs_C : SetMaximalConsistent C) (β ψ : Formula)
    (h_Hψ : Formula.all_past ψ ∈ C) :
    (β.imp (Formula.and β ψ)).all_past ∈ C := by
  have d_conj := conj_intro_curried β ψ
  exact SetMaximalConsistent.implication_property h_mcs_C
    (SetMaximalConsistent.implication_property h_mcs_C
      (theorem_in_mcs h_mcs_C (Bimodal.Theorems.past_k_dist ψ (β.imp (Formula.and β ψ))))
      (theorem_in_mcs h_mcs_C (Bimodal.Theorems.past_necessitation _ d_conj)))
    h_Hψ

/-- g_content(A) ⊆ B when BurgessR3Maximal(A, B, C).

The consistent case ({φ}∪B consistent) is proved via left_mono_until_G +
dc_delta_B_burgessR3 + BurgessR3Maximal_extension_fails.

The inconsistent case ({φ}∪B inconsistent): SORRY (density gap).
φ.neg ∈ B (by DCS closure). From G(φ) ∈ A and untl(φ.neg, γ) ∈ A:
semantically contradictory on dense orders (guard φ.neg on non-empty (t,s)
contradicts G(φ)), but BX lacks a density axiom to derive the contradiction. -/
theorem g_content_sub_B_of_BurgessR3Maximal {A B C : Set Formula}
    (h_mcs_A : SetMaximalConsistent A) (h_mcs_C : SetMaximalConsistent C)
    (h_r3m : BurgessR3Maximal A B C)
    (h_gc : g_content A ⊆ C) :
    g_content A ⊆ B := by
  intro φ hφ
  by_contra h_not_B
  by_cases h_cons : SetConsistent ({φ} ∪ B)
  · exact BurgessR3Maximal_extension_fails h_r3m h_not_B h_cons
      (g_content_consistent_case h_mcs_A h_mcs_C h_r3m h_gc hφ h_cons)
  · sorry -- Density gap

/-- h_content(C) ⊆ B when BurgessR3Maximal(A, B, C) (dual).
Same density gap sorry as g_content_sub_B. -/
theorem h_content_sub_B_of_BurgessR3Maximal {A B C : Set Formula}
    (h_mcs_A : SetMaximalConsistent A) (h_mcs_C : SetMaximalConsistent C)
    (h_r3m : BurgessR3Maximal A B C)
    (h_gc : g_content A ⊆ C) :
    h_content C ⊆ B := by
  intro ψ hψ
  by_contra h_not_B
  by_cases h_cons : SetConsistent ({ψ} ∪ B)
  · apply BurgessR3Maximal_extension_fails h_r3m h_not_B h_cons
    apply dc_delta_B_burgessR3 h_mcs_A h_mcs_C h_r3m.1 h_r3m.2.1
    · intro β hβ γ hγ
      have h_burgessRSince : burgessRSince C (Formula.and β ψ) A := fun α hα =>
        snce_left_mono_H h_mcs_C (H_conj_strengthen h_mcs_C β ψ hψ) (h_r3m.2.1.2 β hβ α hα)
      exact burgessRSince_implies_burgessR h_mcs_A h_mcs_C h_burgessRSince γ hγ
    · intro β hβ α hα
      exact snce_left_mono_H h_mcs_C (H_conj_strengthen h_mcs_C β ψ hψ) (h_r3m.2.1.2 β hβ α hα)
  · sorry -- Density gap

/-- Old seed consistency for Lemma 2.6 splitting (via g_content ⊆ B reduction). -/
private theorem splitting_seed_consistent {A B C : Set Formula}
    (h_mcs_A : SetMaximalConsistent A)
    (h_mcs_C : SetMaximalConsistent C)
    (h_r3m : BurgessR3Maximal A B C)
    (h_gc : g_content A ⊆ C)
    (β : Formula)
    (h_β_not_B : β ∉ B) :
    SetConsistent ({β.neg} ∪ g_content A ∪ h_content C) := by
  have h_gc_B := g_content_sub_B_of_BurgessR3Maximal h_mcs_A h_mcs_C h_r3m h_gc
  have h_hc_B := h_content_sub_B_of_BurgessR3Maximal h_mcs_A h_mcs_C h_r3m h_gc
  have h_sub : {β.neg} ∪ g_content A ∪ h_content C ⊆ {β.neg} ∪ B := by
    intro φ hφ
    rcases hφ with (hφ | hφ) | hφ
    · exact Set.mem_union_left _ hφ
    · exact Set.mem_union_right _ (h_gc_B hφ)
    · exact Set.mem_union_right _ (h_hc_B hφ)
  have h_cons := dcs_neg_union_consistent h_r3m.1 h_β_not_B
  exact fun L hL hd => h_cons L (fun ψ hψ => h_sub (hL ψ hψ)) hd
-/
