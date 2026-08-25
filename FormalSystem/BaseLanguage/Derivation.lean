/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.BaseLanguage.Axioms

/-!
# `BaseLanguage.DerivationTree` — TM's proof system over BL

A constructor-for-constructor mirror of `FormalSystem.ProofSystem.DerivationTree`, over
`BLFormula` instead of `Formula`. The mirror is deliberate: it is what makes
`FormalSystem.Metalogic.Conservativity.translate` a seven-case structural recursion with one
case per rule and no bookkeeping.

## Inference rules (7, matching the BL⁺ side exactly)

1. `axiom` — an `Axiom` instance, gated by `ax.minFrameClass ≤ fc`
2. `assumption` — formulas in the context
3. `modus_ponens` — **MP**
4. `necessitation` — **MN**, empty context only
5. `temporal_necessitation` — `⊢ φ ⟹ ⊢ Gφ`, empty context only
6. `temporal_duality` — **TD**, empty context only, via **`swapBL`**
7. `weakening`

**TD uses `swapBL`, not `swapTemporal`.** `swapTemporal` acts on BL⁺'s `untl`/`snce`; the BL
side has no such constructors. The two are intertwined by `BaseLanguage.tr_swapBL`.

## Fidelity note: `temporal_necessitation` is not a strengthening

TM as axiomatized in the paper (`\S sub:Logic`) has **no primitive temporal necessitation
rule** — its rules are exactly MP, MN and TD. Including `temporal_necessitation` here therefore
looks like an addition, but it changes no theorem of TM: `⊢ φ ⟹ ⊢ Gφ` is already *derivable*
in TM from MN + MF + MT, by necessitating `φ` to `□φ`, applying **MF** (`□φ → □Gφ`) and then
**MT** (`□Gφ → Gφ`). The rule is carried as a primitive purely to keep the seven-rule mirror,
and `FormalSystem.BaseLanguage.temporalNecessitationDerivable` below proves the claim rather
than asserting it.

## Frame-class parameterization

Exactly as on the BL⁺ side: `axiom` carries `ax.minFrameClass ≤ fc`, and `lift` moves a
derivation up the `FrameClass` order. TM, TM_f, TM_d and TM_dc are `fc := .Base`, `.Discrete`,
`.Dense`, `.Dedekind`.

## Notation

`Γ ⊢ᴮᴸ[fc] φ` and `⊢ᴮᴸ[fc] φ`, deliberately distinct from BL⁺'s `Γ ⊢[fc] φ` / `⊢[fc] φ` so
that a file opening both namespaces cannot silently mean the wrong system. There is no
`.Base`-defaulting form: on this side the frame class is always worth writing out.

## References

* JPL paper `\S sub:Logic` — TM's rules MP, MN, TD
* `FormalSystem/ProofSystem/Derivation.lean` — the BL⁺ counterpart being mirrored
-/

namespace FormalSystem.BaseLanguage

open FormalSystem.ProofSystem (FrameClass)

/--
Derivation tree for TM over the base language BL, parameterized by frame class.

`Type`-valued, like its BL⁺ counterpart, so that `Conservativity.translate` can pattern-match
on it while producing a `DerivationTree`.
-/
inductive DerivationTree (fc : FrameClass) : Context → BLFormula → Type where
  /-- Axiom rule, gated by `h.minFrameClass ≤ fc`. -/
  | axiom (Γ : Context) (φ : BLFormula) (h : Axiom φ) (h_fc : h.minFrameClass ≤ fc)
      : DerivationTree fc Γ φ
  /-- Assumption rule: formulas in the context are derivable. -/
  | assumption (Γ : Context) (φ : BLFormula) (h : φ ∈ Γ) : DerivationTree fc Γ φ
  /-- **MP**: from `Γ ⊢ φ → ψ` and `Γ ⊢ φ`, conclude `Γ ⊢ ψ`. -/
  | modus_ponens (Γ : Context) (φ ψ : BLFormula)
      (d1 : DerivationTree fc Γ (φ.imp ψ))
      (d2 : DerivationTree fc Γ φ) : DerivationTree fc Γ ψ
  /-- **MN**: from `⊢ φ`, conclude `⊢ □φ`. Theorems only (empty context). -/
  | necessitation (φ : BLFormula)
      (d : DerivationTree fc [] φ) : DerivationTree fc [] φ.box
  /-- From `⊢ φ`, conclude `⊢ Gφ`. Theorems only. Derivable in TM from MN + MF + MT — see the
      fidelity note in the module docstring and `temporalNecessitationDerivable`. -/
  | temporal_necessitation (φ : BLFormula)
      (d : DerivationTree fc [] φ) : DerivationTree fc [] φ.allFuture
  /-- **TD**: from `⊢ φ`, conclude `⊢ φ⟨P|F⟩`, i.e. `⊢ swapBL φ`. Theorems only. -/
  | temporal_duality (φ : BLFormula)
      (d : DerivationTree fc [] φ) : DerivationTree fc [] φ.swapBL
  /-- Weakening: from `Γ ⊢ φ` and `Γ ⊆ Δ`, conclude `Δ ⊢ φ`. -/
  | weakening (Γ Δ : Context) (φ : BLFormula)
      (d : DerivationTree fc Γ φ)
      (h : Γ ⊆ Δ) : DerivationTree fc Δ φ
  deriving Repr

namespace DerivationTree

/--
Lift a derivation from `fc₁` to `fc₂` when `fc₁ ≤ fc₂`.

Mirrors `ProofSystem.DerivationTree.lift`: the only interesting case is `axiom`, where
transitivity composes the two `≤` proofs. Used by the row corollaries in
`Metalogic/Conservativity.lean` to move a TM theorem into `TM_f` / `TM_d` / `TM_dc`.
-/
def lift {fc₁ fc₂ : FrameClass} (h_le : fc₁ ≤ fc₂)
    {Γ : Context} {φ : BLFormula} : DerivationTree fc₁ Γ φ → DerivationTree fc₂ Γ φ
  | .axiom Γ φ h h_fc => .axiom Γ φ h (le_trans h_fc h_le)
  | .assumption Γ φ h => .assumption Γ φ h
  | .modus_ponens Γ φ ψ d1 d2 => .modus_ponens Γ φ ψ (d1.lift h_le) (d2.lift h_le)
  | .necessitation φ d => .necessitation φ (d.lift h_le)
  | .temporal_necessitation φ d => .temporal_necessitation φ (d.lift h_le)
  | .temporal_duality φ d => .temporal_duality φ (d.lift h_le)
  | .weakening Γ Δ φ d h => .weakening Γ Δ φ (d.lift h_le) h

/-- Height of a derivation, mirroring `ProofSystem.DerivationTree.height`. -/
def height {fc : FrameClass} {Γ : Context} {φ : BLFormula} : DerivationTree fc Γ φ → Nat
  | .axiom _ _ _ _ => 0
  | .assumption _ _ _ => 0
  | .modus_ponens _ _ _ d1 d2 => 1 + max d1.height d2.height
  | .necessitation _ d => 1 + d.height
  | .temporal_necessitation _ d => 1 + d.height
  | .temporal_duality _ d => 1 + d.height
  | .weakening _ _ _ d _ => 1 + d.height

end DerivationTree

/-- Prop-valued derivability, mirroring `ProofSystem.Derivable`. -/
def Derivable (fc : FrameClass) (Γ : Context) (φ : BLFormula) : Prop :=
  Nonempty (DerivationTree fc Γ φ)

/-! ## Notation

`Γ ⊢ᴮᴸ[fc] φ` / `⊢ᴮᴸ[fc] φ`. The `ᴮᴸ` marker keeps these from colliding with BL⁺'s `⊢[fc]`
even in a file that has opened both `FormalSystem.ProofSystem` and
`FormalSystem.BaseLanguage`. -/

/-- Derivability in TM from context `Γ` at frame class `fc`. -/
notation:50 Γ " ⊢ᴮᴸ[" fc "] " φ => DerivationTree fc Γ φ

/-- Theoremhood in TM at frame class `fc`. -/
notation:50 "⊢ᴮᴸ[" fc "] " φ => DerivationTree fc [] φ

/-! ## The fidelity note, discharged

TM's rule set is MP, MN, TD. `temporal_necessitation` is carried as an eighth-slot primitive
only to mirror BL⁺'s seven-rule shape; the derivation below shows it adds nothing. -/

/--
`⊢ᴮᴸ[fc] φ ⟹ ⊢ᴮᴸ[fc] Gφ` **without** using `temporal_necessitation`.

Route: **MN** gives `⊢ □φ`; **MF** (`□φ → □Gφ`) gives `⊢ □Gφ`; **MT** (`□Gφ → Gφ`) gives
`⊢ Gφ`. All three are TM primitives, so including `temporal_necessitation` as a constructor
changes no theorem of TM.
-/
def temporalNecessitationDerivable {fc : FrameClass} (φ : BLFormula)
    (d : ⊢ᴮᴸ[fc] φ) : ⊢ᴮᴸ[fc] φ.allFuture :=
  let boxφ : ⊢ᴮᴸ[fc] φ.box := .necessitation φ d
  let mf : ⊢ᴮᴸ[fc] φ.box.imp φ.allFuture.box :=
    .axiom [] _ (Axiom.modal_future φ) (FrameClass.base_le fc)
  let boxGφ : ⊢ᴮᴸ[fc] φ.allFuture.box := .modus_ponens [] _ _ mf boxφ
  let mt : ⊢ᴮᴸ[fc] φ.allFuture.box.imp φ.allFuture :=
    .axiom [] _ (Axiom.modal_t φ.allFuture)
      (FrameClass.base_le fc)
  .modus_ponens [] _ _ mt boxGφ

/-! ## Smoke tests -/

/-- Identity is a TM theorem, by the propositional basis alone. -/
example (φ : BLFormula) : ⊢ᴮᴸ[FrameClass.Base] φ.imp φ :=
  let k : ⊢ᴮᴸ[FrameClass.Base]
      ((φ.imp ((φ.imp φ).imp φ)).imp ((φ.imp (φ.imp φ)).imp (φ.imp φ))) :=
    .axiom [] _ (Axiom.prop_k φ (φ.imp φ) φ) (FrameClass.base_le _)
  let s1 : ⊢ᴮᴸ[FrameClass.Base] (φ.imp ((φ.imp φ).imp φ)) :=
    .axiom [] _ (Axiom.prop_s φ (φ.imp φ)) (FrameClass.base_le _)
  let s2 : ⊢ᴮᴸ[FrameClass.Base] (φ.imp (φ.imp φ)) :=
    .axiom [] _ (Axiom.prop_s φ φ) (FrameClass.base_le _)
  .modus_ponens [] _ _ (.modus_ponens [] _ _ k s1) s2

/-- `DF` is available at `.Discrete` and its `minFrameClass` side condition discharges by
`decide` once the frame class is concrete. -/
example (φ : BLFormula) :
    ⊢ᴮᴸ[FrameClass.Discrete]
      (((φ.allPast.and φ).and BLFormula.top.someFuture).imp φ.allPast.someFuture) :=
  .axiom [] _ (Axiom.df φ) (show FrameClass.Discrete ≤ FrameClass.Discrete by decide)

/-- Lifting a `Base` theorem into `TM_f`. -/
example (φ : BLFormula) : ⊢ᴮᴸ[FrameClass.Discrete] φ.box.imp φ :=
  DerivationTree.lift (fc₁ := FrameClass.Base) (by decide)
    (.axiom [] _ (Axiom.modal_t φ) (FrameClass.base_le _))

end FormalSystem.BaseLanguage
