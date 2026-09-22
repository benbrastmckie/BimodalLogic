/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Conservativity.MinusMCS

/-!
# The canonical relations on L⁻ maximal consistent sets

The two canonical relations of the L⁻ canonical model — the temporal successor relation `canR`
(`Gχ ∈ Γ ⟹ χ ∈ Δ`) and the modal relation `canBox` (`□χ ∈ Γ ⟹ χ ∈ Δ`) — on `MPoint fc`
carriers, together with every relational fact the ℚ-chronicle construction
(`Conservativity/MinusChronicle.lean`) and the truth lemma
(`Conservativity/MinusChainCompleteness.lean`) consume. The declarations mirror
`Metalogic/BXCanonical/Frame.lean` (`BxLe` ↔ `canR`, `BxModalEquiv` ↔ `canBox`,
`g_content_set_consistent`, `bx_forward_witness`, `bx_modal_witness`) and
`Metalogic/BXCanonical/TruthLemma.lean` (`F_from_witness`), transposed to `MinusFormula`.

## Frame-class discipline

Everything is stated at a variable `fc` except **density**, `exists_canR_between`, which
consumes `fF_of_f` (the one DN use) and is therefore stated at `FrameClass.Dense` only. Nothing
here concludes a completeness statement; the relations are the raw material of one.

## Main Results

* `canR_trans` (T4), `canR_iff_past` (TC and its mirror), `F_of_canR`, `P_of_canR`
* Existence: `exists_canR_of_F`, `exists_canR_of_P`, `exists_canBox_of_dia`, and their
  `¬G`/`¬H`/`¬□` forms; seriality `exists_canR_serial`, `exists_canR_serial_past`
* **Density** at `.Dense`: `exists_canR_between`
* **Weak linearity**, both sides: `canR_weakLinear_right` (TL), `canR_weakLinear_left` (TR
  mirror of TL)
* `canBox_refl`, `canBox_symm`, `canBox_trans` (S5), `canBox_of_canR`, `canBox_of_canR_rev`
  (MF and its TR mirror)

## References

* `FormalSystem/Metalogic/BXCanonical/Frame.lean`, `TruthLemma.lean` — the L-side copy sources
* `FormalSystem/Metalogic/Conservativity/MinusTemporalDerived.lean` — the derivations consumed
* Burgess, *Basic Tense Logic* (1984), §2.5 — density and linearity of the canonical order

## Tags

conservativity · base-language · canonical-model · density · linearity
-/

namespace FormalSystem.Metalogic.Conservativity

open FormalSystem.Syntax
open FormalSystem.ProofSystem (FrameClass)
open FormalSystem.MinusLanguage

variable {fc : FrameClass}

/-! ## The relations -/

/-- The canonical `G`-relation: `Γ R Δ` iff every `Gχ ∈ Γ` has `χ ∈ Δ`. -/
def canR (Γ Δ : Set MinusFormula) : Prop :=
  ∀ χ : MinusFormula, χ.allFuture ∈ Γ → χ ∈ Δ

/-- The canonical `□`-relation: `Γ ~ Δ` iff every `□χ ∈ Γ` has `χ ∈ Δ`. -/
def canBox (Γ Δ : Set MinusFormula) : Prop :=
  ∀ χ : MinusFormula, χ.box ∈ Γ → χ ∈ Δ

/-- `{χ | Gχ ∈ Γ}`. -/
def GContent (Γ : Set MinusFormula) : Set MinusFormula := {χ | χ.allFuture ∈ Γ}

/-- `{χ | Hχ ∈ Γ}`. -/
def HContent (Γ : Set MinusFormula) : Set MinusFormula := {χ | χ.allPast ∈ Γ}

/-- `{χ | □χ ∈ Γ}`. -/
def BoxContent (Γ : Set MinusFormula) : Set MinusFormula := {χ | χ.box ∈ Γ}

/-! ## Negated universals inside an MCS -/

namespace MinusSetMaximalConsistent

variable {S : Set MinusFormula}

/-- `Gψ ∉ S ⟹ F¬ψ ∈ S`. -/
theorem someFuture_neg_of_not_allFuture (h : MinusSetMaximalConsistent fc S) {ψ : MinusFormula}
    (hn : ψ.allFuture ∉ S) : ψ.neg.someFuture ∈ S := by
  change ψ.neg.neg.allFuture.neg ∈ S
  exact h.neg_mem_iff_not_mem.mpr (fun hG => hn (h.mp_of_theorem (gMono (minusDne ψ)) hG))

/-- `Hψ ∉ S ⟹ P¬ψ ∈ S`. -/
theorem somePast_neg_of_not_allPast (h : MinusSetMaximalConsistent fc S) {ψ : MinusFormula}
    (hn : ψ.allPast ∉ S) : ψ.neg.somePast ∈ S := by
  change ψ.neg.neg.allPast.neg ∈ S
  exact h.neg_mem_iff_not_mem.mpr (fun hH => hn (h.mp_of_theorem (hMono (minusDne ψ)) hH))

/-- `□ψ ∉ S ⟹ ◇¬ψ ∈ S`. -/
theorem diamond_neg_of_not_box (h : MinusSetMaximalConsistent fc S) {ψ : MinusFormula}
    (hn : ψ.box ∉ S) : ψ.neg.diamond ∈ S := by
  change ψ.neg.neg.box.neg ∈ S
  exact h.neg_mem_iff_not_mem.mpr (fun hB => hn (h.mp_of_theorem (boxMono (minusDne ψ)) hB))

end MinusSetMaximalConsistent

/-! ## Transitivity, the past characterisation, and witnesses -/

/-- **T4**: `canR` is transitive on points. -/
theorem canR_trans {Γ Δ Θ : MPoint fc} (h₁ : canR Γ.1 Δ.1) (h₂ : canR Δ.1 Θ.1) :
    canR Γ.1 Θ.1 :=
  fun χ hχ => h₂ χ (h₁ _ (Γ.2.mp_of_theorem (g4 χ) hχ))

/-- **The past characterisation of `canR`**: `Γ R Δ` iff every `Hχ ∈ Δ` has `χ ∈ Γ`. Forward
by TC (`¬χ → GP¬χ`) and `Hχ → H¬¬χ`; backward by its mirror `tcPast` (`¬χ → HF¬χ`) and
`Gχ → G¬¬χ`. -/
theorem canR_iff_past (Γ Δ : MPoint fc) :
    canR Γ.1 Δ.1 ↔ ∀ χ : MinusFormula, χ.allPast ∈ Δ.1 → χ ∈ Γ.1 := by
  constructor
  · intro h χ hH
    by_contra hχ
    have hnχ : χ.neg ∈ Γ.1 := Γ.2.not_mem_iff_neg_mem.mp hχ
    have hGP : χ.neg.somePast.allFuture ∈ Γ.1 := Γ.2.mp_of_theorem (tcFuture χ.neg) hnχ
    have hP : χ.neg.somePast ∈ Δ.1 := h _ hGP
    have hHnn : χ.neg.neg.allPast ∈ Δ.1 := Δ.2.mp_of_theorem (hMono (minusNotNotIntro χ)) hH
    exact Δ.2.not_both hHnn hP
  · intro h χ hG
    by_contra hχ
    have hnχ : χ.neg ∈ Δ.1 := Δ.2.not_mem_iff_neg_mem.mp hχ
    have hHF : χ.neg.someFuture.allPast ∈ Δ.1 := Δ.2.mp_of_theorem (tcPast χ.neg) hnχ
    have hF : χ.neg.someFuture ∈ Γ.1 := h _ hHF
    have hGnn : χ.neg.neg.allFuture ∈ Γ.1 := Γ.2.mp_of_theorem (gMono (minusNotNotIntro χ)) hG
    exact Γ.2.not_both hGnn hF

/-- `Γ R Δ` and `ψ ∈ Δ` give `Fψ ∈ Γ`. -/
theorem F_of_canR {Γ Δ : MPoint fc} (h : canR Γ.1 Δ.1) {ψ : MinusFormula} (hψ : ψ ∈ Δ.1) :
    ψ.someFuture ∈ Γ.1 := by
  by_contra hn
  have hG : ψ.neg.allFuture ∈ Γ.1 := Γ.2.neg_neg_mem_iff.mp (Γ.2.not_mem_iff_neg_mem.mp hn)
  exact Δ.2.not_both hψ (h _ hG)

/-- `Γ R Δ` and `ψ ∈ Γ` give `Pψ ∈ Δ`. -/
theorem P_of_canR {Γ Δ : MPoint fc} (h : canR Γ.1 Δ.1) {ψ : MinusFormula} (hψ : ψ ∈ Γ.1) :
    ψ.somePast ∈ Δ.1 := by
  by_contra hn
  have hH : ψ.neg.allPast ∈ Δ.1 := Δ.2.neg_neg_mem_iff.mp (Δ.2.not_mem_iff_neg_mem.mp hn)
  exact Γ.2.not_both hψ ((canR_iff_past Γ Δ).mp h _ hH)

/-! ## Existence

One generic Lindenbaum-seed lemma, `insert_content_consistent`, covers the three witness
lemmas: the operator `op` is `G`, `H` or `□`, and the generalized K rule for `op` turns a
derivation of `¬ψ` from `op`-content into `op ¬ψ ∈ Γ`, refuting `¬ op ¬ψ ∈ Γ`. -/

/-- Generic seed consistency: if `(op ¬ψ).neg ∈ Γ` and `op` admits a generalized K rule, then
`insert ψ {χ | op χ ∈ Γ}` is consistent. -/
theorem insert_content_consistent (Γ : MPoint fc) (op : MinusFormula → MinusFormula)
    (genK : ∀ (Γ' : Context) (χ : MinusFormula), (Γ' ⊢⁻[fc] χ) → ((Γ'.map op) ⊢⁻[fc] op χ))
    (ψ : MinusFormula) (hψ : (op ψ.neg).neg ∈ Γ.1) :
    MinusSetConsistent fc (insert ψ {χ | op χ ∈ Γ.1}) := by
  intro L hL ⟨d⟩
  let Γ' := L.filter (fun y => decide (y ≠ ψ))
  have hsub : L ⊆ ψ :: Γ' := by
    intro x hx
    by_cases hxψ : x = ψ
    · subst hxψ; exact List.mem_cons_self
    · exact List.mem_cons_of_mem _ (List.mem_filter.mpr ⟨hx, by simpa using hxψ⟩)
  have dneg : Γ' ⊢⁻[fc] ψ.neg := deductionOfSubset Γ' ψ d hsub
  have dop : (Γ'.map op) ⊢⁻[fc] op ψ.neg := genK Γ' ψ.neg dneg
  have hmap : ∀ x ∈ Γ'.map op, x ∈ Γ.1 := by
    intro x hx
    obtain ⟨χ, hχ, rfl⟩ := List.mem_map.mp hx
    have hm := List.mem_filter.mp hχ
    have hne : χ ≠ ψ := by simpa using hm.2
    rcases Set.mem_insert_iff.mp (hL χ hm.1) with heq | hc
    · exact absurd heq hne
    · exact hc
  exact Γ.2.not_both (Γ.2.closed_under_derivation _ hmap dop) hψ

/-- **Future witness**: `Fψ ∈ Γ` gives `Δ` with `Γ R Δ` and `ψ ∈ Δ`. -/
theorem exists_canR_of_F (Γ : MPoint fc) {ψ : MinusFormula} (hψ : ψ.someFuture ∈ Γ.1) :
    ∃ Δ : MPoint fc, canR Γ.1 Δ.1 ∧ ψ ∈ Δ.1 := by
  obtain ⟨Δ, hΔ⟩ := exists_mpoint_extending _
    (insert_content_consistent Γ MinusFormula.allFuture
      (fun Γ' χ d => minusGeneralizedTemporalK Γ' d) ψ hψ)
  exact ⟨Δ, fun χ hχ => hΔ (Set.mem_insert_of_mem _ hχ), hΔ (Set.mem_insert _ _)⟩

/-- `Gψ ∉ Γ` gives `Δ` with `Γ R Δ` and `¬ψ ∈ Δ`. -/
theorem exists_canR_of_not_G (Γ : MPoint fc) {ψ : MinusFormula} (hn : ψ.allFuture ∉ Γ.1) :
    ∃ Δ : MPoint fc, canR Γ.1 Δ.1 ∧ ψ.neg ∈ Δ.1 :=
  exists_canR_of_F Γ (Γ.2.someFuture_neg_of_not_allFuture hn)

/-- **Past witness**: `Pψ ∈ Γ` gives `Δ` with `Δ R Γ` and `ψ ∈ Δ`, through the past
characterisation. -/
theorem exists_canR_of_P (Γ : MPoint fc) {ψ : MinusFormula} (hψ : ψ.somePast ∈ Γ.1) :
    ∃ Δ : MPoint fc, canR Δ.1 Γ.1 ∧ ψ ∈ Δ.1 := by
  obtain ⟨Δ, hΔ⟩ := exists_mpoint_extending _
    (insert_content_consistent Γ MinusFormula.allPast
      (fun Γ' χ d => minusGeneralizedPastK Γ' d) ψ hψ)
  exact ⟨Δ, (canR_iff_past Δ Γ).mpr (fun χ hχ => hΔ (Set.mem_insert_of_mem _ hχ)),
    hΔ (Set.mem_insert _ _)⟩

/-- `Hψ ∉ Γ` gives `Δ` with `Δ R Γ` and `¬ψ ∈ Δ`. -/
theorem exists_canR_of_not_H (Γ : MPoint fc) {ψ : MinusFormula} (hn : ψ.allPast ∉ Γ.1) :
    ∃ Δ : MPoint fc, canR Δ.1 Γ.1 ∧ ψ.neg ∈ Δ.1 :=
  exists_canR_of_P Γ (Γ.2.somePast_neg_of_not_allPast hn)

/-- **Modal witness**: `◇ψ ∈ Γ` gives `Δ` with `Γ ~ Δ` and `ψ ∈ Δ`. -/
theorem exists_canBox_of_dia (Γ : MPoint fc) {ψ : MinusFormula} (hψ : ψ.diamond ∈ Γ.1) :
    ∃ Δ : MPoint fc, canBox Γ.1 Δ.1 ∧ ψ ∈ Δ.1 := by
  obtain ⟨Δ, hΔ⟩ := exists_mpoint_extending _
    (insert_content_consistent Γ MinusFormula.box
      (fun Γ' χ d => minusGeneralizedModalK Γ' d) ψ hψ)
  exact ⟨Δ, fun χ hχ => hΔ (Set.mem_insert_of_mem _ hχ), hΔ (Set.mem_insert _ _)⟩

/-- `□ψ ∉ Γ` gives `Δ` with `Γ ~ Δ` and `¬ψ ∈ Δ`. -/
theorem exists_canBox_of_not_box (Γ : MPoint fc) {ψ : MinusFormula} (hn : ψ.box ∉ Γ.1) :
    ∃ Δ : MPoint fc, canBox Γ.1 Δ.1 ∧ ψ.neg ∈ Δ.1 :=
  exists_canBox_of_dia Γ (Γ.2.diamond_neg_of_not_box hn)

/-- **Seriality** (TS): every point has a successor. -/
theorem exists_canR_serial (Γ : MPoint fc) : ∃ Δ : MPoint fc, canR Γ.1 Δ.1 := by
  obtain ⟨Δ, hΔ, -⟩ := exists_canR_of_F Γ (Γ.2.theorem_in_mcs serialF)
  exact ⟨Δ, hΔ⟩

/-- **Past seriality** (`serialP`): every point has a predecessor. -/
theorem exists_canR_serial_past (Γ : MPoint fc) : ∃ Δ : MPoint fc, canR Δ.1 Γ.1 := by
  obtain ⟨Δ, hΔ, -⟩ := exists_canR_of_P Γ (Γ.2.theorem_in_mcs serialP)
  exact ⟨Δ, hΔ⟩

/-! ## Finite conjunctions

The density argument packs a finite list of `H`-content into one formula. -/

/-- `⋀ L`, right-folded with `⊤`. -/
def conj : List MinusFormula → MinusFormula
  | [] => MinusFormula.top
  | χ :: L => χ.and (conj L)

/-- `⋀ L ∈ S` iff every member is. -/
theorem MinusSetMaximalConsistent.conj_mem_iff {S : Set MinusFormula}
    (h : MinusSetMaximalConsistent fc S) (L : List MinusFormula) :
    conj L ∈ S ↔ ∀ χ ∈ L, χ ∈ S := by
  induction L with
  | nil => simpa [conj] using h.top_mem
  | cons χ L ih =>
    simp only [conj, h.and_mem_iff, ih, List.mem_cons, forall_eq_or_imp]

/-- `H(⋀ L) ∈ S` when every `Hχ ∈ S`, by `hAnd` and `hTop`. -/
theorem MinusSetMaximalConsistent.allPast_conj_mem {S : Set MinusFormula}
    (h : MinusSetMaximalConsistent fc S) (L : List MinusFormula)
    (hL : ∀ χ ∈ L, χ.allPast ∈ S) : (conj L).allPast ∈ S := by
  induction L with
  | nil => exact h.theorem_in_mcs hTop
  | cons χ L ih =>
    exact h.mp_of_theorem (hAnd χ (conj L))
      (h.and_mem_iff.mpr
        ⟨hL χ List.mem_cons_self, ih (fun χ' hχ' => hL χ' (List.mem_cons_of_mem _ hχ'))⟩)

/-- `⊢⁻ ⋀ L → χ` for `χ ∈ L`. -/
def conjImpOfMem : (L : List MinusFormula) → (χ : MinusFormula) → χ ∈ L → ⊢⁻[fc] (conj L).imp χ
  | [], _, h => (List.not_mem_nil h).elim
  | a :: L, χ, h =>
    if heq : χ = a then by subst heq; exact andElimL χ (conj L)
    else minusImpTrans (andElimR a (conj L))
      (conjImpOfMem L χ ((List.mem_cons.mp h).resolve_left heq))

/-- **Cut**: if `Γ ⊢⁻ φ` and every assumption of `Γ` is derivable from `Γ'`, then `Γ' ⊢⁻ φ`. -/
def cutList {φ : MinusFormula} (Γ' : Context) :
    (Γ : Context) → (Γ ⊢⁻[fc] φ) → (∀ x ∈ Γ, Γ' ⊢⁻[fc] x) → Γ' ⊢⁻[fc] φ
  | [], d, _ => .weakening [] Γ' φ d (List.nil_subset _)
  | x :: Γ, d, h =>
    mpC (cutList Γ' Γ (minusDeductionTheorem Γ x φ d)
      (fun y hy => h y (List.mem_cons_of_mem _ hy))) (h x List.mem_cons_self)

/-! ## Density at `.Dense` -/

/-- **Seed consistency for density.** For `Γ R Δ` at `.Dense`, `GContent Γ ∪ HContent Δ` is
consistent. A refutation from `A ++ B` (`A ⊆ GContent Γ`, `B ⊆ HContent Δ`) gives, with
`b := ⋀ B`: `G¬b ∈ Γ` (generalized temporal K), `Hb ∈ Δ` (`hAnd`), hence `F(Hb) ∈ Γ` and, by
DN, `FF(Hb) ∈ Γ`; `G(GP¬b) ∈ Γ` by TC under `G`; two applications of `gAndF` land
`FF(P¬b ∧ Hb) ∈ Γ`, refuted by `notPNegAndH` under `notF_of_not` twice. -/
theorem gContent_union_hContent_consistent (Γ Δ : MPoint FrameClass.Dense)
    (h : canR Γ.1 Δ.1) :
    MinusSetConsistent FrameClass.Dense (GContent Γ.1 ∪ HContent Δ.1) := by
  classical
  intro L hL ⟨d⟩
  let B := L.filter (fun χ => decide (χ.allPast ∈ Δ.1))
  let A := L.filter (fun χ => decide (χ.allPast ∉ Δ.1))
  have hA : ∀ χ ∈ A, χ.allFuture ∈ Γ.1 := by
    intro χ hχ
    have hm := List.mem_filter.mp hχ
    have hnot : χ.allPast ∉ Δ.1 := by simpa using hm.2
    rcases hL χ hm.1 with hG | hH
    · exact hG
    · exact absurd hH hnot
  have hB : ∀ χ ∈ B, χ.allPast ∈ Δ.1 := fun χ hχ => by simpa using (List.mem_filter.mp hχ).2
  have hLsub : L ⊆ A ++ B := by
    intro x hx
    by_cases hx' : x.allPast ∈ Δ.1
    · exact List.mem_append_right _ (List.mem_filter.mpr ⟨hx, by simpa using hx'⟩)
    · exact List.mem_append_left _ (List.mem_filter.mpr ⟨hx, by simpa using hx'⟩)
  let b := conj B
  have d₁ : (b :: A) ⊢⁻[FrameClass.Dense] MinusFormula.bot :=
    cutList (b :: A) (A ++ B) (.weakening L _ _ d hLsub) (fun x hx =>
      if hxA : x ∈ A then .assumption _ _ (List.mem_cons_of_mem _ hxA)
      else apC (conjImpOfMem B x ((List.mem_append.mp hx).resolve_left hxA)) (hyp₀ A b))
  have d₂ : A ⊢⁻[FrameClass.Dense] b.neg := minusDeductionTheorem A b .bot d₁
  have hGnb : b.neg.allFuture ∈ Γ.1 :=
    Γ.2.closed_under_derivation _
      (fun x hx => by
        obtain ⟨χ, hχ, rfl⟩ := List.mem_map.mp hx
        exact hA χ hχ)
      (minusGeneralizedTemporalK A d₂)
  have hHb : b.allPast ∈ Δ.1 := Δ.2.allPast_conj_mem B hB
  have hFHb : b.allPast.someFuture ∈ Γ.1 := F_of_canR h hHb
  have hFFHb : b.allPast.someFuture.someFuture ∈ Γ.1 := Γ.2.mp_of_theorem (fF_of_f _) hFHb
  have hGGP : b.neg.somePast.allFuture.allFuture ∈ Γ.1 :=
    Γ.2.mp_of_theorem (gMono (tcFuture b.neg)) hGnb
  have h₁ : (b.neg.somePast.allFuture.and b.allPast.someFuture).someFuture ∈ Γ.1 :=
    Γ.2.mp_of_theorem (gAndF _ _) (Γ.2.and_mem_iff.mpr ⟨hGGP, hFFHb⟩)
  have h₂ : (b.neg.somePast.and b.allPast).someFuture.someFuture ∈ Γ.1 :=
    Γ.2.mp_of_theorem (fMono (gAndF _ _)) h₁
  exact Γ.2.not_mem_of_neg_theorem (notF_of_not (notF_of_not (notPNegAndH b))) h₂

/-- **Density** (`.Dense` only): between any `Γ R Δ` lies a `Θ` with `Γ R Θ R Δ`. Lindenbaum
on `GContent Γ ∪ HContent Δ`, with `Θ R Δ` read off the past characterisation. -/
theorem exists_canR_between {Γ Δ : MPoint FrameClass.Dense} (h : canR Γ.1 Δ.1) :
    ∃ Θ : MPoint FrameClass.Dense, canR Γ.1 Θ.1 ∧ canR Θ.1 Δ.1 := by
  obtain ⟨Θ, hΘ⟩ := exists_mpoint_extending _ (gContent_union_hContent_consistent Γ Δ h)
  refine ⟨Θ, fun χ hχ => hΘ (Or.inl hχ), (canR_iff_past Θ Δ).mpr (fun χ hχ => hΘ (Or.inr hχ))⟩

/-! ## Weak linearity

Right linearity is TL; the three disjuncts of its consequent are each refuted by a closed
derivation (`notTLDisj₁`, `notTLDisj₂`, `notTLDisj₃`), with `φ₁ := Gα ∧ (¬β ∧ γ)` and
`φ₂ := Gβ ∧ (¬α ∧ ¬γ)`. Left linearity is the same argument on `tlPast` with the past mirrors. -/

section Linearity

variable (α β γ : MinusFormula)

/-- `φ₁ := Gα ∧ (¬β ∧ γ)`. -/
private def tlL : MinusFormula := α.allFuture.and (β.neg.and γ)

/-- `φ₂ := Gβ ∧ (¬α ∧ ¬γ)`. -/
private def tlR : MinusFormula := β.allFuture.and (α.neg.and γ.neg)

/-- `⊢⁻ ¬(Fφ₁ ∧ φ₂)`: `φ₂ → Gβ`, `Fφ₁ → F¬β`, and `notGAndFNeg`. -/
private def notTLDisj₁ : ⊢⁻[fc] ((tlL α β γ).someFuture.and (tlR α β γ)).neg :=
  minusDeductionTheorem [] _ .bot (
    let Γ : Context := [(tlL α β γ).someFuture.and (tlR α β γ)]
    let hF : Γ ⊢⁻[fc] β.neg.someFuture :=
      apC (fMono (minusImpTrans (andElimR α.allFuture (β.neg.and γ)) (andElimL β.neg γ)))
        (apC (andElimL _ _) (hyp₀ [] _))
    let hG : Γ ⊢⁻[fc] β.allFuture :=
      apC (andElimL β.allFuture (α.neg.and γ.neg)) (apC (andElimR _ _) (hyp₀ [] _))
    mpC (minusThmIn Γ (notGAndFNeg β)) (mpC (mpC (minusThmIn Γ (andIntro _ _)) hG) hF))

/-- `⊢⁻ ¬(φ₁ ∧ φ₂)`: `γ` from `φ₁`, `¬γ` from `φ₂`. -/
private def notTLDisj₂ : ⊢⁻[fc] ((tlL α β γ).and (tlR α β γ)).neg :=
  minusDeductionTheorem [] _ .bot (
    let Γ : Context := [(tlL α β γ).and (tlR α β γ)]
    let hγ : Γ ⊢⁻[fc] γ :=
      apC (minusImpTrans (andElimR α.allFuture (β.neg.and γ)) (andElimR β.neg γ))
        (apC (andElimL _ _) (hyp₀ [] _))
    let hnγ : Γ ⊢⁻[fc] γ.neg :=
      apC (minusImpTrans (andElimR β.allFuture (α.neg.and γ.neg)) (andElimR α.neg γ.neg))
        (apC (andElimR _ _) (hyp₀ [] _))
    mpC (A := γ) (B := .bot) hnγ hγ)

/-- `⊢⁻ ¬(φ₁ ∧ Fφ₂)`: `φ₁ → Gα`, `Fφ₂ → F¬α`, and `notGAndFNeg`. -/
private def notTLDisj₃ : ⊢⁻[fc] ((tlL α β γ).and (tlR α β γ).someFuture).neg :=
  minusDeductionTheorem [] _ .bot (
    let Γ : Context := [(tlL α β γ).and (tlR α β γ).someFuture]
    let hG : Γ ⊢⁻[fc] α.allFuture :=
      apC (andElimL α.allFuture (β.neg.and γ)) (apC (andElimL _ _) (hyp₀ [] _))
    let hF : Γ ⊢⁻[fc] α.neg.someFuture :=
      apC (fMono (minusImpTrans (andElimR β.allFuture (α.neg.and γ.neg)) (andElimL α.neg γ.neg)))
        (apC (andElimR _ _) (hyp₀ [] _))
    mpC (minusThmIn Γ (notGAndFNeg α)) (mpC (mpC (minusThmIn Γ (andIntro _ _)) hG) hF))

/-- `φ₁' := Hα ∧ (¬β ∧ γ)`, the past twin of `tlL`. -/
private def tlLP : MinusFormula := α.allPast.and (β.neg.and γ)

/-- `φ₂' := Hβ ∧ (¬α ∧ ¬γ)`, the past twin of `tlR`. -/
private def tlRP : MinusFormula := β.allPast.and (α.neg.and γ.neg)

/-- TR mirror of `notTLDisj₁`. -/
private def notTLDisjP₁ : ⊢⁻[fc] ((tlLP α β γ).somePast.and (tlRP α β γ)).neg :=
  ofReflect (A := ((tlL α.reflectTime β.reflectTime γ.reflectTime).someFuture.and
      (tlR α.reflectTime β.reflectTime γ.reflectTime)).neg)
    (by simp [tlL, tlR, tlLP, tlRP, MinusFormula.reflectTime,
      MinusFormula.reflectTime_involution])
    (notTLDisj₁ _ _ _)

/-- TR mirror of `notTLDisj₂`. -/
private def notTLDisjP₂ : ⊢⁻[fc] ((tlLP α β γ).and (tlRP α β γ)).neg :=
  ofReflect (A := ((tlL α.reflectTime β.reflectTime γ.reflectTime).and
      (tlR α.reflectTime β.reflectTime γ.reflectTime)).neg)
    (by simp [tlL, tlR, tlLP, tlRP, MinusFormula.reflectTime,
      MinusFormula.reflectTime_involution])
    (notTLDisj₂ _ _ _)

/-- TR mirror of `notTLDisj₃`. -/
private def notTLDisjP₃ : ⊢⁻[fc] ((tlLP α β γ).and (tlRP α β γ).somePast).neg :=
  ofReflect (A := ((tlL α.reflectTime β.reflectTime γ.reflectTime).and
      (tlR α.reflectTime β.reflectTime γ.reflectTime).someFuture).neg)
    (by simp [tlL, tlR, tlLP, tlRP, MinusFormula.reflectTime,
      MinusFormula.reflectTime_involution])
    (notTLDisj₃ _ _ _)

end Linearity

/-- **Right weak linearity** (TL): two successors of a point are equal or comparable. -/
theorem canR_weakLinear_right {Γ Δ₁ Δ₂ : MPoint fc} (h₁ : canR Γ.1 Δ₁.1) (h₂ : canR Γ.1 Δ₂.1) :
    Δ₁ = Δ₂ ∨ canR Δ₁.1 Δ₂.1 ∨ canR Δ₂.1 Δ₁.1 := by
  by_contra hcon
  push Not at hcon
  obtain ⟨hne, hn₁, hn₂⟩ := hcon
  unfold canR at hn₁ hn₂
  push Not at hn₁ hn₂
  obtain ⟨α, hGα, hα⟩ := hn₁
  obtain ⟨β, hGβ, hβ⟩ := hn₂
  obtain ⟨γ, hγ, hnγ⟩ := MPoint.exists_separating hne
  have hnα : α.neg ∈ Δ₂.1 := Δ₂.2.not_mem_iff_neg_mem.mp hα
  have hnβ : β.neg ∈ Δ₁.1 := Δ₁.2.not_mem_iff_neg_mem.mp hβ
  have hφ₁ : tlL α β γ ∈ Δ₁.1 := Δ₁.2.and_mem_iff.mpr ⟨hGα, Δ₁.2.and_mem_iff.mpr ⟨hnβ, hγ⟩⟩
  have hφ₂ : tlR α β γ ∈ Δ₂.1 := Δ₂.2.and_mem_iff.mpr ⟨hGβ, Δ₂.2.and_mem_iff.mpr ⟨hnα, hnγ⟩⟩
  have hF₁ : (tlL α β γ).someFuture ∈ Γ.1 := F_of_canR h₁ hφ₁
  have hF₂ : (tlR α β γ).someFuture ∈ Γ.1 := F_of_canR h₂ hφ₂
  have hTL := Γ.2.mp_of_theorem (tlFuture (tlL α β γ) (tlR α β γ))
    (Γ.2.and_mem_iff.mpr ⟨hF₁, hF₂⟩)
  rcases Γ.2.or_mem_iff.mp hTL with hd₁ | hd
  · exact Γ.2.not_mem_of_neg_theorem (notF_of_not (notTLDisj₁ α β γ)) hd₁
  rcases Γ.2.or_mem_iff.mp hd with hd₂ | hd₃
  · exact Γ.2.not_mem_of_neg_theorem (notF_of_not (notTLDisj₂ α β γ)) hd₂
  · exact Γ.2.not_mem_of_neg_theorem (notF_of_not (notTLDisj₃ α β γ)) hd₃

/-- **Left weak linearity** (the TR mirror of TL): two predecessors of a point are equal or
comparable. -/
theorem canR_weakLinear_left {Γ Δ₁ Δ₂ : MPoint fc} (h₁ : canR Δ₁.1 Γ.1) (h₂ : canR Δ₂.1 Γ.1) :
    Δ₁ = Δ₂ ∨ canR Δ₁.1 Δ₂.1 ∨ canR Δ₂.1 Δ₁.1 := by
  by_contra hcon
  push Not at hcon
  obtain ⟨hne, hn₁, hn₂⟩ := hcon
  rw [canR_iff_past] at hn₁ hn₂
  push Not at hn₁ hn₂
  -- `hn₁ : ∃ α, Hα ∈ Δ₂ ∧ α ∉ Δ₁`; `hn₂ : ∃ β, Hβ ∈ Δ₁ ∧ β ∉ Δ₂`.
  obtain ⟨α, hHα, hα⟩ := hn₁
  obtain ⟨β, hHβ, hβ⟩ := hn₂
  obtain ⟨γ, hγ, hnγ⟩ := MPoint.exists_separating hne.symm
  have hnα : α.neg ∈ Δ₁.1 := Δ₁.2.not_mem_iff_neg_mem.mp hα
  have hnβ : β.neg ∈ Δ₂.1 := Δ₂.2.not_mem_iff_neg_mem.mp hβ
  have hφ₁ : tlLP α β γ ∈ Δ₂.1 := Δ₂.2.and_mem_iff.mpr ⟨hHα, Δ₂.2.and_mem_iff.mpr ⟨hnβ, hγ⟩⟩
  have hφ₂ : tlRP α β γ ∈ Δ₁.1 := Δ₁.2.and_mem_iff.mpr ⟨hHβ, Δ₁.2.and_mem_iff.mpr ⟨hnα, hnγ⟩⟩
  have hP₁ : (tlLP α β γ).somePast ∈ Γ.1 := P_of_canR h₂ hφ₁
  have hP₂ : (tlRP α β γ).somePast ∈ Γ.1 := P_of_canR h₁ hφ₂
  have hTL := Γ.2.mp_of_theorem (tlPast (tlLP α β γ) (tlRP α β γ))
    (Γ.2.and_mem_iff.mpr ⟨hP₁, hP₂⟩)
  rcases Γ.2.or_mem_iff.mp hTL with hd₁ | hd
  · exact Γ.2.not_mem_of_neg_theorem (notP_of_not (notTLDisjP₁ α β γ)) hd₁
  rcases Γ.2.or_mem_iff.mp hd with hd₂ | hd₃
  · exact Γ.2.not_mem_of_neg_theorem (notP_of_not (notTLDisjP₂ α β γ)) hd₂
  · exact Γ.2.not_mem_of_neg_theorem (notP_of_not (notTLDisjP₃ α β γ)) hd₃

/-! ## The modal relation -/

/-- **T**: `canBox` is reflexive. -/
theorem canBox_refl (Γ : MPoint fc) : canBox Γ.1 Γ.1 :=
  fun χ hχ => Γ.2.mp_of_theorem (.axiom [] _ (Axiom.modal_t χ) (FrameClass.base_le fc)) hχ

/-- **4**: `canBox` is transitive. -/
theorem canBox_trans {Γ Δ Θ : MPoint fc} (h₁ : canBox Γ.1 Δ.1) (h₂ : canBox Δ.1 Θ.1) :
    canBox Γ.1 Θ.1 :=
  fun χ hχ => h₂ χ (h₁ _ (Γ.2.mp_of_theorem (boxImpBoxBox χ) hχ))

/-- **B**: `canBox` is symmetric. If `□χ ∈ Δ` but `χ ∉ Γ`, then `□◇¬χ ∈ Γ` by `minusModalB`,
so `◇¬χ ∈ Δ`, contradicting `□χ → □¬¬χ`. -/
theorem canBox_symm {Γ Δ : MPoint fc} (h : canBox Γ.1 Δ.1) : canBox Δ.1 Γ.1 := by
  intro χ hχ
  by_contra hn
  have hnχ : χ.neg ∈ Γ.1 := Γ.2.not_mem_iff_neg_mem.mp hn
  have hBD : χ.neg.diamond.box ∈ Γ.1 := Γ.2.mp_of_theorem (minusModalB χ.neg) hnχ
  have hD : χ.neg.diamond ∈ Δ.1 := h _ hBD
  have hBnn : χ.neg.neg.box ∈ Δ.1 := Δ.2.mp_of_theorem (boxMono (minusNotNotIntro χ)) hχ
  exact Δ.2.not_both hBnn hD

/-- **MF**: `Γ ~ Δ` and `Δ R Δ'` give `Γ ~ Δ'`. -/
theorem canBox_of_canR {Γ Δ Δ' : MPoint fc} (h₁ : canBox Γ.1 Δ.1) (h₂ : canR Δ.1 Δ'.1) :
    canBox Γ.1 Δ'.1 :=
  fun χ hχ => h₂ χ (h₁ _ (Γ.2.mp_of_theorem (boxImpBoxG χ) hχ))

/-- **MF mirrored**: `Γ ~ Δ` and `Δ' R Δ` give `Γ ~ Δ'`, through `boxImpBoxH` and the past
characterisation. -/
theorem canBox_of_canR_rev {Γ Δ Δ' : MPoint fc} (h₁ : canBox Γ.1 Δ.1) (h₂ : canR Δ'.1 Δ.1) :
    canBox Γ.1 Δ'.1 :=
  fun χ hχ => (canR_iff_past Δ' Δ).mp h₂ χ (h₁ _ (Γ.2.mp_of_theorem (boxImpBoxH χ) hχ))

end FormalSystem.Metalogic.Conservativity
