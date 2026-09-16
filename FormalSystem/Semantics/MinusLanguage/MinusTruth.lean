/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.Truth
import FormalSystem.Syntax.MinusLanguage.Formula
import FormalSystem.Semantics.TruthClauses

-- Lower semantic layer: must not reach the proof system (G-15). `FrameClassValidity.lean`
-- is the one documented seam that imports `ProofSystem.Axioms`; nothing below it may.
assert_not_exists FormalSystem.ProofSystem.Axiom FormalSystem.ProofSystem.DerivationTree
  FormalSystem.ProofSystem.Derivable FormalSystem.ProofSystem.FrameClass

/-!
# `MinusTruthAt` — native task semantics for the tense-primitive base language L⁻

This module defines truth evaluation for `FormalSystem.MinusLanguage.MinusFormula` — the base
language L⁻ of `def:BL-language`, whose `H`/`G` are *primitive* — directly by recursion on
`MinusFormula`'s six constructors, transcribing `def:BL-semantics` clause for clause.

## This is a native recursion, not a composite

`MinusTruthAt` is **not** `TruthAt ∘ tr`. Every clause below quantifies in the base language's own
terms: the `allPast`/`allFuture` clauses state the paper's universal quantification over times
directly rather than routing through L's `untl`/`snce` abbreviations, and no clause mentions
the translation. That is what makes the truth-transfer bridge
(`FormalSystem/Metalogic/Conservativity/MinusLanguageSoundness.lean`'s `truthAt_tr`) a *theorem* with content in
its temporal cases, rather than a definitional unfolding — and it is what makes an L⁻ soundness
theorem stated against `MinusTruthAt` a claim about L⁻ rather than a restatement of the L one.

## Paper Specification Reference

`def:BL-semantics`, clause by clause:

| Clause | Paper | This module |
|---|---|---|
| `pᵢ` | `τ(x)` lies in the extension of `pᵢ` | `∃ (ht : τ.domain t), M.valuation (τ.states t ht) p` |
| `⊥` | `M,τ,x ⊭ ⊥` | `False` |
| `→` | `M,τ,x ⊭ φ` or `M,τ,x ⊨ ψ` | `MinusTruthAt … φ → MinusTruthAt … ψ` |
| `□` | `M,σ,x ⊨ φ` for all `σ ∈ H_F` | `∀ σ, σ.IsTotal → MinusTruthAt M σ t φ` |
| `H` (`\Past`) | `M,τ,y ⊨ φ` for all `y ∈ D` with `y < x` | `∀ s, s < t → MinusTruthAt M τ s φ` |
| `G` (`\Future`) | `M,τ,y ⊨ φ` for all `y ∈ D` with `x < y` | `∀ s, t < s → MinusTruthAt M τ s φ` |

The paper's `H`/`G` clauses are **strict** (`y < x`, `x < y`), and so are these. The box clause's
quantifier ranges over `H_F`, the frame's **total** histories, which `PartialHistory.IsTotal` is the
predicate form of — identical to `Semantics/Truth.lean`'s box clause, with no admissible-history
parameter and no shift-closure side condition.

**Atom clause — a knowingly inherited divergence.** `def:BL-semantics`'s atom clause carries no
domain check, but the clause here carries the same `∃ (ht : τ.domain t), …` conjunct that
`TruthAt` does. That is Decision A of `docs/architecture/total-history-validity-decisions.md`: under
totality the conjunct is vacuously satisfiable at every `t`, so the two readings agree on `H_F`,
and keeping it is exactly what makes the atom case of the bridge `Iff.rfl`. It is inherited on
purpose; do not "correct" it away.

## Module Placement

This module sits under `FormalSystem/Semantics/` and imports `FormalSystem.MinusLanguage.Formula`,
a leaf that itself imports only `FormalSystem.Syntax.Atom`. This is the permitted direction of the
`MinusLanguage/` module invariant, which forbids `MinusLanguage/ → Semantics/` and says nothing
about the converse; see `FormalSystem/MinusLanguage.lean`'s "Module Invariant" section.

## Main Definitions

- `MinusTruthAt`: truth of a `MinusFormula` at a model-history-time triple, by six-clause recursion

## Main Results

`MinusTruth.*` — characterization lemmas mirroring `Semantics/Truth.lean`'s `Truth` namespace:

- `bot_false`, `imp_iff`, `box_iff`, `past_iff`, `future_iff` — the primitive clauses
- `neg_iff`, `top_true`, `and_iff`, `or_iff` — the derived Boolean operators
- `diamond_iff`, `somePast_iff`, `someFuture_iff` — the derived existentials, each the classical
  `¬∀¬ ↔ ∃` step
- `always_iff` — `△φ`, from `and_iff` together with `past_iff` and `future_iff`

## References

* JPL paper `\S sub:Logic` — `def:BL-semantics`, `def:BL-language`
* `FormalSystem/Semantics/Truth.lean` — the L truth definition this mirrors
* `FormalSystem/MinusLanguage/Formula.lean` — `MinusFormula` and its derived operators

## Tags

truth · base-language · MinusTruthAt · def:BL-semantics
-/

namespace FormalSystem.Semantics

open FormalSystem.MinusLanguage

variable {F : TaskFrame}

/--
Truth of a base-language formula at a model-history-time triple.

Six clauses, one per `MinusFormula` constructor, transcribing `def:BL-semantics`. See the module
docstring for the clause-by-clause correspondence with the paper, for why the atom clause carries
a domain conjunct the paper's does not, and for why this is a native recursion rather than
`TruthAt ∘ tr`.

The `box` clause recurses at a different history and the temporal clauses at a different time;
the equation compiler handles both exactly as it already does for `TruthAt`, so no termination
annotation is required.
-/
def MinusTruthAt (M : TaskModel F) (τ : PartialHistory F) (t : F.Duration) : MinusFormula → Prop
  | .atom p => ∃ (ht : τ.domain t), M.valuation (τ.states t ht) p
  | .bot => False
  | .imp φ ψ => MinusTruthAt M τ t φ → MinusTruthAt M τ t ψ
  | .box φ => ∀ (σ : PartialHistory F), σ.IsTotal → MinusTruthAt M σ t φ
  | .allPast φ => ∀ s : F.Duration, s < t → MinusTruthAt M τ s φ
  | .allFuture φ => ∀ s : F.Duration, t < s → MinusTruthAt M τ s φ

/-! ### The abstract clause layer, instantiated

L⁻'s instances of `Semantics/TruthClauses.lean`. This is the first genuine syntax-side
divergence in the tower: `allPast`/`allFuture` are **primitive** constructors here, not
`untl`/`snce` derivatives, so L⁻ instantiates `TenseClauses` and inherits the primed tense tier
rather than the `untl` one. The environment is trivial, exactly as for L. -/

/-- L⁻'s pointed truth relation, with the trivial environment. -/
instance : TruthEnv MinusFormula where
  Env _ := PUnit
  T M τ t _ φ := MinusTruthAt M τ t φ

/-- L⁻'s five primitive operators and their clauses; the tenses are `allFuture`/`allPast`
themselves, not `untl`/`snce`. -/
instance : TenseClauses MinusFormula where
  bot := MinusFormula.bot
  imp := MinusFormula.imp
  box := MinusFormula.box
  allFuture := MinusFormula.allFuture
  allPast := MinusFormula.allPast
  bot_clause _ _ _ _ := fun h => h
  imp_clause _ _ _ _ _ _ := Iff.rfl
  box_clause _ _ _ _ _ := Iff.rfl
  allFuture_clause _ _ _ _ _ := Iff.rfl
  allPast_clause _ _ _ _ _ := Iff.rfl

namespace MinusTruth

variable {M : TaskModel F} {τ : PartialHistory F} {t : F.Duration}

/-! ### The primitive clauses -/

/-- Bot (`⊥`) is false everywhere. -/
theorem bot_false : ¬ MinusTruthAt M τ t MinusFormula.bot := id

/-- Truth of implication is the material conditional. -/
theorem imp_iff (φ ψ : MinusFormula) :
    MinusTruthAt M τ t (φ.imp ψ) ↔ (MinusTruthAt M τ t φ → MinusTruthAt M τ t ψ) := Iff.rfl

/-- Truth of `□φ`: `φ` holds at every **total** history at the current time.

`def:BL-semantics`'s box clause, "M,τ,x ⊨ □φ *iff* M,σ,x ⊨ φ for all σ ∈ H_F", with `H_F`
membership read off `PartialHistory.IsTotal`. -/
theorem box_iff (φ : MinusFormula) :
    MinusTruthAt M τ t φ.box ↔ ∀ (σ : PartialHistory F), σ.IsTotal → MinusTruthAt M σ t φ := Iff.rfl

/-- Truth of `Hφ` (universal past): `φ` holds at every **strictly** past time. -/
theorem past_iff (φ : MinusFormula) :
    MinusTruthAt M τ t φ.allPast ↔ ∀ s : F.Duration, s < t → MinusTruthAt M τ s φ := Iff.rfl

/-- Truth of `Gφ` (universal future): `φ` holds at every **strictly** future time. -/
theorem future_iff (φ : MinusFormula) :
    MinusTruthAt M τ t φ.allFuture ↔ ∀ s : F.Duration, t < s → MinusTruthAt M τ s φ := Iff.rfl

/-! ### The derived Boolean operators -/

/-- Truth of `¬φ`. -/
@[simp] theorem neg_iff (φ : MinusFormula) :
    MinusTruthAt M τ t φ.neg ↔ ¬ MinusTruthAt M τ t φ :=
  TruthClauses.neg_iff (L := MinusFormula) M τ t PUnit.unit φ

/-- `⊤` is true everywhere. -/
@[simp] theorem top_true : MinusTruthAt M τ t MinusFormula.top :=
  TruthClauses.top_true (L := MinusFormula) M τ t PUnit.unit

/-- Truth of `φ ∧ ψ`. Classical: `and` is the double-negated implication. -/
@[simp] theorem and_iff (φ ψ : MinusFormula) :
    MinusTruthAt M τ t (φ.and ψ) ↔ (MinusTruthAt M τ t φ ∧ MinusTruthAt M τ t ψ) :=
  TruthClauses.and_iff (L := MinusFormula) M τ t PUnit.unit φ ψ

/-- Truth of `φ ∨ ψ`. Classical: `or` is `¬φ → ψ`. -/
@[simp] theorem or_iff (φ ψ : MinusFormula) :
    MinusTruthAt M τ t (φ.or ψ) ↔ (MinusTruthAt M τ t φ ∨ MinusTruthAt M τ t ψ) :=
  TruthClauses.or_iff (L := MinusFormula) M τ t PUnit.unit φ ψ

/-! ### The derived existential operators

Each of the three is the classical `¬∀¬ ↔ ∃` step over the corresponding universal clause. These
are the interface a countermodel evaluation actually calls: the paper states its refuting
witnesses with the derived existentials `P`, `F` and `◇`, so having them once here saves
re-deriving the classical step at every evaluation site. -/

/-- Truth of `◇φ` (`¬□¬φ`): `φ` holds at *some* total history at the current time. -/
@[simp] theorem diamond_iff (φ : MinusFormula) :
    MinusTruthAt M τ t φ.diamond ↔ ∃ σ : PartialHistory F, σ.IsTotal ∧ MinusTruthAt M σ t φ :=
  TruthClauses.diamond_iff (L := MinusFormula) M τ t PUnit.unit φ

/-- Truth of `Pφ` (`¬H¬φ`): `φ` held at *some* strictly past time. -/
@[simp] theorem somePast_iff (φ : MinusFormula) :
    MinusTruthAt M τ t φ.somePast ↔ ∃ s : F.Duration, s < t ∧ MinusTruthAt M τ s φ :=
  TruthClauses.somePast_iff_of_allPast (L := MinusFormula) M τ t PUnit.unit φ

/-- Truth of `Fφ` (`¬G¬φ`): `φ` holds at *some* strictly future time. -/
@[simp] theorem someFuture_iff (φ : MinusFormula) :
    MinusTruthAt M τ t φ.someFuture ↔ ∃ s : F.Duration, t < s ∧ MinusTruthAt M τ s φ :=
  TruthClauses.someFuture_iff_of_allFuture (L := MinusFormula) M τ t PUnit.unit φ

/-! ### Temporal `always` -/

/-- Truth of `△φ` (`Hφ ∧ (φ ∧ Gφ)`): `φ` holds at every time, past, present and future.

The association mirrors `MinusFormula.always`, hence `Formula.always`. -/
@[simp] theorem always_iff (φ : MinusFormula) :
    MinusTruthAt M τ t φ.always ↔
      (∀ s : F.Duration, s < t → MinusTruthAt M τ s φ) ∧ MinusTruthAt M τ t φ ∧
        (∀ s : F.Duration, t < s → MinusTruthAt M τ s φ) :=
  TruthClauses.always_iff_of_tense (L := MinusFormula) M τ t PUnit.unit φ

end MinusTruth

end FormalSystem.Semantics
