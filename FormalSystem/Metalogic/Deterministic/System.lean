/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Syntax.PlusLanguage.Substitution

/-!
# TM⁺ + *Determined* — the extended proof system

TM⁺ (`PlusLanguage/Axioms.lean`) with one further axiom schema, *Determined*:

```
φ → ⊡φ      for every PlusFormula φ.
```

This is the system that is **sound** over every frame validating that schema
(`Metalogic/Deterministic/Soundness.lean`) and **complete** over the deterministic frames
(`Metalogic/Deterministic/Completeness.lean`).

## Why a separate inductive, and not a constructor on `PlusAxiom`

*Determined* is refuted at `.Base`: `Fp → ⊡Fp` fails on the permissive two-state frame
(`Semantics/PlusLanguage/PlusNonValidities.lean`, `refute_determined`). Adding a `determined` constructor to
`PlusAxiom` would therefore falsify TM⁺ soundness, which `PlusAxiom`'s own docstring records as
a standing prohibition. The extension is built here instead, and the live proof system is left
untouched — `PlusAxiom` has exactly the constructors it had before.

## Why it cannot live in the context either

The obvious lightweight alternative — carry the *Determined* instances in `Γ` and reason in
`PlusDerivable fc Γ` — does not work: `PlusDerivationTree`'s `necessitation`,
`temporal_necessitation` and `temporal_duality` are all restricted to the **empty** context
(theorems only, as in TM), so no rule application could ever pass under a nonempty `Γ`. An axiom
schema is the only shape that survives those three rules.

## Main Definitions

- `DetAxiom` — `PlusAxiom` re-wrapped through `ofPlus`, plus the `determined` arm;
  `DetAxiom.minFrameClass` extends `PlusAxiom.minFrameClass` with `determined ↦ .Base`
- `DetDerivationTree` — the same seven rules as `PlusDerivationTree`, over `DetAxiom`
- `DetDerivable` — `Nonempty (DetDerivationTree fc Γ φ)`

## Main Results

- `DetDerivationTree.ofPlus`, `detDerivable_of_plusDerivable` — TM⁺ derivations embed
- `DetDerivationTree.determinedAxiom`, `.stabNecessitation`, `.ofTM`, `.ofTMSubst` — the derived
  rules and the two transfers, inherited through the embedding
- `DetDerivable.mono` — monotonicity in the frame class

## References

* `FormalSystem/PlusLanguage/Derivation.lean` — the seven-rule system mirrored here
* `FormalSystem/Semantics/PlusLanguage/PlusNonValidities.lean` — `refute_determined`, the reason for the
  separate inductive

## Tags

proof-system · determinism · plus-language · app:deterministic
-/

namespace FormalSystem.Metalogic.Deterministic

open FormalSystem.Syntax
open FormalSystem.ProofSystem (FrameClass Axiom DerivationTree)
open FormalSystem.PlusLanguage

/-! ## The axiom set -/

/--
Axiom schemata of TM⁺ + *Determined*: every TM⁺ schema through `ofPlus`, plus the *Determined*
schema `φ → ⊡φ` at every `PlusFormula`.

Two constructors rather than a re-declaration of all 53: unlike the `Axiom`/`PlusAxiom` pair,
there is no language change here, so wrapping loses nothing — every TM⁺ schema is already stated
at arbitrary `PlusFormula` arguments.
-/
inductive DetAxiom : PlusFormula → Type where
  /-- Every TM⁺ axiom schema instance. -/
  | ofPlus {φ : PlusFormula} (h : PlusAxiom φ) : DetAxiom φ
  /-- *Determined*: `φ → ⊡φ`. Valid on every deterministic frame
  (`Semantics/PlusLanguage/PlusDeterminism.lean`, `determined_of_deterministic`) and refuted on some
  non-deterministic ones (`Semantics/PlusLanguage/PlusNonValidities.lean`, `refute_determined`) — which is
  why it is here and not in `PlusAxiom`. -/
  | determined (φ : PlusFormula) : DetAxiom (φ.imp (PlusFormula.stab φ))

/-- Minimum frame class of each schema: `PlusAxiom.minFrameClass` on the TM⁺ arm, and `.Base` for
*Determined*, which mentions no order-theoretic condition. -/
def DetAxiom.minFrameClass {φ : PlusFormula} : DetAxiom φ → FrameClass
  | .ofPlus h => h.minFrameClass
  | .determined _ => .Base

@[simp] theorem DetAxiom.minFrameClass_ofPlus {φ : PlusFormula} (h : PlusAxiom φ) :
    (DetAxiom.ofPlus h).minFrameClass = h.minFrameClass := rfl

@[simp] theorem DetAxiom.minFrameClass_determined (φ : PlusFormula) :
    (DetAxiom.determined φ).minFrameClass = FrameClass.Base := rfl

/-! ## The proof system -/

/--
Derivation tree for TM⁺ + *Determined*, a constructor-for-constructor mirror of
`PlusDerivationTree` over `DetAxiom`. `Type`-valued, so that `height` is computable and the
soundness companion recursion can match on it.
-/
inductive DetDerivationTree (fc : FrameClass) : PlusContext → PlusFormula → Type where
  /-- Axiom rule, gated by `h.minFrameClass ≤ fc`. -/
  | axiom (Γ : PlusContext) (φ : PlusFormula) (h : DetAxiom φ) (h_fc : h.minFrameClass ≤ fc)
      : DetDerivationTree fc Γ φ
  /-- Assumption rule. -/
  | assumption (Γ : PlusContext) (φ : PlusFormula) (h : φ ∈ Γ) : DetDerivationTree fc Γ φ
  /-- Modus ponens. -/
  | modus_ponens (Γ : PlusContext) (φ ψ : PlusFormula)
      (d1 : DetDerivationTree fc Γ (φ.imp ψ))
      (d2 : DetDerivationTree fc Γ φ) : DetDerivationTree fc Γ ψ
  /-- Necessitation: from `⊢ φ`, conclude `⊢ □φ`. Theorems only. -/
  | necessitation (φ : PlusFormula)
      (d : DetDerivationTree fc [] φ) : DetDerivationTree fc [] (PlusFormula.box φ)
  /-- Temporal necessitation: from `⊢ φ`, conclude `⊢ Gφ`. Theorems only. -/
  | temporal_necessitation (φ : PlusFormula)
      (d : DetDerivationTree fc [] φ) : DetDerivationTree fc [] (PlusFormula.allFuture φ)
  /-- Temporal duality: from `⊢ φ`, conclude `⊢ swapTemporal φ`. Theorems only. -/
  | temporal_duality (φ : PlusFormula)
      (d : DetDerivationTree fc [] φ) : DetDerivationTree fc [] φ.swapTemporal
  /-- Weakening. -/
  | weakening (Γ Δ : PlusContext) (φ : PlusFormula)
      (d : DetDerivationTree fc Γ φ)
      (h : Γ ⊆ Δ) : DetDerivationTree fc Δ φ

namespace DetDerivationTree

/-- Lift a derivation from `fc₁` to `fc₂` when `fc₁ ≤ fc₂`. -/
def lift {fc₁ fc₂ : FrameClass} (h_le : fc₁ ≤ fc₂)
    {Γ : PlusContext} {φ : PlusFormula} : DetDerivationTree fc₁ Γ φ → DetDerivationTree fc₂ Γ φ
  | .axiom Γ φ h h_fc => .axiom Γ φ h (le_trans h_fc h_le)
  | .assumption Γ φ h => .assumption Γ φ h
  | .modus_ponens Γ φ ψ d1 d2 => .modus_ponens Γ φ ψ (d1.lift h_le) (d2.lift h_le)
  | .necessitation φ d => .necessitation φ (d.lift h_le)
  | .temporal_necessitation φ d => .temporal_necessitation φ (d.lift h_le)
  | .temporal_duality φ d => .temporal_duality φ (d.lift h_le)
  | .weakening Γ Δ φ d h => .weakening Γ Δ φ (d.lift h_le) h

/-- Height of a derivation, mirroring `PlusDerivationTree.height`. -/
def height {fc : FrameClass} {Γ : PlusContext} {φ : PlusFormula} :
    DetDerivationTree fc Γ φ → Nat
  | .axiom _ _ _ _ => 0
  | .assumption _ _ _ => 0
  | .modus_ponens _ _ _ d1 d2 => 1 + max d1.height d2.height
  | .necessitation _ d => 1 + d.height
  | .temporal_necessitation _ d => 1 + d.height
  | .temporal_duality _ d => 1 + d.height
  | .weakening _ _ _ d _ => 1 + d.height

/-- Re-target a derivation whose context is a subset of the empty context. -/
def ofWeakeningNil {fc : FrameClass} {Γ' : PlusContext} {φ : PlusFormula}
    (d : DetDerivationTree fc Γ' φ) (h_sub : Γ' ⊆ ([] : PlusContext)) :
    DetDerivationTree fc [] φ :=
  (List.eq_nil_of_subset_nil h_sub) ▸ d

/-- `ofWeakeningNil` preserves height exactly. -/
@[simp] theorem height_ofWeakeningNil {fc : FrameClass} {Γ' : PlusContext} {φ : PlusFormula}
    (d : DetDerivationTree fc Γ' φ) (h_sub : Γ' ⊆ ([] : PlusContext)) :
    (d.ofWeakeningNil h_sub).height = d.height := by
  have h_eq : Γ' = [] := List.eq_nil_of_subset_nil h_sub
  subst h_eq
  rfl

/-- Transporting to the empty context is strictly cheaper than the `weakening` node. -/
theorem height_ofWeakeningNil_lt {fc : FrameClass} {Γ' : PlusContext} {φ : PlusFormula}
    (d : DetDerivationTree fc Γ' φ) (h_sub : Γ' ⊆ ([] : PlusContext)) :
    (d.ofWeakeningNil h_sub).height <
      (DetDerivationTree.weakening Γ' ([] : PlusContext) φ d h_sub).height := by
  simp only [DetDerivationTree.height_ofWeakeningNil, DetDerivationTree.height]
  omega

/-- Modus ponens height is strictly greater than the left subderivation. -/
theorem mp_height_gt_left {fc : FrameClass} {Γ : PlusContext} {φ ψ : PlusFormula}
    (d1 : DetDerivationTree fc Γ (φ.imp ψ)) (d2 : DetDerivationTree fc Γ φ) :
    d1.height < (modus_ponens Γ φ ψ d1 d2).height := by
  simp [height]
  omega

/-- Modus ponens height is strictly greater than the right subderivation. -/
theorem mp_height_gt_right {fc : FrameClass} {Γ : PlusContext} {φ ψ : PlusFormula}
    (d1 : DetDerivationTree fc Γ (φ.imp ψ)) (d2 : DetDerivationTree fc Γ φ) :
    d2.height < (modus_ponens Γ φ ψ d1 d2).height := by
  simp [height]
  omega

/-- **TM⁺ derivations embed**, rule for rule; the `axiom` case wraps through `DetAxiom.ofPlus`,
which preserves `minFrameClass` definitionally. -/
def ofPlus {fc : FrameClass} : {Γ : PlusContext} → {φ : PlusFormula} →
    PlusDerivationTree fc Γ φ → DetDerivationTree fc Γ φ
  | _, _, .axiom Γ φ h h_fc => .axiom Γ φ (DetAxiom.ofPlus h) h_fc
  | _, _, .assumption Γ φ h => .assumption Γ φ h
  | _, _, .modus_ponens Γ φ ψ d1 d2 => .modus_ponens Γ φ ψ (ofPlus d1) (ofPlus d2)
  | _, _, .necessitation φ d => .necessitation φ (ofPlus d)
  | _, _, .temporal_necessitation φ d => .temporal_necessitation φ (ofPlus d)
  | _, _, .temporal_duality φ d => .temporal_duality φ (ofPlus d)
  | _, _, .weakening Γ Δ φ d h => .weakening Γ Δ φ (ofPlus d) h

/-- The *Determined* schema as a one-line derivation at every frame class. -/
def determinedAxiom {fc : FrameClass} (Γ : PlusContext) (φ : PlusFormula) :
    DetDerivationTree fc Γ (φ.imp (PlusFormula.stab φ)) :=
  .axiom Γ _ (DetAxiom.determined φ) (FrameClass.base_le fc)

/-- **`⊡`-necessitation is derived** in the extended system too, by the same route as in TM⁺:
`necessitation` to `⊢ □φ`, then `box_stab`. -/
def stabNecessitation {fc : FrameClass} {φ : PlusFormula}
    (d : DetDerivationTree fc [] φ) : DetDerivationTree fc [] (PlusFormula.stab φ) :=
  .modus_ponens [] _ _
    (.axiom [] _ (DetAxiom.ofPlus (PlusAxiom.box_stab φ)) (FrameClass.base_le fc))
    (.necessitation φ d)

/-- A TM axiom instance is available at the embedded parameters. `PlusAxiom.ofTM` composed with
the embedding. -/
def ofTM {fc : FrameClass} {Γ : Context} {φ : Formula} (d : DerivationTree fc Γ φ) :
    DetDerivationTree fc (ofCtx Γ) (ofFormula φ) :=
  ofPlus (PlusDerivationTree.ofTM d)

/-- **The substitution transfer, in the extended system**: every TM theorem schema is available
at arbitrary L⁺ arguments. `PlusDerivationTree.ofTMSubst` composed with the embedding; this is
what supplies the propositional reasoning the collapse derivation needs
(`Metalogic/Deterministic/Collapse.lean`). -/
def ofTMSubst {fc : FrameClass} (σ : Atom → PlusFormula) {Γ : Context} {φ : Formula}
    (d : DerivationTree fc Γ φ) :
    DetDerivationTree fc (substCtxPlus σ Γ) (substPlus σ φ) :=
  ofPlus (PlusDerivationTree.ofTMSubst σ d)

end DetDerivationTree

/-- Prop-valued derivability in TM⁺ + *Determined*. -/
def DetDerivable (fc : FrameClass) (Γ : PlusContext) (φ : PlusFormula) : Prop :=
  Nonempty (DetDerivationTree fc Γ φ)

/-- `DetDerivable` is monotone in the frame class. -/
theorem DetDerivable.mono {fc₁ fc₂ : FrameClass} (h : fc₁ ≤ fc₂) {Γ : PlusContext}
    {φ : PlusFormula} (hd : DetDerivable fc₁ Γ φ) : DetDerivable fc₂ Γ φ :=
  hd.elim fun d => ⟨d.lift h⟩

/-- **TM⁺ derivability implies extended derivability**, at every frame class and context. -/
theorem detDerivable_of_plusDerivable {fc : FrameClass} {Γ : PlusContext} {φ : PlusFormula}
    (h : PlusDerivable fc Γ φ) : DetDerivable fc Γ φ :=
  h.elim fun d => ⟨DetDerivationTree.ofPlus d⟩

/-- **TM derivability implies extended derivability** of the embedded formula. -/
theorem detDerivable_of_derivable {fc : FrameClass} {Γ : Context} {φ : Formula}
    (h : ProofSystem.Derivable fc Γ φ) : DetDerivable fc (ofCtx Γ) (ofFormula φ) :=
  detDerivable_of_plusDerivable (plusDerivable_of_derivable h)

/-- **The substitution transfer at the `Prop` level**: a TM theorem yields an extended-system
theorem at arbitrary L⁺ arguments. -/
theorem detDerivable_substPlus {fc : FrameClass} {φ : Formula} (σ : Atom → PlusFormula)
    (h : ProofSystem.Derivable fc [] φ) : DetDerivable fc [] (substPlus σ φ) :=
  detDerivable_of_plusDerivable (plusDerivable_substPlus_nil σ h)

/-- *Determined* is an extended-system theorem at every instance and every frame class. -/
theorem detDerivable_determined {fc : FrameClass} (φ : PlusFormula) :
    DetDerivable fc [] (φ.imp (PlusFormula.stab φ)) :=
  ⟨DetDerivationTree.determinedAxiom [] φ⟩

/-! ### Pins

The live TM⁺ axiom set is unchanged by this module: `DetAxiom` wraps `PlusAxiom`, it does not
extend it. Checkable by `grep -c '  | ' FormalSystem/PlusLanguage/Axioms.lean`, and pinned here
by the fact that the `ofPlus` arm typechecks at an arbitrary `PlusAxiom` instance. -/

example (φ : PlusFormula) : DetAxiom (φ.imp (PlusFormula.stab φ)) := .determined φ

example (φ ψ : PlusFormula) : DetAxiom ((PlusFormula.stab (φ.imp ψ)).imp
    ((PlusFormula.stab φ).imp (PlusFormula.stab ψ))) :=
  .ofPlus (PlusAxiom.stab_k φ ψ)

end FormalSystem.Metalogic.Deterministic
