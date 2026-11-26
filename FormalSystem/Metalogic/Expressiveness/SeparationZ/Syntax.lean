/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Init
import FormalSystem.Syntax.Connectives
import FormalSystem.Syntax.ConnectivesElab
import Mathlib.Data.Int.LeastGreatest
import Mathlib.Order.Basic

/-!
# The auxiliary until/since syntax over abstract leaves

Gabbay's Separation Theorem over the integer flow ([GHR][gabbay1994] vol. 1, Theorem 10.2.9) is
a statement about an until/since language whose leaves are propositional atoms. The development
in this subtree carries it over an auxiliary syntax `USForm` whose leaves are abstract natural
number indices, evaluated by an arbitrary leaf valuation `ℕ → ℤ → Prop`.

## Why an auxiliary syntax

GHR substitute formulas for atoms in four of their eight lemmas. Uniform substitution does not
visibly preserve L⁺ validity over task frames: `PlusFormula.atom p` is evaluated at
`M.valuation (τ.state t)`, a function of the present world state alone, while a substituend is
history- and time-dependent. Abstracting the leaves to *arbitrary* predicates makes every
abstraction/resubstitution step a reindexing of the leaf valuation, so no substitution lemma is
needed anywhere in the development. The seam back to `PlusFormula` is a single interface, in
`SeparationZ/LeafAbstraction.lean`.

## Argument order

`untl` and `snce` take the **guard first and the event second**, matching
`FormalSystem.PlusLanguage.PlusFormula.untl` and `FormalSystem.Syntax.Formula.untl`. This is
**opposite** to GHR's own `U(A, B)`, which reads the event first: GHR's `U(A, B)` is this
module's `untl B A`. Every transcription from the source flips.

## Main Definitions

- `USForm`: the five-constructor auxiliary syntax (`leaf`, `bot`, `imp`, `untl`, `snce`)
- `usTruth`: its truth recursion at a leaf valuation `v : ℕ → ℤ → Prop` and a time `t : ℤ`
- the derived connectives `top`, `neg`, `and`, `or`, `iff`, `someFuture`, `somePast`,
  `allFuture` (GHR's `G`), `allPast` (GHR's `H`), `next`, `prev`, each with the same right-hand
  side its `PlusFormula` counterpart carries
- `swap`: the time reflection exchanging `untl` and `snce`
- `maxLeaf`, `freshLeaf`: the fresh-index device standing in for GHR's "fresh atom"

## Main Results

- the clause lemmas `usTruth_imp_iff` … `usTruth_allPast_iff`, each a `simp`-usable `Iff`
- `swap_involutive`, `usTruth_swap`: the duality that halves every later `snce` case
- `usTruth_congr`, `usTruth_congr_of_update`: a leaf valuation only matters at indices the
  formula mentions

## References

* [D. M. Gabbay, I. Hodkinson and M. Reynolds, *Temporal Logic: Mathematical Foundations and
  Computational Aspects*][gabbay1994], vol. 1, Chapter 10 §10.2
-/

namespace FormalSystem.Metalogic.Expressiveness.SeparationZ

/-! ## The syntax -/

/--
The auxiliary until/since syntax. Leaves are natural-number indices into an abstract leaf
valuation; `untl` and `snce` take the guard first and the event second.
-/
inductive USForm : Type where
  /-- The `i`-th abstract leaf. -/
  | leaf : ℕ → USForm
  /-- Bottom. -/
  | bot : USForm
  /-- Implication. -/
  | imp : USForm → USForm → USForm
  /-- Until, guard first and event second: GHR's `U(event, guard)`. -/
  | untl : USForm → USForm → USForm
  /-- Since, guard first and event second: GHR's `S(event, guard)`. -/
  | snce : USForm → USForm → USForm
  deriving Repr, DecidableEq

instance : FormalSystem.Syntax.HasBot USForm := ⟨USForm.bot⟩
instance : FormalSystem.Syntax.HasImp USForm := ⟨USForm.imp⟩
instance : FormalSystem.Syntax.HasUntl USForm := ⟨USForm.untl⟩
instance : FormalSystem.Syntax.HasSnce USForm := ⟨USForm.snce⟩

namespace USForm

/-! ### Derived connectives

Each right-hand side is the one its `PlusFormula` counterpart carries, so that `toPlus`
commutes with it by `rfl`. -/

/-- Top: `⊥ → ⊥`. -/
def top : USForm := sig% FormalSystem.Syntax.Sig.top

/-- Negation: `φ → ⊥`. -/
def neg (φ : USForm) : USForm := sig% FormalSystem.Syntax.Sig.neg φ

/-- Conjunction: `¬(φ → ¬ψ)`. -/
def and (φ ψ : USForm) : USForm := sig% FormalSystem.Syntax.Sig.and φ ψ

/-- Disjunction: `¬φ → ψ`. -/
def or (φ ψ : USForm) : USForm := sig% FormalSystem.Syntax.Sig.or φ ψ

/-- Biconditional: `(φ → ψ) ∧ (ψ → φ)`. -/
def iff (φ ψ : USForm) : USForm := (φ.imp ψ).and (ψ.imp φ)

/-- Existential future `Fφ`: `⊤ U φ`. -/
def someFuture (φ : USForm) : USForm := sig% FormalSystem.Syntax.Sig.someFuture φ

/-- Existential past `Pφ`: `⊤ S φ`. -/
def somePast (φ : USForm) : USForm := sig% FormalSystem.Syntax.Sig.somePast φ

/-- Universal future `Gφ`: `¬F¬φ`. -/
def allFuture (φ : USForm) : USForm := sig% FormalSystem.Syntax.Sig.allFuture φ

/-- Universal past `Hφ`: `¬P¬φ`. -/
def allPast (φ : USForm) : USForm := sig% FormalSystem.Syntax.Sig.allPast φ

/-- Next step `Xφ`: `⊥ U φ`. -/
def next (φ : USForm) : USForm := sig% FormalSystem.Syntax.Sig.next φ

/-- Previous step `Yφ`: `⊥ S φ`. -/
def prev (φ : USForm) : USForm := sig% FormalSystem.Syntax.Sig.prev φ

end USForm

/-! ## Truth at a leaf valuation over `ℤ` -/

/--
Truth of a `USForm` at the leaf valuation `v` and the time `t`, over the integer flow. The
`untl` and `snce` clauses are `FormalSystem.PlusLanguage.PlusTruthAt`'s verbatim with
`F.Duration` replaced by `ℤ`; in particular the guard quantifies over the **strict open**
interval, which on `ℤ` is empty for adjacent witnesses.
-/
def usTruth (v : ℕ → ℤ → Prop) (t : ℤ) : USForm → Prop
  | .leaf i => v i t
  | .bot => False
  | .imp φ ψ => usTruth v t φ → usTruth v t ψ
  | .untl ψ φ => ∃ s : ℤ, t < s ∧ usTruth v s φ ∧ ∀ r : ℤ, t < r → r < s → usTruth v r ψ
  | .snce ψ φ => ∃ s : ℤ, s < t ∧ usTruth v s φ ∧ ∀ r : ℤ, s < r → r < t → usTruth v r ψ

section Clauses

variable (v : ℕ → ℤ → Prop) (t : ℤ)

@[simp] theorem usTruth_leaf (i : ℕ) : usTruth v t (.leaf i) ↔ v i t := Iff.rfl

@[simp] theorem usTruth_bot : ¬ usTruth v t .bot := fun h => h

@[simp] theorem usTruth_imp_iff (φ ψ : USForm) :
    usTruth v t (φ.imp ψ) ↔ (usTruth v t φ → usTruth v t ψ) := Iff.rfl

theorem usTruth_untl_iff (ψ φ : USForm) :
    usTruth v t (USForm.untl ψ φ) ↔
      ∃ s : ℤ, t < s ∧ usTruth v s φ ∧ ∀ r : ℤ, t < r → r < s → usTruth v r ψ := Iff.rfl

theorem usTruth_snce_iff (ψ φ : USForm) :
    usTruth v t (USForm.snce ψ φ) ↔
      ∃ s : ℤ, s < t ∧ usTruth v s φ ∧ ∀ r : ℤ, s < r → r < t → usTruth v r ψ := Iff.rfl

@[simp] theorem usTruth_top : usTruth v t USForm.top := fun h => h

@[simp] theorem usTruth_neg_iff (φ : USForm) :
    usTruth v t φ.neg ↔ ¬ usTruth v t φ := Iff.rfl

@[simp] theorem usTruth_and_iff (φ ψ : USForm) :
    usTruth v t (φ.and ψ) ↔ usTruth v t φ ∧ usTruth v t ψ := by
  rw [USForm.and, usTruth_neg_iff, usTruth_imp_iff, usTruth_neg_iff]
  tauto

@[simp] theorem usTruth_or_iff (φ ψ : USForm) :
    usTruth v t (φ.or ψ) ↔ usTruth v t φ ∨ usTruth v t ψ := by
  rw [USForm.or, usTruth_imp_iff, usTruth_neg_iff]
  tauto

theorem usTruth_iff_iff (φ ψ : USForm) :
    usTruth v t (φ.iff ψ) ↔ (usTruth v t φ ↔ usTruth v t ψ) := by
  rw [USForm.iff, usTruth_and_iff, usTruth_imp_iff, usTruth_imp_iff]
  tauto

@[simp] theorem usTruth_someFuture_iff (φ : USForm) :
    usTruth v t (USForm.someFuture φ) ↔ ∃ s : ℤ, t < s ∧ usTruth v s φ := by
  rw [USForm.someFuture, usTruth_untl_iff]
  exact exists_congr fun s => and_congr_right fun _ =>
    ⟨fun h => h.1, fun h => ⟨h, fun _ _ _ => usTruth_top v _⟩⟩

@[simp] theorem usTruth_somePast_iff (φ : USForm) :
    usTruth v t (USForm.somePast φ) ↔ ∃ s : ℤ, s < t ∧ usTruth v s φ := by
  rw [USForm.somePast, usTruth_snce_iff]
  exact exists_congr fun s => and_congr_right fun _ =>
    ⟨fun h => h.1, fun h => ⟨h, fun _ _ _ => usTruth_top v _⟩⟩

theorem usTruth_allFuture_iff (φ : USForm) :
    usTruth v t (USForm.allFuture φ) ↔ ∀ s : ℤ, t < s → usTruth v s φ := by
  rw [USForm.allFuture, usTruth_neg_iff, usTruth_someFuture_iff]
  constructor
  · intro h s hs
    by_contra hc
    exact h ⟨s, hs, hc⟩
  · rintro h ⟨s, hs, hns⟩
    exact hns (h s hs)

theorem usTruth_allPast_iff (φ : USForm) :
    usTruth v t (USForm.allPast φ) ↔ ∀ s : ℤ, s < t → usTruth v s φ := by
  rw [USForm.allPast, usTruth_neg_iff, usTruth_somePast_iff]
  constructor
  · intro h s hs
    by_contra hc
    exact h ⟨s, hs, hc⟩
  · rintro h ⟨s, hs, hns⟩
    exact hns (h s hs)

theorem usTruth_next_iff (φ : USForm) :
    usTruth v t (USForm.next φ) ↔ usTruth v (t + 1) φ := by
  rw [USForm.next, usTruth_untl_iff]
  constructor
  · rintro ⟨s, hts, hφ, hg⟩
    rcases lt_or_eq_of_le (by omega : t + 1 ≤ s) with h | h
    · exact absurd (hg (t + 1) (by omega) h) (usTruth_bot v _)
    · exact h ▸ hφ
  · intro h
    exact ⟨t + 1, by omega, h, fun r h1 h2 => absurd h1 (by omega)⟩

theorem usTruth_prev_iff (φ : USForm) :
    usTruth v t (USForm.prev φ) ↔ usTruth v (t - 1) φ := by
  rw [USForm.prev, usTruth_snce_iff]
  constructor
  · rintro ⟨s, hst, hφ, hg⟩
    rcases lt_or_eq_of_le (by omega : s ≤ t - 1) with h | h
    · exact absurd (hg (t - 1) h (by omega)) (usTruth_bot v _)
    · exact h ▸ hφ
  · intro h
    exact ⟨t - 1, by omega, h, fun r h1 h2 => absurd h2 (by omega)⟩

end Clauses

/-! ## The time reflection -/

/-- The time reflection on the syntax: exchange `untl` and `snce` throughout. -/
def USForm.swap : USForm → USForm
  | .leaf i => .leaf i
  | .bot => .bot
  | .imp φ ψ => .imp φ.swap ψ.swap
  | .untl ψ φ => .snce ψ.swap φ.swap
  | .snce ψ φ => .untl ψ.swap φ.swap

namespace USForm

@[simp] theorem swap_involutive (φ : USForm) : φ.swap.swap = φ := by
  induction φ with
  | leaf i => rfl
  | bot => rfl
  | imp φ ψ ihφ ihψ => simp [swap, ihφ, ihψ]
  | untl ψ φ ihψ ihφ => simp [swap, ihψ, ihφ]
  | snce ψ φ ihψ ihφ => simp [swap, ihψ, ihφ]

@[simp] theorem swap_top : top.swap = top := rfl

@[simp] theorem swap_neg (φ : USForm) : φ.neg.swap = φ.swap.neg := rfl

@[simp] theorem swap_and (φ ψ : USForm) : (φ.and ψ).swap = φ.swap.and ψ.swap := rfl

@[simp] theorem swap_or (φ ψ : USForm) : (φ.or ψ).swap = φ.swap.or ψ.swap := rfl

@[simp] theorem swap_imp (φ ψ : USForm) : (φ.imp ψ).swap = φ.swap.imp ψ.swap := rfl

@[simp] theorem swap_someFuture (φ : USForm) : (someFuture φ).swap = somePast φ.swap := rfl

@[simp] theorem swap_somePast (φ : USForm) : (somePast φ).swap = someFuture φ.swap := rfl

@[simp] theorem swap_allFuture (φ : USForm) : (allFuture φ).swap = allPast φ.swap := rfl

@[simp] theorem swap_allPast (φ : USForm) : (allPast φ).swap = allFuture φ.swap := rfl

@[simp] theorem swap_untl (ψ φ : USForm) : (USForm.untl ψ φ).swap = USForm.snce ψ.swap φ.swap :=
  rfl

@[simp] theorem swap_snce (ψ φ : USForm) : (USForm.snce ψ φ).swap = USForm.untl ψ.swap φ.swap :=
  rfl

end USForm

/-- The reflected leaf valuation: read `v` at the negated time. -/
def reflectVal (v : ℕ → ℤ → Prop) : ℕ → ℤ → Prop := fun i s => v i (-s)

@[simp] theorem reflectVal_reflectVal (v : ℕ → ℤ → Prop) : reflectVal (reflectVal v) = v := by
  funext i s
  simp [reflectVal]

/--
**Truth under the time reflection.** The `USForm`-level counterpart of
`FormalSystem.PlusLanguage.plusValidIn_reflectTime_iff`: this is what halves every `snce` case
in the development below, since a past-side statement is the image of its future-side
counterpart under `swap` together with this lemma.

Paper: — (formalization-native; the manuscript has no auxiliary until/since syntax and no
leaf abstraction, so it carries no label for this)
-/
theorem usTruth_swap (v : ℕ → ℤ → Prop) (t : ℤ) (φ : USForm) :
    usTruth v t φ.swap ↔ usTruth (reflectVal v) (-t) φ := by
  induction φ generalizing t with
  | leaf i => simp [USForm.swap, usTruth, reflectVal]
  | bot => exact Iff.rfl
  | imp φ ψ ihφ ihψ =>
    change (usTruth v t φ.swap → usTruth v t ψ.swap) ↔ _
    exact imp_congr (ihφ t) (ihψ t)
  | untl ψ φ ihψ ihφ =>
    change (∃ s : ℤ, s < t ∧ usTruth v s φ.swap ∧ ∀ r : ℤ, s < r → r < t → usTruth v r ψ.swap) ↔
      ∃ s : ℤ, -t < s ∧ usTruth (reflectVal v) s φ ∧
        ∀ r : ℤ, -t < r → r < s → usTruth (reflectVal v) r ψ
    constructor
    · rintro ⟨s, hst, hφ, hg⟩
      refine ⟨-s, by omega, (ihφ s).mp hφ, fun r h1 h2 => ?_⟩
      have := hg (-r) (by omega) (by omega)
      have h := (ihψ (-r)).mp this
      simpa using h
    · rintro ⟨s, hst, hφ, hg⟩
      refine ⟨-s, by omega, (ihφ (-s)).mpr (by simpa using hφ), fun r h1 h2 => ?_⟩
      refine (ihψ r).mpr ?_
      exact hg (-r) (by omega) (by omega)
  | snce ψ φ ihψ ihφ =>
    change (∃ s : ℤ, t < s ∧ usTruth v s φ.swap ∧ ∀ r : ℤ, t < r → r < s → usTruth v r ψ.swap) ↔
      ∃ s : ℤ, s < -t ∧ usTruth (reflectVal v) s φ ∧
        ∀ r : ℤ, s < r → r < -t → usTruth (reflectVal v) r ψ
    constructor
    · rintro ⟨s, hst, hφ, hg⟩
      refine ⟨-s, by omega, (ihφ s).mp hφ, fun r h1 h2 => ?_⟩
      have := hg (-r) (by omega) (by omega)
      have h := (ihψ (-r)).mp this
      simpa using h
    · rintro ⟨s, hst, hφ, hg⟩
      refine ⟨-s, by omega, (ihφ (-s)).mpr (by simpa using hφ), fun r h1 h2 => ?_⟩
      refine (ihψ r).mpr ?_
      exact hg (-r) (by omega) (by omega)

/-! ## The fresh-index device -/

/-- The largest leaf index the formula mentions (`0` when it mentions none). -/
def USForm.maxLeaf : USForm → ℕ
  | .leaf i => i
  | .bot => 0
  | .imp φ ψ => max φ.maxLeaf ψ.maxLeaf
  | .untl ψ φ => max ψ.maxLeaf φ.maxLeaf
  | .snce ψ φ => max ψ.maxLeaf φ.maxLeaf

/-- An index the formula does not mention: GHR's "fresh atom" device. -/
def USForm.freshLeaf (φ : USForm) : ℕ := φ.maxLeaf + 1

theorem USForm.lt_freshLeaf (φ : USForm) : φ.maxLeaf < φ.freshLeaf := Nat.lt_succ_self _

/-- Truth only depends on the leaf valuation at indices the formula mentions. -/
theorem usTruth_congr {v w : ℕ → ℤ → Prop} (φ : USForm)
    (h : ∀ i ≤ φ.maxLeaf, ∀ s : ℤ, v i s ↔ w i s) (t : ℤ) :
    usTruth v t φ ↔ usTruth w t φ := by
  induction φ generalizing t with
  | leaf i => exact h i le_rfl t
  | bot => exact Iff.rfl
  | imp φ ψ ihφ ihψ =>
    change (usTruth v t φ → usTruth v t ψ) ↔ _
    exact imp_congr (ihφ (fun i hi => h i (le_trans hi (le_max_left _ _))) t)
      (ihψ (fun i hi => h i (le_trans hi (le_max_right _ _))) t)
  | untl ψ φ ihψ ihφ =>
    have hψ' : ∀ i ≤ ψ.maxLeaf, ∀ s : ℤ, v i s ↔ w i s :=
      fun i hi => h i (le_trans hi (le_max_left _ _))
    have hφ' : ∀ i ≤ φ.maxLeaf, ∀ s : ℤ, v i s ↔ w i s :=
      fun i hi => h i (le_trans hi (le_max_right _ _))
    exact exists_congr fun s => and_congr_right fun _ =>
      and_congr (ihφ hφ' s) (forall_congr' fun r => imp_congr_right fun _ =>
        imp_congr_right fun _ => ihψ hψ' r)
  | snce ψ φ ihψ ihφ =>
    have hψ' : ∀ i ≤ ψ.maxLeaf, ∀ s : ℤ, v i s ↔ w i s :=
      fun i hi => h i (le_trans hi (le_max_left _ _))
    have hφ' : ∀ i ≤ φ.maxLeaf, ∀ s : ℤ, v i s ↔ w i s :=
      fun i hi => h i (le_trans hi (le_max_right _ _))
    exact exists_congr fun s => and_congr_right fun _ =>
      and_congr (ihφ hφ' s) (forall_congr' fun r => imp_congr_right fun _ =>
        imp_congr_right fun _ => ihψ hψ' r)

/--
**The whole content of GHR's "fresh atom" device**: updating the leaf valuation at an index
above `maxLeaf φ` does not change `φ`'s truth.

Paper: — (formalization-native; the manuscript has no auxiliary until/since syntax and no
leaf abstraction, so it carries no label for this)
-/
theorem usTruth_congr_of_update {v : ℕ → ℤ → Prop} {j : ℕ} (φ : USForm)
    (hj : φ.maxLeaf < j) (p : ℤ → Prop) (t : ℤ) :
    usTruth (Function.update v j p) t φ ↔ usTruth v t φ := by
  refine usTruth_congr φ (fun i hi s => ?_) t
  have : i ≠ j := by omega
  simp [Function.update_of_ne this]

end FormalSystem.Metalogic.Expressiveness.SeparationZ
