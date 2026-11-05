/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.OpenLanguage.Formula
import FormalSystem.ProofSystem.Axioms

/-!
# `OpenAxiom` — the axiom schemata of the L^▷ proof system

The axiom system for the language L^▷ (`OpenLanguage/Formula.lean`): the TM⁺ schemata
(`PlusLanguage/Axioms.lean`) **re-declared with `OpenFormula` parameters**, plus a restricted-modal
block for the open-future modal `▷` and the open-past modal `◁`. This file is syntax only; the
validity of each schema is discharged in `Metalogic/Conservativity/Open/OpenAxiomValidity.lean`
against the landed semantics of `OpenLanguage/OpenTruth.lean` and `OpenLanguage/OpenValidity.lean`.

## No completeness is claimed

**This module, and the proof system it heads, make no completeness claim for L^▷ at any frame
class, in any form.** The system is sound and conservative over TM⁺ in both directions; that is
all. The canonical-bundle obstruction that blocks completeness for L⁺ is untouched here —
`FormalSystem/Metalogic/Independence/` keeps `plus_incomplete_base` exactly as proved, the
Burgess-style limit-closure principle stays a non-theorem, and an LC_n-style schema is still
required in L^▷ exactly as it is in L⁺. Nothing in this file is evidence to the contrary.

## The class split: where the restricted modals are new

The open-future modal is **L⁺-definable over integer and real time** and **not definable** over
the base and dense classes; the two halves are landed in
`FormalSystem/Metalogic/Expressiveness/OpenFutureElimination.lean` and its non-definability
companion. `OpenValid` quantifies over the base class, so the restricted-modal block below is a
genuine extension of TM⁺ where it is stated, and a notational variant of it over integer and real
time. Every docstring in this component that mentions novelty states that split rather than
claiming novelty outright.

## Why the TM⁺ schemata are re-declared rather than embedded

An embedding constructor `ofPlus : PlusAxiom φ → OpenAxiom (ofPlus φ)` would yield only the
`▷`/`◁`-free instances of each schema, and the system needs, for instance, `□▷p → □G▷p` — MF at
`▷p`. So every schema must range over all of `OpenFormula`. The re-declaration is mechanical:
constructor for constructor, the same name, the same parameter list, the same statement through the
derived operators of `OpenLanguage/Formula.lean`, whose right-hand sides are `PlusFormula`'s
verbatim. `OpenAxiom.ofPlus` (`OpenLanguage/OpenDerivation.lean`) sends each `PlusAxiom` instance
to the re-declared twin at the embedded parameters; every one of its arms is `rfl`-shaped, so drift
between the two inductives fails to typecheck there.

## Extension recipe: adding an `OpenAxiom` constructor

`OpenAxiom` is a **closed** inductive, and a new constructor owes **five** surfaces, one more than
`FormalSystem/PlusLanguage/README.md`'s recipe states for `PlusAxiom`:

1. the constructor line, here;
2. one `OpenAxiom.minFrameClass` arm, here — the dispatch has no wildcard, so a missing arm is a
   build error;
3. one arm in `openAxiom_validIn_min` (`Metalogic/Conservativity/Open/OpenAxiomValidity.lean`);
4. one arm in `openAxiom_reflect_time_validIn_min` (same file);
5. one arm in `dischargeAxiom` (`OpenLanguage/OpenErasure.lean`).

The fifth is the reason the count differs, and it is the one that can be **impossible** rather than
merely laborious: the discharge arm must produce a TM⁺ derivation of the schema's `eraseOpen`
image, and a schema whose erasure is not TM⁺-derivable cannot be admitted without forfeiting
forward conservativity. That is exactly what excludes the backward definability half; see the
constructor-block note below.

## Frame classes

`OpenAxiom.minFrameClass` routes the re-declared TM⁺ schemata exactly as `PlusAxiom.minFrameClass`
routes their originals, and every restricted-modal schema below is valid over every task frame and
is routed to `.Base`. The dispatch is **wildcard-free**, unlike `PlusAxiom.minFrameClass`'s
`| _ => .Base` catch-all: a constructor added without a `minFrameClass` arm must fail to compile.

## Main Definitions

- `IsPureFutureOpen`, `IsPurePastOpen` — the purity side conditions of the pasting and rigidity
  schemata, at `OpenFormula`
- `OpenAxiom` — the axiom schemata, restricted-modal block first
- `OpenAxiom.minFrameClass` — the frame-class floor of each schema

## References

* JPL paper `sub:RestrictedModalities` — the open-future and open-past operators, and the
  restricted-modal schemata this block states
* JPL paper `def:BLstar-semantics` — the stability modal `⊡` and its class `⟨τ⟩_x`
* `FormalSystem/PlusLanguage/Axioms.lean` — the TM⁺ schemata whose re-declarations this file
  carries, and the authoritative docstring for each of them
* `FormalSystem/OpenLanguage/OpenValidity.lean` — the landed validities every restricted-modal
  schema is discharged from

## Tags

open-language · proof-system · axioms · open-future · open-past
-/

namespace FormalSystem.OpenLanguage

open FormalSystem.Syntax
open FormalSystem.ProofSystem (FrameClass)
open OpenFormula

/-! ### Two derived operators the Dedekind schemata need

`OpenLanguage/Formula.lean` carries every derived operator its own results use, and the Reynolds
operators are not among them; they are declared here, at their `PlusFormula` namesakes' right-hand
sides verbatim, so that `ofPlus` and `eraseOpen` commute with each one by `rfl`. They are declared
in this file rather than beside `OpenFormula` so that `OpenLanguage/Formula.lean` and its module
invariants stay untouched, the same divergence `OpenContext`'s placement records in
`OpenLanguage/OpenDerivation.lean`. -/

namespace OpenFormula

/-- Reynolds' `K⁺`: `¬U(¬φ, ⊤)` in guard-first order. Mirrors `PlusFormula.kPlus`. -/
def kPlus (φ : OpenFormula) : OpenFormula := (OpenFormula.untl φ.neg OpenFormula.top).neg

/-- Reynolds' `K⁻`: `¬S(¬φ, ⊤)` in guard-first order. Mirrors `PlusFormula.kMinus`. -/
def kMinus (φ : OpenFormula) : OpenFormula := (OpenFormula.snce φ.neg OpenFormula.top).neg

end OpenFormula

/-! ### Purity predicates

The side conditions of the pasting schemata (`paste`, `untl_paste`) and of the two rigidity
blocks, at `OpenFormula`. The seven shared clauses mirror
`PlusFormula.IsPureFuture`/`IsPurePast` (`PlusLanguage/Formula.lean`) exactly: `box ψ` and
`stab ψ` are leaves for any `ψ`, since `□ψ` is history-independent and `⊡ψ` depends on the present
world state alone.

**The two new clauses are crossed, and recursive.** `◁ψ` quantifies over the histories agreeing
with the history of evaluation *from* the time of evaluation onward, so its truth value is fixed by
the future and it belongs to the pure-**future** predicate; `▷ψ` quantifies over the histories
agreeing *up to* that time, so it belongs to the pure-**past** one. Neither is admitted in its own
direction: `▷ψ` is not future-determined, and admitting it as pure-future would falsify `paste`.

Both new clauses carry a **recursive guard** rather than being blanket leaves. A blanket
`| opast (ψ : OpenFormula) : IsPureFutureOpen (.opast ψ)` is semantically true — the class `⟨τ|_x`
is fixed by agreement from `x` onward whatever `ψ` is — but it breaks the erasure transport
`isPureFuture_eraseOpen` of `OpenLanguage/OpenErasure.lean`, because `eraseOpen` *deletes* `◁`
rather than keeping it, so `eraseOpen (◁ψ) = eraseOpen ψ` would have to be pure-future for an
arbitrary `ψ`. The recursive guard is what buys that transport. -/

/-- Pure-future L^▷ formulas: no `snce` and no `ofut` outside a `box`/`stab` scope. -/
inductive IsPureFutureOpen : OpenFormula → Prop
  /-- An atom is pure-future. -/
  | atom (p : Atom) : IsPureFutureOpen (.atom p)
  /-- `⊥` is pure-future. -/
  | bot : IsPureFutureOpen .bot
  /-- An implication of pure-future formulas is pure-future. -/
  | imp {φ ψ : OpenFormula} : IsPureFutureOpen φ → IsPureFutureOpen ψ →
      IsPureFutureOpen (.imp φ ψ)
  /-- `□φ` is pure-future for any `φ`: it is history-independent. -/
  | box (φ : OpenFormula) : IsPureFutureOpen (.box φ)
  /-- `⊡φ` is pure-future for any `φ`: it depends on the present world state alone. -/
  | stab (φ : OpenFormula) : IsPureFutureOpen (.stab φ)
  /-- `ψ U φ` is pure-future when both parts are. -/
  | untl {ψ φ : OpenFormula} : IsPureFutureOpen ψ → IsPureFutureOpen φ →
      IsPureFutureOpen (.untl ψ φ)
  /-- `◁φ` is pure-future when `φ` is: the class `⟨τ|_x` is fixed by agreement from `x` onward.
  The guard is not semantically needed but is what `isPureFuture_eraseOpen` rests on. -/
  | opast {φ : OpenFormula} : IsPureFutureOpen φ → IsPureFutureOpen (.opast φ)

/-- Pure-past L^▷ formulas: no `untl` and no `opast` outside a `box`/`stab` scope. -/
inductive IsPurePastOpen : OpenFormula → Prop
  /-- An atom is pure-past. -/
  | atom (p : Atom) : IsPurePastOpen (.atom p)
  /-- `⊥` is pure-past. -/
  | bot : IsPurePastOpen .bot
  /-- An implication of pure-past formulas is pure-past. -/
  | imp {φ ψ : OpenFormula} : IsPurePastOpen φ → IsPurePastOpen ψ → IsPurePastOpen (.imp φ ψ)
  /-- `□φ` is pure-past for any `φ`: it is history-independent. -/
  | box (φ : OpenFormula) : IsPurePastOpen (.box φ)
  /-- `⊡φ` is pure-past for any `φ`: it depends on the present world state alone. -/
  | stab (φ : OpenFormula) : IsPurePastOpen (.stab φ)
  /-- `ψ S φ` is pure-past when both parts are. -/
  | snce {ψ φ : OpenFormula} : IsPurePastOpen ψ → IsPurePastOpen φ → IsPurePastOpen (.snce ψ φ)
  /-- `▷φ` is pure-past when `φ` is: the class `|τ⟩_x` is fixed by agreement up to `x`. The guard
  is not semantically needed but is what `isPurePast_eraseOpen` rests on. -/
  | ofut {φ : OpenFormula} : IsPurePastOpen φ → IsPurePastOpen (.ofut φ)

/-! ### The axiom schemata -/

/--
Axiom schemata of the L^▷ proof system over `OpenFormula`.

This declaration carries the **restricted-modal block** only; the re-declared TM⁺ schemata are
appended to the same inductive. See the module docstring for the design, the class split, and the
five-surface extension recipe.

**The backward definability half is deliberately absent.** `▷◁φ → ⊡φ` is *valid* — it is the
landed `openValid_ofut_opast_imp_stab` of `OpenLanguage/OpenValidity.lean` — and it is **not** a
constructor here. Its `eraseOpen` image is `φ → ⊡φ`, the *Determined* schema, which
`FormalSystem/PlusLanguage/PlusNonValidities.lean` refutes over non-deterministic frames; so
admitting it would make the discharge arm of surface 5 above impossible and forfeit unconditional
forward conservativity over TM⁺. The forward half `definability_fwd` is admitted, and the backward
direction is anyway derivable in this system from `stab_4`, the two bridges `ofut_of_stab` and
`opast_of_stab`, `ofut_k` and derived `▷`-necessitation.

Paper: — (formalization-native; the manuscript sets the restricted modals aside and
supplies no logic for them)
-/
inductive OpenAxiom : OpenFormula → Type where
  -- The restricted modals: S5 for `▷` (4)
  /-- `▷`-K: `▷(φ → ψ) → (▷φ → ▷ψ)`; validity `openValid_ofut_k`. -/
  | ofut_k (φ ψ : OpenFormula) :
      OpenAxiom (imp (ofut (imp φ ψ)) (imp (ofut φ) (ofut ψ)))
  /-- `▷`-T: `▷φ → φ`; validity `openValid_ofut_t`. -/
  | ofut_t (φ : OpenFormula) : OpenAxiom (imp (ofut φ) φ)
  /-- `▷`-4: `▷φ → ▷▷φ`; validity `openValid_ofut_four`. -/
  | ofut_four (φ : OpenFormula) : OpenAxiom (imp (ofut φ) (ofut (ofut φ)))
  /-- `▷`-5: `▷̂φ → ▷▷̂φ`, stated through `dofut`; validity `openValid_ofut_five`. -/
  | ofut_five (φ : OpenFormula) : OpenAxiom (imp (dofut φ) (ofut (dofut φ)))
  -- The restricted modals: S5 for `◁` (4)
  /-- `◁`-K: `◁(φ → ψ) → (◁φ → ◁ψ)`; validity `openValid_opast_k`. -/
  | opast_k (φ ψ : OpenFormula) :
      OpenAxiom (imp (opast (imp φ ψ)) (imp (opast φ) (opast ψ)))
  /-- `◁`-T: `◁φ → φ`; validity `openValid_opast_t`. -/
  | opast_t (φ : OpenFormula) : OpenAxiom (imp (opast φ) φ)
  /-- `◁`-4: `◁φ → ◁◁φ`; validity `openValid_opast_four`. -/
  | opast_four (φ : OpenFormula) : OpenAxiom (imp (opast φ) (opast (opast φ)))
  /-- `◁`-5: `◁̂φ → ◁◁̂φ`, stated through `dopast`; validity `openValid_opast_five`. -/
  | opast_five (φ : OpenFormula) : OpenAxiom (imp (dopast φ) (opast (dopast φ)))
  -- The strength ordering `□ ⟹ ⊡ ⟹ ▷/◁` (3)
  /-- `□φ → ⊡φ`; validity `openValid_stab_of_box`. The TM⁺ mirror `box_stab` states the same
  schema; both are kept, so that the restricted-modal block is self-contained and the TM⁺ mirror
  block is constructor-for-constructor with `PlusAxiom`. -/
  | stab_of_box (φ : OpenFormula) : OpenAxiom (imp (box φ) (stab φ))
  /-- `⊡φ → ▷φ`; validity `openValid_ofut_of_stab`. -/
  | ofut_of_stab (φ : OpenFormula) : OpenAxiom (imp (stab φ) (ofut φ))
  /-- `⊡φ → ◁φ`; validity `openValid_opast_of_stab`. -/
  | opast_of_stab (φ : OpenFormula) : OpenAxiom (imp (stab φ) (opast φ))
  -- Historical necessity for the restricted modals (2)
  /-- The Ockhamist principle `Pα → ▷P▷̂α`; validity `hnOpen_openValid`. It is **not** stated for
  `⊡`: the stability transposition `Pp → ⊡P⟐p` is refuted on `sinkFrame`
  (`hnStab_refuted_sinkFrame`). -/
  | hn_open (α : OpenFormula) :
      OpenAxiom (imp (somePast α) (ofut (somePast (dofut α))))
  /-- The open-past mirror `Fα → ◁F◁̂α`; validity `openValid_hnOpenPast`, itself the time
  reflection of `hnOpen_openValid`. -/
  | hn_open_mirror (α : OpenFormula) :
      OpenAxiom (imp (someFuture α) (opast (someFuture (dopast α))))
  -- Rigidity of the pure fragments under the crossed modal (4)
  /-- `◁φ⁺ → φ⁺` for pure-future `φ⁺`. Stated as one half of an implication pair rather than a
  biconditional. -/
  | rigidity_opast_fwd (φ : OpenFormula) (hφ : IsPureFutureOpen φ) :
      OpenAxiom (imp (opast φ) φ)
  /-- `φ⁺ → ◁φ⁺` for pure-future `φ⁺`: the informative half, from the future-determinacy of the
  pure-future fragment. -/
  | rigidity_opast_bwd (φ : OpenFormula) (hφ : IsPureFutureOpen φ) :
      OpenAxiom (imp φ (opast φ))
  /-- `▷ψ⁻ → ψ⁻` for pure-past `ψ⁻`. -/
  | rigidity_ofut_fwd (φ : OpenFormula) (hφ : IsPurePastOpen φ) :
      OpenAxiom (imp (ofut φ) φ)
  /-- `ψ⁻ → ▷ψ⁻` for pure-past `ψ⁻`: the informative half, from the past-determinacy of the
  pure-past fragment. -/
  | rigidity_ofut_bwd (φ : OpenFormula) (hφ : IsPurePastOpen φ) :
      OpenAxiom (imp φ (ofut φ))
  -- Definability, forward half only (1)
  /-- `⊡φ → ▷◁φ`; validity `openValid_stab_imp_ofut_opast`. The backward half is excluded; see the
  note on the inductive. -/
  | definability_fwd (φ : OpenFormula) : OpenAxiom (imp (stab φ) (ofut (opast φ)))
  -- The TM⁺ schemata, re-declared at `OpenFormula` parameters (53)
  -- Read constructor for constructor against `FormalSystem/PlusLanguage/Axioms.lean`, whose
  -- docstrings are authoritative for each schema's reading and provenance.
  -- Layer 1: Propositional (4)
  /-- Propositional K: `(φ → (ψ → χ)) → ((φ → ψ) → (φ → χ))` -/
  | prop_k (φ ψ χ : OpenFormula) :
      OpenAxiom ((φ.imp (ψ.imp χ)).imp ((φ.imp ψ).imp (φ.imp χ)))
  /-- Propositional S (weakening): `φ → (ψ → φ)` -/
  | prop_s (φ ψ : OpenFormula) : OpenAxiom (φ.imp (ψ.imp φ))
  /-- Ex Falso Quodlibet: `⊥ → φ` -/
  | ex_falso (φ : OpenFormula) : OpenAxiom (OpenFormula.bot.imp φ)
  /-- Peirce's Law: `((φ → ψ) → φ) → φ` -/
  | peirce (φ ψ : OpenFormula) : OpenAxiom (((φ.imp ψ).imp φ).imp φ)
  -- Layer 2: S5 Modal (5)
  /-- Modal T: `□φ → φ` -/
  | modal_t (φ : OpenFormula) : OpenAxiom (OpenFormula.box φ |>.imp φ)
  /-- Modal 4: `□φ → □□φ` -/
  | modal_4 (φ : OpenFormula) : OpenAxiom
      ((OpenFormula.box φ).imp (OpenFormula.box (OpenFormula.box φ)))
  /-- Modal B: `φ → □◇φ` -/
  | modal_b (φ : OpenFormula) : OpenAxiom (φ.imp (OpenFormula.box φ.diamond))
  /-- Modal 5 Collapse: `◇□φ → □φ` -/
  | modal_5_collapse (φ : OpenFormula) : OpenAxiom (φ.box.diamond.imp φ.box)
  /-- Modal K Distribution: `□(φ → ψ) → (□φ → □ψ)` -/
  | modal_k_dist (φ ψ : OpenFormula) :
      OpenAxiom ((φ.imp ψ).box.imp (φ.box.imp ψ.box))
  -- Layer 3: BX Temporal (22)
  /-- Serial future: `F(⊤)` (the paper's TS verbatim) -/
  | serial_future :
    OpenAxiom (OpenFormula.someFuture (OpenFormula.bot.imp OpenFormula.bot))
  /-- Serial past: `⊤ → P(⊤)` -/
  | serial_past :
    OpenAxiom ((OpenFormula.bot.imp OpenFormula.bot).imp
      (OpenFormula.somePast (OpenFormula.bot.imp OpenFormula.bot)))
  /-- BX2G: `G(φ→χ) → ((φ U ψ) → (χ U ψ))` -/
  | left_mono_until_G (φ χ ψ : OpenFormula) :
      OpenAxiom ((φ.imp χ).allFuture.imp ((OpenFormula.untl φ ψ).imp (OpenFormula.untl χ ψ)))
  /-- BX2H: `H(φ→χ) → ((φ S ψ) → (χ S ψ))` -/
  | left_mono_since_H (φ χ ψ : OpenFormula) :
      OpenAxiom ((φ.imp χ).allPast.imp ((OpenFormula.snce φ ψ).imp (OpenFormula.snce χ ψ)))
  /-- BX3: `G(φ → ψ) → ((χ U φ) → (χ U ψ))` -/
  | right_mono_until (φ ψ χ : OpenFormula) :
      OpenAxiom ((φ.imp ψ).allFuture.imp ((OpenFormula.untl χ φ).imp (OpenFormula.untl χ ψ)))
  /-- BX3': `H(φ → ψ) → ((χ S φ) → (χ S ψ))` -/
  | right_mono_since (φ ψ χ : OpenFormula) :
      OpenAxiom ((φ.imp ψ).allPast.imp ((OpenFormula.snce χ φ).imp (OpenFormula.snce χ ψ)))
  /-- BX4: `φ → G(P(φ))` -/
  | connect_future (φ : OpenFormula) :
      OpenAxiom (φ.imp (φ.somePast.allFuture))
  /-- BX4': `φ → H(F(φ))` -/
  | connect_past (φ : OpenFormula) :
      OpenAxiom (φ.imp (φ.someFuture.allPast))
  /-- BX13: `p ∧ untl(φ, ψ) → untl(φ, ψ ∧ snce(φ, p))` (Burgess A3a) -/
  | enrichment_until (φ ψ p : OpenFormula) :
      OpenAxiom (OpenFormula.and p (OpenFormula.untl φ ψ) |>.imp
        (OpenFormula.untl φ (OpenFormula.and ψ (OpenFormula.snce φ p))))
  /-- BX13': `p ∧ snce(φ, ψ) → snce(φ, ψ ∧ untl(φ, p))` (Burgess A3b) -/
  | enrichment_since (φ ψ p : OpenFormula) :
      OpenAxiom (OpenFormula.and p (OpenFormula.snce φ ψ) |>.imp
        (OpenFormula.snce φ (OpenFormula.and ψ (OpenFormula.untl φ p))))
  /-- BX5: `U(ψ, φ) → U(ψ, φ ∧ U(ψ, φ))` -/
  | self_accum_until (φ ψ : OpenFormula) :
      OpenAxiom ((OpenFormula.untl φ ψ).imp
        (OpenFormula.untl (OpenFormula.and φ (OpenFormula.untl φ ψ)) ψ))
  /-- BX5': `S(ψ, φ) → S(ψ, φ ∧ S(ψ, φ))` -/
  | self_accum_since (φ ψ : OpenFormula) :
      OpenAxiom ((OpenFormula.snce φ ψ).imp
        (OpenFormula.snce (OpenFormula.and φ (OpenFormula.snce φ ψ)) ψ))
  /-- BX6: `U(φ ∧ U(ψ, φ), φ) → U(ψ, φ)` -/
  | absorb_until (φ ψ : OpenFormula) :
      OpenAxiom ((OpenFormula.untl φ (OpenFormula.and φ (OpenFormula.untl φ ψ))).imp
        (OpenFormula.untl φ ψ))
  /-- BX6': `S(φ ∧ S(ψ, φ), φ) → S(ψ, φ)` -/
  | absorb_since (φ ψ : OpenFormula) :
      OpenAxiom ((OpenFormula.snce φ (OpenFormula.and φ (OpenFormula.snce φ ψ))).imp
        (OpenFormula.snce φ ψ))
  /-- BX7: linearity of Until (the paper's CN, right-associated) -/
  | linear_until (φ ψ χ θ : OpenFormula) :
      OpenAxiom (OpenFormula.and (OpenFormula.untl φ ψ) (OpenFormula.untl χ θ)
        |>.imp (OpenFormula.or
          (OpenFormula.untl (OpenFormula.and φ χ) (OpenFormula.and ψ θ))
          (OpenFormula.or
            (OpenFormula.untl (OpenFormula.and φ χ) (OpenFormula.and ψ χ))
            (OpenFormula.untl (OpenFormula.and φ χ) (OpenFormula.and φ θ)))))
  /-- BX7': linearity of Since -/
  | linear_since (φ ψ χ θ : OpenFormula) :
      OpenAxiom (OpenFormula.and (OpenFormula.snce φ ψ) (OpenFormula.snce χ θ)
        |>.imp (OpenFormula.or
          (OpenFormula.or
            (OpenFormula.snce (OpenFormula.and φ χ) (OpenFormula.and ψ θ))
            (OpenFormula.snce (OpenFormula.and φ χ) (OpenFormula.and ψ χ)))
          (OpenFormula.snce (OpenFormula.and φ χ) (OpenFormula.and φ θ))))
  /-- BX10: `U(ψ, φ) → F(ψ)` -/
  | until_F (φ ψ : OpenFormula) :
      OpenAxiom ((OpenFormula.untl φ ψ).imp (OpenFormula.someFuture ψ))
  /-- BX10': `S(ψ, φ) → P(ψ)` -/
  | since_P (φ ψ : OpenFormula) :
      OpenAxiom ((OpenFormula.snce φ ψ).imp (OpenFormula.somePast ψ))
  /-- BX11 (the paper's TL, verbatim): `F(φ) ∧ F(ψ) → F(F(φ) ∧ ψ) ∨ (F(φ ∧ ψ) ∨ F(φ ∧ F(ψ)))` -/
  | temp_linearity (φ ψ : OpenFormula) :
      OpenAxiom (OpenFormula.and (OpenFormula.someFuture φ) (OpenFormula.someFuture ψ) |>.imp
        (OpenFormula.or (OpenFormula.someFuture (OpenFormula.and (OpenFormula.someFuture φ) ψ))
          (OpenFormula.or (OpenFormula.someFuture (OpenFormula.and φ ψ))
            (OpenFormula.someFuture (OpenFormula.and φ (OpenFormula.someFuture ψ))))))
  /-- BX11': `P(φ) ∧ P(ψ) → P(φ ∧ ψ) ∨ P(φ ∧ P(ψ)) ∨ P(P(φ) ∧ ψ)` -/
  | temp_linearity_past (φ ψ : OpenFormula) :
      OpenAxiom (OpenFormula.and (OpenFormula.somePast φ) (OpenFormula.somePast ψ) |>.imp
        (OpenFormula.or (OpenFormula.somePast (OpenFormula.and φ ψ))
          (OpenFormula.or (OpenFormula.somePast (OpenFormula.and φ (OpenFormula.somePast ψ)))
            (OpenFormula.somePast (OpenFormula.and (OpenFormula.somePast φ) ψ)))))
  /-- BX12: `F(φ) → U(φ, ⊤)` -/
  | F_until_equiv (φ : OpenFormula) :
      OpenAxiom ((OpenFormula.someFuture φ).imp
        (OpenFormula.untl (OpenFormula.bot.imp OpenFormula.bot) φ))
  /-- BX12': `P(φ) → S(φ, ⊤)` -/
  | P_since_equiv (φ : OpenFormula) :
      OpenAxiom ((OpenFormula.somePast φ).imp
        (OpenFormula.snce (OpenFormula.bot.imp OpenFormula.bot) φ))
  -- Layer 4: Modal-Temporal Interaction (1)
  /-- Modal-Future: `□φ → □(Gφ)` -/
  | modal_future (φ : OpenFormula) :
      OpenAxiom ((OpenFormula.box φ).imp (OpenFormula.box (OpenFormula.allFuture φ)))
  -- Layer 5: Uniformity (5)
  /-- `U(⊤,⊥) → S(⊤,⊥)` -/
  | discrete_symm_fwd :
      OpenAxiom ((OpenFormula.untl OpenFormula.bot (OpenFormula.bot.imp OpenFormula.bot)).imp
        (OpenFormula.snce OpenFormula.bot (OpenFormula.bot.imp OpenFormula.bot)))
  /-- `S(⊤,⊥) → U(⊤,⊥)` -/
  | discrete_symm_bwd :
      OpenAxiom ((OpenFormula.snce OpenFormula.bot (OpenFormula.bot.imp OpenFormula.bot)).imp
        (OpenFormula.untl OpenFormula.bot (OpenFormula.bot.imp OpenFormula.bot)))
  /-- `U(⊤,⊥) → G(U(⊤,⊥))` -/
  | discrete_propagate_fwd :
      OpenAxiom ((OpenFormula.untl OpenFormula.bot (OpenFormula.bot.imp OpenFormula.bot)).imp
        (OpenFormula.allFuture
          (OpenFormula.untl OpenFormula.bot (OpenFormula.bot.imp OpenFormula.bot))))
  /-- `U(⊤,⊥) → H(U(⊤,⊥))` -/
  | discrete_propagate_bwd :
      OpenAxiom ((OpenFormula.untl OpenFormula.bot (OpenFormula.bot.imp OpenFormula.bot)).imp
        (OpenFormula.allPast
          (OpenFormula.untl OpenFormula.bot (OpenFormula.bot.imp OpenFormula.bot))))
  /-- `U(⊤,⊥) → □(U(⊤,⊥))` -/
  | discrete_box_necessity :
      OpenAxiom ((OpenFormula.untl OpenFormula.bot (OpenFormula.bot.imp OpenFormula.bot)).imp
        (OpenFormula.box (OpenFormula.untl OpenFormula.bot (OpenFormula.bot.imp OpenFormula.bot))))
  -- Layer 6: Prior (2)
  /-- Prior-UZ: `F(φ) → U(φ, ¬φ)` -/
  | prior_UZ (φ : OpenFormula) :
      OpenAxiom (φ.someFuture.imp (OpenFormula.untl φ.neg φ))
  /-- Prior-SZ: `P(φ) → S(φ, ¬φ)` -/
  | prior_SZ (φ : OpenFormula) :
      OpenAxiom (φ.somePast.imp (OpenFormula.snce φ.neg φ))
  -- Layer 7: Z1 (1)
  /-- Z1: `G(Gφ→φ) → (FGφ→Gφ)` -/
  | z1 (φ : OpenFormula) :
      OpenAxiom ((φ.allFuture.imp φ).allFuture.imp (φ.allFuture.someFuture.imp φ.allFuture))
  -- Layer 8: Density (2)
  /-- Density: `GGφ → Gφ` -/
  | density (φ : OpenFormula) :
      OpenAxiom (φ.allFuture.allFuture.imp φ.allFuture)
  /-- Dense indicator: `¬U(⊤,⊥)` -/
  | dense_indicator :
      OpenAxiom (OpenFormula.untl OpenFormula.bot (OpenFormula.bot.imp OpenFormula.bot)).neg
  -- Layer 9: Reynolds Dedekind (3)
  /-- Prior-U (gap form): `U(⊤,φ) ∧ F(¬φ) → U(¬φ ∨ K⁺(¬φ), φ)` -/
  | prior_U_gap (φ : OpenFormula) :
      OpenAxiom ((OpenFormula.and (OpenFormula.untl φ OpenFormula.top) φ.neg.someFuture).imp
        (OpenFormula.untl φ (OpenFormula.or φ.neg (OpenFormula.kPlus φ.neg))))
  /-- Prior-S (gap form): `S(⊤,φ) ∧ P(¬φ) → S(¬φ ∨ K⁻(¬φ), φ)` -/
  | prior_S_gap (φ : OpenFormula) :
      OpenAxiom ((OpenFormula.and (OpenFormula.snce φ OpenFormula.top) φ.neg.somePast).imp
        (OpenFormula.snce φ (OpenFormula.or φ.neg (OpenFormula.kMinus φ.neg))))
  /-- Sep: `K⁺φ ∧ ¬K⁺(φ ∧ U(φ,¬φ)) → K⁺(K⁺φ ∧ K⁻φ)` -/
  | sep (φ : OpenFormula) :
      OpenAxiom ((OpenFormula.and (OpenFormula.kPlus φ)
        (OpenFormula.kPlus (OpenFormula.and φ (OpenFormula.untl φ.neg φ))).neg).imp
        (OpenFormula.kPlus (OpenFormula.and (OpenFormula.kPlus φ) (OpenFormula.kMinus φ))))
  -- The stability modal (8)
  /-- SK: `⊡(φ → ψ) → (⊡φ → ⊡ψ)` — K for `⊡`, from the universal-quantifier shape of the
  `stab` clause (`def:BLstar-semantics`). -/
  | stab_k (φ ψ : OpenFormula) :
      OpenAxiom ((OpenFormula.stab (φ.imp ψ)).imp ((OpenFormula.stab φ).imp (OpenFormula.stab ψ)))
  /-- ST: `⊡φ → φ` — T for `⊡` (the footnote to the Stability clause); `Semantics.of_stab`. -/
  | stab_t (φ : OpenFormula) : OpenAxiom ((OpenFormula.stab φ).imp φ)
  /-- S4: `⊡φ → ⊡⊡φ` (the footnote to the Stability clause); `Semantics.stab_four`. `stab_4` is
  not among the schemata of the manuscript's commented-out TM-stability axiomatization (SK, ST,
  S5, MS, AS, PS and US); it is derivable from SK, ST and the S5 schema, and is kept here as a
  primitive constructor for convenience. -/
  | stab_4 (φ : OpenFormula) :
      OpenAxiom ((OpenFormula.stab φ).imp (OpenFormula.stab (OpenFormula.stab φ)))
  /-- S5: `⟐φ → ⊡⟐φ`, stated as `¬⊡¬φ → ⊡¬⊡¬φ` through `dstab` (the footnote to the Stability
  clause); `Semantics.stab_five` at `¬φ`. -/
  | stab_5 (φ : OpenFormula) :
      OpenAxiom ((dstab φ).imp (OpenFormula.stab (dstab φ)))
  /-- MS: `□φ → ⊡φ` — `⟨τ⟩_x ⊆ H_F` (`def:BLstar-semantics`); `Semantics.stab_of_box`. -/
  | box_stab (φ : OpenFormula) : OpenAxiom ((OpenFormula.box φ).imp (OpenFormula.stab φ))
  /-- AS: `p → ⊡p` for atoms (the footnote to the Stability clause); `Semantics.stab_of_stateLocal`
      at `stateLocal_atom`. The axiom stays atom-restricted — widening it would change TM⁺ — but
      its semantic witness is the whole state-locality fragment. -/
  | atom_stab (p : Atom) :
      OpenAxiom ((OpenFormula.atom p).imp (OpenFormula.stab (OpenFormula.atom p)))
  /-- PS (same-time pasting): `⟐φ⁺ → (⟐ψ⁻ → ⟐(φ⁺ ∧ ψ⁻))` for pure-future `φ⁺` and pure-past
  `ψ⁻`; `Semantics.paste_valid`. -/
  | paste (φ ψ : OpenFormula) (hφ : IsPureFutureOpen φ) (hψ : IsPurePastOpen ψ) :
      OpenAxiom ((dstab φ).imp ((dstab ψ).imp (dstab (φ.and ψ))))
  /-- US (future pasting): `(α⁻ U ⟐φ⁺) → ⟐(α⁻ U φ⁺)` for pure-past `α⁻` and pure-future `φ⁺`;
  `Semantics.untl_dstab_valid`. -/
  | untl_paste (α φ : OpenFormula) (hα : IsPurePastOpen α) (hφ : IsPureFutureOpen φ) :
      OpenAxiom ((OpenFormula.untl α (dstab φ)).imp (dstab (OpenFormula.untl α φ)))

namespace OpenAxiom

/--
Minimum frame class of each L^▷ schema. Every restricted-modal schema is valid over every task
frame and is routed to `.Base`; the re-declared TM⁺ arms repeat `PlusAxiom.minFrameClass`'s
assignment.

The dispatch is **wildcard-free** on purpose. `PlusAxiom.minFrameClass` ends in `| _ => .Base`,
which silently absorbs a new constructor; here a new constructor without an arm fails to compile.
-/
def minFrameClass {φ : OpenFormula} : OpenAxiom φ → FrameClass
  | .ofut_k _ _ => .Base
  | .ofut_t _ => .Base
  | .ofut_four _ => .Base
  | .ofut_five _ => .Base
  | .opast_k _ _ => .Base
  | .opast_t _ => .Base
  | .opast_four _ => .Base
  | .opast_five _ => .Base
  | .stab_of_box _ => .Base
  | .ofut_of_stab _ => .Base
  | .opast_of_stab _ => .Base
  | .hn_open _ => .Base
  | .hn_open_mirror _ => .Base
  | .rigidity_opast_fwd _ _ => .Base
  | .rigidity_opast_bwd _ _ => .Base
  | .rigidity_ofut_fwd _ _ => .Base
  | .rigidity_ofut_bwd _ _ => .Base
  | .definability_fwd _ => .Base
  -- The re-declared TM⁺ schemata, repeating `PlusAxiom.minFrameClass`'s assignment
  | .prop_k _ _ _ => .Base
  | .prop_s _ _ => .Base
  | .ex_falso _ => .Base
  | .peirce _ _ => .Base
  | .modal_t _ => .Base
  | .modal_4 _ => .Base
  | .modal_b _ => .Base
  | .modal_5_collapse _ => .Base
  | .modal_k_dist _ _ => .Base
  | .serial_future => .Base
  | .serial_past => .Base
  | .left_mono_until_G _ _ _ => .Base
  | .left_mono_since_H _ _ _ => .Base
  | .right_mono_until _ _ _ => .Base
  | .right_mono_since _ _ _ => .Base
  | .connect_future _ => .Base
  | .connect_past _ => .Base
  | .enrichment_until _ _ _ => .Base
  | .enrichment_since _ _ _ => .Base
  | .self_accum_until _ _ => .Base
  | .self_accum_since _ _ => .Base
  | .absorb_until _ _ => .Base
  | .absorb_since _ _ => .Base
  | .linear_until _ _ _ _ => .Base
  | .linear_since _ _ _ _ => .Base
  | .until_F _ _ => .Base
  | .since_P _ _ => .Base
  | .temp_linearity _ _ => .Base
  | .temp_linearity_past _ _ => .Base
  | .F_until_equiv _ => .Base
  | .P_since_equiv _ => .Base
  | .modal_future _ => .Base
  | .discrete_symm_fwd => .Base
  | .discrete_symm_bwd => .Base
  | .discrete_propagate_fwd => .Base
  | .discrete_propagate_bwd => .Base
  | .discrete_box_necessity => .Base
  | .prior_UZ _ => .ZTime
  | .prior_SZ _ => .ZTime
  | .z1 _ => .ZTime
  | .density _ => .Dense
  | .dense_indicator => .Dense
  | .prior_U_gap _ => .RTime
  | .prior_S_gap _ => .RTime
  | .sep _ => .RTime
  | .stab_k _ _ => .Base
  | .stab_t _ => .Base
  | .stab_4 _ => .Base
  | .stab_5 _ => .Base
  | .box_stab _ => .Base
  | .atom_stab _ => .Base
  | .paste _ _ _ _ => .Base
  | .untl_paste _ _ _ _ => .Base

end OpenAxiom

/-! ### Pins

`minFrameClass` on the restricted-modal block, by `rfl`. -/

example (φ : OpenFormula) : (OpenAxiom.ofut_t φ).minFrameClass = .Base := rfl
example (φ : OpenFormula) : (OpenAxiom.opast_five φ).minFrameClass = .Base := rfl
example (α : OpenFormula) : (OpenAxiom.hn_open α).minFrameClass = .Base := rfl
example (φ : OpenFormula) (hφ : IsPureFutureOpen φ) :
    (OpenAxiom.rigidity_opast_bwd φ hφ).minFrameClass = .Base := rfl
example (φ : OpenFormula) : (OpenAxiom.definability_fwd φ).minFrameClass = .Base := rfl

/-! One representative TM⁺ mirror at each of the four frame classes. -/

example (φ : OpenFormula) : (OpenAxiom.stab_t φ).minFrameClass = .Base := rfl
example (φ : OpenFormula) : (OpenAxiom.density φ).minFrameClass = .Dense := rfl
example (φ : OpenFormula) : (OpenAxiom.z1 φ).minFrameClass = .ZTime := rfl
example (φ : OpenFormula) : (OpenAxiom.sep φ).minFrameClass = .RTime := rfl
example (φ ψ : OpenFormula) (hφ : IsPureFutureOpen φ) (hψ : IsPurePastOpen ψ) :
    (OpenAxiom.paste φ ψ hφ hψ).minFrameClass = .Base := rfl

end FormalSystem.OpenLanguage
