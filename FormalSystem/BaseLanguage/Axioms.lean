/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.BaseLanguage.Formula
import FormalSystem.ProofSystem.Axioms

/-!
# `BaseLanguage.Axiom` — TM's axiom schemata over the base language BL

TM, the *Logic of Tense and Modality*, is (JPL paper, `\S sub:Logic`) the smallest extension of
**CPL** over the base language BL closed under the schemata MK, MT, M5, MF, TK, T4, TB, TA, TL
and the rules MP, MN, TD. This module carries the **axiom** half of that list; MP, MN and TD are
*rules* and live in `BaseLanguage/Derivation.lean`.

The three extension axioms of `\S sub:Extension` are included in the same inductive, routed to
their frame classes by `Axiom.minFrameClass`:

| Key | Schema | Frame class | Paper system |
|---|---|---|---|
| DF | `(Hφ ∧ φ ∧ F⊤) → F(Hφ)` | `.Discrete` | `TM_f` |
| DN | `GGφ → Gφ` | `.Dense` | `TM_d` |
| CO | `△(Hφ → F Hφ) → (Hφ → Gφ)` | `.Dedekind` | `TM_c` (see the caveat below) |

## Reuse of `ProofSystem.FrameClass`

The frame class is the **existing** `FormalSystem.ProofSystem.FrameClass`, not a clone. That is
what makes the backward bridge one theorem with four instantiations rather than four parallel
developments. Only `FrameClass`, its order, and `FrameClass.base_le` are used from
`ProofSystem.Axioms`; no BL⁺ `Axiom` constructor is referenced here.

**CEC fidelity caveat.** This repository's `Dedekind` class satisfies `Dense ≤ Dedekind`, so a
`.Dedekind` derivation admits the dense axioms too. `Axiom.co ↦ .Dedekind` therefore lands the
CO row at the paper's **TM_dc**, not at TM_c; there is no repository frame class for "complete
but not dense". See `FormalSystem/Metalogic/Conservativity.lean`'s `cec_backward`.

## `Type` rather than `Prop`

`Axiom` is `Type`-valued, mirroring `FormalSystem.ProofSystem.Axiom`. This is forced twice over:
`Axiom.minFrameClass` is a function *into data*, and
`FormalSystem.Metalogic.Conservativity.translate` must pattern-match an `Axiom` derivation node
while producing a `DerivationTree` (itself a `Type`). A `Prop`-valued inductive supports neither.

## Polarity

`allPast` is the universal H and `allFuture` the universal G; `someFuture`/`somePast` are the
*derived* existentials F/P (`BLFormula.someFuture φ = ¬G¬φ`). See the polarity warning in
`BaseLanguage/Formula.lean`.

## References

* JPL paper `\S sub:Logic` — the TM axiomatization (MP/MN/MK/MT/M5/MF/TD/TK/T4/TB/TA/TL)
* JPL paper `\S sub:Extension` — DF, DN, CO
* `FormalSystem/ProofSystem/Axioms.lean` — the BL⁺ (Burgess-Xu) counterpart
-/

namespace FormalSystem.BaseLanguage

open FormalSystem.ProofSystem (FrameClass)

/--
TM's axiom schemata over the base language BL, plus the three extension axioms DF/DN/CO.

The propositional group (`prop_k`, `prop_s`, `ex_falso`, `peirce`) is transcribed
constructor-for-constructor from `FormalSystem.ProofSystem.Axiom`'s own propositional layer, so
that the discharge in `BaseLanguage/AxiomDischarge.lean` is a one-line match on each.

MP, MN and TD are **rules**, not axioms; they are constructors of
`BaseLanguage.DerivationTree`.
-/
inductive Axiom : BLFormula → Type where
  -- Propositional (CPL), matching `ProofSystem.Axiom`'s basis exactly
  /-- Propositional K: `(φ → (ψ → χ)) → ((φ → ψ) → (φ → χ))`. -/
  | prop_k (φ ψ χ : BLFormula) :
      Axiom ((φ.imp (ψ.imp χ)).imp ((φ.imp ψ).imp (φ.imp χ)))
  /-- Propositional S (weakening): `φ → (ψ → φ)`. -/
  | prop_s (φ ψ : BLFormula) : Axiom (φ.imp (ψ.imp φ))
  /-- Ex falso quodlibet: `⊥ → φ`. -/
  | ex_falso (φ : BLFormula) : Axiom (BLFormula.bot.imp φ)
  /-- Peirce's law: `((φ → ψ) → φ) → φ`. -/
  | peirce (φ ψ : BLFormula) : Axiom (((φ.imp ψ).imp φ).imp φ)
  -- Modal (S5 fragment of TM)
  /-- **MK**: `□(φ → ψ) → (□φ → □ψ)`. -/
  | modal_k (φ ψ : BLFormula) :
      Axiom ((φ.imp ψ).box.imp (φ.box.imp ψ.box))
  /-- **MT**: `□φ → φ`. -/
  | modal_t (φ : BLFormula) : Axiom (φ.box.imp φ)
  /-- **M5**: `◇□φ → □φ`. -/
  | modal_5 (φ : BLFormula) : Axiom (φ.box.diamond.imp φ.box)
  /-- **MF**: `□φ → □Gφ`. The modal-temporal interaction axiom. -/
  | modal_future (φ : BLFormula) : Axiom (φ.box.imp φ.allFuture.box)
  -- Temporal
  /-- **TK**: `G(φ → ψ) → (Gφ → Gψ)`. -/
  | temp_k (φ ψ : BLFormula) :
      Axiom ((φ.imp ψ).allFuture.imp (φ.allFuture.imp ψ.allFuture))
  /-- **T4**: `Gφ → GGφ`. -/
  | temp_4 (φ : BLFormula) : Axiom (φ.allFuture.imp φ.allFuture.allFuture)
  /-- **TB**: `F⊤`. Future seriality, stated as a bare theorem rather than an implication. -/
  | temp_serial : Axiom BLFormula.top.someFuture
  /-- **TA**: `φ → G P φ`. Temporal connectedness: the present is always in the past of the
      future. -/
  | temp_connect (φ : BLFormula) : Axiom (φ.imp φ.somePast.allFuture)
  /-- **TL**: `(Fφ ∧ Fψ) → [F(Fφ ∧ ψ) ∨ F(φ ∧ ψ) ∨ F(φ ∧ Fψ)]`.

      The disjunct order and right-association here are the **paper's**, transcribed verbatim.
      This repository's `ProofSystem.Axiom.temp_linearity` carries the same three disjuncts in a
      different order and association; the reshuffle happens once, in
      `BaseLanguage/AxiomDischarge.lean`, and is deliberately not pre-applied here. -/
  | temp_linearity (φ ψ : BLFormula) :
      Axiom ((φ.someFuture.and ψ.someFuture).imp
        (((φ.someFuture.and ψ).someFuture).or
          (((φ.and ψ).someFuture).or ((φ.and ψ.someFuture).someFuture))))
  -- Extension axioms (`\S sub:Extension`)
  /-- **DF** (`TM_f`, discrete): `(Hφ ∧ φ ∧ F⊤) → F(Hφ)`.

      Association `((Hφ ∧ φ) ∧ F⊤)` is pinned to match
      `FormalSystem.Theorems.DiscreteUnfolding.dfSchema`, which discharges its translation. -/
  | df (φ : BLFormula) :
      Axiom (((φ.allPast.and φ).and BLFormula.top.someFuture).imp φ.allPast.someFuture)
  /-- **DN** (`TM_d`, dense): `GGφ → Gφ`. -/
  | dn (φ : BLFormula) : Axiom (φ.allFuture.allFuture.imp φ.allFuture)
  /-- **CO** (`TM_c`, complete order): `△(Hφ → F Hφ) → (Hφ → Gφ)`.

      `△` is `BLFormula.always` (`Hχ ∧ (χ ∧ Gχ)`), the *temporal* triangle, not the modal box —
      the same operator-resolution trap flagged on `Formula.co`. The association mirrors
      `Formula.always` so that the translation is `Formula.co` up to the `F`-bridge alone. -/
  | co (φ : BLFormula) :
      Axiom ((φ.allPast.imp φ.allPast.someFuture).always.imp
        (φ.allPast.imp φ.allFuture))
  deriving Repr

/--
Minimum frame class for each BL axiom constructor.

Only the three extension axioms are non-`Base`; every TM axiom proper falls through the
catch-all, exactly as in `ProofSystem.Axiom.minFrameClass`. The invariant
`ax.minFrameClass ≤ fc` in `BaseLanguage.DerivationTree`'s `axiom` constructor is what makes
`TM`, `TM_f`, `TM_d` and `TM_dc` the four instantiations `fc := .Base`, `.Discrete`, `.Dense`,
`.Dedekind` of a single derivation type.
-/
def Axiom.minFrameClass {φ : BLFormula} : Axiom φ → FrameClass
  | df _ => .Discrete
  | dn _ => .Dense
  | co _ => .Dedekind
  | _ => .Base

/-! ### Frame-class regression checks

These pin the three non-`Base` assignments and one `Base` representative, so that a future edit
to the catch-all cannot silently move an extension axiom into the base system. -/

example (φ : BLFormula) : (Axiom.df φ).minFrameClass = FrameClass.Discrete := rfl
example (φ : BLFormula) : (Axiom.dn φ).minFrameClass = FrameClass.Dense := rfl
example (φ : BLFormula) : (Axiom.co φ).minFrameClass = FrameClass.Dedekind := rfl
example (φ : BLFormula) : (Axiom.modal_future φ).minFrameClass = FrameClass.Base := rfl

-- The `≤` side conditions the `axiom` rule demands. `decide` cannot act on a goal carrying the
-- free `φ`, so each is routed through `show` at the already-reduced frame class first — the
-- same shape `BaseLanguage/AxiomDischarge.lean` uses at every discharge site.
example (φ : BLFormula) : (Axiom.df φ).minFrameClass ≤ FrameClass.Discrete :=
  show FrameClass.Discrete ≤ FrameClass.Discrete by decide
example (φ : BLFormula) : ¬ ((Axiom.df φ).minFrameClass ≤ FrameClass.Base) :=
  show ¬ (FrameClass.Discrete ≤ FrameClass.Base) by decide
example (φ : BLFormula) : (Axiom.dn φ).minFrameClass ≤ FrameClass.Dedekind :=
  show FrameClass.Dense ≤ FrameClass.Dedekind by decide
example (φ : BLFormula) : (Axiom.co φ).minFrameClass ≤ FrameClass.Dedekind :=
  show FrameClass.Dedekind ≤ FrameClass.Dedekind by decide

end FormalSystem.BaseLanguage
