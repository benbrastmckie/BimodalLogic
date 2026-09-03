/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.Truth
import FormalSystem.BaseLanguage.Formula

/-!
# `BLTruthAt` — native task semantics for the tense-primitive base language BL

This module defines truth evaluation for `FormalSystem.BaseLanguage.BLFormula` — the base
language BL of `def:BL-language`, whose `H`/`G` are *primitive* — directly by recursion on
`BLFormula`'s six constructors, transcribing `def:BL-semantics` clause for clause.

## This is a native recursion, not a composite

`BLTruthAt` is **not** `TruthAt ∘ tr`. Every clause below quantifies in the base language's own
terms: the `allPast`/`allFuture` clauses state the paper's universal quantification over times
directly rather than routing through BL⁺'s `untl`/`snce` abbreviations, and no clause mentions
the translation. That is what makes the truth-transfer bridge
(`FormalSystem/Metalogic/Conservativity/BaseLanguageSoundness.lean`'s `truthAt_tr`) a *theorem* with content in
its temporal cases, rather than a definitional unfolding — and it is what makes a BL soundness
theorem stated against `BLTruthAt` a claim about BL rather than a restatement of the BL⁺ one.

## Paper Specification Reference

`def:BL-semantics`, clause by clause:

| Clause | Paper | This module |
|---|---|---|
| `pᵢ` | `τ(x)` lies in the extension of `pᵢ` | `∃ (ht : τ.domain t), M.valuation (τ.states t ht) p` |
| `⊥` | `M,τ,x ⊭ ⊥` | `False` |
| `→` | `M,τ,x ⊭ φ` or `M,τ,x ⊨ ψ` | `BLTruthAt … φ → BLTruthAt … ψ` |
| `□` | `M,σ,x ⊨ φ` for all `σ ∈ H_F` | `∀ σ, σ.IsTotal → BLTruthAt M σ t φ` |
| `H` (`\Past`) | `M,τ,y ⊨ φ` for all `y ∈ D` with `y < x` | `∀ s, s < t → BLTruthAt M τ s φ` |
| `G` (`\Future`) | `M,τ,y ⊨ φ` for all `y ∈ D` with `x < y` | `∀ s, t < s → BLTruthAt M τ s φ` |

The paper's `H`/`G` clauses are **strict** (`y < x`, `x < y`), and so are these. The box clause's
quantifier ranges over `H_F`, the frame's **total** histories, which `WorldHistory.IsTotal` is the
predicate form of — identical to `Semantics/Truth.lean`'s box clause, with no admissible-history
parameter and no shift-closure side condition.

**Atom clause — a knowingly inherited divergence.** `def:BL-semantics`'s atom clause carries no
domain check, but the clause here carries the same `∃ (ht : τ.domain t), …` conjunct that
`TruthAt` does. That is Decision A of `specs/decisions/total-history-validity-decisions.md`: under
totality the conjunct is vacuously satisfiable at every `t`, so the two readings agree on `H_F`,
and keeping it is exactly what makes the atom case of the bridge `Iff.rfl`. It is inherited on
purpose; do not "correct" it away.

## Module Placement

This module sits under `FormalSystem/Semantics/` and imports `FormalSystem.BaseLanguage.Formula`,
a leaf that itself imports only `FormalSystem.Syntax.Atom`. This is the permitted direction of the
`BaseLanguage/` module invariant, which forbids `BaseLanguage/ → Semantics/` and says nothing
about the converse; see `FormalSystem/BaseLanguage.lean`'s "Module Invariant" section.

## Main Definitions

- `BLTruthAt`: truth of a `BLFormula` at a model-history-time triple, by six-clause recursion

## Main Results

`BLTruth.*` — characterization lemmas mirroring `Semantics/Truth.lean`'s `Truth` namespace:

- `bot_false`, `imp_iff`, `box_iff`, `past_iff`, `future_iff` — the primitive clauses
- `neg_iff`, `top_true`, `and_iff`, `or_iff` — the derived Boolean operators
- `diamond_iff`, `somePast_iff`, `someFuture_iff` — the derived existentials, each the classical
  `¬∀¬ ↔ ∃` step
- `always_iff` — `△φ`, from `and_iff` together with `past_iff` and `future_iff`

## References

* JPL paper `\S sub:Logic` — `def:BL-semantics`, `def:BL-language`
* `FormalSystem/Semantics/Truth.lean` — the BL⁺ truth definition this mirrors
* `FormalSystem/BaseLanguage/Formula.lean` — `BLFormula` and its derived operators
-/

namespace FormalSystem.Semantics

open FormalSystem.BaseLanguage

variable {F : TaskFrame}

/--
Truth of a base-language formula at a model-history-time triple.

Six clauses, one per `BLFormula` constructor, transcribing `def:BL-semantics`. See the module
docstring for the clause-by-clause correspondence with the paper, for why the atom clause carries
a domain conjunct the paper's does not, and for why this is a native recursion rather than
`TruthAt ∘ tr`.

The `box` clause recurses at a different history and the temporal clauses at a different time;
the equation compiler handles both exactly as it already does for `TruthAt`, so no termination
annotation is required.
-/
def BLTruthAt (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration) : BLFormula → Prop
  | .atom p => ∃ (ht : τ.domain t), M.valuation (τ.states t ht) p
  | .bot => False
  | .imp φ ψ => BLTruthAt M τ t φ → BLTruthAt M τ t ψ
  | .box φ => ∀ (σ : WorldHistory F), σ.IsTotal → BLTruthAt M σ t φ
  | .allPast φ => ∀ s : F.Duration, s < t → BLTruthAt M τ s φ
  | .allFuture φ => ∀ s : F.Duration, t < s → BLTruthAt M τ s φ

namespace BLTruth

variable {M : TaskModel F} {τ : WorldHistory F} {t : F.Duration}

/-! ### The primitive clauses -/

/-- Bot (`⊥`) is false everywhere. -/
theorem bot_false : ¬ BLTruthAt M τ t BLFormula.bot := id

/-- Truth of implication is the material conditional. -/
theorem imp_iff (φ ψ : BLFormula) :
    BLTruthAt M τ t (φ.imp ψ) ↔ (BLTruthAt M τ t φ → BLTruthAt M τ t ψ) := Iff.rfl

/-- Truth of `□φ`: `φ` holds at every **total** history at the current time.

`def:BL-semantics`'s box clause, "M,τ,x ⊨ □φ *iff* M,σ,x ⊨ φ for all σ ∈ H_F", with `H_F`
membership read off `WorldHistory.IsTotal`. -/
theorem box_iff (φ : BLFormula) :
    BLTruthAt M τ t φ.box ↔ ∀ (σ : WorldHistory F), σ.IsTotal → BLTruthAt M σ t φ := Iff.rfl

/-- Truth of `Hφ` (universal past): `φ` holds at every **strictly** past time. -/
theorem past_iff (φ : BLFormula) :
    BLTruthAt M τ t φ.allPast ↔ ∀ s : F.Duration, s < t → BLTruthAt M τ s φ := Iff.rfl

/-- Truth of `Gφ` (universal future): `φ` holds at every **strictly** future time. -/
theorem future_iff (φ : BLFormula) :
    BLTruthAt M τ t φ.allFuture ↔ ∀ s : F.Duration, t < s → BLTruthAt M τ s φ := Iff.rfl

/-! ### The derived Boolean operators -/

/-- Truth of `¬φ`. -/
@[simp] theorem neg_iff (φ : BLFormula) :
    BLTruthAt M τ t φ.neg ↔ ¬ BLTruthAt M τ t φ := Iff.rfl

/-- `⊤` is true everywhere. -/
@[simp] theorem top_true : BLTruthAt M τ t BLFormula.top := id

/-- Truth of `φ ∧ ψ`. Classical: `and` is the double-negated implication. -/
@[simp] theorem and_iff (φ ψ : BLFormula) :
    BLTruthAt M τ t (φ.and ψ) ↔ (BLTruthAt M τ t φ ∧ BLTruthAt M τ t ψ) := by
  simp only [BLFormula.and, BLFormula.neg, BLTruthAt]
  tauto

/-- Truth of `φ ∨ ψ`. Classical: `or` is `¬φ → ψ`. -/
@[simp] theorem or_iff (φ ψ : BLFormula) :
    BLTruthAt M τ t (φ.or ψ) ↔ (BLTruthAt M τ t φ ∨ BLTruthAt M τ t ψ) := by
  simp only [BLFormula.or, BLFormula.neg, BLTruthAt]
  tauto

/-! ### The derived existential operators

Each of the three is the classical `¬∀¬ ↔ ∃` step over the corresponding universal clause. These
are the interface a countermodel evaluation actually calls: the paper states its refuting
witnesses with the derived existentials `P`, `F` and `◇`, so having them once here saves
re-deriving the classical step at every evaluation site. -/

/-- Truth of `◇φ` (`¬□¬φ`): `φ` holds at *some* total history at the current time. -/
@[simp] theorem diamond_iff (φ : BLFormula) :
    BLTruthAt M τ t φ.diamond ↔ ∃ σ : WorldHistory F, σ.IsTotal ∧ BLTruthAt M σ t φ := by
  simp only [BLFormula.diamond, BLFormula.neg, BLTruthAt]
  constructor
  · intro h; by_contra hc; push Not at hc; exact h (fun σ hσ hφ => hc σ hσ hφ)
  · rintro ⟨σ, hσ, hφ⟩ h; exact h σ hσ hφ

/-- Truth of `Pφ` (`¬H¬φ`): `φ` held at *some* strictly past time. -/
@[simp] theorem somePast_iff (φ : BLFormula) :
    BLTruthAt M τ t φ.somePast ↔ ∃ s : F.Duration, s < t ∧ BLTruthAt M τ s φ := by
  simp only [BLFormula.somePast, BLFormula.neg, BLTruthAt]
  constructor
  · intro h; by_contra hc; push Not at hc; exact h (fun s hs hφ => hc s hs hφ)
  · rintro ⟨s, hs, hφ⟩ h; exact h s hs hφ

/-- Truth of `Fφ` (`¬G¬φ`): `φ` holds at *some* strictly future time. -/
@[simp] theorem someFuture_iff (φ : BLFormula) :
    BLTruthAt M τ t φ.someFuture ↔ ∃ s : F.Duration, t < s ∧ BLTruthAt M τ s φ := by
  simp only [BLFormula.someFuture, BLFormula.neg, BLTruthAt]
  constructor
  · intro h; by_contra hc; push Not at hc; exact h (fun s hs hφ => hc s hs hφ)
  · rintro ⟨s, hs, hφ⟩ h; exact h s hs hφ

/-! ### Temporal `always` -/

/-- Truth of `△φ` (`Hφ ∧ (φ ∧ Gφ)`): `φ` holds at every time, past, present and future.

The association mirrors `BLFormula.always`, hence `Formula.always`. -/
@[simp] theorem always_iff (φ : BLFormula) :
    BLTruthAt M τ t φ.always ↔
      (∀ s : F.Duration, s < t → BLTruthAt M τ s φ) ∧ BLTruthAt M τ t φ ∧
        (∀ s : F.Duration, t < s → BLTruthAt M τ s φ) := by
  simp only [BLFormula.always, and_iff, past_iff, future_iff]

end BLTruth

end FormalSystem.Semantics
