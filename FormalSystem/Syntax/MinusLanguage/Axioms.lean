/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Syntax.MinusLanguage.Formula
import FormalSystem.ProofSystem.Axioms

/-!
# `MinusLanguage.Axiom` — TM⁻'s axiom schemata over the base language L⁻

TM⁻, the *Logic of Tense and Modality*, is (JPL paper, `\S sub:Logic`) the smallest extension of
**CPL** over the base language L⁻ closed under the schemata MK, MT, M5, MF, TK, T4, TS, TC, TL
and the rules MP, MN, TD. This module carries the **axiom** half of that list; MP, MN and TD are
*rules* and live in `MinusLanguage/Derivation.lean`.

The three extension axioms of `\S sub:Extension` are included in the same inductive, routed to
their frame classes by `Axiom.minFrameClass`:

| Key | Schema | Frame class | System |
|---|---|---|---|
| DF | `(Hφ ∧ φ ∧ F⊤) → F(Hφ)` | `.ZTime` | `TM⁻_z` |
| DN | `GGφ → Gφ` | `.Dense` | `TM⁻_d` |
| CO | `△(Hφ → F Hφ) → (Hφ → Gφ)` | `.RTime` | `TM⁻_r` |

**These four system names are Lean-only and have no paper counterpart.** The paper names no
Past/Future system, so `TM⁻`, `TM⁻_z`, `TM⁻_d` and `TM⁻_r` on this side of the tree name nothing in
it; the `z`/`d`/`r` subscripts were chosen to run parallel to the `TM` side and to the frame-class
tags. `FormalSystem/Metalogic/Conservativity.lean`'s module docstring states the mapping between
the two families of name in full, and is the place to read it.

## Paper Name Correspondence

Every live `\aitem` key in the JPL paper (`possible_worlds.tex`), mapped to its paper section and
its Lean identifier where one exists. This table is the single maintained source of truth for the
paper-to-Lean name mapping; a future paper rename should be a mechanical sweep through this table
plus the doc-comments it cites, not a re-derivation from scratch. Names below are current as of
the paper's `TP`/`CT` → `TP1`/`TP2`, `P9`/`P10` → `P7`/`P8`, `TB`/`TA` → `TS`/`TC`, and
`SP` → `SEP` rename round; see `possible_worlds.tex` for the historical names these replaced.

**Introduction (`\S sec:Introduction`) — motivating, invalid principles:**

| Paper key | Lean identifier | Notes |
|---|---|---|
| `SP1` | none | Invalid-under-2D-semantics principle; not formalized (the Lean tree formalizes `TM⁻`, not the 2D-semantics counterexample). |
| `SP2` | none | As above. |

**Necessarily Always (`\S sub:NecessarilyAlways`):**

| Paper key | Lean identifier | Notes |
|---|---|---|
| `TP1` | none | Trivial (Montagovian) perpetuity principle; no Lean counterpart. |
| `TP2` | none | As above. |

**Bimodal Logic (`\S sub:Logic`) — S5 modal group:**

| Paper key | Lean identifier | Notes |
|---|---|---|
| `MK` | `Axiom.modal_k` | |
| `MT` | `Axiom.modal_t` | |
| `M5` | `Axiom.modal_5` | |
| `MP` | `MinusLanguage.DerivationTree.modus_ponens` | Rule, in `MinusLanguage/Derivation.lean`. |
| `MN` | `MinusLanguage.DerivationTree.necessitation` | Rule, in `MinusLanguage/Derivation.lean`. |

**Bimodal Logic (`\S sub:Logic`) — BX temporal group** (`BX` = Burgess–Xu tense system,
`def:BX` in the paper):

| Paper key | Lean identifier | Notes |
|---|---|---|
| `TN` | `MinusLanguage.DerivationTree.temporal_necessitation` | Rule; content matches, paper key not quoted verbatim in the doc-comment. |
| `TD` | `MinusLanguage.DerivationTree.temporal_duality` | Rule. |
| `TS` | `Axiom.temp_serial` | |
| `TC` | `Axiom.temp_connect` | |
| `TL` | `Axiom.temp_linearity` | Disjunct order/association is the paper's, transcribed verbatim (see the doc-comment above). |
| `UE`, `UT`, `NP`, `NF`, `UI`, `UC`, `UF`, `UG`, `SU`, `NA`, `NB`, `CN` | none (under these names) | The Lean `BX` layer (`ProofSystem/Axioms.lean`'s 45-constructor until/since system: `serial_future`, `left_mono_until_G`, `enrichment_until`, ...) is a structurally finer, differently-named axiomatization of the same fragment. A constructor-by-constructor naming audit remains open — see `specs/archive/514_align_definitions_with_source_paper/reports/01_definitional-review-and-closure.md` §1.2 in this repository. |

**Bimodal Logic (`\S sub:Logic`) — interaction and derived perpetuity principles:**

| Paper key | Lean identifier | Notes |
|---|---|---|
| `MF` | `Axiom.modal_future` | |
| `P1` | `FormalSystem.Theorems.Perpetuity.perpetuity1` | |
| `P2` | `FormalSystem.Theorems.Perpetuity.perpetuity2` | |
| `TF` | `FormalSystem.Theorems.Combinators.temporalFutureDerived` | Derived, not primitive — matches the paper, where `TF` is likewise a derived theorem. |
| `P3` | `FormalSystem.Theorems.Perpetuity.perpetuity3` | |
| `P4` | `FormalSystem.Theorems.Perpetuity.perpetuity4` | |
| `TK` | `Axiom.temp_k` | |
| `T4` | `Axiom.temp_4` | |
| `P5` | `FormalSystem.Theorems.Perpetuity.perpetuity5` | |
| `P6` | `FormalSystem.Theorems.Perpetuity.perpetuity6` | |

**Extensions (`\S sub:Extension`):**

| Paper key | Lean identifier | Notes |
|---|---|---|
| `DF` | `Axiom.df` | |
| `DN` | `Axiom.dn` / `ProofSystem.Axiom.density` | |
| `CO` | `Axiom.co` | See the CEC fidelity caveat below. |
| `UZ` | `ProofSystem.Axiom.prior_UZ` | Doc-comment still says "Prior-UZ" (the paper's pre-rename display name); documentation lag, not a Lean defect. |
| `Z1` | `ProofSystem.Axiom.z1` | |
| `NN` | `ProofSystem.Axiom.dense_indicator` | |
| `PU` | `ProofSystem.Axiom.prior_U_gap` | Doc-comment still says "Prior-U" (pre-rename display name); documentation lag. |
| `SEP` | `ProofSystem.Axiom.sep` | Doc-comments across the Metalogic tree still say "Sep" (Reynolds' own historical name, distinct from the paper's two-letter key convention); out of scope to reconcile here. |

**Appendix: Objective Modality (`\S app:ObjectiveModality`):**

| Paper key | Lean identifier | Notes |
|---|---|---|
| `Ref`, `Imp`, `LL`, `I1`–`I7`, `Fac`, `Ax`, `Ord`, `O-Ax`, `O-Nec`, `O-Tran`, `O-Comp`, `O-Conv`, `O-Meet`, `O-Rev`, `O-Cons` | none | No Lean counterpart at all (exhaustive grep, zero hits) — this appendix is not formalized. |

**Appendix: Soundness and Completeness (`\S sub:Soundness...`):**

| Paper key | Lean identifier | Notes |
|---|---|---|
| `P7`, `P8` | none | No Lean counterpart yet. |

## Reuse of `ProofSystem.FrameClass`

The frame class is the **existing** `FormalSystem.ProofSystem.FrameClass`, not a clone. That is
what makes the backward bridge one theorem with four instantiations rather than four parallel
developments. Only `FrameClass`, its order, and `FrameClass.base_le` are used from
`ProofSystem.Axioms`; no L `Axiom` constructor is referenced here.

**Where the CO row lands.** This repository's `RTime` class satisfies `Dense ≤ RTime`, so a
`.RTime` derivation admits the dense axioms too, and `Axiom.co ↦ .RTime` lands the CO row at
`TM⁻_r`. There is no repository frame class for "complete but not dense", and none is wanted: the
`ℝ`-time row is the dense-and-complete one on both sides of the bridge. See
`FormalSystem/Metalogic/Conservativity/Backward.lean`'s `cec_backward`.

## `Type` rather than `Prop`

`Axiom` is `Type`-valued, mirroring `FormalSystem.ProofSystem.Axiom`. This is forced twice over:
`Axiom.minFrameClass` is a function *into data*, and
`FormalSystem.Metalogic.Conservativity.translate` must pattern-match an `Axiom` derivation node
while producing a `DerivationTree` (itself a `Type`). A `Prop`-valued inductive supports neither.

## Polarity

`allPast` is the universal H and `allFuture` the universal G; `someFuture`/`somePast` are the
*derived* existentials F/P (`MinusFormula.someFuture φ = ¬G¬φ`). See the polarity warning in
`MinusLanguage/Formula.lean`.

## References

* JPL paper `\S sub:Logic` — the TM axiomatization (MP/MN/MK/MT/M5/MF/TD/TK/T4/TS/TC/TL) that TM⁻ transposes
* JPL paper `\S sub:Extension` — DF, DN, CO
* `FormalSystem/ProofSystem/Axioms.lean` — the L (Burgess-Xu) counterpart
-/

namespace FormalSystem.MinusLanguage

open FormalSystem.ProofSystem (FrameClass)

/--
TM⁻'s axiom schemata over the base language L⁻, plus the three extension axioms DF/DN/CO.

The propositional group (`prop_k`, `prop_s`, `ex_falso`, `peirce`) is transcribed
constructor-for-constructor from `FormalSystem.ProofSystem.Axiom`'s own propositional layer, so
that the discharge in `MinusLanguage/AxiomDischarge.lean` is a one-line match on each.

MP, MN and TD are **rules**, not axioms; they are constructors of
`MinusLanguage.DerivationTree`.
-/
inductive Axiom : MinusFormula → Type where
  -- Propositional (CPL), matching `ProofSystem.Axiom`'s basis exactly
  /-- Propositional K: `(φ → (ψ → χ)) → ((φ → ψ) → (φ → χ))`. -/
  | prop_k (φ ψ χ : MinusFormula) :
      Axiom ((φ.imp (ψ.imp χ)).imp ((φ.imp ψ).imp (φ.imp χ)))
  /-- Propositional S (weakening): `φ → (ψ → φ)`. -/
  | prop_s (φ ψ : MinusFormula) : Axiom (φ.imp (ψ.imp φ))
  /-- Ex falso quodlibet: `⊥ → φ`. -/
  | ex_falso (φ : MinusFormula) : Axiom (MinusFormula.bot.imp φ)
  /-- Peirce's law: `((φ → ψ) → φ) → φ`. -/
  | peirce (φ ψ : MinusFormula) : Axiom (((φ.imp ψ).imp φ).imp φ)
  -- Modal (S5 fragment of TM⁻)
  /-- **MK**: `□(φ → ψ) → (□φ → □ψ)`. -/
  | modal_k (φ ψ : MinusFormula) :
      Axiom ((φ.imp ψ).box.imp (φ.box.imp ψ.box))
  /-- **MT**: `□φ → φ`. -/
  | modal_t (φ : MinusFormula) : Axiom (φ.box.imp φ)
  /-- **M5**: `◇□φ → □φ`. -/
  | modal_5 (φ : MinusFormula) : Axiom (φ.box.diamond.imp φ.box)
  /-- **MF**: `□φ → □Gφ`. The modal-temporal interaction axiom. -/
  | modal_future (φ : MinusFormula) : Axiom (φ.box.imp φ.allFuture.box)
  -- Temporal
  /-- **TK**: `G(φ → ψ) → (Gφ → Gψ)`. -/
  | temp_k (φ ψ : MinusFormula) :
      Axiom ((φ.imp ψ).allFuture.imp (φ.allFuture.imp ψ.allFuture))
  /-- **T4**: `Gφ → GGφ`. -/
  | temp_4 (φ : MinusFormula) : Axiom (φ.allFuture.imp φ.allFuture.allFuture)
  /-- **TS**: `F⊤`. Future seriality, stated as a bare theorem rather than an implication. -/
  | temp_serial : Axiom MinusFormula.top.someFuture
  /-- **TC**: `φ → G P φ`. Temporal connectedness: the present is always in the past of the
      future. -/
  | temp_connect (φ : MinusFormula) : Axiom (φ.imp φ.somePast.allFuture)
  /-- **TL**: `(Fφ ∧ Fψ) → [F(Fφ ∧ ψ) ∨ F(φ ∧ ψ) ∨ F(φ ∧ Fψ)]`.

      The disjunct order and right-association here are the **paper's**, transcribed verbatim.
      This repository's `ProofSystem.Axiom.temp_linearity` carries the same three disjuncts in a
      different order and association; the reshuffle happens once, in
      `MinusLanguage/AxiomDischarge.lean`, and is deliberately not pre-applied here. -/
  | temp_linearity (φ ψ : MinusFormula) :
      Axiom ((φ.someFuture.and ψ.someFuture).imp
        (((φ.someFuture.and ψ).someFuture).or
          (((φ.and ψ).someFuture).or ((φ.and ψ.someFuture).someFuture))))
  -- Extension axioms (`\S sub:Extension`)
  /-- **DF** (`TM⁻_z`, discrete): `(Hφ ∧ φ ∧ F⊤) → F(Hφ)`.

      Association `((Hφ ∧ φ) ∧ F⊤)` is pinned to match
      `FormalSystem.Theorems.DiscreteUnfolding.dfSchema`, which discharges its translation. -/
  | df (φ : MinusFormula) :
      Axiom (((φ.allPast.and φ).and MinusFormula.top.someFuture).imp φ.allPast.someFuture)
  /-- **DN** (`TM⁻_d`, dense): `GGφ → Gφ`. -/
  | dn (φ : MinusFormula) : Axiom (φ.allFuture.allFuture.imp φ.allFuture)
  /-- **CO** (`TM⁻_r`, complete order): `△(Hφ → F Hφ) → (Hφ → Gφ)`.

      `△` is `MinusFormula.always` (`Hχ ∧ (χ ∧ Gχ)`), the *temporal* triangle, not the modal box —
      the same operator-resolution trap flagged on `Formula.co`. The association mirrors
      `Formula.always` so that the translation is `Formula.co` up to the `F`-bridge alone. -/
  | co (φ : MinusFormula) :
      Axiom ((φ.allPast.imp φ.allPast.someFuture).always.imp
        (φ.allPast.imp φ.allFuture))
  deriving Repr

/--
Minimum frame class for each L⁻ axiom constructor.

Only the three extension axioms are non-`Base`; every TM⁻ axiom proper falls through the
catch-all, exactly as in `ProofSystem.Axiom.minFrameClass`. The invariant
`ax.minFrameClass ≤ fc` in `MinusLanguage.DerivationTree`'s `axiom` constructor is what makes
`TM⁻`, `TM⁻_z`, `TM⁻_d` and `TM⁻_r` the four instantiations `fc := .Base`, `.ZTime`, `.Dense`,
`.RTime` of a single derivation type.
-/
def Axiom.minFrameClass {φ : MinusFormula} : Axiom φ → FrameClass
  | df _ => .ZTime
  | dn _ => .Dense
  | co _ => .RTime
  | _ => .Base

/-! ### Frame-class regression checks

These pin the three non-`Base` assignments and one `Base` representative, so that a future edit
to the catch-all cannot silently move an extension axiom into the base system. -/

example (φ : MinusFormula) : (Axiom.df φ).minFrameClass = FrameClass.ZTime := rfl
example (φ : MinusFormula) : (Axiom.dn φ).minFrameClass = FrameClass.Dense := rfl
example (φ : MinusFormula) : (Axiom.co φ).minFrameClass = FrameClass.RTime := rfl
example (φ : MinusFormula) : (Axiom.modal_future φ).minFrameClass = FrameClass.Base := rfl

-- The `≤` side conditions the `axiom` rule demands. `decide` cannot act on a goal carrying the
-- free `φ`, so each is routed through `show` at the already-reduced frame class first — the
-- same shape `MinusLanguage/AxiomDischarge.lean` uses at every discharge site.
example (φ : MinusFormula) : (Axiom.df φ).minFrameClass ≤ FrameClass.ZTime :=
  show FrameClass.ZTime ≤ FrameClass.ZTime by decide
example (φ : MinusFormula) : ¬ ((Axiom.df φ).minFrameClass ≤ FrameClass.Base) :=
  show ¬ (FrameClass.ZTime ≤ FrameClass.Base) by decide
example (φ : MinusFormula) : (Axiom.dn φ).minFrameClass ≤ FrameClass.RTime :=
  show FrameClass.Dense ≤ FrameClass.RTime by decide
example (φ : MinusFormula) : (Axiom.co φ).minFrameClass ≤ FrameClass.RTime :=
  show FrameClass.RTime ≤ FrameClass.RTime by decide

end FormalSystem.MinusLanguage
