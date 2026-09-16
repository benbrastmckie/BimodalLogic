/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Syntax.PlusLanguage.Formula
import FormalSystem.ProofSystem.Axioms

/-!
# `PlusAxiom` — the axiom schemata of TM⁺ over `PlusFormula`

The axiom system **TM⁺** for the language L⁺ (`PlusLanguage/Formula.lean`): the 45 schemata of
TM (`ProofSystem/Axioms.lean`) **re-declared with `PlusFormula` parameters**, plus eight
schemata for the stability modal `⊡`.

## Why the TM schemata are re-declared rather than embedded

An embedding constructor `ofTM : Axiom φ → PlusAxiom (ofFormula φ)` would yield only the
`⊡`-free instances of each schema. TM⁺ needs, for instance, `□⊡p → □G⊡p` — MF at `⊡p` — so every
schema must range over all of `PlusFormula`. The re-declaration is mechanical: constructor for
constructor, the same name, the same parameter list, the same statement through the derived
operators of `PlusLanguage/Formula.lean`, whose right-hand sides are `Formula`'s verbatim. The
function `PlusAxiom.ofTM` (`PlusLanguage/Derivation.lean`) sends each `Axiom` instance to the
re-declared twin at the embedded parameters; every one of its 45 arms is `rfl`-shaped, so any
drift between the two inductives fails to typecheck there.

## The `⊡` schemata

| Name | Schema | Validity |
|------|--------|----------|
| `stab_k` | `⊡(φ → ψ) → (⊡φ → ⊡ψ)` | universal-quantifier shape of the `stab` clause |
| `stab_t` | `⊡φ → φ` | `Semantics/PlusTruth.lean`, `of_stab` |
| `stab_4` | `⊡φ → ⊡⊡φ` | `stab_four` |
| `stab_5` | `⟐φ → ⊡⟐φ` (as `¬⊡¬φ → ⊡¬⊡¬φ`) | `stab_five` |
| `box_stab` | `□φ → ⊡φ` | `stab_of_box` (`⟨τ⟩_x ⊆ H_F`, paper line 1108) |
| `atom_stab` | `p → ⊡p` for atoms | `stab_of_stateLocal` at `stateLocal_atom` (paper footnote, line 1119) |
| `paste` | `⟐φ⁺ → (⟐ψ⁻ → ⟐(φ⁺ ∧ ψ⁻))`, `φ⁺` pure-future, `ψ⁻` pure-past | `Semantics/PlusPasting.lean`, `paste_valid` |
| `untl_paste` | `(α⁻ U ⟐φ⁺) → ⟐(α⁻ U φ⁺)`, `α⁻` pure-past, `φ⁺` pure-future | `untl_dstab_valid` |

The first four say that the monomodal logic of `⊡` is S5 (paper footnote, line 1118: `⟨τ⟩_x`
is an equivalence class of `σ ∼_x τ := σ(x) = τ(x)`), and the next two are the bridge principles
relating `⊡` to `□` and to atoms. **That set alone is provably incomplete**: it knows that `∼_x`
is an equivalence contained in the universal relation and respected by atoms, and nothing
else. The two pasting schemata `paste` and `untl_paste` add the one structural fact about
`⟨τ⟩_x` that the S5 axioms miss — the total histories through a world state are the product of
its possible pasts and its possible futures — and they are exactly what makes, for instance,
`⊡Gφ⁺ → G⊡φ⁺` derivable. Their purity side conditions are necessary
(`Semantics/PlusNonValidities.lean`).

**Derived, not constructors.** FS (`F⟐φ⁺ → ⟐Fφ⁺`) is `untl_paste` at `α⁻ := ⊤`; GS
(`⊡Gφ⁺ → G⊡φ⁺`) is its contrapositive; the past mirrors (PS with the conjuncts exchanged, and
SS `(α⁺ S ⟐φ⁻) → ⟐(α⁺ S φ⁻)`) are obtained by the temporal-duality rule, since `swapTemporal`
exchanges `IsPureFuture` and `IsPurePast`. `⊡`-necessitation is likewise a derived rule
(necessitation for `□` followed by `box_stab`; `PlusLanguage/Derivation.lean`,
`stabNecessitation`).

**Refuted, hence absent.** `⊡φ → □⊡φ`, `G⊡p → ⊡Gp`, `⊡GPp → G⊡Pp`, *Determined* `φ → ⊡φ` (over
non-deterministic frames), and `P⊡p → ⊡Pp` are all refuted in
`Semantics/PlusNonValidities.lean`. In particular *Determined* must never be added here: it is
refuted at `.Base`, so adding it would falsify TM⁺ soundness. A validity notion over the
deterministic frames can be stated through `PlusValidOnFrames` without touching this inductive.

**Open.** Completeness of TM⁺ over the all-histories semantics, and decidability of TM⁺, are
both open and outside this module's scope; nothing here promises either.

## Frame classes

`PlusAxiom.minFrameClass` routes the TM schemata exactly as `Axiom.minFrameClass` does (Dense,
Discrete and Dedekind axioms to their classes, everything else to `.Base`); every `⊡` schema is
valid over every task frame and is routed to `.Base`.

## Extension recipe

`PlusAxiom` is a **closed** inductive. Exactly three declarations pattern-match on its
constructors: `PlusAxiom.minFrameClass` below, and the two dispatch lemmas
`plusAxiom_validIn_min` / `plusAxiom_swap_validIn_min`
(`Metalogic/Conservativity/Plus/AxiomValidity.lean`). Adding a constructor means one constructor
line, one `minFrameClass` arm and one arm in each dispatch lemma; every other file recompiles
unchanged.

## References

* `FormalSystem/ProofSystem/Axioms.lean` — the 45 TM schemata, with their [burgess1982] / [xu1988] /
  [reynolds1992] provenance; the docstrings there are authoritative for each schema's reading
* JPL paper `possible_worlds.tex` lines 1108, 1114, 1118-1119, 1121
-/

namespace FormalSystem.PlusLanguage

open FormalSystem.Syntax
open FormalSystem.ProofSystem (FrameClass)
open PlusFormula

/--
Axiom schemata of TM⁺ over `PlusFormula`: the 45 TM schemata re-declared with `PlusFormula`
parameters, then the eight `⊡` schemata. See the module docstring for the design and the axiom
inventory.
-/
inductive PlusAxiom : PlusFormula → Type where
  -- Layer 1: Propositional (4)
  /-- Propositional K: `(φ → (ψ → χ)) → ((φ → ψ) → (φ → χ))` -/
  | prop_k (φ ψ χ : PlusFormula) :
      PlusAxiom ((φ.imp (ψ.imp χ)).imp ((φ.imp ψ).imp (φ.imp χ)))
  /-- Propositional S (weakening): `φ → (ψ → φ)` -/
  | prop_s (φ ψ : PlusFormula) : PlusAxiom (φ.imp (ψ.imp φ))
  /-- Ex Falso Quodlibet: `⊥ → φ` -/
  | ex_falso (φ : PlusFormula) : PlusAxiom (PlusFormula.bot.imp φ)
  /-- Peirce's Law: `((φ → ψ) → φ) → φ` -/
  | peirce (φ ψ : PlusFormula) : PlusAxiom (((φ.imp ψ).imp φ).imp φ)
  -- Layer 2: S5 Modal (5)
  /-- Modal T: `□φ → φ` -/
  | modal_t (φ : PlusFormula) : PlusAxiom (PlusFormula.box φ |>.imp φ)
  /-- Modal 4: `□φ → □□φ` -/
  | modal_4 (φ : PlusFormula) : PlusAxiom ((PlusFormula.box φ).imp (PlusFormula.box (PlusFormula.box φ)))
  /-- Modal B: `φ → □◇φ` -/
  | modal_b (φ : PlusFormula) : PlusAxiom (φ.imp (PlusFormula.box φ.diamond))
  /-- Modal 5 Collapse: `◇□φ → □φ` -/
  | modal_5_collapse (φ : PlusFormula) : PlusAxiom (φ.box.diamond.imp φ.box)
  /-- Modal K Distribution: `□(φ → ψ) → (□φ → □ψ)` -/
  | modal_k_dist (φ ψ : PlusFormula) :
      PlusAxiom ((φ.imp ψ).box.imp (φ.box.imp ψ.box))
  -- Layer 3: BX Temporal (22)
  /-- Serial future: `⊤ → F(⊤)` -/
  | serial_future :
    PlusAxiom ((PlusFormula.bot.imp PlusFormula.bot).imp
      (PlusFormula.someFuture (PlusFormula.bot.imp PlusFormula.bot)))
  /-- Serial past: `⊤ → P(⊤)` -/
  | serial_past :
    PlusAxiom ((PlusFormula.bot.imp PlusFormula.bot).imp
      (PlusFormula.somePast (PlusFormula.bot.imp PlusFormula.bot)))
  /-- BX2G: `G(φ→χ) → ((φ U ψ) → (χ U ψ))` -/
  | left_mono_until_G (φ χ ψ : PlusFormula) :
      PlusAxiom ((φ.imp χ).allFuture.imp ((PlusFormula.untl φ ψ).imp (PlusFormula.untl χ ψ)))
  /-- BX2H: `H(φ→χ) → ((φ S ψ) → (χ S ψ))` -/
  | left_mono_since_H (φ χ ψ : PlusFormula) :
      PlusAxiom ((φ.imp χ).allPast.imp ((PlusFormula.snce φ ψ).imp (PlusFormula.snce χ ψ)))
  /-- BX3: `G(φ → ψ) → ((χ U φ) → (χ U ψ))` -/
  | right_mono_until (φ ψ χ : PlusFormula) :
      PlusAxiom ((φ.imp ψ).allFuture.imp ((PlusFormula.untl χ φ).imp (PlusFormula.untl χ ψ)))
  /-- BX3': `H(φ → ψ) → ((χ S φ) → (χ S ψ))` -/
  | right_mono_since (φ ψ χ : PlusFormula) :
      PlusAxiom ((φ.imp ψ).allPast.imp ((PlusFormula.snce χ φ).imp (PlusFormula.snce χ ψ)))
  /-- BX4: `φ → G(P(φ))` -/
  | connect_future (φ : PlusFormula) :
      PlusAxiom (φ.imp (φ.somePast.allFuture))
  /-- BX4': `φ → H(F(φ))` -/
  | connect_past (φ : PlusFormula) :
      PlusAxiom (φ.imp (φ.someFuture.allPast))
  /-- BX13: `p ∧ untl(φ, ψ) → untl(φ, ψ ∧ snce(φ, p))` (Burgess A3a) -/
  | enrichment_until (φ ψ p : PlusFormula) :
      PlusAxiom (PlusFormula.and p (PlusFormula.untl φ ψ) |>.imp
        (PlusFormula.untl φ (PlusFormula.and ψ (PlusFormula.snce φ p))))
  /-- BX13': `p ∧ snce(φ, ψ) → snce(φ, ψ ∧ untl(φ, p))` (Burgess A3b) -/
  | enrichment_since (φ ψ p : PlusFormula) :
      PlusAxiom (PlusFormula.and p (PlusFormula.snce φ ψ) |>.imp
        (PlusFormula.snce φ (PlusFormula.and ψ (PlusFormula.untl φ p))))
  /-- BX5: `U(ψ, φ) → U(ψ, φ ∧ U(ψ, φ))` -/
  | self_accum_until (φ ψ : PlusFormula) :
      PlusAxiom ((PlusFormula.untl φ ψ).imp
        (PlusFormula.untl (PlusFormula.and φ (PlusFormula.untl φ ψ)) ψ))
  /-- BX5': `S(ψ, φ) → S(ψ, φ ∧ S(ψ, φ))` -/
  | self_accum_since (φ ψ : PlusFormula) :
      PlusAxiom ((PlusFormula.snce φ ψ).imp
        (PlusFormula.snce (PlusFormula.and φ (PlusFormula.snce φ ψ)) ψ))
  /-- BX6: `U(φ ∧ U(ψ, φ), φ) → U(ψ, φ)` -/
  | absorb_until (φ ψ : PlusFormula) :
      PlusAxiom ((PlusFormula.untl φ (PlusFormula.and φ (PlusFormula.untl φ ψ))).imp
        (PlusFormula.untl φ ψ))
  /-- BX6': `S(φ ∧ S(ψ, φ), φ) → S(ψ, φ)` -/
  | absorb_since (φ ψ : PlusFormula) :
      PlusAxiom ((PlusFormula.snce φ (PlusFormula.and φ (PlusFormula.snce φ ψ))).imp
        (PlusFormula.snce φ ψ))
  /-- BX7: linearity of Until -/
  | linear_until (φ ψ χ θ : PlusFormula) :
      PlusAxiom (PlusFormula.and (PlusFormula.untl φ ψ) (PlusFormula.untl χ θ)
        |>.imp (PlusFormula.or
          (PlusFormula.or
            (PlusFormula.untl (PlusFormula.and φ χ) (PlusFormula.and ψ θ))
            (PlusFormula.untl (PlusFormula.and φ χ) (PlusFormula.and ψ χ)))
          (PlusFormula.untl (PlusFormula.and φ χ) (PlusFormula.and φ θ))))
  /-- BX7': linearity of Since -/
  | linear_since (φ ψ χ θ : PlusFormula) :
      PlusAxiom (PlusFormula.and (PlusFormula.snce φ ψ) (PlusFormula.snce χ θ)
        |>.imp (PlusFormula.or
          (PlusFormula.or
            (PlusFormula.snce (PlusFormula.and φ χ) (PlusFormula.and ψ θ))
            (PlusFormula.snce (PlusFormula.and φ χ) (PlusFormula.and ψ χ)))
          (PlusFormula.snce (PlusFormula.and φ χ) (PlusFormula.and φ θ))))
  /-- BX10: `U(ψ, φ) → F(ψ)` -/
  | until_F (φ ψ : PlusFormula) :
      PlusAxiom ((PlusFormula.untl φ ψ).imp (PlusFormula.someFuture ψ))
  /-- BX10': `S(ψ, φ) → P(ψ)` -/
  | since_P (φ ψ : PlusFormula) :
      PlusAxiom ((PlusFormula.snce φ ψ).imp (PlusFormula.somePast ψ))
  /-- BX11: `F(φ) ∧ F(ψ) → F(φ ∧ ψ) ∨ F(φ ∧ F(ψ)) ∨ F(F(φ) ∧ ψ)` -/
  | temp_linearity (φ ψ : PlusFormula) :
      PlusAxiom (PlusFormula.and (PlusFormula.someFuture φ) (PlusFormula.someFuture ψ) |>.imp
        (PlusFormula.or (PlusFormula.someFuture (PlusFormula.and φ ψ))
          (PlusFormula.or (PlusFormula.someFuture (PlusFormula.and φ (PlusFormula.someFuture ψ)))
            (PlusFormula.someFuture (PlusFormula.and (PlusFormula.someFuture φ) ψ)))))
  /-- BX11': `P(φ) ∧ P(ψ) → P(φ ∧ ψ) ∨ P(φ ∧ P(ψ)) ∨ P(P(φ) ∧ ψ)` -/
  | temp_linearity_past (φ ψ : PlusFormula) :
      PlusAxiom (PlusFormula.and (PlusFormula.somePast φ) (PlusFormula.somePast ψ) |>.imp
        (PlusFormula.or (PlusFormula.somePast (PlusFormula.and φ ψ))
          (PlusFormula.or (PlusFormula.somePast (PlusFormula.and φ (PlusFormula.somePast ψ)))
            (PlusFormula.somePast (PlusFormula.and (PlusFormula.somePast φ) ψ)))))
  /-- BX12: `F(φ) → U(φ, ⊤)` -/
  | F_until_equiv (φ : PlusFormula) :
      PlusAxiom ((PlusFormula.someFuture φ).imp
        (PlusFormula.untl (PlusFormula.bot.imp PlusFormula.bot) φ))
  /-- BX12': `P(φ) → S(φ, ⊤)` -/
  | P_since_equiv (φ : PlusFormula) :
      PlusAxiom ((PlusFormula.somePast φ).imp
        (PlusFormula.snce (PlusFormula.bot.imp PlusFormula.bot) φ))
  -- Layer 4: Modal-Temporal Interaction (1)
  /-- Modal-Future: `□φ → □(Gφ)` -/
  | modal_future (φ : PlusFormula) :
      PlusAxiom ((PlusFormula.box φ).imp (PlusFormula.box (PlusFormula.allFuture φ)))
  -- Layer 5: Uniformity (5)
  /-- `U(⊤,⊥) → S(⊤,⊥)` -/
  | discrete_symm_fwd :
      PlusAxiom ((PlusFormula.untl PlusFormula.bot (PlusFormula.bot.imp PlusFormula.bot)).imp
        (PlusFormula.snce PlusFormula.bot (PlusFormula.bot.imp PlusFormula.bot)))
  /-- `S(⊤,⊥) → U(⊤,⊥)` -/
  | discrete_symm_bwd :
      PlusAxiom ((PlusFormula.snce PlusFormula.bot (PlusFormula.bot.imp PlusFormula.bot)).imp
        (PlusFormula.untl PlusFormula.bot (PlusFormula.bot.imp PlusFormula.bot)))
  /-- `U(⊤,⊥) → G(U(⊤,⊥))` -/
  | discrete_propagate_fwd :
      PlusAxiom ((PlusFormula.untl PlusFormula.bot (PlusFormula.bot.imp PlusFormula.bot)).imp
        (PlusFormula.allFuture
          (PlusFormula.untl PlusFormula.bot (PlusFormula.bot.imp PlusFormula.bot))))
  /-- `U(⊤,⊥) → H(U(⊤,⊥))` -/
  | discrete_propagate_bwd :
      PlusAxiom ((PlusFormula.untl PlusFormula.bot (PlusFormula.bot.imp PlusFormula.bot)).imp
        (PlusFormula.allPast
          (PlusFormula.untl PlusFormula.bot (PlusFormula.bot.imp PlusFormula.bot))))
  /-- `U(⊤,⊥) → □(U(⊤,⊥))` -/
  | discrete_box_necessity :
      PlusAxiom ((PlusFormula.untl PlusFormula.bot (PlusFormula.bot.imp PlusFormula.bot)).imp
        (PlusFormula.box (PlusFormula.untl PlusFormula.bot (PlusFormula.bot.imp PlusFormula.bot))))
  -- Layer 6: Prior (2)
  /-- Prior-UZ: `F(φ) → U(φ, ¬φ)` -/
  | prior_UZ (φ : PlusFormula) :
      PlusAxiom (φ.someFuture.imp (PlusFormula.untl φ.neg φ))
  /-- Prior-SZ: `P(φ) → S(φ, ¬φ)` -/
  | prior_SZ (φ : PlusFormula) :
      PlusAxiom (φ.somePast.imp (PlusFormula.snce φ.neg φ))
  -- Layer 7: Z1 (1)
  /-- Z1: `G(Gφ→φ) → (FGφ→Gφ)` -/
  | z1 (φ : PlusFormula) :
      PlusAxiom ((φ.allFuture.imp φ).allFuture.imp (φ.allFuture.someFuture.imp φ.allFuture))
  -- Layer 8: Density (2)
  /-- Density: `GGφ → Gφ` -/
  | density (φ : PlusFormula) :
      PlusAxiom (φ.allFuture.allFuture.imp φ.allFuture)
  /-- Dense indicator: `¬U(⊤,⊥)` -/
  | dense_indicator :
      PlusAxiom (PlusFormula.untl PlusFormula.bot (PlusFormula.bot.imp PlusFormula.bot)).neg
  -- Layer 9: Reynolds Dedekind (3)
  /-- Prior-U (gap form): `U(⊤,φ) ∧ F(¬φ) → U(¬φ ∨ K⁺(¬φ), φ)` -/
  | prior_U_gap (φ : PlusFormula) :
      PlusAxiom ((PlusFormula.and (PlusFormula.untl φ PlusFormula.top) φ.neg.someFuture).imp
        (PlusFormula.untl φ (PlusFormula.or φ.neg (PlusFormula.kPlus φ.neg))))
  /-- Prior-S (gap form): `S(⊤,φ) ∧ P(¬φ) → S(¬φ ∨ K⁻(¬φ), φ)` -/
  | prior_S_gap (φ : PlusFormula) :
      PlusAxiom ((PlusFormula.and (PlusFormula.snce φ PlusFormula.top) φ.neg.somePast).imp
        (PlusFormula.snce φ (PlusFormula.or φ.neg (PlusFormula.kMinus φ.neg))))
  /-- Sep: `K⁺φ ∧ ¬K⁺(φ ∧ U(φ,¬φ)) → K⁺(K⁺φ ∧ K⁻φ)` -/
  | sep (φ : PlusFormula) :
      PlusAxiom ((PlusFormula.and (PlusFormula.kPlus φ)
        (PlusFormula.kPlus (PlusFormula.and φ (PlusFormula.untl φ.neg φ))).neg).imp
        (PlusFormula.kPlus (PlusFormula.and (PlusFormula.kPlus φ) (PlusFormula.kMinus φ))))
  -- The stability modal (8)
  /-- SK: `⊡(φ → ψ) → (⊡φ → ⊡ψ)` — K for `⊡`, from the universal-quantifier shape of the
  `stab` clause (`def:BLstar-semantics`). -/
  | stab_k (φ ψ : PlusFormula) :
      PlusAxiom ((PlusFormula.stab (φ.imp ψ)).imp ((PlusFormula.stab φ).imp (PlusFormula.stab ψ)))
  /-- ST: `⊡φ → φ` — T for `⊡` (paper footnote, line 1118); `Semantics.of_stab`. -/
  | stab_t (φ : PlusFormula) : PlusAxiom ((PlusFormula.stab φ).imp φ)
  /-- S4: `⊡φ → ⊡⊡φ` (paper footnote, line 1118); `Semantics.stab_four`. -/
  | stab_4 (φ : PlusFormula) :
      PlusAxiom ((PlusFormula.stab φ).imp (PlusFormula.stab (PlusFormula.stab φ)))
  /-- S5: `⟐φ → ⊡⟐φ`, stated as `¬⊡¬φ → ⊡¬⊡¬φ` through `dstab` (paper footnote, line 1118);
  `Semantics.stab_five` at `¬φ`. -/
  | stab_5 (φ : PlusFormula) :
      PlusAxiom ((dstab φ).imp (PlusFormula.stab (dstab φ)))
  /-- MS: `□φ → ⊡φ` — `⟨τ⟩_x ⊆ H_F` (paper line 1108); `Semantics.stab_of_box`. -/
  | box_stab (φ : PlusFormula) : PlusAxiom ((PlusFormula.box φ).imp (PlusFormula.stab φ))
  /-- AS: `p → ⊡p` for atoms (paper footnote, line 1119); `Semantics.stab_of_stateLocal` at
      `stateLocal_atom`. The axiom stays atom-restricted — widening it would change TM⁺ — but its
      semantic witness is the whole state-locality fragment. -/
  | atom_stab (p : Atom) :
      PlusAxiom ((PlusFormula.atom p).imp (PlusFormula.stab (PlusFormula.atom p)))
  /-- PS (same-time pasting): `⟐φ⁺ → (⟐ψ⁻ → ⟐(φ⁺ ∧ ψ⁻))` for pure-future `φ⁺` and pure-past
  `ψ⁻`; `Semantics.paste_valid`. -/
  | paste (φ ψ : PlusFormula) (hφ : IsPureFuture φ) (hψ : IsPurePast ψ) :
      PlusAxiom ((dstab φ).imp ((dstab ψ).imp (dstab (φ.and ψ))))
  /-- US (future pasting): `(α⁻ U ⟐φ⁺) → ⟐(α⁻ U φ⁺)` for pure-past `α⁻` and pure-future `φ⁺`;
  `Semantics.untl_dstab_valid`. -/
  | untl_paste (α φ : PlusFormula) (hα : IsPurePast α) (hφ : IsPureFuture φ) :
      PlusAxiom ((PlusFormula.untl α (dstab φ)).imp (dstab (PlusFormula.untl α φ)))

/--
Minimum frame class of each TM⁺ schema. The TM arms are `Axiom.minFrameClass`'s
(`ProofSystem/Axioms.lean`); every `⊡` schema is valid over every task frame and is routed to
`.Base`.
-/
def PlusAxiom.minFrameClass {φ : PlusFormula} : PlusAxiom φ → FrameClass
  | .density _ => .Dense
  | .dense_indicator => .Dense
  | .prior_UZ _ => .ZTime
  | .prior_SZ _ => .ZTime
  | .z1 _ => .ZTime
  | .prior_U_gap _ => .RTime
  | .prior_S_gap _ => .RTime
  | .sep _ => .RTime
  | _ => .Base

/-! ### Pins -/

example (φ : PlusFormula) : (PlusAxiom.stab_t φ).minFrameClass = .Base := rfl
example (φ : PlusFormula) : (PlusAxiom.density φ).minFrameClass = .Dense := rfl
example (φ ψ : PlusFormula) (hφ : IsPureFuture φ) (hψ : IsPurePast ψ) :
    (PlusAxiom.paste φ ψ hφ hψ).minFrameClass = .Base := rfl

end FormalSystem.PlusLanguage
