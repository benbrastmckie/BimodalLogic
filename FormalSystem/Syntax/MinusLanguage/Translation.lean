/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Syntax.MinusLanguage.Formula
import FormalSystem.Syntax.Formula
import FormalSystem.Syntax.Context

/-!
# `tr` — the translation of L⁻ into L

`tr : MinusFormula → Formula` maps the tense-primitive base language into this repository's
until/since-primitive `Formula`, sending each L⁻ primitive to the L operator of the same
name. For `allPast`/`allFuture` the target is L's *derived* `Formula.allPast`/
`Formula.allFuture` — that substitution is the whole content of the translation.

## Main Definitions

- `tr : MinusFormula → Formula`
- `trCtx : MinusLanguage.Context → Syntax.Context` (`List.map tr`)

## Main Results

- `tr_swapMinus` : `tr (swapMinus φ) = swapTemporal (tr φ)` — **the load-bearing lemma**, without
  which the TD case of `FormalSystem.Metalogic.Conservativity.translate` does not typecheck
- `tr_ne_untl`, `tr_ne_snce` : `tr` never produces a top-level `untl`/`snce`
- `tr_injective` : `tr` is injective
- push-through equations for the derived Boolean and modal operators

## The existential operators do NOT push through — a measured fact, not an oversight

`tr` commutes definitionally with `neg`, `and`, `or`, `iff`, `diamond` and `always`. It does
**not** commute with `somePast`/`someFuture`:

```
tr (MinusFormula.someFuture φ)  =  ¬ (Formula.allFuture (tr φ).neg)  =  ¬¬ F(¬¬ (tr φ))
Formula.someFuture (tr φ)    =  U(⊤, tr φ)
```

and these are not merely differently associated, they are *different constructors* —
`tr_someFuture_ne` records this by proof. The reason is structural rather than incidental:
`Formula.someFuture` is a top-level `untl`, and by `tr_ne_untl` **no** formula in the range of
`tr` is a top-level `untl`. So no choice of L⁻-side abbreviation could have made this exact.

The consequence is that the research report's claim that TC discharges by an "exact syntactic
match" against `Axiom.connect_future`, and the analogous claim for TS, are **refuted**. Every
TM⁻ axiom mentioning `F` or `P` needs the derivable equivalence `¬G¬ψ ↔ Fψ` instead, supplied
once by `MinusLanguage/AxiomDischarge.lean`'s bridge lemmas. Axioms mentioning only `□`, `G`,
`H`, `→` and `⊥` (MK, MT, M5, MF, TK, T4, DN) *are* exact.

## References

* Research report §7 — the prototypes transcribed below
* `FormalSystem/MinusLanguage/AxiomDischarge.lean` — where the `F`/`P` bridge is discharged
-/

namespace FormalSystem.MinusLanguage

open FormalSystem.Syntax

/--
The translation of L⁻ into L: each primitive to the operator of the same name.

`allPast` and `allFuture` land on `Formula.allPast`/`Formula.allFuture`, which on the L side
are *derived* from `snce`/`untl` — that is exactly the point of the conservativity question.
-/
def tr : MinusFormula → Formula
  | .atom a => Formula.atom a
  | .bot => Formula.bot
  | .imp φ ψ => Formula.imp (tr φ) (tr ψ)
  | .box φ => Formula.box (tr φ)
  | .allPast φ => Formula.allPast (tr φ)
  | .allFuture φ => Formula.allFuture (tr φ)

/-! ### Push-through equations

Everything here is `rfl`: `tr` is structural and the L⁻-side abbreviations were chosen to
mirror the L ones. The `somePast`/`someFuture` entries are the deliberate exceptions, stated
in the shape `tr` actually produces rather than the shape one might expect. -/

@[simp] theorem tr_atom (a : Atom) : tr (.atom a) = Formula.atom a := rfl
@[simp] theorem tr_bot : tr .bot = Formula.bot := rfl
@[simp] theorem tr_imp (φ ψ : MinusFormula) : tr (φ.imp ψ) = (tr φ).imp (tr ψ) := rfl
@[simp] theorem tr_box (φ : MinusFormula) : tr φ.box = Formula.box (tr φ) := rfl
@[simp] theorem tr_allPast (φ : MinusFormula) : tr φ.allPast = Formula.allPast (tr φ) := rfl
@[simp] theorem tr_allFuture (φ : MinusFormula) : tr φ.allFuture = Formula.allFuture (tr φ) := rfl

@[simp] theorem tr_top : tr MinusFormula.top = Formula.top := rfl
@[simp] theorem tr_neg (φ : MinusFormula) : tr φ.neg = (tr φ).neg := rfl
@[simp] theorem tr_and (φ ψ : MinusFormula) : tr (φ.and ψ) = (tr φ).and (tr ψ) := rfl
@[simp] theorem tr_or (φ ψ : MinusFormula) : tr (φ.or ψ) = (tr φ).or (tr ψ) := rfl
@[simp] theorem tr_diamond (φ : MinusFormula) : tr φ.diamond = (tr φ).diamond := rfl

/-- `tr` commutes with the temporal `△`, because `MinusFormula.always` was given exactly
`Formula.always`'s association. Needed by the CO discharge. -/
@[simp] theorem tr_always (φ : MinusFormula) : tr φ.always = Formula.always (tr φ) := rfl

/-- `tr` of L⁻'s existential future, in the shape it actually takes. **Not**
`Formula.someFuture (tr φ)` — see `tr_someFuture_ne`. -/
theorem tr_someFuture (φ : MinusFormula) :
    tr φ.someFuture = (Formula.allFuture (tr φ).neg).neg := rfl

/-- `tr` of L⁻'s existential past, in the shape it actually takes. **Not**
`Formula.somePast (tr φ)` — see `tr_somePast_ne`. -/
theorem tr_somePast (φ : MinusFormula) :
    tr φ.somePast = (Formula.allPast (tr φ).neg).neg := rfl

/-! ### The range of `tr` -/

/-- `tr` never produces a top-level `untl`. -/
@[simp] theorem tr_ne_untl (φ : MinusFormula) (a b : Formula) : tr φ ≠ Formula.untl a b := by
  cases φ <;> simp [tr, Formula.allPast, Formula.allFuture, Formula.somePast,
    Formula.someFuture, Formula.neg, Formula.top]

/-- `tr` never produces a top-level `snce`. -/
@[simp] theorem tr_ne_snce (φ : MinusFormula) (a b : Formula) : tr φ ≠ Formula.snce a b := by
  cases φ <;> simp [tr, Formula.allPast, Formula.allFuture, Formula.somePast,
    Formula.someFuture, Formula.neg, Formula.top]

/-- The existential future does not push through `tr`. A corollary of `tr_ne_untl`:
`Formula.someFuture ψ` is a top-level `untl`, and nothing in the range of `tr` is. -/
theorem tr_someFuture_ne (φ : MinusFormula) :
    tr φ.someFuture ≠ Formula.someFuture (tr φ) :=
  tr_ne_untl φ.someFuture Formula.top (tr φ)

/-- The existential past does not push through `tr`; dual of `tr_someFuture_ne`. -/
theorem tr_somePast_ne (φ : MinusFormula) :
    tr φ.somePast ≠ Formula.somePast (tr φ) :=
  tr_ne_snce φ.somePast Formula.top (tr φ)

/-! ### The commutation lemma for TM⁻'s TD rule -/

/--
**The load-bearing lemma**: `tr` intertwines the L⁻-side past/future interchange `swapMinus` with
the L-side one `swapTemporal`.

TM⁻'s **TD** rule concludes `⊢ swapMinus φ` from `⊢ φ`; L's `DerivationTree.temporal_duality`
concludes `⊢ swapTemporal ψ` from `⊢ ψ`. Without this equation the TD case of
`FormalSystem.Metalogic.Conservativity.translate` does not typecheck at all.

The `allPast`/`allFuture` cases are the only real content: they need
`Formula.swap_temporal_all_past` / `Formula.swap_temporal_all_future`, since on the L side
`allPast`/`allFuture` are abbreviations over `snce`/`untl` and `swapTemporal` acts on the
primitives.
-/
theorem tr_swapMinus (φ : MinusFormula) : tr φ.swapMinus = (tr φ).swapTemporal := by
  induction φ with
  | atom _ => rfl
  | bot => rfl
  | imp _ _ ih1 ih2 => simp [tr, MinusFormula.swapMinus, Formula.swapTemporal, ih1, ih2]
  | box _ ih => simp [tr, MinusFormula.swapMinus, Formula.swapTemporal, ih]
  | allPast _ ih => simp [tr, MinusFormula.swapMinus, Formula.swap_temporal_all_past, ih]
  | allFuture _ ih => simp [tr, MinusFormula.swapMinus, Formula.swap_temporal_all_future, ih]

/-! ### Injectivity

Not required by the backward direction — it would be needed only if faithfulness were stated
as a biconditional — but cheap, and it certifies that the L⁻-side and L-side statements of a
theorem determine one another. -/

/-- `tr` is injective.

The four `imp`-versus-`allPast`/`allFuture` cases are *shape clashes* rather than constructor
clashes: on the L side `allPast`/`allFuture` are themselves top-level `imp`s (`neg` of a
`snce`/`untl`), so the mismatch has to be resolved one level down, by `tr_ne_snce`/`tr_ne_untl`
saying that nothing in the range of `tr` is a top-level `snce`/`untl`. -/
theorem tr_injective : Function.Injective tr := by
  intro φ
  induction φ with
  | atom a => intro ψ h; cases ψ <;> simp_all [tr, Formula.allPast, Formula.allFuture,
      Formula.somePast, Formula.someFuture, Formula.neg, Formula.top]
  | bot => intro ψ h; cases ψ <;> simp_all [tr, Formula.allPast, Formula.allFuture,
      Formula.somePast, Formula.someFuture, Formula.neg, Formula.top]
  | imp p q ih1 ih2 =>
      intro ψ h
      cases ψ with
      | imp p' q' =>
          simp only [tr_imp, Formula.imp.injEq] at h
          exact congrArg₂ MinusFormula.imp (ih1 h.1) (ih2 h.2)
      | allPast r =>
          simp only [tr_imp, tr_allPast, Formula.allPast, Formula.somePast, Formula.neg,
            Formula.top, Formula.imp.injEq] at h
          exact (tr_ne_snce p _ _ h.1).elim
      | allFuture r =>
          simp only [tr_imp, tr_allFuture, Formula.allFuture, Formula.someFuture, Formula.neg,
            Formula.top, Formula.imp.injEq] at h
          exact (tr_ne_untl p _ _ h.1).elim
      | atom a => exact absurd h (by simp [tr])
      | bot => exact absurd h (by simp [tr])
      | box r => exact absurd h (by simp [tr])
  | box p ih =>
      intro ψ h
      cases ψ with
      | box r => simp only [tr_box, Formula.box.injEq] at h; exact congrArg MinusFormula.box (ih h)
      | atom a => exact absurd h (by simp [tr])
      | bot => exact absurd h (by simp [tr])
      | imp a b => exact absurd h (by simp [tr])
      | allPast r => exact absurd h (by simp [tr, Formula.allPast, Formula.somePast,
          Formula.neg, Formula.top])
      | allFuture r => exact absurd h (by simp [tr, Formula.allFuture, Formula.someFuture,
          Formula.neg, Formula.top])
  | allPast p ih =>
      intro ψ h
      cases ψ with
      | allPast r =>
          simp only [tr_allPast, Formula.allPast, Formula.somePast, Formula.neg, Formula.top,
            Formula.imp.injEq, Formula.snce.injEq] at h
          exact congrArg MinusFormula.allPast (ih h.1.2.1)
      | imp a b =>
          simp only [tr_allPast, tr_imp, Formula.allPast, Formula.somePast, Formula.neg,
            Formula.top, Formula.imp.injEq] at h
          exact (tr_ne_snce a _ _ h.1.symm).elim
      | atom a => exact absurd h (by simp [tr, Formula.allPast, Formula.somePast,
          Formula.neg, Formula.top])
      | bot => exact absurd h (by simp [tr, Formula.allPast, Formula.somePast,
          Formula.neg, Formula.top])
      | box r => exact absurd h (by simp [tr, Formula.allPast, Formula.somePast,
          Formula.neg, Formula.top])
      | allFuture r => exact absurd h (by simp [tr, Formula.allPast, Formula.allFuture,
          Formula.somePast, Formula.someFuture, Formula.neg, Formula.top])
  | allFuture p ih =>
      intro ψ h
      cases ψ with
      | allFuture r =>
          simp only [tr_allFuture, Formula.allFuture, Formula.someFuture, Formula.neg,
            Formula.top, Formula.imp.injEq, Formula.untl.injEq] at h
          exact congrArg MinusFormula.allFuture (ih h.1.2.1)
      | imp a b =>
          simp only [tr_allFuture, tr_imp, Formula.allFuture, Formula.someFuture, Formula.neg,
            Formula.top, Formula.imp.injEq] at h
          exact (tr_ne_untl a _ _ h.1.symm).elim
      | atom a => exact absurd h (by simp [tr, Formula.allFuture, Formula.someFuture,
          Formula.neg, Formula.top])
      | bot => exact absurd h (by simp [tr, Formula.allFuture, Formula.someFuture,
          Formula.neg, Formula.top])
      | box r => exact absurd h (by simp [tr, Formula.allFuture, Formula.someFuture,
          Formula.neg, Formula.top])
      | allPast r => exact absurd h (by simp [tr, Formula.allPast, Formula.allFuture,
          Formula.somePast, Formula.someFuture, Formula.neg, Formula.top])

/-! ### Contexts -/

/-- The translation lifted to contexts. Definitionally `List.map tr`, so `List.mem_map` and
friends apply directly at the `assumption` case of the bridge. -/
abbrev trCtx (Γ : Context) : Syntax.Context := Γ.map tr

@[simp] theorem trCtx_nil : trCtx [] = [] := rfl

@[simp] theorem trCtx_cons (φ : MinusFormula) (Γ : Context) :
    trCtx (φ :: Γ) = tr φ :: trCtx Γ := rfl

/-- Membership transports through `tr`, which is the `assumption` case of the bridge. -/
theorem mem_trCtx {φ : MinusFormula} {Γ : Context} (h : φ ∈ Γ) : tr φ ∈ trCtx Γ :=
  List.mem_map_of_mem h

/-! ### Spot checks -/

example (a : Atom) : tr (MinusFormula.allFuture (MinusFormula.atom a))
    = Formula.allFuture (Formula.atom a) := rfl

example (a : Atom) : tr (MinusFormula.allPast (MinusFormula.atom a))
    = Formula.allPast (Formula.atom a) := rfl

end FormalSystem.MinusLanguage
