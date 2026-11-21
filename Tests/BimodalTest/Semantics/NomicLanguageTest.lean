/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.NomicLanguage
import FormalSystem.Semantics.Nomic

/-!
# Regression coverage for BL plus the nomic operator

The first test module to reference `FormalSystem/NomicLanguage/` at all. It covers the component
in four sections, following `OpenLanguageAxiomTest.lean`'s shape for a **semantic-only** language
component — one with no proof system, so neither `ValidityLayerTest.lean`'s generic-validity-layer
defeq pins nor `LanguageDerivationTest.lean`'s `DerivationTree` terms can host it.

1. **Syntax.** `NomicFormula`'s derived `DecidableEq` separates the constructors, the embedding
   `ofFormula` commutes with `Formula`'s constructors by `rfl`, and `ofFormula_injective` is
   applied rather than merely stated.
2. **Truth clauses.** The `Iff.rfl`-shaped clause lemmas `NomicTruth.nomic_iff`, `box_iff`,
   `always_iff` and `diamond_iff` are applied at an arbitrary `NomicFrame D`, pinning the shape of
   each right-hand side against a silent change to `NomicTruthAt`.
3. **A concrete frame.** A real `NomicModel` over `FormalSystem/Semantics/Nomic/Witnesses.lean`'s
   three-state ℤ-time witness `NomicHierarchy.F3`: truth evaluated at it both ways, seriality
   (`Semantics.nomic_serial`) instantiated there, and axiom 4's failure witnessed through
   `Semantics.four_validOn_iff_uniform` together with `NomicHierarchy.F3.not_uniform`. Also one
   negative on the tense-free fragment. `F3.IsRegular` does **not** synthesize — `F3` is a plain
   `def`, so the instance head is not syntactically `ofStepFamily …` — and is bound with `haveI`
   exactly as `FormalSystem/NomicLanguage/NomicFour.lean` does.
4. **Axiom profiles.** `#guard_msgs`-gated `#print axioms` blocks for seven headline declarations.
   They are **build-breaking**: if a profile moves, this module stops compiling. Every expected
   string was measured from this toolchain, not predicted. The pins are worth having precisely
   because the component's own docstrings make the claims in prose — "choice-free … measures at
   `[propext]`" for `nomic_iff_box_of_uniform`, "a theorem of ZFC, not of ZF" for `nomic_serial` —
   and nothing else in the tree checks them.

## When one of these guards fires

The expected block is updated in the same commit as the change that moved the profile, with the
move justified there — never re-baselined on its own to turn a red build green.

## References

* `FormalSystem/NomicLanguage/README.md` — the component's recorded exclusions
* `FormalSystem/NomicLanguage/NomicTruth.lean`, "Why the clause layer is duplicated rather than
  instantiated" — why `ValidityLayerTest.lean` cannot host this module
* `Tests/BimodalTest/Semantics/OpenLanguageAxiomTest.lean` — the semantic-only-component precedent
-/

namespace BimodalTest.Semantics.NomicLanguageTest

open FormalSystem.Syntax
open FormalSystem.NomicLanguage
open FormalSystem.Semantics

/-! ## Syntax: constructors, the embedding, and its injectivity -/

#guard (NomicFormula.bot == NomicFormula.bot)
#guard !(NomicFormula.bot == NomicFormula.top)
#guard !(NomicFormula.box NomicFormula.bot == NomicFormula.nomic NomicFormula.bot)

example (φ ψ : Formula) : ofFormula (.imp φ ψ) = .imp (ofFormula φ) (ofFormula ψ) := rfl

example (φ : Formula) : ofFormula (.box φ) = .box (ofFormula φ) := rfl

example (φ ψ : Formula) : ofFormula (.untl φ ψ) = .untl (ofFormula φ) (ofFormula ψ) := rfl

example (φ ψ : Formula) (h : ofFormula φ = ofFormula ψ) : φ = ψ := ofFormula_injective h

/-! ## Truth clauses at an arbitrary nomic frame -/

example {D : TemporalOrder} {F : NomicFrame D} (M : NomicModel F) (τ : ↑D → F.World) (x : ↑D)
    (φ : NomicFormula) :
    NomicTruthAt M τ x (.nomic φ) ↔ ∀ σ ∈ F.lawHist (τ x), NomicTruthAt M σ x φ :=
  NomicTruth.nomic_iff M τ x φ

example {D : TemporalOrder} {F : NomicFrame D} (M : NomicModel F) (τ : ↑D → F.World) (x : ↑D)
    (φ : NomicFormula) :
    NomicTruthAt M τ x (.box φ) ↔ ∀ σ ∈ F.HF, NomicTruthAt M σ x φ :=
  NomicTruth.box_iff M τ x φ

example {D : TemporalOrder} {F : NomicFrame D} (M : NomicModel F) (τ : ↑D → F.World) (x : ↑D)
    (φ : NomicFormula) :
    NomicTruthAt M τ x (NomicFormula.always φ) ↔ ∀ y : ↑D, NomicTruthAt M τ y φ :=
  NomicTruth.always_iff M τ x φ

example {D : TemporalOrder} {F : NomicFrame D} (M : NomicModel F) (τ : ↑D → F.World) (x : ↑D)
    (φ : NomicFormula) :
    NomicTruthAt M τ x (NomicFormula.diamond φ) ↔ ∃ σ ∈ F.HF, NomicTruthAt M σ x φ :=
  NomicTruth.diamond_iff M τ x φ

/-! ## A concrete model over the static-and-lawful ℤ-time witness -/

/-- The atom evaluated at `NomicHierarchy.F3`'s states below. -/
def pAtom : Atom := Atom.mkBase "p"

/-- A model on `NomicHierarchy.F3`: every atom holds exactly at the world state `W3.a`. -/
def modelThree : NomicModel NomicHierarchy.F3 where
  valuation := fun w _ => w = NomicHierarchy.W3.a

example : NomicTruthAt modelThree (fun _ => NomicHierarchy.W3.a) (0 : ℤ) (.atom pAtom) := rfl

example : ¬ NomicTruthAt modelThree (fun _ => NomicHierarchy.W3.b) (0 : ℤ) (.atom pAtom) := by
  intro h
  have h' : NomicHierarchy.W3.b = NomicHierarchy.W3.a := h
  exact NomicHierarchy.W3.noConfusion h'

example (φ : NomicFormula) :
    NomicTruthAt modelThree (fun _ => NomicHierarchy.W3.a) (0 : ℤ) (.nomic φ) ↔
      ∀ σ ∈ NomicHierarchy.F3.lawHist NomicHierarchy.W3.a,
        NomicTruthAt modelThree σ (0 : ℤ) φ :=
  NomicTruth.nomic_iff modelThree (fun _ => NomicHierarchy.W3.a) (0 : ℤ) φ

example (φ : NomicFormula) :
    NomicHierarchy.F3.NomicValidOn
      (.imp (.nomic φ) (.imp (.nomic (.imp φ .bot)) .bot)) := by
  haveI : NomicHierarchy.F3.IsRegular :=
    NomicFrame.ofStepFamily_isRegular NomicHierarchy.R3 NomicHierarchy.R3.fwd
      NomicHierarchy.R3.bwd
  exact nomic_serial NomicHierarchy.F3 φ

example : ¬ ∀ φ : NomicFormula,
    NomicHierarchy.F3.NomicValidOn (.imp (.nomic φ) (.nomic (.nomic φ))) := by
  haveI : NomicHierarchy.F3.IsRegular :=
    NomicFrame.ofStepFamily_isRegular NomicHierarchy.R3 NomicHierarchy.R3.fwd
      NomicHierarchy.R3.bwd
  intro hvalid
  exact NomicHierarchy.F3.not_uniform ((four_validOn_iff_uniform NomicHierarchy.F3).mp hvalid)

example : ¬ TenseFree (NomicFormula.someFuture (.atom pAtom)) := by
  intro h
  cases h

/-! ## Axiom profiles -/

/-- info: 'FormalSystem.NomicLanguage.ofFormula_injective' depends on axioms: [propext] -/
#guard_msgs in
#print axioms FormalSystem.NomicLanguage.ofFormula_injective

/-- info: 'FormalSystem.NomicLanguage.nomic_iff_box_of_uniform' depends on axioms: [propext] -/
#guard_msgs in
#print axioms FormalSystem.NomicLanguage.nomic_iff_box_of_uniform

/--
info: 'FormalSystem.Semantics.nomicValidOn_nomic_iff_box_of_uniform' depends on axioms: [propext]
-/
#guard_msgs in
#print axioms FormalSystem.Semantics.nomicValidOn_nomic_iff_box_of_uniform

/--
info: 'FormalSystem.Semantics.nomic_serial' depends on axioms: [propext, Classical.choice, Quot.sound]
-/
#guard_msgs in
#print axioms FormalSystem.Semantics.nomic_serial

/--
info: 'FormalSystem.Semantics.four_validOn_iff_uniform' depends on axioms: [propext, Classical.choice, Quot.sound]
-/
#guard_msgs in
#print axioms FormalSystem.Semantics.four_validOn_iff_uniform

/--
info: 'FormalSystem.Semantics.not_four_nomicValid' depends on axioms: [propext, Classical.choice, Quot.sound]
-/
#guard_msgs in
#print axioms FormalSystem.Semantics.not_four_nomicValid

/--
info: 'FormalSystem.NomicLanguage.tenseFree_satSet_iff' depends on axioms: [propext, Classical.choice, Quot.sound]
-/
#guard_msgs in
#print axioms FormalSystem.NomicLanguage.tenseFree_satSet_iff

end BimodalTest.Semantics.NomicLanguageTest
