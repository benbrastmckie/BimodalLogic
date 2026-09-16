/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Syntax.MinusLanguage.Axioms

/-!
# `MinusLanguage.DerivationTree` — TM⁻'s proof system over L⁻

A constructor-for-constructor mirror of `FormalSystem.ProofSystem.DerivationTree`, over
`MinusFormula` instead of `Formula`. The mirror is deliberate: it is what makes
`FormalSystem.Metalogic.Conservativity.translate` a seven-case structural recursion with one
case per rule and no bookkeeping.

## Inference rules (7, matching the L side exactly)

1. `axiom` — an `Axiom` instance, gated by `ax.minFrameClass ≤ fc`
2. `assumption` — formulas in the context
3. `modus_ponens` — **MP**
4. `necessitation` — **MN**, empty context only
5. `temporal_necessitation` — `⊢ φ ⟹ ⊢ Gφ`, empty context only
6. `temporal_duality` — **TD**, empty context only, via **`swapMinus`**
7. `weakening`

**TD uses `swapMinus`, not `swapTemporal`.** `swapTemporal` acts on L's `untl`/`snce`; the L⁻
side has no such constructors. The two are intertwined by `MinusLanguage.tr_swapMinus`.

## Fidelity note: `temporal_necessitation` is not a strengthening

TM⁻ as axiomatized in the paper (`\S sub:Logic`) has **no primitive temporal necessitation
rule** — its rules are exactly MP, MN and TD. Including `temporal_necessitation` here therefore
looks like an addition, but it changes no theorem of TM⁻: `⊢ φ ⟹ ⊢ Gφ` is already *derivable*
in TM⁻ from MN + MF + MT, by necessitating `φ` to `□φ`, applying **MF** (`□φ → □Gφ`) and then
**MT** (`□Gφ → Gφ`). The rule is carried as a primitive purely to keep the seven-rule mirror,
and `FormalSystem.MinusLanguage.temporalNecessitationDerivable` below proves the claim rather
than asserting it.

## Frame-class parameterization

Exactly as on the L side: `axiom` carries `ax.minFrameClass ≤ fc`, and `lift` moves a
derivation up the `FrameClass` order. TM⁻, TM⁻_z, TM⁻_d and TM⁻_r are `fc := .Base`, `.ZTime`,
`.Dense`, `.RTime`.

## Notation

`Γ ⊢⁻[fc] φ` and `⊢⁻[fc] φ`, deliberately distinct from L's `Γ ⊢[fc] φ` / `⊢[fc] φ` so
that a file opening both namespaces cannot silently mean the wrong system. There is no
`.Base`-defaulting form: on this side the frame class is always worth writing out.

## References

* JPL paper `\S sub:Logic` — the rules MP, MN, TD that TM⁻ inherits
* `FormalSystem/ProofSystem/Derivation.lean` — the L counterpart being mirrored
-/

namespace FormalSystem.MinusLanguage

open FormalSystem.ProofSystem (FrameClass)

/--
Derivation tree for TM⁻ over the base language L⁻, parameterized by frame class.

`Type`-valued, like its L counterpart, so that `Conservativity.translate` can pattern-match
on it while producing a `DerivationTree`.
-/
inductive DerivationTree (fc : FrameClass) : Context → MinusFormula → Type where
  /-- Axiom rule, gated by `h.minFrameClass ≤ fc`. -/
  | axiom (Γ : Context) (φ : MinusFormula) (h : Axiom φ) (h_fc : h.minFrameClass ≤ fc)
      : DerivationTree fc Γ φ
  /-- Assumption rule: formulas in the context are derivable. -/
  | assumption (Γ : Context) (φ : MinusFormula) (h : φ ∈ Γ) : DerivationTree fc Γ φ
  /-- **MP**: from `Γ ⊢ φ → ψ` and `Γ ⊢ φ`, conclude `Γ ⊢ ψ`. -/
  | modus_ponens (Γ : Context) (φ ψ : MinusFormula)
      (d1 : DerivationTree fc Γ (φ.imp ψ))
      (d2 : DerivationTree fc Γ φ) : DerivationTree fc Γ ψ
  /-- **MN**: from `⊢ φ`, conclude `⊢ □φ`. Theorems only (empty context). -/
  | necessitation (φ : MinusFormula)
      (d : DerivationTree fc [] φ) : DerivationTree fc [] φ.box
  /-- From `⊢ φ`, conclude `⊢ Gφ`. Theorems only. Derivable in TM⁻ from MN + MF + MT — see the
      fidelity note in the module docstring and `temporalNecessitationDerivable`. -/
  | temporal_necessitation (φ : MinusFormula)
      (d : DerivationTree fc [] φ) : DerivationTree fc [] φ.allFuture
  /-- **TD**: from `⊢ φ`, conclude `⊢ φ⟨P|F⟩`, i.e. `⊢ swapMinus φ`. Theorems only. -/
  | temporal_duality (φ : MinusFormula)
      (d : DerivationTree fc [] φ) : DerivationTree fc [] φ.swapMinus
  /-- Weakening: from `Γ ⊢ φ` and `Γ ⊆ Δ`, conclude `Δ ⊢ φ`. -/
  | weakening (Γ Δ : Context) (φ : MinusFormula)
      (d : DerivationTree fc Γ φ)
      (h : Γ ⊆ Δ) : DerivationTree fc Δ φ
  deriving Repr

namespace DerivationTree

/--
Lift a derivation from `fc₁` to `fc₂` when `fc₁ ≤ fc₂`.

Mirrors `ProofSystem.DerivationTree.lift`: the only interesting case is `axiom`, where
transitivity composes the two `≤` proofs. Used by the row corollaries in
`Metalogic/Conservativity/Backward.lean` to move a TM⁻ theorem into `TM⁻_z` / `TM⁻_d` / `TM⁻_r`.
-/
def lift {fc₁ fc₂ : FrameClass} (h_le : fc₁ ≤ fc₂)
    {Γ : Context} {φ : MinusFormula} : DerivationTree fc₁ Γ φ → DerivationTree fc₂ Γ φ
  | .axiom Γ φ h h_fc => .axiom Γ φ h (le_trans h_fc h_le)
  | .assumption Γ φ h => .assumption Γ φ h
  | .modus_ponens Γ φ ψ d1 d2 => .modus_ponens Γ φ ψ (d1.lift h_le) (d2.lift h_le)
  | .necessitation φ d => .necessitation φ (d.lift h_le)
  | .temporal_necessitation φ d => .temporal_necessitation φ (d.lift h_le)
  | .temporal_duality φ d => .temporal_duality φ (d.lift h_le)
  | .weakening Γ Δ φ d h => .weakening Γ Δ φ (d.lift h_le) h

/-- Height of a derivation, mirroring `ProofSystem.DerivationTree.height`. -/
def height {fc : FrameClass} {Γ : Context} {φ : MinusFormula} : DerivationTree fc Γ φ → Nat
  | .axiom _ _ _ _ => 0
  | .assumption _ _ _ => 0
  | .modus_ponens _ _ _ d1 d2 => 1 + max d1.height d2.height
  | .necessitation _ d => 1 + d.height
  | .temporal_necessitation _ d => 1 + d.height
  | .temporal_duality _ d => 1 + d.height
  | .weakening _ _ _ d _ => 1 + d.height

/--
Re-target a derivation whose context is a subset of the empty context.

Mirror of `ProofSystem.DerivationTree.ofWeakeningNil`. `MinusLanguage.DerivationTree`
is a distinct inductive type, so the twin is required rather than optional.
-/
def ofWeakeningNil {fc : FrameClass} {Γ' : Context} {φ : MinusFormula}
    (d : DerivationTree fc Γ' φ) (h_sub : Γ' ⊆ ([] : Context)) : DerivationTree fc [] φ :=
  (List.eq_nil_of_subset_nil h_sub) ▸ d

/-- `ofWeakeningNil` preserves height exactly. -/
@[simp] theorem height_ofWeakeningNil {fc : FrameClass} {Γ' : Context} {φ : MinusFormula}
    (d : DerivationTree fc Γ' φ) (h_sub : Γ' ⊆ ([] : Context)) :
    (d.ofWeakeningNil h_sub).height = d.height := by
  have h_eq : Γ' = [] := List.eq_nil_of_subset_nil h_sub
  subst h_eq
  rfl

/-- Transporting to the empty context is strictly cheaper than the `weakening` node. -/
theorem height_ofWeakeningNil_lt {fc : FrameClass} {Γ' : Context} {φ : MinusFormula}
    (d : DerivationTree fc Γ' φ) (h_sub : Γ' ⊆ ([] : Context)) :
    (d.ofWeakeningNil h_sub).height <
      (DerivationTree.weakening Γ' ([] : Context) φ d h_sub).height := by
  simp only [DerivationTree.height_ofWeakeningNil, DerivationTree.height]
  omega

end DerivationTree

/-- Prop-valued derivability, mirroring `ProofSystem.Derivable`. -/
def Derivable (fc : FrameClass) (Γ : Context) (φ : MinusFormula) : Prop :=
  Nonempty (DerivationTree fc Γ φ)

/-! ## Notation

`Γ ⊢⁻[fc] φ` / `⊢⁻[fc] φ`. The `⁻` marker keeps these from colliding with L's `⊢[fc]`
even in a file that has opened both `FormalSystem.ProofSystem` and
`FormalSystem.MinusLanguage`. -/

/-- Derivability in TM⁻ from context `Γ` at frame class `fc`. -/
notation:50 Γ " ⊢⁻[" fc "] " φ => DerivationTree fc Γ φ

/-- Theoremhood in TM⁻ at frame class `fc`. -/
notation:50 "⊢⁻[" fc "] " φ => DerivationTree fc [] φ

/-! ## The fidelity note, discharged

TM⁻'s rule set is MP, MN, TD. `temporal_necessitation` is carried as an eighth-slot primitive
only to mirror L's seven-rule shape; the derivation below shows it adds nothing. -/

/--
`⊢⁻[fc] φ ⟹ ⊢⁻[fc] Gφ` **without** using `temporal_necessitation`.

Route: **MN** gives `⊢ □φ`; **MF** (`□φ → □Gφ`) gives `⊢ □Gφ`; **MT** (`□Gφ → Gφ`) gives
`⊢ Gφ`. All three are TM⁻ primitives, so including `temporal_necessitation` as a constructor
changes no theorem of TM⁻.
-/
def temporalNecessitationDerivable {fc : FrameClass} (φ : MinusFormula)
    (d : ⊢⁻[fc] φ) : ⊢⁻[fc] φ.allFuture :=
  let boxφ : ⊢⁻[fc] φ.box := .necessitation φ d
  let mf : ⊢⁻[fc] φ.box.imp φ.allFuture.box :=
    .axiom [] _ (Axiom.modal_future φ) (FrameClass.base_le fc)
  let boxGφ : ⊢⁻[fc] φ.allFuture.box := .modus_ponens [] _ _ mf boxφ
  let mt : ⊢⁻[fc] φ.allFuture.box.imp φ.allFuture :=
    .axiom [] _ (Axiom.modal_t φ.allFuture)
      (FrameClass.base_le fc)
  .modus_ponens [] _ _ mt boxGφ

/-! Worked derivations in this system live in
`Tests/BimodalTest/Syntax/LanguageDerivationTest.lean`. -/

end FormalSystem.MinusLanguage
