/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.BiLasso.Extraction

/-!
# The Box Oracle, by Modal-Depth Stratification

`BoxOracleSound` (`Annotation.lean`) is a *specification*, deliberately stated before any oracle
exists, so that the truth lemma could be proved relative to any oracle meeting it. This module
supplies a concrete oracle and proves it meets the specification, closing the last gap between the
truth lemma and a decision procedure.

## The circularity, and how the stratification breaks it

An oracle sound in the sense of `BoxOracleSound` decides *validity on the presented frame*:
`bx χ = true` exactly when `χ` holds at time `0` along every total world history. Deciding that
is exactly what the small-model theorem is for — and the small-model theorem consumes a sound
oracle. Circular, unless something decreases.

Something does: **modal depth**. The annotations `exists_annot_of_truth` enumerates for `¬χ` only
ever consult the oracle at formulas `ψ` with `□ψ ∈ subformulaClosure (¬χ)`, and every such `ψ`
satisfies `modalDepth ψ < modalDepth χ` (`modalDepth_lt_of_box_mem_closure`). So `boxOracle`
recurses on strictly smaller modal depth, and the recursion is well-founded.

## The interface problem, and the congruence that solves it

`BoxOracleSound` is a *global* condition — sound at every formula — while the stratified oracle is
only correct below its own depth. Weakening the hypothesis of the landed `truth_along_annot` is
not an option: it is landed and consumed.

The resolution does not touch either. `LocalCoherent P φ bx A` reads `bx` **only** at formulas `ψ`
with `□ψ ∈ subformulaClosure φ` (its box clause is guarded by exactly that), and `bx` enters
`boundedAnnots` through nothing else (`annotsOf` filters by `LocalCoherent` and by nothing that
mentions `bx`). So two oracles agreeing on the box-subformulas of `φ` enumerate the same
annotations — `mem_boundedAnnots_congr_oracle`. The soundness proof therefore runs the landed
machinery against the *classical* validity oracle, which is globally sound by construction, and
transfers membership back to the computed one.

That classical oracle is a proof-local object. It is never a definition, never an instance, and
never reachable from `check`; the computable `boxOracle` below is what the decision procedure
calls.

## Cost

No efficiency is claimed. `boxOracle P χ` enumerates every annotated bi-lasso with segments
bounded by `bound P (¬χ)`, and does so once per box-subformula stratum. The point is that it
terminates and is correct, not that it is fast.

## Main Definitions

- `boxOracle` — the stratified oracle, by well-founded recursion on `modalDepth`

## Main Results

- `modalDepth_lt_of_box_mem_closure` — the measure that makes the recursion well-founded
- `mem_boundedAnnots_congr_oracle` — the enumeration depends on the oracle only through the box
  subformulas of the annotated formula
- `boxOracle_sound` — **`BoxOracleSound P (boxOracle P)`**

Argument order is **guard first**: `Formula.untl g e`, `Formula.snce g e`.
-/

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.Syntax
open FormalSystem.Semantics

variable {P : IntPresentation} {φ : Formula}

/-! ## The measure -/

/-- Modal depth is monotone along the subformula relation. -/
theorem modalDepth_le_of_mem_subformulas :
    ∀ {χ ψ : Formula}, ψ ∈ Formula.subformulas χ → Formula.modalDepth ψ ≤ Formula.modalDepth χ := by
  intro χ
  induction χ with
  | atom p =>
    intro ψ h
    simp only [Formula.subformulas, List.mem_singleton] at h
    rw [h]
  | bot =>
    intro ψ h
    simp only [Formula.subformulas, List.mem_singleton] at h
    rw [h]
  | imp a b iha ihb =>
    intro ψ h
    simp only [Formula.subformulas, List.mem_cons, List.mem_append] at h
    rcases h with rfl | h | h
    · exact le_refl _
    · exact le_trans (iha h) (by simp only [Formula.modalDepth]; omega)
    · exact le_trans (ihb h) (by simp only [Formula.modalDepth]; omega)
  | box a iha =>
    intro ψ h
    simp only [Formula.subformulas, List.mem_cons] at h
    rcases h with rfl | h
    · exact le_refl _
    · exact le_trans (iha h) (by simp only [Formula.modalDepth]; omega)
  | untl g e ihg ihe =>
    intro ψ h
    simp only [Formula.subformulas, List.mem_cons, List.mem_append] at h
    rcases h with rfl | h | h
    · exact le_refl _
    · exact le_trans (ihe h) (by simp only [Formula.modalDepth]; omega)
    · exact le_trans (ihg h) (by simp only [Formula.modalDepth]; omega)
  | snce g e ihg ihe =>
    intro ψ h
    simp only [Formula.subformulas, List.mem_cons, List.mem_append] at h
    rcases h with rfl | h | h
    · exact le_refl _
    · exact le_trans (ihe h) (by simp only [Formula.modalDepth]; omega)
    · exact le_trans (ihg h) (by simp only [Formula.modalDepth]; omega)

/--
**The measure that makes the stratification well-founded.**

Every formula the oracle is consulted at while deciding `χ` has strictly smaller modal depth than
`χ`: the oracle is only ever read at `ψ` with `□ψ` in the closure of `¬χ`, `□ψ` costs one unit of
depth, and negation costs none.
-/
theorem modalDepth_lt_of_box_mem_closure {χ ψ : Formula}
    (h : Formula.box ψ ∈ subformulaClosure (Formula.neg χ)) :
    Formula.modalDepth ψ < Formula.modalDepth χ := by
  rw [subformulaClosure, List.mem_toFinset] at h
  have hle := modalDepth_le_of_mem_subformulas h
  simp only [Formula.neg, Formula.modalDepth] at hle
  omega

/-! ## The enumeration depends on the oracle only through the box subformulas -/

/-- `LocalCoherent` reads the oracle only at the box subformulas of the annotated formula. -/
theorem localCoherent_congr_oracle {bx bx' : Formula → Bool}
    (h : ∀ ψ : Formula, Formula.box ψ ∈ subformulaClosure φ → bx ψ = bx' ψ) (A : Annot P φ) :
    LocalCoherent P φ bx A ↔ LocalCoherent P φ bx' A := by
  constructor <;> intro hloc t <;>
    obtain ⟨h1, h2, h3, h4, h5, h6⟩ := hloc t <;>
    exact ⟨h1, h2, h3, fun χ hχ => by rw [h4 χ hχ, h χ hχ], h5, h6⟩

/--
**Two oracles agreeing on the box subformulas of `φ` enumerate the same annotations.**

`bx` enters `boundedAnnots` through the `LocalCoherent` filter and through nothing else, and
`LocalCoherent`'s box clause is guarded by `□χ ∈ subformulaClosure φ`. This is what lets the
soundness proof below run the landed truth lemma against a globally sound oracle while the
*computation* uses the stratified one.
-/
theorem mem_boundedAnnots_congr_oracle {bx bx' : Formula → Bool} {n : ℕ} {A : Annot P φ}
    (h : ∀ ψ : Formula, Formula.box ψ ∈ subformulaClosure φ → bx ψ = bx' ψ)
    (hA : A ∈ boundedAnnots P φ bx n) : A ∈ boundedAnnots P φ bx' n := by
  obtain ⟨hloc, hful, hb, hm, hf⟩ := boundedAnnots_sound hA
  exact mem_boundedAnnots A hb hm hf ((localCoherent_congr_oracle h A).mp hloc) hful

/-! ## Negation, semantically -/

/-- Truth of a negation is failure of truth. -/
theorem truth_neg_iff (M : TaskModel P.toTaskFrame) (σ : WorldHistory P.toTaskFrame) (t : ℤ)
    (χ : Formula) : TruthAt M σ t (Formula.neg χ) ↔ ¬ TruthAt M σ t χ := by
  rw [Formula.neg, Truth.imp_iff]
  exact ⟨fun h hχ => Truth.bot_false (h hχ), fun h hχ => absurd hχ h⟩

/-! ## The oracle -/

/--
**The box oracle**: `boxOracle P χ` is `true` exactly when no bounded annotated bi-lasso for `¬χ`
carries `¬χ` anywhere in its coherence window.

The oracle handed to the inner enumeration is `boxOracle P` itself, guarded by a strict decrease
in `modalDepth` — which is what makes the recursion well-founded, and which is legitimate because
the enumeration never reads the oracle above that depth
(`modalDepth_lt_of_box_mem_closure`). Below the guard the fallback value is irrelevant and is
`false`.

Computable: no `Classical.dec` anywhere on this path. The classical validity oracle appearing in
`boxOracle_sound` is proof-local and is not reachable from here.
-/
def boxOracle (P : IntPresentation) (χ : Formula) : Bool :=
  !decide (∃ A ∈ boundedAnnots P (Formula.neg χ)
      (fun ψ => if _h : Formula.modalDepth ψ < Formula.modalDepth χ then boxOracle P ψ else false)
      (bound P (Formula.neg χ)),
    ∃ i ∈ Finset.Ico (cohWindowLo A) (cohWindowHi A), Formula.neg χ ∈ A.label i)
termination_by Formula.modalDepth χ
decreasing_by all_goals assumption

/--
**The oracle meets its specification.**

Proved by induction on a bound for the modal depth. At each formula the argument is:

- the *classical* validity oracle `bxs` is globally `BoxOracleSound` by construction, so the
  landed `truth_along_annot_at` and this task's `exists_annot_of_truth` both apply to it;
- the stratified oracle agrees with `bxs` on every `ψ` with `□ψ ∈ subformulaClosure (¬χ)`, because
  all such `ψ` have strictly smaller modal depth and the induction hypothesis covers them;
- hence `mem_boundedAnnots_congr_oracle` transports annotations between the two enumerations in
  both directions.

The `←` direction of the specification is where the **time shift** is spent, and it is not
optional: `BoxOracleSound` is anchored at time `0`, while the windowed enumeration finds its
refuting witness at a position `i`. `timeShift_preserves_truth` together with
`WorldHistory.isTotal_timeShift` moves the witness to `0`, which is exactly the obligation the
windowed shape of `exists_annot_of_truth` pushes downstream.
-/
theorem boxOracle_sound (P : IntPresentation) : BoxOracleSound P (boxOracle P) := by
  classical
  -- the classical validity oracle: globally sound by construction, proof-local
  set bxs : Formula → Bool :=
    fun ψ => decide (∀ σ : WorldHistory P.toTaskFrame, σ.IsTotal → TruthAt P.toModel σ 0 ψ)
    with hbxsdef
  have hbxs : BoxOracleSound P bxs := by
    intro ψ
    rw [hbxsdef]
    simp
  have main : ∀ χ : Formula,
      (∀ ψ : Formula, Formula.modalDepth ψ < Formula.modalDepth χ →
        (boxOracle P ψ = true ↔ bxs ψ = true)) →
      (boxOracle P χ = true ↔
        ∀ σ : WorldHistory P.toTaskFrame, σ.IsTotal → TruthAt P.toModel σ 0 χ) := by
    intro χ IH
    -- the stratified oracle agrees with the classical one wherever the enumeration reads it
    have hagree : ∀ ψ : Formula, Formula.box ψ ∈ subformulaClosure (Formula.neg χ) →
        (fun ψ => if h : Formula.modalDepth ψ < Formula.modalDepth χ then boxOracle P ψ
          else false) ψ = bxs ψ := by
      intro ψ hmem
      have hd := modalDepth_lt_of_box_mem_closure hmem
      simp only [dif_pos hd]
      exact Bool.eq_iff_iff.mpr (IH ψ hd)
    have hagree' : ∀ ψ : Formula, Formula.box ψ ∈ subformulaClosure (Formula.neg χ) →
        bxs ψ = (fun ψ => if h : Formula.modalDepth ψ < Formula.modalDepth χ then boxOracle P ψ
          else false) ψ := fun ψ h => (hagree ψ h).symm
    rw [boxOracle]
    simp only [Bool.not_eq_true', decide_eq_false_iff_not]
    constructor
    · -- no enumerated annotation carries `¬χ`, so no total history refutes `χ` at `0`
      intro hno σ hσ
      by_contra hcon
      have htr : TruthAt P.toModel σ 0 (Formula.neg χ) :=
        (truth_neg_iff P.toModel σ 0 χ).mpr hcon
      obtain ⟨A, hA, i, hi, -, hlab⟩ := exists_annot_of_truth hbxs σ hσ 0 htr
      exact hno ⟨A, mem_boundedAnnots_congr_oracle hagree' hA, i, hi, hlab⟩
    · -- conversely, an enumerated annotation carrying `¬χ` yields a refuting total history
      rintro hall ⟨A, hA, i, hi, hlab⟩
      obtain ⟨hloc, hful, -, -, -⟩ :=
        boundedAnnots_sound (mem_boundedAnnots_congr_oracle hagree hA)
      have htr : TruthAt P.toModel A.lasso.toHF.val i (Formula.neg χ) :=
        (truth_along_annot_at hbxs A hloc hful i (Formula.neg χ)
          (self_mem_subformulaClosure _)).mpr hlab
      have hshift := (TimeShift.timeShift_preserves_truth P.toModel A.lasso.toHF.val 0 i
        (Formula.neg χ))
      rw [sub_zero] at hshift
      have hgood := hall (WorldHistory.timeShift A.lasso.toHF.val i)
        (WorldHistory.isTotal_timeShift A.lasso.toHF.property i)
      exact (truth_neg_iff P.toModel _ 0 χ).mp (hshift.mpr htr) hgood
  -- induct on a bound for the modal depth
  have key : ∀ (k : ℕ) (χ : Formula), Formula.modalDepth χ ≤ k →
      (boxOracle P χ = true ↔
        ∀ σ : WorldHistory P.toTaskFrame, σ.IsTotal → TruthAt P.toModel σ 0 χ) := by
    intro k
    induction k with
    | zero => exact fun χ hχ => main χ (fun ψ hψ => absurd hψ (by omega))
    | succ k ih =>
      refine fun χ hχ => main χ (fun ψ hψ => ?_)
      rw [ih ψ (by omega), hbxsdef]
      simp
  intro χ
  exact key (Formula.modalDepth χ) χ (le_refl _)

end FormalSystem.Metalogic.Decidability
