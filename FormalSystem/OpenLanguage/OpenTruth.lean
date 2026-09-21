/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.Truth
import FormalSystem.Semantics.TruthClauses
import FormalSystem.OpenLanguage.Formula
import FormalSystem.OpenLanguage.OpenClasses

/-!
# `OpenTruthAt` — truth for the language L^▷

The native truth recursion for `OpenFormula` (`FormalSystem/OpenLanguage/Formula.lean`). The seven
L⁺ clauses are those of `PlusTruthAt` (`PlusLanguage/PlusTruth.lean`) verbatim, and the two new
ones are the manuscript's clauses for the open-future and open-past operators
(`sub:RestrictedModalities`):

```
M,τ,x ⊨ ▷φ   iff   M,σ,x ⊨ φ for all σ ∈ |τ⟩_x,
M,τ,x ⊨ ◁φ   iff   M,σ,x ⊨ φ for all σ ∈ ⟨τ|_x,
```

where `|τ⟩_x` is the set of possible worlds that agree with `τ` at every time `y ≤ x` and `⟨τ|_x`
the set of those that agree at every `y ≥ x` (`OpenLanguage/OpenClasses.lean`). Both classes are
rendered on the nose: `σ : WorldHistory F` with `AgreeUpTo τ σ x`, resp. `AgreeFrom τ σ x`.

## Main Definitions

- `OpenTruthAt M τ t φ` — the nine-clause truth recursion

## Main Results

- The `OpenTruth.*_iff` clause lemmas, including `ofut_iff`, `opast_iff` and the clauses
  `dofut_iff`, `dopast_iff` of the two duals
- `openTruthAt_ofPlus` — **truth-level conservativity over L⁺**: an L⁺ formula embedded into L^▷
  is true exactly when it is true in L⁺, at the same model, history and time
- Pointwise **S5** for each new operator, from the fact that each of `|τ⟩_x` and `⟨τ|_x` is an
  equivalence class (`agreeUpTo_equivalence`, `agreeFrom_equivalence`): `ofut_k`, `of_ofut` (T),
  `ofut_four`, `ofut_five`, and the four `opast` mirrors
- The pointwise **strength ordering** `□ ⟹ ⊡ ⟹ ▷` and `⊡ ⟹ ◁`: `stab_of_box`, `ofut_of_stab`,
  `opast_of_stab`, from `⟨τ⟩_x ⊆ H_F`, `|τ⟩_x ⊆ ⟨τ⟩_x` and `⟨τ|_x ⊆ ⟨τ⟩_x`

## References

* JPL paper `sub:RestrictedModalities` — the clauses for the open-future and open-past operators
* JPL paper `def:BLstar-semantics` — the stability clause
* `FormalSystem/PlusLanguage/PlusTruth.lean` — the seven L⁺ clauses being mirrored
* `FormalSystem/OpenLanguage/OpenClasses.lean` — the three classes and their equivalences

## Tags

truth · open-language · open-future · open-past
-/

namespace FormalSystem.OpenLanguage

open FormalSystem.Syntax
open FormalSystem.PlusLanguage
open FormalSystem.OpenLanguage.OpenFormula
open FormalSystem.Semantics

variable {F : TaskFrame}

/-! ## The truth recursion -/

/--
Truth of an L^▷ formula at a model, world history and time.

The seven L⁺ clauses are `PlusTruthAt`'s verbatim. The `ofut` clause is the manuscript's clause
for the open-future operator: `▷φ` holds at `(τ, t)` iff `φ` holds at `(σ, t)` for every world `σ`
that occupies "the same world state as `τ` at each time up to and including" `t` — every
`σ ∈ |τ⟩_t`. The `opast` clause is its mirror over `⟨τ|_t`, the worlds that agree with `τ` at `t`
"and all later times".
-/
def OpenTruthAt (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration) : OpenFormula → Prop
  | .atom p => M.valuation (τ.state t) p
  | .bot => False
  | .imp φ ψ => OpenTruthAt M τ t φ → OpenTruthAt M τ t ψ
  | .box φ => ∀ σ : WorldHistory F, OpenTruthAt M σ t φ
  | .untl ψ φ => ∃ s : F.Duration, t < s ∧ OpenTruthAt M τ s φ ∧
      ∀ r : F.Duration, t < r → r < s → OpenTruthAt M τ r ψ
  | .snce ψ φ => ∃ s : F.Duration, s < t ∧ OpenTruthAt M τ s φ ∧
      ∀ r : F.Duration, s < r → r < t → OpenTruthAt M τ r ψ
  | .stab φ => ∀ σ : WorldHistory F, τ.state t = σ.state t → OpenTruthAt M σ t φ
  | .ofut φ => ∀ σ : WorldHistory F, AgreeUpTo τ σ t → OpenTruthAt M σ t φ
  | .opast φ => ∀ σ : WorldHistory F, AgreeFrom τ σ t → OpenTruthAt M σ t φ

/-! ### The abstract clause layer, instantiated

L^▷'s instances of `Semantics/TruthClauses.lean`. L^▷ keeps L⁺'s six primitive operators, so it
instantiates the `stab` tier and inherits every derived-operator clause lemma; the two new
operators have no abstract tier and get their clause lemmas directly below. -/

/-- L^▷'s pointed truth relation, with the trivial environment. -/
instance : TruthEnv OpenFormula where
  Env _ := PUnit
  T M τ t _ φ := OpenTruthAt M τ t φ

/-- L^▷'s six inherited primitive operators and their clauses. -/
instance : StabClauses OpenFormula where
  bot := OpenFormula.bot
  imp := OpenFormula.imp
  box := OpenFormula.box
  untl := OpenFormula.untl
  snce := OpenFormula.snce
  stab := OpenFormula.stab
  bot_clause _ _ _ _ := fun h => h
  imp_clause _ _ _ _ _ _ := Iff.rfl
  box_clause _ _ _ _ _ := Iff.rfl
  untl_clause _ _ _ _ _ _ := Iff.rfl
  snce_clause _ _ _ _ _ _ := Iff.rfl
  stab_clause _ _ _ _ _ := Iff.rfl

namespace OpenTruth

/-! ### Clause lemmas -/

variable (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)

theorem atom_iff (p : Atom) :
    OpenTruthAt M τ t (.atom p) ↔ M.valuation (τ.state t) p := Iff.rfl

theorem stab_iff (φ : OpenFormula) :
    OpenTruthAt M τ t (.stab φ) ↔
      ∀ σ : WorldHistory F, τ.state t = σ.state t → OpenTruthAt M σ t φ := Iff.rfl

/-- The manuscript's open-future clause: `▷φ` quantifies over `|τ⟩_t`. -/
theorem ofut_iff (φ : OpenFormula) :
    OpenTruthAt M τ t (.ofut φ) ↔
      ∀ σ : WorldHistory F, AgreeUpTo τ σ t → OpenTruthAt M σ t φ := Iff.rfl

/-- The manuscript's open-past clause: `◁φ` quantifies over `⟨τ|_t`. -/
theorem opast_iff (φ : OpenFormula) :
    OpenTruthAt M τ t (.opast φ) ↔
      ∀ σ : WorldHistory F, AgreeFrom τ σ t → OpenTruthAt M σ t φ := Iff.rfl

theorem neg_iff (φ : OpenFormula) :
    OpenTruthAt M τ t (neg φ) ↔ ¬ OpenTruthAt M τ t φ :=
  TruthClauses.neg_iff (L := OpenFormula) M τ t PUnit.unit φ

theorem someFuture_iff (φ : OpenFormula) :
    OpenTruthAt M τ t (someFuture φ) ↔ ∃ s, t < s ∧ OpenTruthAt M τ s φ :=
  TruthClauses.someFuture_iff (L := OpenFormula) M τ t PUnit.unit φ

theorem somePast_iff (φ : OpenFormula) :
    OpenTruthAt M τ t (somePast φ) ↔ ∃ s, s < t ∧ OpenTruthAt M τ s φ :=
  TruthClauses.somePast_iff (L := OpenFormula) M τ t PUnit.unit φ

/-- `⟐φ`: some world in `⟨τ⟩_t` satisfies `φ`. -/
theorem dstab_iff (φ : OpenFormula) :
    OpenTruthAt M τ t (dstab φ) ↔
      ∃ σ : WorldHistory F, τ.state t = σ.state t ∧ OpenTruthAt M σ t φ :=
  TruthClauses.dstab_iff (L := OpenFormula) M τ t PUnit.unit φ

/-- `▷̂φ`: some world in `|τ⟩_t` satisfies `φ`. The `dstab_iff` argument, over `AgreeUpTo`. -/
theorem dofut_iff (φ : OpenFormula) :
    OpenTruthAt M τ t (dofut φ) ↔
      ∃ σ : WorldHistory F, AgreeUpTo τ σ t ∧ OpenTruthAt M σ t φ := by
  rw [dofut, neg_iff, ofut_iff]
  constructor
  · intro h
    by_contra hc
    push Not at hc
    exact h (fun σ hs => (neg_iff M σ t φ).mpr (hc σ hs))
  · rintro ⟨σ, hs, hφ⟩ h
    exact ((neg_iff M σ t φ).mp (h σ hs)) hφ

/-- `◁̂φ`: some world in `⟨τ|_t` satisfies `φ`. The `dstab_iff` argument, over `AgreeFrom`. -/
theorem dopast_iff (φ : OpenFormula) :
    OpenTruthAt M τ t (dopast φ) ↔
      ∃ σ : WorldHistory F, AgreeFrom τ σ t ∧ OpenTruthAt M σ t φ := by
  rw [dopast, neg_iff, opast_iff]
  constructor
  · intro h
    by_contra hc
    push Not at hc
    exact h (fun σ hs => (neg_iff M σ t φ).mpr (hc σ hs))
  · rintro ⟨σ, hs, hφ⟩ h
    exact ((neg_iff M σ t φ).mp (h σ hs)) hφ

end OpenTruth

open OpenTruth

/-! ## Truth-level conservativity over L⁺ -/

/--
**The truth-transfer bridge.** An L⁺ formula embedded into L^▷ is true exactly when it is true in
L⁺, at the same model, history and time.

By induction on `φ`, generalizing the history and the time: the `box` and `stab` cases need the
hypothesis at a different history and the two temporal cases at a different time. Every case is
congruence, because the seven L⁺ clauses of `OpenTruthAt` are `PlusTruthAt`'s verbatim and
`ofPlus` is constructor-to-constructor.
-/
theorem openTruthAt_ofPlus (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (φ : PlusFormula) : OpenTruthAt M τ t (ofPlus φ) ↔ PlusTruthAt M τ t φ := by
  induction φ generalizing τ t with
  | atom p => exact Iff.rfl
  | bot => exact Iff.rfl
  | imp φ ψ ihφ ihψ => exact Iff.imp (ihφ τ t) (ihψ τ t)
  | box φ ih => exact forall_congr' fun σ => ih σ t
  | untl ψ φ ihψ ihφ =>
    exact exists_congr fun s => and_congr_right fun _ =>
      and_congr (ihφ τ s)
        (forall_congr' fun r => imp_congr_right fun _ => imp_congr_right fun _ => ihψ τ r)
  | snce ψ φ ihψ ihφ =>
    exact exists_congr fun s => and_congr_right fun _ =>
      and_congr (ihφ τ s)
        (forall_congr' fun r => imp_congr_right fun _ => imp_congr_right fun _ => ihψ τ r)
  | stab φ ih => exact forall_congr' fun σ => imp_congr_right fun _ => ih σ t

/-! ## Pointwise S5 for `▷`

Each fact is the corresponding field of `agreeUpTo_equivalence`: reflexivity gives T, transitivity
4, symmetry with transitivity 5. -/

/-- **K for `▷`**: `▷(φ → ψ) → (▷φ → ▷ψ)`. -/
theorem ofut_k (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration) (φ ψ : OpenFormula)
    (h : OpenTruthAt M τ t (.ofut (.imp φ ψ))) (hφ : OpenTruthAt M τ t (.ofut φ)) :
    OpenTruthAt M τ t (.ofut ψ) :=
  fun σ hσ => h σ hσ (hφ σ hσ)

/-- **T for `▷`**: `▷φ → φ` (`τ ∈ |τ⟩_t`). -/
theorem of_ofut (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration) (φ : OpenFormula)
    (h : OpenTruthAt M τ t (.ofut φ)) : OpenTruthAt M τ t φ :=
  h τ ((agreeUpTo_equivalence t).refl τ)

/-- **4 for `▷`**: `▷φ → ▷▷φ`, by transitivity of agreement up to `t`. -/
theorem ofut_four (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration) (φ : OpenFormula)
    (h : OpenTruthAt M τ t (.ofut φ)) : OpenTruthAt M τ t (.ofut (.ofut φ)) :=
  fun _ hσ ρ hρ => h ρ ((agreeUpTo_equivalence t).trans hσ hρ)

/-- **5 for `▷`**: `▷̂φ → ▷▷̂φ`, by symmetry and transitivity of agreement up to `t`. -/
theorem ofut_five (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration) (φ : OpenFormula)
    (h : OpenTruthAt M τ t (dofut φ)) : OpenTruthAt M τ t (.ofut (dofut φ)) := by
  obtain ⟨ρ, hρ, hφ⟩ := (dofut_iff M τ t φ).mp h
  intro σ hσ
  exact (dofut_iff M σ t φ).mpr
    ⟨ρ, (agreeUpTo_equivalence t).trans ((agreeUpTo_equivalence t).symm hσ) hρ, hφ⟩

/-! ## Pointwise S5 for `◁` -/

/-- **K for `◁`**: `◁(φ → ψ) → (◁φ → ◁ψ)`. -/
theorem opast_k (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration) (φ ψ : OpenFormula)
    (h : OpenTruthAt M τ t (.opast (.imp φ ψ))) (hφ : OpenTruthAt M τ t (.opast φ)) :
    OpenTruthAt M τ t (.opast ψ) :=
  fun σ hσ => h σ hσ (hφ σ hσ)

/-- **T for `◁`**: `◁φ → φ` (`τ ∈ ⟨τ|_t`). -/
theorem of_opast (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration) (φ : OpenFormula)
    (h : OpenTruthAt M τ t (.opast φ)) : OpenTruthAt M τ t φ :=
  h τ ((agreeFrom_equivalence t).refl τ)

/-- **4 for `◁`**: `◁φ → ◁◁φ`, by transitivity of agreement from `t`. -/
theorem opast_four (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration) (φ : OpenFormula)
    (h : OpenTruthAt M τ t (.opast φ)) : OpenTruthAt M τ t (.opast (.opast φ)) :=
  fun _ hσ ρ hρ => h ρ ((agreeFrom_equivalence t).trans hσ hρ)

/-- **5 for `◁`**: `◁̂φ → ◁◁̂φ`, by symmetry and transitivity of agreement from `t`. -/
theorem opast_five (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration) (φ : OpenFormula)
    (h : OpenTruthAt M τ t (dopast φ)) : OpenTruthAt M τ t (.opast (dopast φ)) := by
  obtain ⟨ρ, hρ, hφ⟩ := (dopast_iff M τ t φ).mp h
  intro σ hσ
  exact (dopast_iff M σ t φ).mpr
    ⟨ρ, (agreeFrom_equivalence t).trans ((agreeFrom_equivalence t).symm hσ) hρ, hφ⟩

/-! ## The strength ordering `□ ⟹ ⊡ ⟹ ▷` and `⊡ ⟹ ◁` -/

/-- **`□φ → ⊡φ`**: `⟨τ⟩_t ⊆ H_F`. -/
theorem stab_of_box (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration) (φ : OpenFormula)
    (h : OpenTruthAt M τ t (.box φ)) : OpenTruthAt M τ t (.stab φ) :=
  fun σ _ => h σ

/-- **`⊡φ → ▷φ`**: `|τ⟩_t ⊆ ⟨τ⟩_t` (`openFutureClass_subset_stabClass`). Stability is the
stronger necessity. -/
theorem ofut_of_stab (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration) (φ : OpenFormula)
    (h : OpenTruthAt M τ t (.stab φ)) : OpenTruthAt M τ t (.ofut φ) :=
  fun σ hσ => h σ (openFutureClass_subset_stabClass τ t hσ)

/-- **`⊡φ → ◁φ`**: `⟨τ|_t ⊆ ⟨τ⟩_t` (`openPastClass_subset_stabClass`). -/
theorem opast_of_stab (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration) (φ : OpenFormula)
    (h : OpenTruthAt M τ t (.stab φ)) : OpenTruthAt M τ t (.opast φ) :=
  fun σ hσ => h σ (openPastClass_subset_stabClass τ t hσ)

end FormalSystem.OpenLanguage
