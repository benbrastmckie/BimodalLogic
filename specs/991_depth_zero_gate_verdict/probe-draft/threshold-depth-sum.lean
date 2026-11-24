/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.RaySummary.LadderStepFrag

/-!
# The two owed threshold inequalities FOLLOW from `ParamsOk`

The go/no-go probe for the step-fragment bridge.  `cellAt_const_of_kappa_eq_stepFrag` carries four
numeric hypotheses; the two threshold ones — `2 (dBack + dFwd) ≤ Tc` and `≤ Tn` — are owed by
`LadderStepFrag.lean`'s own module docstring and supplied by nothing in the tree.  This probe
establishes, by compilation and at GENERIC parameters, that both follow from `ParamsOk` through
`(K3)`'s two conjuncts and one new piece of pure syntax: the two exactness depths sum to at most
the subformula closure's cardinality.

The route, in three steps:

1. `dBack` is bounded by the number of `snce`-rooted closure members and `dFwd` by the number of
   `untl`-rooted ones.  The two filters are DISJOINT subsets of the closure, so the depths sum to
   at most its cardinality.
2. `k ≤ 2 ^ k` and `1 ≤ Fintype.card Q` carry that to the type-pigeonhole budget, which
   `card_prodState` reads as `tShort Q φ`.
3. `(K3)`'s second conjunct `2 * tShort + tIdle + 2 ≤ Tc` then gives the `Tc` form, and `(K3)`'s
   first conjunct `Tc + 2 * ell0 ≤ Tn + 1` carries it to `Tn` with two to spare.
-/

namespace FormalSystem.Metalogic.Decidability.RaySummary
namespace ProbeThresholdDepthSum

open FormalSystem.Syntax FormalSystem.PlusLanguage FormalSystem.Semantics

/-! ## A local size function, and no self-containment -/

/-- A local structural size on `PlusFormula`, used only to rule out a formula's own membership in
a proper subformula's closure.  `sizeOf` would do, but its `atom` arm reads `Atom`'s own size and
the arithmetic is cleaner with a function whose arms are written here. -/
def fsize : PlusFormula → ℕ
  | .atom _ => 1
  | .bot => 1
  | .imp α β => fsize α + fsize β + 1
  | .box α => fsize α + 1
  | .untl α β => fsize α + fsize β + 1
  | .snce α β => fsize α + fsize β + 1
  | .stab α => fsize α + 1

/-- The missing step `Subformulas.lean` does not carry: size is monotone along `subformulas`. -/
theorem fsize_le_of_mem_subformulas {ψ φ : PlusFormula}
    (h : ψ ∈ PlusFormula.subformulas φ) : fsize ψ ≤ fsize φ := by
  induction φ with
  | atom p =>
    simp only [PlusFormula.subformulas, List.mem_singleton] at h
    subst h; exact Nat.le_refl _
  | bot =>
    simp only [PlusFormula.subformulas, List.mem_singleton] at h
    subst h; exact Nat.le_refl _
  | imp α β ihα ihβ =>
    simp only [PlusFormula.subformulas, List.mem_cons, List.mem_append] at h
    rcases h with h | h | h
    · subst h; exact Nat.le_refl _
    · have := ihα h; simp only [fsize]; omega
    · have := ihβ h; simp only [fsize]; omega
  | box α ihα =>
    simp only [PlusFormula.subformulas, List.mem_cons] at h
    rcases h with h | h
    · subst h; exact Nat.le_refl _
    · have := ihα h; simp only [fsize]; omega
  | untl α β ihα ihβ =>
    simp only [PlusFormula.subformulas, List.mem_cons, List.mem_append] at h
    rcases h with h | h | h
    · subst h; exact Nat.le_refl _
    · have := ihβ h; simp only [fsize]; omega
    · have := ihα h; simp only [fsize]; omega
  | snce α β ihα ihβ =>
    simp only [PlusFormula.subformulas, List.mem_cons, List.mem_append] at h
    rcases h with h | h | h
    · subst h; exact Nat.le_refl _
    · have := ihβ h; simp only [fsize]; omega
    · have := ihα h; simp only [fsize]; omega
  | stab α ihα =>
    simp only [PlusFormula.subformulas, List.mem_cons] at h
    rcases h with h | h
    · subst h; exact Nat.le_refl _
    · have := ihα h; simp only [fsize]; omega

/-- A closure is monotone along the subformula relation, read off `subformulas_trans`. -/
theorem closure_subset_of_mem_subformulas {ψ φ : PlusFormula}
    (h : ψ ∈ PlusFormula.subformulas φ) :
    plusSubformulaClosure ψ ⊆ plusSubformulaClosure φ := by
  intro χ hχ
  simp only [plusSubformulaClosure, List.mem_toFinset] at hχ ⊢
  exact PlusFormula.subformulas_trans hχ h

/-! ## The two root predicates -/

/-- `snce`-rootedness, as a decidable `Bool`. -/
def isSnceB : PlusFormula → Bool
  | .snce _ _ => true
  | _ => false

/-- `untl`-rootedness, as a decidable `Bool`. -/
def isUntlB : PlusFormula → Bool
  | .untl _ _ => true
  | _ => false

/-- No formula is both `snce`-rooted and `untl`-rooted. -/
theorem not_isSnceB_of_isUntlB {ψ : PlusFormula} (h : isUntlB ψ = true) :
    isSnceB ψ = false := by
  cases ψ <;> simp_all [isSnceB, isUntlB]

/-! ## The two depth bounds -/

/-- **The backward depth is bounded by the `snce`-rooted closure members.** -/
theorem dBack_le_card_snce (φ : PlusFormula) :
    dBack φ ≤ ((plusSubformulaClosure φ).filter (fun ψ => isSnceB ψ = true)).card := by
  induction φ with
  | atom p => simp [dBack]
  | bot => simp [dBack]
  | imp α β ihα ihβ =>
    have hα : plusSubformulaClosure α ⊆ plusSubformulaClosure (PlusFormula.imp α β) :=
      closure_subset_of_mem_subformulas (PlusFormula.imp_left_mem_subformulas α β)
    have hβ : plusSubformulaClosure β ⊆ plusSubformulaClosure (PlusFormula.imp α β) :=
      closure_subset_of_mem_subformulas (PlusFormula.imp_right_mem_subformulas α β)
    have cα := Finset.card_le_card (Finset.filter_subset_filter (fun ψ => isSnceB ψ = true) hα)
    have cβ := Finset.card_le_card (Finset.filter_subset_filter (fun ψ => isSnceB ψ = true) hβ)
    simp only [dBack]
    omega
  | box α ihα =>
    have hα : plusSubformulaClosure α ⊆ plusSubformulaClosure (PlusFormula.box α) :=
      closure_subset_of_mem_subformulas (PlusFormula.box_inner_mem_subformulas α)
    have cα := Finset.card_le_card (Finset.filter_subset_filter (fun ψ => isSnceB ψ = true) hα)
    simp only [dBack]
    omega
  | stab α ihα =>
    have hα : plusSubformulaClosure α ⊆ plusSubformulaClosure (PlusFormula.stab α) :=
      closure_subset_of_mem_subformulas (PlusFormula.stab_inner_mem_subformulas α)
    have cα := Finset.card_le_card (Finset.filter_subset_filter (fun ψ => isSnceB ψ = true) hα)
    simp only [dBack]
    omega
  | untl α β ihα ihβ =>
    have hα : plusSubformulaClosure α ⊆ plusSubformulaClosure (PlusFormula.untl α β) :=
      closure_subset_of_mem_subformulas (PlusFormula.untl_right_mem_subformulas β α)
    have hβ : plusSubformulaClosure β ⊆ plusSubformulaClosure (PlusFormula.untl α β) :=
      closure_subset_of_mem_subformulas (PlusFormula.untl_left_mem_subformulas β α)
    have cα := Finset.card_le_card (Finset.filter_subset_filter (fun ψ => isSnceB ψ = true) hα)
    have cβ := Finset.card_le_card (Finset.filter_subset_filter (fun ψ => isSnceB ψ = true) hβ)
    simp only [dBack]
    omega
  | snce α β ihα ihβ =>
    -- The `+ 1` case: the root itself is a `snce`-rooted member of its own closure and of
    -- neither component's, so both components' filters embed in the root's filter with the
    -- root erased.
    set S := (plusSubformulaClosure (PlusFormula.snce α β)).filter
      (fun ψ => isSnceB ψ = true) with hS
    have hroot : PlusFormula.snce α β ∈ S := by
      rw [hS]
      refine Finset.mem_filter.mpr ⟨self_mem_plusSubformulaClosure _, ?_⟩
      simp [isSnceB]
    have hnotα : PlusFormula.snce α β ∉ plusSubformulaClosure α := by
      intro hmem
      simp only [plusSubformulaClosure, List.mem_toFinset] at hmem
      have := fsize_le_of_mem_subformulas hmem
      simp only [fsize] at this
      omega
    have hnotβ : PlusFormula.snce α β ∉ plusSubformulaClosure β := by
      intro hmem
      simp only [plusSubformulaClosure, List.mem_toFinset] at hmem
      have := fsize_le_of_mem_subformulas hmem
      simp only [fsize] at this
      omega
    have hα : plusSubformulaClosure α ⊆ plusSubformulaClosure (PlusFormula.snce α β) :=
      closure_subset_of_mem_subformulas (PlusFormula.snce_right_mem_subformulas β α)
    have hβ : plusSubformulaClosure β ⊆ plusSubformulaClosure (PlusFormula.snce α β) :=
      closure_subset_of_mem_subformulas (PlusFormula.snce_left_mem_subformulas β α)
    have eα : (plusSubformulaClosure α).filter (fun ψ => isSnceB ψ = true) ⊆
        S.erase (PlusFormula.snce α β) := by
      intro χ hχ
      obtain ⟨hχ1, hχ2⟩ := Finset.mem_filter.mp hχ
      refine Finset.mem_erase.mpr ⟨?_, ?_⟩
      · intro heq; exact hnotα (heq ▸ hχ1)
      · rw [hS]; exact Finset.mem_filter.mpr ⟨hα hχ1, hχ2⟩
    have eβ : (plusSubformulaClosure β).filter (fun ψ => isSnceB ψ = true) ⊆
        S.erase (PlusFormula.snce α β) := by
      intro χ hχ
      obtain ⟨hχ1, hχ2⟩ := Finset.mem_filter.mp hχ
      refine Finset.mem_erase.mpr ⟨?_, ?_⟩
      · intro heq; exact hnotβ (heq ▸ hχ1)
      · rw [hS]; exact Finset.mem_filter.mpr ⟨hβ hχ1, hχ2⟩
    have cα := Finset.card_le_card eα
    have cβ := Finset.card_le_card eβ
    rw [Finset.card_erase_of_mem hroot] at cα cβ
    have hpos : 1 ≤ S.card := Finset.card_pos.mpr ⟨_, hroot⟩
    simp only [dBack]
    omega

/-- **The forward depth is bounded by the `untl`-rooted closure members.** The mirror of
`dBack_le_card_snce`, with the `+ 1` case at `untl` instead of `snce`. -/
theorem dFwd_le_card_untl (φ : PlusFormula) :
    dFwd φ ≤ ((plusSubformulaClosure φ).filter (fun ψ => isUntlB ψ = true)).card := by
  induction φ with
  | atom p => simp [dFwd]
  | bot => simp [dFwd]
  | imp α β ihα ihβ =>
    have hα : plusSubformulaClosure α ⊆ plusSubformulaClosure (PlusFormula.imp α β) :=
      closure_subset_of_mem_subformulas (PlusFormula.imp_left_mem_subformulas α β)
    have hβ : plusSubformulaClosure β ⊆ plusSubformulaClosure (PlusFormula.imp α β) :=
      closure_subset_of_mem_subformulas (PlusFormula.imp_right_mem_subformulas α β)
    have cα := Finset.card_le_card (Finset.filter_subset_filter (fun ψ => isUntlB ψ = true) hα)
    have cβ := Finset.card_le_card (Finset.filter_subset_filter (fun ψ => isUntlB ψ = true) hβ)
    simp only [dFwd]
    omega
  | box α ihα =>
    have hα : plusSubformulaClosure α ⊆ plusSubformulaClosure (PlusFormula.box α) :=
      closure_subset_of_mem_subformulas (PlusFormula.box_inner_mem_subformulas α)
    have cα := Finset.card_le_card (Finset.filter_subset_filter (fun ψ => isUntlB ψ = true) hα)
    simp only [dFwd]
    omega
  | stab α ihα =>
    have hα : plusSubformulaClosure α ⊆ plusSubformulaClosure (PlusFormula.stab α) :=
      closure_subset_of_mem_subformulas (PlusFormula.stab_inner_mem_subformulas α)
    have cα := Finset.card_le_card (Finset.filter_subset_filter (fun ψ => isUntlB ψ = true) hα)
    simp only [dFwd]
    omega
  | snce α β ihα ihβ =>
    have hα : plusSubformulaClosure α ⊆ plusSubformulaClosure (PlusFormula.snce α β) :=
      closure_subset_of_mem_subformulas (PlusFormula.snce_right_mem_subformulas β α)
    have hβ : plusSubformulaClosure β ⊆ plusSubformulaClosure (PlusFormula.snce α β) :=
      closure_subset_of_mem_subformulas (PlusFormula.snce_left_mem_subformulas β α)
    have cα := Finset.card_le_card (Finset.filter_subset_filter (fun ψ => isUntlB ψ = true) hα)
    have cβ := Finset.card_le_card (Finset.filter_subset_filter (fun ψ => isUntlB ψ = true) hβ)
    simp only [dFwd]
    omega
  | untl α β ihα ihβ =>
    set S := (plusSubformulaClosure (PlusFormula.untl α β)).filter
      (fun ψ => isUntlB ψ = true) with hS
    have hroot : PlusFormula.untl α β ∈ S := by
      rw [hS]
      refine Finset.mem_filter.mpr ⟨self_mem_plusSubformulaClosure _, ?_⟩
      simp [isUntlB]
    have hnotα : PlusFormula.untl α β ∉ plusSubformulaClosure α := by
      intro hmem
      simp only [plusSubformulaClosure, List.mem_toFinset] at hmem
      have := fsize_le_of_mem_subformulas hmem
      simp only [fsize] at this
      omega
    have hnotβ : PlusFormula.untl α β ∉ plusSubformulaClosure β := by
      intro hmem
      simp only [plusSubformulaClosure, List.mem_toFinset] at hmem
      have := fsize_le_of_mem_subformulas hmem
      simp only [fsize] at this
      omega
    have hα : plusSubformulaClosure α ⊆ plusSubformulaClosure (PlusFormula.untl α β) :=
      closure_subset_of_mem_subformulas (PlusFormula.untl_right_mem_subformulas β α)
    have hβ : plusSubformulaClosure β ⊆ plusSubformulaClosure (PlusFormula.untl α β) :=
      closure_subset_of_mem_subformulas (PlusFormula.untl_left_mem_subformulas β α)
    have eα : (plusSubformulaClosure α).filter (fun ψ => isUntlB ψ = true) ⊆
        S.erase (PlusFormula.untl α β) := by
      intro χ hχ
      obtain ⟨hχ1, hχ2⟩ := Finset.mem_filter.mp hχ
      refine Finset.mem_erase.mpr ⟨?_, ?_⟩
      · intro heq; exact hnotα (heq ▸ hχ1)
      · rw [hS]; exact Finset.mem_filter.mpr ⟨hα hχ1, hχ2⟩
    have eβ : (plusSubformulaClosure β).filter (fun ψ => isUntlB ψ = true) ⊆
        S.erase (PlusFormula.untl α β) := by
      intro χ hχ
      obtain ⟨hχ1, hχ2⟩ := Finset.mem_filter.mp hχ
      refine Finset.mem_erase.mpr ⟨?_, ?_⟩
      · intro heq; exact hnotβ (heq ▸ hχ1)
      · rw [hS]; exact Finset.mem_filter.mpr ⟨hβ hχ1, hχ2⟩
    have cα := Finset.card_le_card eα
    have cβ := Finset.card_le_card eβ
    rw [Finset.card_erase_of_mem hroot] at cα cβ
    have hpos : 1 ≤ S.card := Finset.card_pos.mpr ⟨_, hroot⟩
    simp only [dFwd]
    omega

/-! ## The pure-syntax bound -/

/-- **THE TWO EXACTNESS DEPTHS SUM TO AT MOST THE CLOSURE'S CARDINALITY.** The one new piece of
mathematical content the threshold discharge needs: `dBack` counts `snce`-rooted closure members
and `dFwd` counts `untl`-rooted ones, and no member is both. -/
theorem dBack_add_dFwd_le_closure_card (φ : PlusFormula) :
    dBack φ + dFwd φ ≤ (plusSubformulaClosure φ).card := by
  classical
  have h1 := dBack_le_card_snce φ
  have h2 := dFwd_le_card_untl φ
  have hsub : (plusSubformulaClosure φ).filter (fun ψ => isUntlB ψ = true) ⊆
      (plusSubformulaClosure φ).filter (fun ψ => ¬ (isSnceB ψ = true)) := by
    intro χ hχ
    obtain ⟨hχ1, hχ2⟩ := Finset.mem_filter.mp hχ
    exact Finset.mem_filter.mpr ⟨hχ1, by simp [not_isSnceB_of_isUntlB hχ2]⟩
  have hc := Finset.card_le_card hsub
  have hsplit :
      ((plusSubformulaClosure φ).filter (fun ψ => isSnceB ψ = true)).card +
        ((plusSubformulaClosure φ).filter (fun ψ => ¬ (isSnceB ψ = true))).card =
          (plusSubformulaClosure φ).card :=
    Finset.card_filter_add_card_filter_not (fun ψ => isSnceB ψ = true)
  omega

/-! ## The two threshold discharges -/

/-- The depth sum is bounded by `(K3)`'s short-region threshold. -/
theorem dBack_add_dFwd_le_tShort {Q : Type} [Fintype Q] [Nonempty Q] (φ : PlusFormula) :
    dBack φ + dFwd φ ≤ tShort Q φ := by
  have hcard := dBack_add_dFwd_le_closure_card φ
  have hpow : (plusSubformulaClosure φ).card ≤ 2 ^ (plusSubformulaClosure φ).card :=
    Nat.le_of_lt (Nat.lt_two_pow_self)
  have hQ : 1 ≤ Fintype.card Q := Fintype.card_pos
  have hmul : 2 ^ (plusSubformulaClosure φ).card ≤
      Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card :=
    Nat.le_mul_of_pos_left _ hQ
  have hts : tShort Q φ = Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card := by
    rw [tShort, card_prodState]
  omega

/-- `(K3)`'s idle slack is at least one: it is a cardinality plus one. -/
theorem one_le_tIdle {Q : Type} [Fintype Q] (pend : Q → Bool) : 1 ≤ tIdle pend := by
  simp [tIdle]

/-- **THE FIRST OWED THRESHOLD, DISCHARGED FROM `ParamsOk`.** -/
theorem paramsOk_two_depth_sum_le_Tc {Q : Type} [Fintype Q] [Nonempty Q]
    (step : Q → Q → Bool) (pend : Q → Bool) (lab : Q → Atom → Bool) (φ : PlusFormula)
    (Tc Tn P B : ℕ) (hp : ParamsOk step pend lab φ Tc Tn P B) :
    2 * (dBack φ + dFwd φ) ≤ Tc := by
  obtain ⟨-, -, ⟨-, hK3b⟩, -⟩ := hp
  have hts : dBack φ + dFwd φ ≤ tShort Q φ := dBack_add_dFwd_le_tShort φ
  have hti : 1 ≤ tIdle pend := one_le_tIdle pend
  omega

/-- **THE SECOND OWED THRESHOLD, DISCHARGED FROM `ParamsOk`.** `(K3)`'s ordering carries the `Tc`
form to `Tn` with two to spare, because `(K3)`'s own short-region conjunct leaves
`tIdle pend + 2 ≥ 3` above `2 * tShort` under `Tc`. -/
theorem paramsOk_two_depth_sum_le_Tn {Q : Type} [Fintype Q] [Nonempty Q]
    (step : Q → Q → Bool) (pend : Q → Bool) (lab : Q → Atom → Bool) (φ : PlusFormula)
    (Tc Tn P B : ℕ) (hp : ParamsOk step pend lab φ Tc Tn P B) :
    2 * (dBack φ + dFwd φ) ≤ Tn := by
  obtain ⟨-, -, ⟨hK3a, hK3b⟩, -⟩ := hp
  have hts : dBack φ + dFwd φ ≤ tShort Q φ := dBack_add_dFwd_le_tShort φ
  have hti : 1 ≤ tIdle pend := one_le_tIdle pend
  omega

/-! ## Axiom profiles -/

#print axioms fsize_le_of_mem_subformulas
#print axioms closure_subset_of_mem_subformulas
#print axioms not_isSnceB_of_isUntlB
#print axioms dBack_le_card_snce
#print axioms dFwd_le_card_untl
#print axioms dBack_add_dFwd_le_closure_card
#print axioms dBack_add_dFwd_le_tShort
#print axioms one_le_tIdle
#print axioms paramsOk_two_depth_sum_le_Tc
#print axioms paramsOk_two_depth_sum_le_Tn

end ProbeThresholdDepthSum
end FormalSystem.Metalogic.Decidability.RaySummary
