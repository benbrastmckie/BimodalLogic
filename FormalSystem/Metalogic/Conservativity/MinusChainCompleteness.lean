/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Conservativity.MinusChronicle
import FormalSystem.Metalogic.Conservativity.FragmentAxiomatization
import FormalSystem.Metalogic.Conservativity.TMCompletenessReduction

/-!
# Chain-completeness of TM⁻_d at `.Dense`

The `.Dense` row of `Conservativity/FragmentAxiomatization.lean`'s verdict table, machine-checked:
**`ChainComplete FrameClass.Dense ∅`** — every L⁻ formula valid on every chain bundle in
`FrameClass.Dense` is a theorem of TM⁻_d. This discharges the explicit hypothesis of
`minusExt_empty_iff_tmFrag_dense_of_chainComplete`, so `TM⁻_d = TMFrag .Dense` unconditionally
(`minusExt_iff_tmFrag_dense`), and through `minusValidIn_chainValidIn` and the reduction of
`Conservativity/TMCompletenessReduction.lean` it also closes `TMMinusComplete .Dense`
(`tmMinusComplete_dense`) and `Forward .Dense` (`forward_dense`).

The other three `ChainComplete` rows remain explicit, undischarged hypotheses; nothing here is
stated at any class other than `.Dense` (except `minusValidIn_chainValidIn`, which is generic and
has no completeness content).

## Route

Burgess, *Basic Tense Logic* (1984), §2.5, with `□` universal (the universal-modality reduction of
`FragmentAxiomatization.lean`):

* Fix a seed `Γ₀ : MPoint .Dense`. The bundle index `FamIdx Γ₀` is the set of ℚ-chronicles
  (`Conservativity/MinusChronicle.lean`) lying in the `canBox`-class of `Γ₀`; the valuation reads
  atoms off the labels.
* `truth_lemma`: `chainSat` at `(c, q)` is membership in `c.c q`, by induction on the formula.
  `H`/`G` use coherence one way and the chronicle's witnesses the other; `□` uses the S5 facts on
  `canBox` one way and, the other way, a `◇`-witness `Δ` with a chronicle through it
  (`exists_chronicle_through Δ`), which lies in the class of `Γ₀` by `chronicle_canBox_closed`.
* `refutation_engine`: from `¬ ⊢⁻[.Dense] φ`, Lindenbaum gives `Γ₀ ∋ ¬φ`, a chronicle through
  `Γ₀` gives a bundle point refuting `φ`.
* `chainComplete_dense`: the engine's refutation lands in `ChainValidIn .Dense` at
  `D := TemporalOrder.of ℚ`, whose `.Dense` side condition is `inferInstance`.

## References

* Burgess, *Basic Tense Logic* (1984), §2.5 — the tense logic of ℚ
* `FormalSystem/Metalogic/Conservativity/FragmentAxiomatization.lean` — `ChainValidIn`,
  `ChainComplete`, the conditional theorem discharged here
* `FormalSystem/Metalogic/Conservativity/ChainBundleTruth.lean` — `chainSat`,
  `not_minusValidIn_of_not_chainSat`
* `FormalSystem/Metalogic/Conservativity/TMCompletenessReduction.lean` — `TMMinusComplete`,
  `Forward`, `tmMinusCompleteDense_iff_forwardDense`

## Tags

conservativity · base-language · completeness · chain-bundle · dense
-/

namespace FormalSystem.Metalogic.Conservativity

open FormalSystem.Syntax
open FormalSystem.ProofSystem
open FormalSystem.MinusLanguage
open FormalSystem.Semantics
open FormalSystem.Metalogic
open FormalSystem.Metalogic.Algebraic

/-- The rational chain order, as a `TemporalOrder`. -/
abbrev ratOrder : TemporalOrder := TemporalOrder.of ℚ

section Bundle

variable (Γ₀ : DPoint)

/-- The bundle index: ℚ-chronicles lying in the `canBox`-class of the seed. -/
def FamIdx : Type := {c : Chronicle // ∀ q, canBox Γ₀.1 (c.c q).1}

/-- The bundle is non-empty: a chronicle through `Γ₀` itself lies in its class. -/
instance : Nonempty (FamIdx Γ₀) := by
  obtain ⟨c, hc⟩ := exists_chronicle_through Γ₀
  exact ⟨⟨c, chronicle_canBox_closed c (q₀ := 0) (by rw [hc]; exact canBox_refl Γ₀)⟩⟩

/-- The canonical valuation: an atom holds at `(c, q)` iff it lies in the label `c.c q`. -/
def val : FamIdx Γ₀ × (ratOrder : Type) → Atom → Prop :=
  fun p a => MinusFormula.atom a ∈ (p.1.1.c p.2).1

/-- **The truth lemma.** `chainSat` on the bundle of `Γ₀` is membership in the label. -/
theorem truth_lemma (ψ : MinusFormula) :
    ∀ (c : FamIdx Γ₀) (q : ℚ), chainSat (val Γ₀) (c, q) ψ ↔ ψ ∈ (c.1.c q).1 := by
  induction ψ with
  | atom a => exact fun _ _ => Iff.rfl
  | bot => exact fun c q => ⟨fun h => h.elim, fun h => (c.1.c q).2.bot_not_mem h⟩
  | imp φ ψ ih₁ ih₂ =>
    exact fun c q => (imp_congr (ih₁ c q) (ih₂ c q)).trans (c.1.c q).2.imp_mem_iff.symm
  | box φ ih =>
    intro c q
    constructor
    · intro h
      by_contra hn
      obtain ⟨Δ, hΔ, hnφ⟩ := exists_canBox_of_not_box _ hn
      obtain ⟨c', hc'⟩ := exists_chronicle_through Δ
      have hcls : ∀ q', canBox Γ₀.1 (c'.c q').1 :=
        chronicle_canBox_closed c' (q₀ := 0) (by rw [hc']; exact canBox_trans (c.2 q) hΔ)
      have hφ : φ ∈ (c'.c 0).1 := (ih ⟨c', hcls⟩ 0).mp (h (⟨c', hcls⟩, 0))
      rw [hc'] at hφ
      exact Δ.2.not_both hφ hnφ
    · rintro h ⟨c', q'⟩
      exact (ih c' q').mpr (canBox_trans (canBox_symm (c.2 q)) (c'.2 q') φ h)
  | allPast φ ih =>
    intro c q
    constructor
    · intro h
      by_contra hn
      have hP : φ.neg.somePast ∈ (c.1.c q).1 := (c.1.c q).2.somePast_neg_of_not_allPast hn
      obtain ⟨q', hq'q, hnφ⟩ := c.1.witP q φ.neg hP
      exact (c.1.c q').2.not_both ((ih c q').mp (h q' hq'q)) hnφ
    · intro h s hs
      exact (ih c s).mpr ((canR_iff_past _ _).mp (c.1.coh s q hs) φ h)
  | allFuture φ ih =>
    intro c q
    constructor
    · intro h
      by_contra hn
      have hF : φ.neg.someFuture ∈ (c.1.c q).1 := (c.1.c q).2.someFuture_neg_of_not_allFuture hn
      obtain ⟨q', hqq', hnφ⟩ := c.1.witF q φ.neg hF
      exact (c.1.c q').2.not_both ((ih c q').mp (h q' hqq')) hnφ
    · intro h s hs
      exact (ih c s).mpr (c.1.coh q s hs φ h)

end Bundle

/-! ## The refutation engine and the theorem -/

/-- **Refutation engine.** A TM⁻_d-underivable formula is refuted at some point of some ℚ-chain
bundle: Lindenbaum on `{¬φ}`, a chronicle through the resulting `Γ₀`, and the truth lemma at
`(c₀, 0)`. -/
theorem refutation_engine (φ : MinusFormula)
    (hnd : ¬ MinusLanguage.Derivable FrameClass.Dense [] φ) :
    ∃ (I : Type) (_ : Nonempty I) (v : I × (ratOrder : Type) → Atom → Prop)
      (q : I × (ratOrder : Type)), ¬ chainSat v q φ := by
  obtain ⟨Γ₀, hΓ₀⟩ := exists_mpoint_extending _ (neg_consistent_of_not_minus_derivable φ hnd)
  obtain ⟨c, hc⟩ := exists_chronicle_through Γ₀
  let c₀ : FamIdx Γ₀ := ⟨c, chronicle_canBox_closed c (q₀ := 0) (by rw [hc]; exact canBox_refl Γ₀)⟩
  refine ⟨FamIdx Γ₀, inferInstance, val Γ₀, (c₀, 0), ?_⟩
  intro h
  have hφ : φ ∈ (c.c 0).1 := (truth_lemma Γ₀ φ c₀ 0).mp h
  rw [hc] at hφ
  exact Γ₀.2.not_both hφ (hΓ₀ (Set.mem_singleton _))

/-- A single refutation on a ℚ-chain bundle refutes `ChainValidIn .Dense`. The `.Dense` side
condition for `multiFamTaskFrameGen (TemporalOrder.of ℚ) I` is `inferInstance`, exactly as in
`not_minusValidDense_of_not_chainSat`. -/
theorem not_chainValidIn_dense_of_rat_refutation (φ : MinusFormula) (I : Type) [Nonempty I]
    (v : I × (ratOrder : Type) → Atom → Prop) (q : I × (ratOrder : Type))
    (h : ¬ chainSat v q φ) : ¬ ChainValidIn FrameClass.Dense φ :=
  fun hv => h (hv ratOrder I ⟨inferInstance, inferInstance⟩ v q)

/-- **Chain-completeness of TM⁻_d.** Every formula valid on every chain bundle in
`FrameClass.Dense` is in `MinusExt .Dense ∅`, i.e. is a TM⁻_d theorem.

Paper: — (formalization-native; the classical source is Burgess 1984 §2.5, the tense logic of
ℚ, composed with the universal-modality reduction, neither of which is a manuscript anchor)
-/
theorem chainComplete_dense : ChainComplete FrameClass.Dense ∅ := by
  intro φ hv
  by_contra hn
  have hnd : ¬ MinusLanguage.Derivable FrameClass.Dense [] φ :=
    fun hd => hn (minusExt_empty_iff.mpr hd)
  obtain ⟨I, hne, v, q, hq⟩ := refutation_engine φ hnd
  exact @not_chainValidIn_dense_of_rat_refutation φ I hne v q hq hv

/-- **`TM⁻_d = TMFrag .Dense`**, unconditionally: the `.Dense` corollary of
`FragmentAxiomatization.lean` with its hypothesis discharged by `chainComplete_dense`.

Paper: — (formalization-native; the H/G-fragment is this tree's construction)
-/
theorem minusExt_iff_tmFrag_dense (φ : MinusFormula) :
    MinusExt FrameClass.Dense ∅ φ ↔ TMFrag FrameClass.Dense φ :=
  minusExt_empty_iff_tmFrag_dense_of_chainComplete chainComplete_dense φ

/-! ## Corollaries: `TMMinusComplete .Dense` and `Forward .Dense` -/

/-- Task-frame validity implies chain-bundle validity, at any class: the contrapositive of
`not_minusValidIn_of_not_chainSat`.

Paper: — (formalization-native; the chain-bundle semantics is this tree's construction)
-/
theorem minusValidIn_chainValidIn {fc : FrameClass} {φ : MinusFormula}
    (h : MinusValidIn fc φ) : ChainValidIn fc φ := by
  intro D I _ hSat v q
  by_contra hn
  exact not_minusValidIn_of_not_chainSat hSat v q φ hn h

/-- **TM⁻_d is complete over `FrameClass.Dense` task frames.** The `.Dense` row of
`TMCompletenessReduction.lean`'s status table, closed: `MinusValidIn .Dense φ` gives
`ChainValidIn .Dense φ`, hence `MinusExt .Dense ∅ φ`, hence `⊢⁻[.Dense] φ`.

Paper: — (formalization-native; TM⁻ names no paper system, and the classical source is Burgess
1984 §2.5 rather than a manuscript anchor)
-/
theorem tmMinusComplete_dense : TMMinusComplete FrameClass.Dense :=
  fun φ h => minusExt_empty_iff.mp (chainComplete_dense φ (minusValidIn_chainValidIn h))

/-- **Forward conservativity at `FrameClass.Dense`**: `⊢[.Dense] tr φ ⟹ ⊢⁻[.Dense] φ`, through
`tmMinusCompleteDense_iff_forwardDense`.

Paper: — (formalization-native; the forward direction is this tree's question)
-/
theorem forward_dense : Forward FrameClass.Dense :=
  tmMinusCompleteDense_iff_forwardDense.mp tmMinusComplete_dense

end FormalSystem.Metalogic.Conservativity
