/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.BaseLanguage.Formula
import FormalSystem.Syntax.Formula
import FormalSystem.Syntax.Context

/-!
# `tr` — the translation of BL into BL⁺

`tr : BLFormula → Formula` maps the tense-primitive base language into this repository's
until/since-primitive `Formula`, sending each BL primitive to the BL⁺ operator of the same
name. For `allPast`/`allFuture` the target is BL⁺'s *derived* `Formula.allPast`/
`Formula.allFuture` — that substitution is the whole content of the translation.

## Main Definitions

- `tr : BLFormula → Formula`
- `trCtx : BaseLanguage.Context → Syntax.Context` (`List.map tr`)

## Main Results

- `tr_swapBL` : `tr (swapBL φ) = swapTemporal (tr φ)` — **the load-bearing lemma**, without
  which the TD case of `FormalSystem.Metalogic.Conservativity.translate` does not typecheck
- `tr_ne_untl`, `tr_ne_snce` : `tr` never produces a top-level `untl`/`snce`
- `tr_injective` : `tr` is injective
- push-through equations for the derived Boolean and modal operators

## The existential operators do NOT push through — a measured fact, not an oversight

`tr` commutes definitionally with `neg`, `and`, `or`, `iff`, `diamond` and `always`. It does
**not** commute with `somePast`/`someFuture`:

```
tr (BLFormula.someFuture φ)  =  ¬ (Formula.allFuture (tr φ).neg)  =  ¬¬ F(¬¬ (tr φ))
Formula.someFuture (tr φ)    =  U(⊤, tr φ)
```

and these are not merely differently associated, they are *different constructors* —
`tr_someFuture_ne` records this by proof. The reason is structural rather than incidental:
`Formula.someFuture` is a top-level `untl`, and by `tr_ne_untl` **no** formula in the range of
`tr` is a top-level `untl`. So no choice of BL-side abbreviation could have made this exact.

The consequence is that the research report's claim that TA discharges by an "exact syntactic
match" against `Axiom.connect_future`, and the analogous claim for TB, are **refuted**. Every
TM axiom mentioning `F` or `P` needs the derivable equivalence `¬G¬ψ ↔ Fψ` instead, supplied
once by `BaseLanguage/AxiomDischarge.lean`'s bridge lemmas. Axioms mentioning only `□`, `G`,
`H`, `→` and `⊥` (MK, MT, M5, MF, TK, T4, DN) *are* exact.

## References

* Research report §7 — the prototypes transcribed below
* `FormalSystem/BaseLanguage/AxiomDischarge.lean` — where the `F`/`P` bridge is discharged
-/

namespace FormalSystem.BaseLanguage

open FormalSystem.Syntax

/--
The translation of BL into BL⁺: each primitive to the operator of the same name.

`allPast` and `allFuture` land on `Formula.allPast`/`Formula.allFuture`, which on the BL⁺ side
are *derived* from `snce`/`untl` — that is exactly the point of the conservativity question.
-/
def tr : BLFormula → Formula
  | .atom a => Formula.atom a
  | .bot => Formula.bot
  | .imp φ ψ => Formula.imp (tr φ) (tr ψ)
  | .box φ => Formula.box (tr φ)
  | .allPast φ => Formula.allPast (tr φ)
  | .allFuture φ => Formula.allFuture (tr φ)

/-! ### Push-through equations

Everything here is `rfl`: `tr` is structural and the BL-side abbreviations were chosen to
mirror the BL⁺ ones. The `somePast`/`someFuture` entries are the deliberate exceptions, stated
in the shape `tr` actually produces rather than the shape one might expect. -/

@[simp] theorem tr_atom (a : Atom) : tr (.atom a) = Formula.atom a := rfl
@[simp] theorem tr_bot : tr .bot = Formula.bot := rfl
@[simp] theorem tr_imp (φ ψ : BLFormula) : tr (φ.imp ψ) = (tr φ).imp (tr ψ) := rfl
@[simp] theorem tr_box (φ : BLFormula) : tr φ.box = Formula.box (tr φ) := rfl
@[simp] theorem tr_allPast (φ : BLFormula) : tr φ.allPast = Formula.allPast (tr φ) := rfl
@[simp] theorem tr_allFuture (φ : BLFormula) : tr φ.allFuture = Formula.allFuture (tr φ) := rfl

@[simp] theorem tr_top : tr BLFormula.top = Formula.top := rfl
@[simp] theorem tr_neg (φ : BLFormula) : tr φ.neg = (tr φ).neg := rfl
@[simp] theorem tr_and (φ ψ : BLFormula) : tr (φ.and ψ) = (tr φ).and (tr ψ) := rfl
@[simp] theorem tr_or (φ ψ : BLFormula) : tr (φ.or ψ) = (tr φ).or (tr ψ) := rfl
@[simp] theorem tr_diamond (φ : BLFormula) : tr φ.diamond = (tr φ).diamond := rfl

/-- `tr` commutes with the temporal `△`, because `BLFormula.always` was given exactly
`Formula.always`'s association. Needed by the CO discharge. -/
@[simp] theorem tr_always (φ : BLFormula) : tr φ.always = Formula.always (tr φ) := rfl

/-- `tr` of BL's existential future, in the shape it actually takes. **Not**
`Formula.someFuture (tr φ)` — see `tr_someFuture_ne`. -/
theorem tr_someFuture (φ : BLFormula) :
    tr φ.someFuture = (Formula.allFuture (tr φ).neg).neg := rfl

/-- `tr` of BL's existential past, in the shape it actually takes. **Not**
`Formula.somePast (tr φ)` — see `tr_somePast_ne`. -/
theorem tr_somePast (φ : BLFormula) :
    tr φ.somePast = (Formula.allPast (tr φ).neg).neg := rfl

/-! ### The range of `tr` -/

/-- `tr` never produces a top-level `untl`. -/
@[simp] theorem tr_ne_untl (φ : BLFormula) (a b : Formula) : tr φ ≠ Formula.untl a b := by
  cases φ <;> simp [tr, Formula.allPast, Formula.allFuture, Formula.somePast,
    Formula.someFuture, Formula.neg, Formula.top]

/-- `tr` never produces a top-level `snce`. -/
@[simp] theorem tr_ne_snce (φ : BLFormula) (a b : Formula) : tr φ ≠ Formula.snce a b := by
  cases φ <;> simp [tr, Formula.allPast, Formula.allFuture, Formula.somePast,
    Formula.someFuture, Formula.neg, Formula.top]

/-- The existential future does not push through `tr`. A corollary of `tr_ne_untl`:
`Formula.someFuture ψ` is a top-level `untl`, and nothing in the range of `tr` is. -/
theorem tr_someFuture_ne (φ : BLFormula) :
    tr φ.someFuture ≠ Formula.someFuture (tr φ) :=
  tr_ne_untl φ.someFuture Formula.top (tr φ)

/-- The existential past does not push through `tr`; dual of `tr_someFuture_ne`. -/
theorem tr_somePast_ne (φ : BLFormula) :
    tr φ.somePast ≠ Formula.somePast (tr φ) :=
  tr_ne_snce φ.somePast Formula.top (tr φ)

/-! ### The commutation lemma for TM's TD rule -/

/--
**The load-bearing lemma**: `tr` intertwines the BL-side past/future interchange `swapBL` with
the BL⁺-side one `swapTemporal`.

TM's **TD** rule concludes `⊢ swapBL φ` from `⊢ φ`; BL⁺'s `DerivationTree.temporal_duality`
concludes `⊢ swapTemporal ψ` from `⊢ ψ`. Without this equation the TD case of
`FormalSystem.Metalogic.Conservativity.translate` does not typecheck at all.

The `allPast`/`allFuture` cases are the only real content: they need
`Formula.swap_temporal_all_past` / `Formula.swap_temporal_all_future`, since on the BL⁺ side
`allPast`/`allFuture` are abbreviations over `snce`/`untl` and `swapTemporal` acts on the
primitives.
-/
theorem tr_swapBL (φ : BLFormula) : tr φ.swapBL = (tr φ).swapTemporal := by
  induction φ with
  | atom _ => rfl
  | bot => rfl
  | imp _ _ ih1 ih2 => simp [tr, BLFormula.swapBL, Formula.swapTemporal, ih1, ih2]
  | box _ ih => simp [tr, BLFormula.swapBL, Formula.swapTemporal, ih]
  | allPast _ ih => simp [tr, BLFormula.swapBL, Formula.swap_temporal_all_past, ih]
  | allFuture _ ih => simp [tr, BLFormula.swapBL, Formula.swap_temporal_all_future, ih]

/-! ### Injectivity

Not required by the backward direction — it would be needed only if faithfulness were stated
as a biconditional — but cheap, and it certifies that the BL-side and BL⁺-side statements of a
theorem determine one another. -/

/-- `tr` is injective.

The four `imp`-versus-`allPast`/`allFuture` cases are *shape clashes* rather than constructor
clashes: on the BL⁺ side `allPast`/`allFuture` are themselves top-level `imp`s (`neg` of a
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
          exact congrArg₂ BLFormula.imp (ih1 h.1) (ih2 h.2)
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
      | box r => simp only [tr_box, Formula.box.injEq] at h; exact congrArg BLFormula.box (ih h)
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
          exact congrArg BLFormula.allPast (ih h.1.2.1)
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
          exact congrArg BLFormula.allFuture (ih h.1.2.1)
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

@[simp] theorem trCtx_cons (φ : BLFormula) (Γ : Context) :
    trCtx (φ :: Γ) = tr φ :: trCtx Γ := rfl

/-- Membership transports through `tr`, which is the `assumption` case of the bridge. -/
theorem mem_trCtx {φ : BLFormula} {Γ : Context} (h : φ ∈ Γ) : tr φ ∈ trCtx Γ :=
  List.mem_map_of_mem h

/-! ### Spot checks -/

example (a : Atom) : tr (BLFormula.allFuture (BLFormula.atom a))
    = Formula.allFuture (Formula.atom a) := rfl

example (a : Atom) : tr (BLFormula.allPast (BLFormula.atom a))
    = Formula.allPast (Formula.atom a) := rfl

end FormalSystem.BaseLanguage
