/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.MinusLanguage.Derivation

/-!
# L⁻ deduction theorem and the `□`-globality derivations

The `MinusLanguage.DerivationTree` mirror of `FormalSystem/Theorems/DeductionTheorem.lean`,
restricted to what four target derivations consume, plus those derivations. **Nothing here is
semantic**: the only import is `MinusLanguage/Derivation.lean`, and every declaration is a
`DerivationTree` term.

## Why these four derivations

On a task model, `□` is the universal modality: its truth value is the same at every history and
every time. The semantic side of that fact is `Semantics.Truth.box_const` and
`minus_box_universal`; this module supplies the **proof-theoretic** side, the first bullet of the
universal-modality reduction that `Conservativity/FragmentAxiomatization.lean` rests on:

* `boxGlobalFuture` — `⊢⁻ □χ → G□χ`
* `boxGlobalPast` — `⊢⁻ □χ → H□χ`
* `notBoxGlobalFuture` — `⊢⁻ ¬□χ → G¬□χ`
* `notBoxGlobalPast` — `⊢⁻ ¬□χ → H¬□χ`

at every frame class. Together they say every `□`-subformula has a globally constant truth
value *inside TM⁻*, which is what lets a TM⁻ + Σ consistency question reduce to a pure-tense
one on paper.

## Route

* `□χ → □□χ` (`boxImpBoxBox`, S5's 4) from MT, M5 and MK, mirroring `Combinators.modal4`;
  then MF at `□χ` (`□□χ → □G□χ`) and MT (`□G□χ → G□χ`).
* `¬□χ → □¬□χ` (`notBoxImpBoxNotBox`) from M5 contraposed (`¬□χ → ¬◇□χ`) and double negation
  elimination (`¬◇□χ = ¬¬□¬□χ`); then MF and MT as before.
* The two past forms by **TR** on the future forms at `χ.reflectTime`, transported back along
  `reflectTime_involution`.

## The deduction theorem

`minusDeductionTheorem : (A :: Γ) ⊢⁻[fc] B → Γ ⊢⁻[fc] A.imp B`, with the same four case lemmas
as the L side (`deductionAxiom`, `deductionAssumptionSame`, `deductionAssumptionOther`,
`deductionMp`). The recursion is structural rather than height-based: it is stated for an
arbitrary `Γ' ⊆ A :: Γ` (`deductionOfSubset`), so the `weakening` case recurses on the
sub-derivation directly and the empty-context rules (MN, TN, TR) are handled as theorems
weakened under `A →`, rather than being ruled out. `MinusFormula` has decidable equality, so
the whole thing is computable.

The propositional combinators (`minusImpTrans`, `minusFlip`, `minusNotNotIntro`,
`minusContrapos`, `minusDne`) are derived through the deduction theorem, which is what keeps
them short.

## References

* `FormalSystem/Theorems/DeductionTheorem.lean` — the L-side deduction theorem being mirrored
* `FormalSystem/Theorems/Combinators.lean` — `modalB`, `modal4`, the S5 routes being mirrored
* `FormalSystem/Metalogic/Conservativity/FragmentAxiomatization.lean` — the consumer
-/

namespace FormalSystem.Metalogic.Conservativity

open FormalSystem.Syntax
open FormalSystem.ProofSystem (FrameClass)
open FormalSystem.MinusLanguage

/-! ## Deduction theorem cases -/

/-- Deduction case for axioms: `Γ ⊢⁻ A → φ` when `φ` is an axiom available at `fc`, by `prop_s`. -/
def deductionAxiom {fc : FrameClass} (Γ : Context) (A φ : MinusFormula) (h_ax : Axiom φ)
    (h_fc : h_ax.minFrameClass ≤ fc) : Γ ⊢⁻[fc] A.imp φ :=
  .modus_ponens Γ φ (A.imp φ)
    (.axiom Γ _ (Axiom.prop_s φ A) (FrameClass.base_le fc))
    (.axiom Γ φ h_ax h_fc)

/-- Deduction case for a theorem: `Γ ⊢⁻ A → φ` when `⊢⁻ φ`, by `prop_s` and weakening. Covers the
empty-context rules MN, TN, TR. -/
def deductionThm {fc : FrameClass} (Γ : Context) (A φ : MinusFormula) (d : ⊢⁻[fc] φ) :
    Γ ⊢⁻[fc] A.imp φ :=
  .modus_ponens Γ φ (A.imp φ)
    (.axiom Γ _ (Axiom.prop_s φ A) (FrameClass.base_le fc))
    (.weakening [] Γ φ d (List.nil_subset Γ))

/-- Deduction case for the same assumption: `Γ ⊢⁻ A → A`, the SKK identity. -/
def deductionAssumptionSame {fc : FrameClass} (Γ : Context) (A : MinusFormula) :
    Γ ⊢⁻[fc] A.imp A :=
  let k₁ : Γ ⊢⁻[fc] A.imp ((A.imp A).imp A) :=
    .axiom Γ _ (Axiom.prop_s A (A.imp A)) (FrameClass.base_le fc)
  let k₂ : Γ ⊢⁻[fc] A.imp (A.imp A) :=
    .axiom Γ _ (Axiom.prop_s A A) (FrameClass.base_le fc)
  let s : Γ ⊢⁻[fc] (A.imp ((A.imp A).imp A)).imp ((A.imp (A.imp A)).imp (A.imp A)) :=
    .axiom Γ _ (Axiom.prop_k A (A.imp A) A) (FrameClass.base_le fc)
  .modus_ponens Γ _ _ (.modus_ponens Γ _ _ s k₁) k₂

/-- Deduction case for another assumption: `Γ ⊢⁻ A → B` when `B ∈ Γ`, by `prop_s`. -/
def deductionAssumptionOther {fc : FrameClass} (Γ : Context) (A B : MinusFormula)
    (h_mem : B ∈ Γ) : Γ ⊢⁻[fc] A.imp B :=
  .modus_ponens Γ B (A.imp B)
    (.axiom Γ _ (Axiom.prop_s B A) (FrameClass.base_le fc))
    (.assumption Γ B h_mem)

/-- Deduction case for modus ponens: from `Γ ⊢⁻ A → (C → D)` and `Γ ⊢⁻ A → C`, `Γ ⊢⁻ A → D`,
by `prop_k`. -/
def deductionMp {fc : FrameClass} (Γ : Context) (A C D : MinusFormula)
    (h₁ : Γ ⊢⁻[fc] A.imp (C.imp D)) (h₂ : Γ ⊢⁻[fc] A.imp C) : Γ ⊢⁻[fc] A.imp D :=
  .modus_ponens Γ (A.imp C) (A.imp D)
    (.modus_ponens Γ (A.imp (C.imp D)) ((A.imp C).imp (A.imp D))
      (.axiom Γ _ (Axiom.prop_k A C D) (FrameClass.base_le fc)) h₁)
    h₂

/-! ## The deduction theorem -/

/--
**Generalized deduction theorem.** From `Γ' ⊢⁻ φ` and `Γ' ⊆ A :: Γ`, conclude `Γ ⊢⁻ A → φ`.

Structural recursion on the derivation. The generalization over `Γ'` is what makes the
`weakening` case a direct recursive call (its sub-derivation lives at some `Γ'' ⊆ Γ' ⊆ A :: Γ`),
with no height measure needed; the three empty-context rules land in `deductionThm`.
-/
def deductionOfSubset {fc : FrameClass} {Γ' : Context} {φ : MinusFormula} (Γ : Context)
    (A : MinusFormula) (d : Γ' ⊢⁻[fc] φ) (h_sub : Γ' ⊆ A :: Γ) : Γ ⊢⁻[fc] A.imp φ :=
  match d with
  | .axiom _ φ h_ax h_fc => deductionAxiom Γ A φ h_ax h_fc
  | .assumption _ φ h_mem =>
      if h_eq : φ = A then
        h_eq ▸ deductionAssumptionSame Γ φ
      else
        deductionAssumptionOther Γ A φ
          (by
            have := h_sub h_mem
            simp only [List.mem_cons] at this
            exact this.resolve_left h_eq)
  | .modus_ponens _ ψ χ d₁ d₂ =>
      deductionMp Γ A ψ χ (deductionOfSubset Γ A d₁ h_sub) (deductionOfSubset Γ A d₂ h_sub)
  | .necessitation ψ d => deductionThm Γ A _ (.necessitation ψ d)
  | .temporal_necessitation ψ d => deductionThm Γ A _ (.temporal_necessitation ψ d)
  | .time_reflection ψ d => deductionThm Γ A _ (.time_reflection ψ d)
  | .weakening Γ'' _ _ d h => deductionOfSubset Γ A d (fun _ hx => h_sub (h hx))

/--
**The deduction theorem for TM⁻**: `(A :: Γ) ⊢⁻[fc] B → Γ ⊢⁻[fc] A.imp B`.

The `Γ' := A :: Γ` instance of `deductionOfSubset`.
-/
def minusDeductionTheorem {fc : FrameClass} (Γ : Context) (A B : MinusFormula)
    (d : (A :: Γ) ⊢⁻[fc] B) : Γ ⊢⁻[fc] A.imp B :=
  deductionOfSubset Γ A d (List.Subset.refl _)

/-- Converse of the deduction theorem: `Γ ⊢⁻ A → B → (A :: Γ) ⊢⁻ B`, by weakening and MP. -/
def minusDeductionConverse {fc : FrameClass} (Γ : Context) (A B : MinusFormula)
    (d : Γ ⊢⁻[fc] A.imp B) : (A :: Γ) ⊢⁻[fc] B :=
  .modus_ponens (A :: Γ) A B
    (.weakening Γ (A :: Γ) (A.imp B) d (List.subset_cons_self A Γ))
    (.assumption (A :: Γ) A (List.mem_cons_self))

/-! ## Propositional combinators

Each is a theorem-level derivation obtained by working in a context and discharging with
`minusDeductionTheorem`. -/

/-- Weakening a theorem into a context. -/
def minusThmIn {fc : FrameClass} (Γ : Context) {A : MinusFormula} (d : ⊢⁻[fc] A) :
    Γ ⊢⁻[fc] A :=
  .weakening [] Γ A d (List.nil_subset Γ)

/-- Transitivity: from `⊢⁻ A → B` and `⊢⁻ B → C`, `⊢⁻ A → C`. -/
def minusImpTrans {fc : FrameClass} {A B C : MinusFormula} (h₁ : ⊢⁻[fc] A.imp B)
    (h₂ : ⊢⁻[fc] B.imp C) : ⊢⁻[fc] A.imp C :=
  minusDeductionTheorem [] A C
    (.modus_ponens [A] B C (minusThmIn [A] h₂)
      (.modus_ponens [A] A B (minusThmIn [A] h₁) (.assumption [A] A List.mem_cons_self)))

/-- Flip: from `⊢⁻ A → (B → C)`, `⊢⁻ B → (A → C)`. -/
def minusFlip {fc : FrameClass} {A B C : MinusFormula} (h : ⊢⁻[fc] A.imp (B.imp C)) :
    ⊢⁻[fc] B.imp (A.imp C) :=
  minusDeductionTheorem [] B (A.imp C) (minusDeductionTheorem [B] A C
    (.modus_ponens [A, B] B C
      (.modus_ponens [A, B] A (B.imp C) (minusThmIn [A, B] h)
        (.assumption [A, B] A List.mem_cons_self))
      (.assumption [A, B] B (List.mem_cons_of_mem A List.mem_cons_self))))

/-- Double negation introduction: `⊢⁻ A → ¬¬A`. -/
def minusNotNotIntro {fc : FrameClass} (A : MinusFormula) : ⊢⁻[fc] A.imp A.neg.neg :=
  minusDeductionTheorem [] A A.neg.neg (minusDeductionTheorem [A] A.neg .bot
    (.modus_ponens [A.neg, A] A .bot
      (.assumption [A.neg, A] A.neg List.mem_cons_self)
      (.assumption [A.neg, A] A (List.mem_cons_of_mem A.neg List.mem_cons_self))))

/-- Contraposition: from `⊢⁻ A → B`, `⊢⁻ ¬B → ¬A`. -/
def minusContrapos {fc : FrameClass} {A B : MinusFormula} (h : ⊢⁻[fc] A.imp B) :
    ⊢⁻[fc] B.neg.imp A.neg :=
  minusDeductionTheorem [] B.neg A.neg (minusDeductionTheorem [B.neg] A .bot
    (.modus_ponens [A, B.neg] B .bot
      (.assumption [A, B.neg] B.neg (List.mem_cons_of_mem A List.mem_cons_self))
      (.modus_ponens [A, B.neg] A B (minusThmIn [A, B.neg] h)
        (.assumption [A, B.neg] A List.mem_cons_self))))

/-- Double negation elimination: `⊢⁻ ¬¬A → A`, from `peirce` and `ex_falso`. In context
`[¬¬A]`: `¬A → A` (via `⊥ → A`), then Peirce `((A → ⊥) → A) → A`. -/
def minusDne {fc : FrameClass} (A : MinusFormula) : ⊢⁻[fc] A.neg.neg.imp A :=
  minusDeductionTheorem [] A.neg.neg A
    (.modus_ponens [A.neg.neg] (A.neg.imp A) A
      (.axiom [A.neg.neg] _ (Axiom.peirce A .bot) (FrameClass.base_le fc))
      (minusDeductionTheorem [A.neg.neg] A.neg A
        (.modus_ponens [A.neg, A.neg.neg] .bot A
          (.axiom [A.neg, A.neg.neg] _ (Axiom.ex_falso A) (FrameClass.base_le fc))
          (.modus_ponens [A.neg, A.neg.neg] A.neg .bot
            (.assumption [A.neg, A.neg.neg] A.neg.neg
              (List.mem_cons_of_mem A.neg List.mem_cons_self))
            (.assumption [A.neg, A.neg.neg] A.neg List.mem_cons_self)))))

/-! ## S5 fragments: modal B and modal 4 over L⁻

Mirrors of `Combinators.modalB` / `modal4`, with the L⁻ axioms `modal_t`, `modal_5`, `modal_k`. -/

/-- `⊢⁻ φ → ◇φ`: MT at `¬φ` (`□¬φ → ¬φ`), flipped. `◇φ` is `¬□¬φ` definitionally. -/
def minusToDiamond {fc : FrameClass} (φ : MinusFormula) : ⊢⁻[fc] φ.imp φ.diamond :=
  minusFlip (A := φ.neg.box) (B := φ) (C := .bot)
    (.axiom [] _ (Axiom.modal_t φ.neg) (FrameClass.base_le fc))

/-- Modal B, `⊢⁻ φ → □◇φ`: `φ → ◇φ`, then M5 at `¬φ` contraposed (`◇φ → ¬¬□◇φ`), then DNE. -/
def minusModalB {fc : FrameClass} (φ : MinusFormula) : ⊢⁻[fc] φ.imp φ.diamond.box :=
  let m5 : ⊢⁻[fc] φ.neg.box.diamond.imp φ.neg.box :=
    .axiom [] _ (Axiom.modal_5 φ.neg) (FrameClass.base_le fc)
  -- `φ.neg.box.diamond = φ.diamond.box.neg` and `φ.neg.box.neg = φ.diamond`, both by `rfl`.
  let diaBox : ⊢⁻[fc] φ.diamond.imp φ.diamond.box.neg.neg := minusContrapos m5
  minusImpTrans (minusToDiamond φ) (minusImpTrans diaBox (minusDne φ.diamond.box))

/-- Modal 4, `⊢⁻ □χ → □□χ`: B at `□χ` (`□χ → □◇□χ`), then M5 (`◇□χ → □χ`) necessitated and
distributed by MK (`□◇□χ → □□χ`). -/
def boxImpBoxBox {fc : FrameClass} (χ : MinusFormula) : ⊢⁻[fc] χ.box.imp χ.box.box :=
  let b : ⊢⁻[fc] χ.box.imp χ.box.diamond.box := minusModalB χ.box
  let m5 : ⊢⁻[fc] χ.box.diamond.imp χ.box :=
    .axiom [] _ (Axiom.modal_5 χ) (FrameClass.base_le fc)
  let mk : ⊢⁻[fc] (χ.box.diamond.imp χ.box).box.imp (χ.box.diamond.box.imp χ.box.box) :=
    .axiom [] _ (Axiom.modal_k χ.box.diamond χ.box) (FrameClass.base_le fc)
  minusImpTrans b (.modus_ponens [] _ _ mk (.necessitation _ m5))

/-- `⊢⁻ ¬□χ → □¬□χ`: M5 at `χ` contraposed (`¬□χ → ¬◇□χ`), and `¬◇□χ = ¬¬□¬□χ`, so DNE. -/
def notBoxImpBoxNotBox {fc : FrameClass} (χ : MinusFormula) :
    ⊢⁻[fc] χ.box.neg.imp χ.box.neg.box :=
  let m5 : ⊢⁻[fc] χ.box.diamond.imp χ.box :=
    .axiom [] _ (Axiom.modal_5 χ) (FrameClass.base_le fc)
  minusImpTrans (minusContrapos m5) (minusDne χ.box.neg.box)

/-! ## The four `□`-globality derivations -/

/-- From `⊢⁻ ψ → □ψ`, conclude `⊢⁻ ψ → Gψ`: MF at `ψ` (`□ψ → □Gψ`) then MT (`□Gψ → Gψ`). -/
def globalFutureOfBoxIdem {fc : FrameClass} {ψ : MinusFormula} (h : ⊢⁻[fc] ψ.imp ψ.box) :
    ⊢⁻[fc] ψ.imp ψ.allFuture :=
  minusImpTrans h (minusImpTrans
    (.axiom [] _ (Axiom.modal_future ψ) (FrameClass.base_le fc))
    (.axiom [] _ (Axiom.modal_t ψ.allFuture) (FrameClass.base_le fc)))

/-- **`⊢⁻[fc] □χ → G□χ`.** `□χ → □□χ → □G□χ → G□χ` by 4, MF, MT.

Paper: — (formalization-native; the `□`-globality lemma is this tree's construction)
-/
def boxGlobalFuture {fc : FrameClass} (χ : MinusFormula) :
    ⊢⁻[fc] χ.box.imp χ.box.allFuture :=
  globalFutureOfBoxIdem (boxImpBoxBox χ)

/-- **`⊢⁻[fc] ¬□χ → G¬□χ`.** `¬□χ → □¬□χ → □G¬□χ → G¬□χ` by M5-contraposed, MF, MT.

Paper: — (formalization-native; the `□`-globality lemma is this tree's construction)
-/
def notBoxGlobalFuture {fc : FrameClass} (χ : MinusFormula) :
    ⊢⁻[fc] χ.box.neg.imp χ.box.neg.allFuture :=
  globalFutureOfBoxIdem (notBoxImpBoxNotBox χ)

/-- The reflection of the `Future` statement at `χ.reflectTime` is the `Past` statement at `χ`. -/
theorem reflectTime_boxGlobal (χ : MinusFormula) :
    (χ.reflectTime.box.imp χ.reflectTime.box.allFuture).reflectTime =
      χ.box.imp χ.box.allPast := by
  simp [MinusFormula.reflectTime, MinusFormula.reflectTime_involution]

/-- The reflection of the negated `Future` statement at `χ.reflectTime` is the negated `Past`
statement at `χ`. -/
theorem reflectTime_notBoxGlobal (χ : MinusFormula) :
    (χ.reflectTime.box.neg.imp χ.reflectTime.box.neg.allFuture).reflectTime =
      χ.box.neg.imp χ.box.neg.allPast := by
  simp [MinusFormula.reflectTime, MinusFormula.neg, MinusFormula.reflectTime_involution]

/-- **`⊢⁻[fc] □χ → H□χ`.** **TR** on `boxGlobalFuture` at `χ.reflectTime`, transported along
`reflectTime_involution`.

Paper: — (formalization-native; the `□`-globality lemma is this tree's construction)
-/
def boxGlobalPast {fc : FrameClass} (χ : MinusFormula) :
    ⊢⁻[fc] χ.box.imp χ.box.allPast :=
  reflectTime_boxGlobal χ ▸ DerivationTree.time_reflection _ (boxGlobalFuture χ.reflectTime)

/-- **`⊢⁻[fc] ¬□χ → H¬□χ`.** **TR** on `notBoxGlobalFuture` at `χ.reflectTime`, transported
along `reflectTime_involution`.

Paper: — (formalization-native; the `□`-globality lemma is this tree's construction)
-/
def notBoxGlobalPast {fc : FrameClass} (χ : MinusFormula) :
    ⊢⁻[fc] χ.box.neg.imp χ.box.neg.allPast :=
  reflectTime_notBoxGlobal χ ▸
    DerivationTree.time_reflection _ (notBoxGlobalFuture χ.reflectTime)

/-! ### Acceptance checks -/

/-- The four globality facts at an atom, at `.ZTime`, as `Derivable` propositions. -/
example (p : Atom) :
    MinusLanguage.Derivable FrameClass.ZTime []
      ((MinusFormula.atom p).box.imp (MinusFormula.atom p).box.allFuture) ∧
    MinusLanguage.Derivable FrameClass.ZTime []
      ((MinusFormula.atom p).box.imp (MinusFormula.atom p).box.allPast) ∧
    MinusLanguage.Derivable FrameClass.ZTime []
      ((MinusFormula.atom p).box.neg.imp (MinusFormula.atom p).box.neg.allFuture) ∧
    MinusLanguage.Derivable FrameClass.ZTime []
      ((MinusFormula.atom p).box.neg.imp (MinusFormula.atom p).box.neg.allPast) :=
  ⟨⟨boxGlobalFuture _⟩, ⟨boxGlobalPast _⟩, ⟨notBoxGlobalFuture _⟩, ⟨notBoxGlobalPast _⟩⟩

end FormalSystem.Metalogic.Conservativity
